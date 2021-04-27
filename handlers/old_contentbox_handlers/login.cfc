/**
* ContentBox - A Modular Content Platform
* Copyright since 2012 by Ortus Solutions, Corp
* www.ortussolutions.com/products/contentbox
* ---
* ContentBox security handler
*/
component{

	// DI
	property name="securityService" inject="securityService@cbadmin";
	property name="userService" 	inject="userService@cbadmin";
	property name="antiSamy"		inject="antisamy@cbantisamy";
	property name="messagebox"		inject="messagebox@cbMessagebox";

	// Method Security
	this.allowedMethods = {
		doLogin 		= "POST",
		doLostPassword 	= "POST"
	};

	/**
	* Pre handler
	*/
	function preHandler( event, currentAction, rc, prc ){
		prc.langs 		= getModuleSettings( "cbadmin" ).languages;
		prc.entryPoint 	= getModuleConfig( "cbadmin" ).entryPoint&'/login';
		prc.xehLang 	= event.buildLink( "#prc.entryPoint#/language" );
	}

	/**
	* Change language
	*/
	function changeLang( event, rc, prc ){
		event.paramValue( "lang", "en_US" );
		setFWLocale( rc.lang );
		relocate( prc.entryPoint );
	}

	/**
	* Login screen
	*/
	function login( event, rc, prc ){
		prc.xehDoLogin 			= "#prc.cbAdminEntryPoint#.login.doLogin";
		prc.xehLostPassword 	= "#prc.cbAdminEntryPoint#.login.lostPassword";
		// remember me
		prc.rememberMe = antiSamy.htmlSanitizer( securityService.getRememberMe() );
		// secured URL from security interceptor
		arguments.event.paramValue( "_securedURL", "" );
		rc._securedURL = antiSamy.htmlSanitizer( rc._securedURL );
		// view
		event.setView( view="login/login",layout="simple" );
	}

	/**
	* Do a login
	*/
	function doLogin( event, rc, prc ){
		// params
		event.paramValue( "rememberMe", 0 )
			.paramValue( "_securedURL", "" );
		// Sanitize
		rc.username 	= antiSamy.htmlSanitizer( rc.username );
		rc.password 	= antiSamy.htmlSanitizer( rc.password );
		rc.rememberMe 	= antiSamy.htmlSanitizer( rc.rememberMe );
		rc._securedURL 	= antiSamy.htmlSanitizer( rc._securedURL );

		// announce event
		announceInterception( "cbadmin_preLogin" );
		// authenticate users
		var authUser = securityService.authenticate( rc.username, rc.password );
		if( authUser.ISAUTHENTICATED ){
			// set remember me
			securityService.setRememberMe( rc.username, val( rc.rememberMe ) );
			securityService.setUserSession(authUser.user);
			// announce event
			announceInterception( "cbadmin_onLogin" );
			// check if securedURL came in?
			if( len( rc._securedURL ) ){
				relocate( uri=rc._securedURL );
			} else {
				relocate( "#prc.cbAdminEntryPoint#.dashboard" );
			}
		} else {
			// announce event
			announceInterception( "cbadmin_onBadLogin" );
			// message and redirect
			messagebox.warn( cb.r( "messages.invalid_credentials@login" ));
			// Relocate
			relocate( "#prc.cbAdminEntryPoint#.login.login" );
		}
	}

	/**
	* Logout a user
	*/
	function doLogout( event, rc, prc ){
		// logout
		securityService.logout();
		// announce event
		announceInterception( "cbadmin_onLogout" );
		// message redirect
		messagebox.info( cb.r( "messages.seeyou@login" ) );
		// relocate
		relocate( "#prc.cbAdminEntryPoint#.login.login" );
	}

	/**
	* Present lost password screen
	*/
	function lostPassword( event, rc, prc ){
		prc.xehLogin 			= "#prc.cbAdminEntryPoint#.login.login";
		prc.xehDoLostPassword 	= "#prc.cbAdminEntryPoint#.login.doLostPassword";

		event.setView( view="login/lostPassword",layout="simple" );
	}

	/**
	* Do lost password reset
	*/
	function doLostPassword( event, rc, prc ){
		var errors 	= [];
		var oUser = "";

		// Param email
		event.paramValue( "email", "" );

		rc.email = antiSamy.htmlSanitizer( rc.email );

		// Validate email
		if( NOT trim( rc.email ).length() ){
			arrayAppend( errors, "#cb.r( 'validation.need_email@login' )#<br />" );
		} else {
			// Try To get the Author
			oUser = userService.findWhere( { email = rc.email } );
			if( isNull( oUser ) OR NOT oUser.isLoaded() ){
				// Don't give away that the email did not exist.
				messagebox.info( cb.r( resource='messages.lostpassword_check@login', values="5" ) );
				relocate( "#prc.cbAdminEntryPoint#.login.lostPassword" );
			}
		}

		// Check if Errors
		if( NOT arrayLen( errors ) ){
			// Send Reminder
			securityService.sendPasswordReminder( oUser );
			// announce event
			announceInterception( "cbadmin_onPasswordReminder", { author = oUser } );
			// messagebox
			messagebox.info( cb.r( resource='messages.reminder_sent@login', values="15" ) );
		} else {
			// announce event
			announceInterception( "cbadmin_onInvalidPasswordReminder", { errors = errors, email = rc.email } );
			// messagebox
			messagebox.error( messageArray=errors );
		}
		// Re Route
		relocate( "#prc.cbAdminEntryPoint#.login.lostPassword" );
	}

	/**
	* Verify the reset
	*/
	function verifyReset( event, rc, prc ){
		arguments.event.paramValue( "token", "" );

		// Validate token
		var results = securityService.resetUserPassword( trim( rc.token ) );
		if( !results.error ){
			// announce event
			announceInterception( "cbadmin_onPasswordReset", { author = results.author } );
			// Messagebox
			messagebox.info( cb.r( "messages.password_reset@login" ) );
		} else {
			// announce event
			announceInterception( "cbadmin_onInvalidPasswordReset", { token = rc.token } );
			// messagebox
			messagebox.error( cb.r( "messages.invalid_token@login" ) );
		}

		// Relcoate to login
		relocate( "#prc.cbAdminEntryPoint#.login.lostPassword" );
	}

}