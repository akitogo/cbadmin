component extends="coldbox.system.RestHandler"
{
	property name="securityService" 	inject="securityService@cbadmin";
	property name="roleService" 		inject="roleService@cbadmin";
	property name="userService" 		inject="userService@cbadmin";

	property name="antiSamy"			inject="antisamy@cbantisamy";
	property name="resourceService"		inject="resourceService@cbi18n";

	this.allowedMethods = { 
        'login' 		= "POST",
        'logout' 		= "POST,GET",
		'unauthorized'	= "GET,POST",
		'register'		= "POST",
		'reset'			= "POST"
    };


	function preHandler( event, rc, prc )
	{
		//getPageContext().getResponse().setHeader( "Access-Control-Allow-Origin", "*" );
	}

	/**
	 * if invalid credentials cbSecurity throws an InvalidCredentials error
	 * the rest handler automatically returns correct response
	 *
	 */
	function login( event, rc, prc )
	{
			auth().authenticate( rc.username, rc.password );
			var token = jwtAuth().attempt( rc.username, rc.password );
			var user = jwtAuth().getUser();
			event.getResponse()
				.setData({
					'token': token,
					'userId': user.getId(),
					'firstName': user.getFirstname(),
					'lastName': user.getLastname()
				})
				.addMessage("Bearer token created and it expires in #jwtAuth().getSettings().jwt.expiration# minutes");
	}

	/**
	 * logout
	 *
	 */
	function logout(event, rc, prc)
	{
		//auth().logout();
		jwtAuth().logout();
		event.getResponse().setData( "Successfully logged out" );
	}

	/**
	 * throws an InvalidCredentials error
	 *
	 */
	function unauthorized(event, rc, prc)
	{
		throw(type="InvalidCredentials");
	}

	/**
	 * register user
	 *
	 */
	function register(event, rc, prc)
	{
		rc.username = event.getValue('email', '');

		var oUser = userService.new( {
			isActive        : false
		} );
		var role = roleService.findWhere( { role : 'User' } );
		if ( isNull(role) ) {
			throw('no role');
		}

		// get and populate user
		populateModel(
			model                = oUser,
			composeRelationships = true,
			exclude              = "preference"
		);

		oUser.setRole( role );
		oUser.setPreferences( {} );

		// validate it
		var vResults = validateModel( target = oUser);
		if ( vResults.hasErrors() ) {
			var sErrors = {};
			for (var el in vResults.getErrors() ){
				sErrors[lcase(el.getField())] = {'valid': false ,'error': el.getMessage()};
			}
		
			event.getResponse().setError(true).setData(sErrors);
			return;
		} 

		// we don't have any errors, so we create a new user
		announce( "cbadmin_preNewUserSave", { user : oUser } );
		userService.createNewUser( oUser );
		announce( "cbadmin_postNewUserSave", { user : oUser } );

		event.getResponse().setData( "User registered" );

	}	

	/**
	* Do lost password reset
	* requires email, firstnam and lastname to identify user
	*/
	function reset( event, rc, prc ){
		param rc.email		= '';
		param rc.firstname	='';
		param rc.lastname	='';

		var errors 			= [];

		rc.email = antiSamy.htmlSanitizer( rc.email );

		if( !trim( rc.email ).length() )
			arrayAppend( errors, resourceService.getResource( 'validation.need_email@login' ) );
		if( !trim( rc.firstname ).length() )
			arrayAppend( errors, resourceService.getResource( 'validation.need_firstname@login' ) );
		if( !trim( rc.lastname ).length() )
			arrayAppend( errors, resourceService.getResource( 'validation.need_email@login' ) );

		// only check in database if all information is provided
		if( !arrayLen( errors ) ){
			var oUser = userService.findWhere( { email = rc.email, firstname = rc.firstname, lastname = rc.lastname } );

			if( isNull( oUser ) OR !oUser.isLoaded() )
				arrayAppend( errors, resourceService.getResource( 'validation.no_user@login' ) );
		}

		if( arrayLen( errors ) ){
			announce( "cbadmin_onInvalidPasswordReminder", { errors = errors, email = rc.email } );

			event.getResponse().setError(true).setMessages(errors);
			return;
		}


		securityService.sendPasswordReminder( oUser );

		// we need to reset the view, not sure why
		event.setView('');
		event.getResponse().setData( resourceService.getResource( resource='messages.reminder_sent@login', values="15" ) );
	}
}