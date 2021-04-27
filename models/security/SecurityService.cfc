/**
 * ContentBox - A Modular Content Platform
 * Copyright since 2012 by Ortus Solutions, Corp
 * www.ortussolutions.com/products/contentbox
 * ---
 * Our contentbox security service must match our interface: ISecurityService
 */
component singleton {

	// Dependencies
	property name="userService"  inject="userService@cbadmin";
	property name="settingService" inject="settingService@cbadmin";
	property name="cacheStorage"   inject="cacheStorage@cbStorages";
	property name="cookieStorage"  inject="cookieStorage@cbStorages";
	property name="mailService"    inject="mailService@cbmailservices";
	property name="renderer"       inject="coldbox:renderer";
	property name="CBHelper"       inject="CBHelper@cbadmin";
	property name="log"            inject="logbox:logger:{this}";
	property name="cache"          inject="cachebox:template";
	property name="bCrypt"         inject="BCrypt@BCrypt";

	// Properties
	property name="encryptionKey";

	// Static Variables
	RESET_TOKEN_TIMEOUT = 60;

	/**
	 * Constructor
	 */
	SecurityService function init(){
		variables.encryptionKey = "";
		return this;
	}

	/**
	 * Update an author's last login timestamp
	 *
	 * @user The user object
	 */
	SecurityService function updateUserLoginTimestamp( required user ){
		arguments.user.setLastLogin( now() );
		userService.save( arguments.user );
		return this;
	}

	/**
	 * This function is called once an incoming event matches a security rule.
	 * You will receive the security rule that matched and an instance of the
	 * ColdBox controller.
	 *
	 * You must return a struct with two keys:
	 * - allow:boolean True, user can continue access, false, invalid access actions will ensue
	 * - type:string(authentication|authorization) The type of block that ocurred.  Either an authentication or an authorization issue.
	 * - messages:string Info/debug messages
	 *
	 * @return { allow:boolean, type:authentication|authorization, messages:string }
	 */
	struct function ruleValidator( required rule, required controller ){
		return validateSecurity( rule: arguments.rule, controller: arguments.controller );
	}

	/**
	 * This function is called once access to a handler/action is detected.
	 * You will receive the secured annotation value and an instance of the ColdBox Controller
	 *
	 * You must return a struct with two keys:
	 * - allow:boolean True, user can continue access, false, invalid access actions will ensue
	 * - type:string(authentication|authorization) The type of block that ocurred.  Either an authentication or an authorization issue.
	 * - messages:string Info/debug messages
	 *
	 * @return { allow:boolean, type:authentication|authorization, messages:string }
	 */
	struct function annotationValidator( required securedValue, required controller ){
		return validateSecurity(
			securedValue: arguments.securedValue,
			controller  : arguments.controller
		);
	}

	/**
	 * Validates if a user can access an event. Called via the cbSecurity module.
	 *
	 * @rule The security rule being tested for
	 * @controller The ColdBox controller calling the validation
	 */
	struct function validateSecurity( struct rule, securedValue, any controller ){
		var results = {
			"allow"    : false,
			"type"     : "authentication",
			"messages" : ""
		};
		// Get the currently logged in user, if any
		var user = getUserSession();

		// First check if user has been authenticated.
		if ( user.isLoaded() AND user.isLoggedIn() ) {
			// Check if the rule requires roles
			if ( !isNull( arguments.rule ) && len( arguments.rule.roles ) ) {
				for ( var x = 1; x lte listLen( arguments.rule.roles ); x++ ) {
					if ( listGetAt( arguments.rule.roles, x ) eq user.getRole().getRole() ) {
						results.allow = true;
						results.type  = "authorization";
						break;
					}
				}
			}

			// Check if the rule requires permissions
			if ( !isNull( arguments.rule ) && len( arguments.rule.permissions ) ) {
				for ( var y = 1; y lte listLen( arguments.rule.permissions ); y++ ) {
					if ( user.checkPermission( listGetAt( arguments.rule.permissions, y ) ) ) {
						results.allow = true;
						results.type  = "authorization";
						break;
					}
				}
			}

			// Check if the secured annotations is set
			if ( !isNull( arguments.securedValue ) && len( arguments.securedValue ) ) {
				for ( var y = 1; y lte listLen( arguments.securedValue ); y++ ) {
					if ( user.checkPermission( listGetAt( arguments.securedValue, y ) ) ) {
						results.allow = true;
						results.type  = "authorization";
						break;
					}
				}
			}

			// Check for empty rules and perms
			if ( !len( rule.roles ) AND !len( rule.permissions ) ) {
				results.allow = true;
			}
		}

		// If the rule has a message, then set a messagebox
		if (
			!results.allow &&
			!isNull( arguments.rule ) &&
			structKeyExists( rule, "message" ) &&
			len( rule.message )
		) {
			arguments.controller
				.getWireBox()
				.getInstance( "messagebox@cbmessagebox" )
				.setMessage(
					type: (
						structKeyExists( rule, "messageType" ) && len( rule.messageType ) ? rule.messageType : "info"
					),
					message: rule.message
				);
		}

		return results;
	}

	/**
	 * Get an user from session, or returns a new empty user entity
	 *
	 * @return Logged in or new user object
	 */
	User function getUserSession(){
		// Check if valid user id in session
		var userId = val( cacheStorage.get( "loggedInuserId", "" ) );

		// If that fails, check for a cookie
		if ( !userId ) {
			userId = getKeepMeLoggedIn();
		}

		// If we found an userId, load it up
		if ( userId ) {
			// try to get it with that ID
			var user = userService.findWhere( { userId : userId, isActive : true } );
			// If user found?
			if ( NOT isNull( user ) ) {
				user.setLoggedIn( true );
				return user;
			}
		}

		// return new user, not found or not valid
		return userService.new();
	}

	/**
	 * Set a new user in session
	 *
	 * @user The user to login to ContentBox
	 *
	 * @return SecurityService
	 */
	SecurityService function setUserSession( required User user ){
		cacheStorage.set( "loggedInuserId", user.getuserId() );
		return this;
	}

	/**
	 * Delete an user session
	 *
	 * @return SecurityService
	 */
	SecurityService function logout(){
		cacheStorage.clearAll();
		cookieStorage.delete( name = "contentbox_keep_logged_in" );

		return this;
	}

	/**
	 * Authenticate an user via ContentBox credentials.
	 * This method returns a structure containing an indicator if the authentication was valid (`isAuthenticated` and
	 * The `user` object which it represents.
	 *
	 * @username The username to validate
	 * @password The password to validate
	 *
	 * @return struct:{ isAuthenticated:boolean, user:User }
	 */
	struct function authenticate( required username, required password ){
		var results = { isAuthenticated : false, user : userService.new() };

		// Find username
		var oUser = userService.findWhere( {
			username  : arguments.username,
			isActive  : true,
			isDeleted : false
		} );

		// Verify if user found
		if ( isNull( oUser ) ) {
			// return not authenticated
			return results;
		}

		var samePassword = isSamePassword(oUser,arguments.password);

		// check if found and return verification
		if ( SamePassword ) {
			// Do we update the password algorithm?
			var isBcrypt = ( findNoCase( "$", oUser.getPassword() ) ? true : false );
			if ( !isBcrypt ) {
				oUser.setPassword( encryptString( arguments.password ) );
			}
			// Set last login date
			updateUserLoginTimestamp( oUser );

			// User authenticated, mark and return
			results.isAuthenticated = true;
			results.user          = oUser;
		}

		return results;
	}

	/**
	 * Check user credentials. Returns boolean. Function used by cbserucity.
	 *
	 * @username The username to validate
	 * @password The password to validate
	 *
	 * @return boolean
	 */
	boolean function isValidCredentials( required username, required password ){
		var auth = this.authenticate(username, password);
		return auth.isauthenticated;
	}

	/**
	 * Check if password passed matches oUser password
	 *
	 * @oUser 
	 * @password 
	 */
	boolean function isSamePassword( required oUser, required password ){

		// Determine password type
		var isBcrypt       = ( findNoCase( "$", oUser.getPassword() ) ? true : false );
		// Hash password according to algorithm
		var isSamePw = false;
		if ( isBcrypt ) {
			try {
				isSamePw = variables.bCrypt.checkPassword(
					arguments.password,
					oUser.getPassword()
				);
			} catch ( "java.lang.IllegalArgumentException" e ) {
				// Usually means the value is not bcrypt.
				isSamePw = false;
			}
		} else {
			// Legacy hash compare
			isSamePw = (
				compareNoCase( hash( arguments.password, "SHA-256" ), oUser.getPassword() ) eq 0 ? true : false
			);
		}
		return isSamePw;
	}

	struct function retrieveUserById(required id)
	{
		// Find username
		var oUser = userService.findWhere( {
			userId  : arguments.id,
			isActive  : true,
			isDeleted : false
		} );

		// Verify if user found
		if ( isNull( oUser ) ) {
			// return not authenticated
			return null;
		}

		return oUser;
	}

	struct function retrieveUserByUsername(required string username)
	{
		// Find username
		var oUser = userService.findWhere( {
			username  : arguments.username,
			isActive  : true,
			isDeleted : false
		} );

		// Verify if user found
		if ( isNull( oUser ) ) {
			// return not authenticated
			return null;
		}

		return oUser;
	}

	/**
	 * Leverages bcrypt to encrypt a string
	 *
	 * @string The string to bcrypt
	 */
	string function encryptString( required string ){
		return bCrypt.hashPassword( arguments.string );
	}

	/**
	 * This function will store a reset token in hash for the user to pickup on password resets
	 *
	 * @user The user to create the reset token for.
	 */
	string function generateResetToken( required User user ){
		// Store Security Token For X minutes
		var token = hash( arguments.user.getEmail() & arguments.user.getuserId() & now() );
		cache.set(
			"reset-token-#cgi.server_name#-#token#",
			arguments.user.getuserId(),
			RESET_TOKEN_TIMEOUT,
			RESET_TOKEN_TIMEOUT
		);
		return token;
	}

	/**
	 * Sends a new user their reminder to reset their password and log in to their account
	 *
	 * @user The user to send the reminder to
	 *
	 * @return error:boolean,errorArray
	 */
	struct function sendNewUserReminder( required User user ){
		// Generate security token
		var token = generateResetToken( arguments.user );

		// get settings + default site
		var settings    = variables.settingService.getAllSettings();

		// get mail payload
		var bodyTokens = {
			name        : arguments.user.getName(),
			email       : arguments.user.getEmail(),
			username    : arguments.user.getUsername(),
			linkTimeout : RESET_TOKEN_TIMEOUT,
			linkToken   : CBHelper.linkAdmin(
				event = "security.verifyReset",
				ssl   = settings.cbadmin_admin_ssl
			) & "?token=#token#",
			resetLink : CBHelper.linkAdmin(
				event = "security.lostPassword",
				ssl   = settings.cbadmin_admin_ssl
			),
			siteName    : "",
			issuedBy    : "",
			issuedEmail : ""
		};

		// Build email out
		var mail = newMail(
			to         = arguments.user.getEmail(),
			from       = settings.cbadmin_outgoingEmail,
			subject    = " Account was created for you",
			bodyTokens = bodyTokens
		);

		mail.setBody(
			renderer.renderLayout(
				view   = "/cbadmin/email_templates/author_welcome",
				layout = "/cbadmin/email_templates/layouts/email"
			)
		);

		// send it out
		return mailService.send( mail );
	}

	/**
	 * Send password reminder email, this verifies that the email is valid and they must click on the token
	 * link in order to reset their password.
	 * @user 		The user to send the reminder to
	 * @adminIssued 	Was this reset issued by a user or an admin
	 * @issuer 		The admin that issued the reset
	 *
	 * @return The mailing results of the password reminder: struct.
	 */
	struct function sendPasswordReminder(
		required User user,
		boolean adminIssued = false,
		User issuer
	){
		// Generate security token
		var token = generateResetToken( arguments.user );

		// get settings
		var settings    = variables.settingService.getAllSettings();

		// get mail payload
		var bodyTokens = {
			name        : arguments.user.getName(),
			ip          : settingService.getRealIP(),
			linkTimeout : RESET_TOKEN_TIMEOUT,
			siteName    : "",
			linkToken   : CBHelper.linkAdmin(
				event = "security.verifyReset",
				ssl   = settings.cbadmin_admin_ssl
			) & "?token=#token#",
			issuedBy    : "",
			issuedEmail : ""
		};

		// Check if an issuer was passed
		if ( !isNull( arguments.issuer ) ) {
			bodyTokens.issuedBy    = arguments.issuer.getName();
			bodyTokens.issuedEmail = arguments.issuer.getEmail();
		}

		// Build email out
		var mail = newMail(
			to         = arguments.user.getEmail(),
			from       = settings.cbadmin_outgoingEmail,
			subject    = "Password Reset Verification",
			bodyTokens = bodyTokens
		);

		// Decide template depending if issued by user or admin
		var emailTemplate = "password_verification";
		if ( arguments.adminIssued ) {
			emailTemplate &= "_admin";
		}

		mail.setBody(
			renderer.renderLayout(
				view   = "/cbadmin/email_templates/#emailTemplate#",
				layout = "/cbadmin/email_templates/layouts/email"
			)
		);

		// send it out
		return mailService.send( mail );
	}

	/**
	 * This function validates an incoming pw reset token to figure out their user.
	 * The token is not removed just yet. It will be removed once the password has been reset.
	 * @token The security token
	 *
	 * @returns {error, user}
	 */
	struct function validateResetToken( required token ){
		var results  = { "error" : false, "user" : "" };
		var cacheKey = "reset-token-#cgi.server_name#-#arguments.token#";
		var userId = cache.get( cacheKey );

		// If token not found, don't reset and return back
		if ( isNull( userId ) ) {
			results.error = true;
			return results;
		};

		// Verify the user of the token
		results.user = userService.get( userId );
		if ( isNull( results.user ) ) {
			results.error = true;
			return results;
		};

		return results;
	}

	/**
	 * Resets a user's password.
	 * @token 	Security token
	 * @user 	The user you are reseting the password for
	 * @password The password you have chosen
	 *
	 * @return {error:boolean, messages:string}
	 */
	struct function resetUserPassword(
		required token,
		required User user,
		required password
	){
		var results  = { "error" : false, "messages" : "" };
		var cacheKey = "reset-token-#cgi.server_name#-#arguments.token#";
		var userId = cache.get( cacheKey );

		// If token not found, don't reset and return back
		if ( isNull( userId ) ) {
			results.error    = true;
			results.messages = "Token does not exist or has expired";
			return results;
		};

		// Verify the user of the token
		if ( arguments.user.getuserId() neq userId ) {
			results.error    = true;
			results.messages = "User reset token mismatch";
			return results;
		};

		// Remove token now that we have the data and it has been validated
		cache.clear( cacheKey );

		// get settings
		var settings    = settingService.getAllSettings();

		// set it in the user and save reset password
		arguments.user.setPassword( arguments.password );
		arguments.user.setIsPasswordReset( false );
		userService.saveUser( user = arguments.user, passwordChange = true );

		// get mail payload
		var bodyTokens = {
			name       : arguments.user.getName(),
			ip         : settingService.getRealIP(),
			linkLogin  : CBHelper.linkAdminLogin( ssl = settings.cbadmin_admin_ssl ),
			siteName   : "",
			adminEmail : settings.cbadmin_email
		};
		var mail = newMail(
			to         = arguments.user.getEmail(),
			from       = settings.cbadmin_outgoingEmail,
			subject    = "#defaultSite.getName()# Password Reset Completed",
			bodyTokens = bodyTokens
		);
		// ,body=renderer.$get().renderExternalView(view="/cbadmin/email_templates/password_reminder" )
		mail.setBody(
			renderer.renderLayout(
				view   = "/cbadmin/email_templates/password_reset",
				layout = "/cbadmin/email_templates/layouts/email"
			)
		);
		// send it out
		mailService.send( mail );

		return results;
	}


	/**
	 * Get remember me cookie
	 */
	any function getRememberMe(){
		var cookieValue = cookieStorage.get( name = "contentbox_remember_me", defaultValue = "" );

		try {
			return decryptIt( cookieValue );
		} catch ( Any e ) {
			// Errors on decryption
			log.error( "Error decrypting remember me key: #e.message# #e.detail#", cookieValue );
			cookieStorage.delete( name = "contentbox_remember_me" );
			return "";
		}
	}


	/**
	 * Get keep me logged in cookie
	 */
	any function getKeepMeLoggedIn(){
		var cookieValue = cookieStorage.get( name = "contentbox_keep_logged_in", defaultValue = "" );

		try {
			// Decrypted value should be a number representing the userId
			return val( decryptIt( cookieValue ) );
		} catch ( Any e ) {
			// Errors on decryption
			log.error(
				"Error decrypting Keep Me Logged in key: #e.message# #e.detail#",
				cookieValue
			);
			cookieStorage.delete( name = "contentbox_keep_logged_in" );
			return 0;
		}
	}


	/**
	 * Set remember me cookie
	 * @username The username to store
	 * @days The days to store
	 */
	SecurityService function setRememberMe( required username, required numeric days = 0 ){
		// If the user now only wants to be remembered for this session, remove any existing cookies.
		if ( !arguments.days ) {
			cookieStorage.delete( name = "contentbox_remember_me" );
			cookieStorage.delete( name = "contentbox_keep_logged_in" );
			return this;
		}

		// Save the username to pre-populate the login field after their login expires for up to a year.
		cookieStorage.set(
			name    = "contentbox_remember_me",
			value   = encryptIt( arguments.username ),
			expires = 365
		);

		// Look up the user ID and store for the duration specified
		var user = userService.findWhere( { username : arguments.username, isActive : true } );
		if ( !isNull( user ) ) {
			// The user will be auto-logged in as long as this cookie exists
			cookieStorage.set(
				name    = "contentbox_keep_logged_in",
				value   = encryptIt( user.getuserId() ),
				expires = arguments.days
			);
		}

		return this;
	}

	/**
	 * ContentBox encryption
	 * @encValue value to encrypt
	 */
	string function encryptIt( required encValue ){
		// if empty just return it
		if ( !len( arguments.encValue ) ) {
			return arguments.encValue;
		}
		return encrypt(
			arguments.encValue,
			getEncryptionKey(),
			"BLOWFISH",
			"HEX"
		);
	}

	/**
	 * ContentBox Decryption
	 * @decValue value to decrypt
	 */
	string function decryptIt( required decValue ){
		if ( !len( arguments.decValue ) ) {
			return arguments.decValue;
		}
		return decrypt(
			arguments.decValue,
			getEncryptionKey(),
			"BLOWFISH",
			"HEX"
		);
	}

	/**
	 * Verifies we have a salt in our installation
	 * if not, it will generate a new cb_enc_key
	 */
	string function getEncryptionKey(){
		// Is the encryption key loaded?
		if ( len( variables.encryptionKey ) ) {
			return variables.encryptionKey;
		}

		// Verify we have one in the installation, else generate one
		var oSetting = settingService.findWhere( { name : "cb_enc_key" } );

		// if no key, then create it for this ContentBox installation
		if ( isNull( oSetting ) ) {
			oSetting = settingService.new( {
				name  : "cb_enc_key",
				value : generateSecretKey( "BLOWFISH" )
			} );
			settingService.save( entity = oSetting );
			log.info( "Registered new cookie encryption key" );
		}

		// Seed it locally, so we do not ask the DB again
		variables.encryptionKey = oSetting.getValue();

		// Return it.
		return oSetting.getValue();
	}

	private function newMail(to,from,subject,bodytokens){
		var settings    = settingService.getAllSettings();

		return mailservice.newMail(
			to         = arguments.to,
			from       = arguments.from,
			subject    = arguments.subject,
			bodyTokens = arguments.bodyTokens,
			type       = "html",
			server     = settings.cbadmin_mail_server,
			username   = settings.cbadmin_mail_username ?: '',
			password   = settings.cbadmin_mail_password ?: '',
			port       = settings.cbadmin_mail_smtp ?: 25,
			useTLS     = settings.cbadmin_mail_tls ?: false,
			useSSL     = settings.cbadmin_mail_ssl ?: false
		);		
	}
}
