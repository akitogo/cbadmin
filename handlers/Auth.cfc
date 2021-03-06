component extends="coldbox.system.RestHandler"
{
    property name="securityService"     inject="securityService@cbadmin";
    property name="roleService"         inject="roleService@cbadmin";
    property name="userService"         inject="userService@cbadmin";
    property name="languageService"     inject="CfgLanguageService@cbadmin";
    property name="cbadminSettings"     inject="coldbox:modulesettings:cbadmin";

    property name="antiSamy"            inject="antisamy@cbantisamy";
    property name="resourceService"     inject="resourceService@cbi18n";

    function preHandler( event, rc, prc )
    {
        //getPageContext().getResponse().setHeader( "Access-Control-Allow-Origin", "*" );
    }

    function test()
    {
        dump('test');
        abort;
    }

    /**
     * @hint Try to log a user into the system. If invalid credentials are provided, cbSecurity will thwor an IvalidCredentials error. The REST handler will automatically return the correct response.
     * @requestBody ~Auth/requestBodyLogin.json
     * @operationId authLogin
     * @tags Auth
     */
    function login( event, rc, prc ) allowedMethods="POST"
    {
        auth().authenticate( rc.username, rc.password );
        var token = jwtAuth().attempt( rc.username, rc.password );
        var user = jwtAuth().getUser();
        event.getResponse()
            .setData({
                'token': token,
                'tokenExpiration': 0,
                'tokenValidity': jwtAuth().getSettings().jwt.expiration * 60,
                'userId': user.getId(),
                'firstName': user.getFirstname(),
                'lastName': user.getLastname()
            });
            //.addMessage("Bearer token created and it expires in #jwtAuth().getSettings().jwt.expiration# minutes");
    }

    /**
     * @hint Log user out of the system.
     * @operationId authLogout
     * @tags Auth
     */
    function logout(event, rc, prc) allowedMethods="POST"
    {
        //auth().logout();
        try {
            jwtAuth().logout();
            event.getResponse().setData( "Successfully logged out" );
        } catch (any error) {
            event.getResponse().setError(true);
            event.getResponse().addMessage(error.message);
        }
    }

    /**
     * @hint Register a new user.
     * @requestBody ~Auth/requestBodyRegister.json
     * @operationId authRegister
     * @tags Auth
     */
    function register(event, rc, prc) allowedMethods="POST"
    {
        var oUser = userService.new( {
            isActive        : false
        } );

        var role = roleService.findWhere( { role : 'User' } );
        if ( isNull(role) ) {
            throw('no role');
        }

        var language = languageService.findWhere( { locale : 'en_EN' } );
        if ( isNull(language) ) {
            throw('no language');
        }

        // get and populate user
        populateModel(
            model                = oUser,
            composeRelationships = true,
            exclude              = "preference"
        );

        oUser.setRole( role );
        oUser.setLanguage( language );
        oUser.setPreferences( {} );

        // Validation error struct.
        var vErrors = {};

        // If the cbadmin configuration requires accepting a privacy policy, check if it was accepted.
        var privacyPolicyPass = true;
        if (cbadminSettings.privacy_policy_required) {
            privacyPolicyPass = false;
            if (StructKeyExists(rc, "acceptPrivacyPolicy") && rc.acceptPrivacyPolicy == true){
                privacyPolicyPass = true;
            }
        }

        if (!privacyPolicyPass) {
            vErrors['acceptPrivacyPolicy'] = { 'valid': false, 'error': 'You must accept the privacy policy.' };
            event.getResponse().setError(true);
        }

        // Validate the oUser object.
        var vResults = validateModel( target = oUser);
        if ( vResults.hasErrors() || event.getResponse().getError() === true) {
            for (var el in vResults.getErrors() ){
                vErrors[lcase(el.getField())] = {'valid': false ,'error': el.getMessage()};
            }
            event.getResponse().setError(true).setData(vErrors);
            return;
        }

        // we don't have any errors, so we create a new user
        announce( "cbadmin_preNewUserSave", { user : oUser } );
        userService.createNewUser( oUser );
        announce( "cbadmin_postNewUserSave", { user : oUser } );

        // We need to reset the view because otherwise the createNewUser method above will throw
        // a 'missinginclude' exception while trying to load /layouts/admin.cfm.
        event.setView('');

        event.getResponse()
            .setData( "New account successfully created. Please check your email and confirm your account to activate it." );
    }

    /**
     * @hint Check if the account activation token is valid.
     * @requestBody ~Auth/requestBodyCheckAccountActivationToken.json
     * @operationId authCheckAccountActivationToken
     * @tags Auth
     */
    function checkAccountActivationToken(event, rc, prc) allowedMethods="POST"
    {
        var validation = securityService.validateAccountActivationToken(rc.token);

        event.getResponse()
            .setError(validation.error);
        for (var msg in validation.messages) {
            event.getResponse()
                .addMessage(msg);
        }
    }

    /**
     * @hint Activate user's account with token.
     * @requestBody ~Auth/requestBodyActivateAccount.json
     * @operationId authActivateAccount
     * @tags Auth
     */
    function activateAccount(event, rc, prc) allowedMethods="POST"
    {
        var activation = securityService.activateAccount(rc.token);
        event.getResponse().setError(activation.error);
        for (var msg in activation.messages) {
            event.getResponse().addMessage(msg);
        }

        // We need to reset the view, otherwise a 'missinginclude' exception will be thrown.
        event.setView('');
    }

    /**
     * @hint Request reset password link. Requires firstname, lastname and email to identify the user.
     * @requestBody ~Auth/requestBodyRequestPasswordReset.json
     * @operationId authRequestPasswordReset
     * @tags Auth
     */
    function reset( event, rc, prc ) allowedMethods="POST"
    {
        param rc.email = '';
        param rc.firstname ='';
        param rc.lastname ='';

        var errors = [];

        rc.email = antiSamy.htmlSanitizer( rc.email );

        if ( !trim( rc.email ).length() ) {
            arrayAppend( errors, resourceService.getResource( 'validation.need_email@login' ) );
        }
        if ( !trim( rc.firstname ).length() ) {
            arrayAppend( errors, resourceService.getResource( 'validation.need_firstname@login' ) );
        }
        if ( !trim( rc.lastname ).length() ) {
            arrayAppend( errors, resourceService.getResource( 'validation.need_email@login' ) );
        }

        // only check in database if all information is provided
        if ( !arrayLen( errors ) ) {
            var oUser = userService.findWhere( { email = rc.email, firstname = rc.firstname, lastname = rc.lastname } );

            if ( isNull( oUser ) OR !oUser.isLoaded() ) {
                arrayAppend( errors, resourceService.getResource( 'validation.no_user@login' ) );
            }
        }

        if ( arrayLen( errors ) ){
            announce( "cbadmin_onInvalidPasswordReminder", { errors = errors, email = rc.email } );

            event.getResponse().setError(true).setMessages(errors);
            return;
        }

        securityService.sendPasswordReminder( oUser );

        // We need to reset the view because otherwise the sendPasswordReminder method above will throw
        // a 'missinginclude' exception while trying to load /layouts/admin.cfm.
        event.setView('');

        event.getResponse()
            .addMessage(resourceService.getResource( resource='messages.reminder_sent@login', values="15" ));
    }

    /**
     * @hint Check if the password reset token is valid.
     * @requestBody ~Auth/requestBodyCheckPasswordResetToken.json
     * @operationId authCheckPasswordResetToken
     * @tags Auth
     */
    function checkPasswordResetToken(event, rc, prc) allowedMethods="POST"
    {
        var validation = securityService.validatePasswordResetToken(rc.token);

        event.getResponse().setError(validation.error);
        for (var msg in validation.messages) {
            event.getResponse().addMessage(msg);
        }
    }

    /**
     * @hint Update the user's password. Requires a valid password reset token.
     * @requestBody ~Auth/requestBodySaveNewPassword.json
     * @operationId authSaveNewPassword
     * @tags Auth
     */
    function saveNewPassword(event, rc, prc) allowedMethods="POST"
    {
        // This check might appear redundant here, but is required as we need the user
        // object to pass to the securityService.resetUserPassword() method below.
        this.checkPasswordResetToken(event, rc, prc);
        if (event.getResponse().getError()) {
            return;
        }

        // Makre sure that the passwords are identical.
        if (Compare(rc.newPassword, rc.repeatPassword)) {
            event.getResponse()
                .setError(true)
                .addMessage('Passwords must be identical!');
            return;
        }

        // Finally, save the new password.
        var validation = securityService.validatePasswordResetToken(rc.token);
        var result = securityService.resetUserPassword(rc.token, validation.user, rc.newPassword);

        // We need to reset the view because otherwise the sendPasswordReminder method above will throw
        // a 'missinginclude' exception while trying to load /layouts/admin.cfm.
        event.setView('');

        event.getResponse()
            .setError(result.error)
        for (var msg in result.messages) {
            event.getResponse()
                .addMessage(msg);
        }
    }

    /**
     * Before you physically remove the user account from the database,
     * first disable the account.
     */
    function disableaccount(event, rc, prc)
    {
        // todo
    }

    /**
     * throws an InvalidCredentials error
     */
    function unauthorized(event, rc, prc)
    {
        throw(type="InvalidCredentials");
    }

    /*******************************************
     * 
     * Some test functions only for development.
     * 
     ******************************************/

    // This is jsut a test function to get the cache keys.
    function testGetCacheKeys()
    {
        abort;
        var tmp = securityService.getCacheKeys();
        dump(tmp);
        abort;
    }

    // This is just a test function to quickly create an account activation token.
    function newAccountActivationToken(event, rc)
    {
        abort;
        var userId = event.getValue('userId', '');
        var oUser = securityService.retrieveUserById(userId, false);

        if (!IsInstanceOf(oUser, 'User')) {
            event.getResponse().setError(true).addMessage('Could not find user.');
            return;
        }

        var token = securityService.generateAccountActivationToken(oUser);

        event.getResponse().setData({
            'token': token
        });
    }

    // This is just a test function to quickly create a test token for resetting passwords.
    function newPasswordResetToken(event)
    {
        abort;
        var user = securityService.retrieveUserByUsername('slawek')
        var token = securityService.generatePasswordResetToken(user);

        event.getResponse().setData(token);
    }
}