/**
* ContentBox - A Modular Content Platform
* Copyright since 2012 by Ortus Solutions, Corp
* www.ortussolutions.com/products/contentbox
* ---
* Manage ContentBox users
*/
component {

	// Dependencies
	property name="userService" inject="userService@cbadmin";
	property name="securityService" inject="securityService@cbadmin";
	property name="permissionService" inject="permissionService@cbadmin";
	property name="permissionGroupService" inject="permissionGroupService@cbadmin";
	property name="roleService" inject="roleService@cbadmin";
	property name="paging" inject="paging@cbadmin";
	property name="twoFactorService" inject="twoFactorService@cbadmin";

	/**
	 * Pre handler
	 */
	function preHandler( event, rc, prc, action, eventArguments ){
		var protectedActions = [
			"save",
			"editor",
			"savePreferences",
			"passwordChange",
			"doPasswordReset",
			"saveRawPreferences",
			"saveTwoFactor"
		];

		// Specific admin validation actions
		if ( arrayFindNoCase( protectedActions, arguments.action ) ) {
			// Get incoming author to verify credentials
			arguments.event.paramValue( "userId", 0 );
			var oUser = userService.get( rc.userId );

			prc.ocurrentUser = variables.securityService.getUserSession();

			// Validate credentials only if you are an admin or you are yourself.
			if (
				!prc.ocurrentUser.checkPermission( "ADMIN" )
				AND
				oUser.getUserID() NEQ prc.ocurrentUser.getUserID()
			) {
				// relocate
				cbMessagebox.error( "You do not have permissions to do this!" );
				relocate( event = prc.xehAuthors );
				return;
			}
		}
	}

	/**
	 * List system authors
	 * @return html
	 */
	function index( event, rc, prc ){
		// View all tab
		prc.tabUsers_manage = true;

		// exit handlers
		prc.xehAuthorTable         = "#prc.cbAdminEntryPoint#.users.indexTable";
		prc.xehImportAll           = "#prc.cbAdminEntryPoint#.users.importAll";
		prc.xehExportAll           = "#prc.cbAdminEntryPoint#.users.exportAll";
		prc.xehAuthorRemove        = "#prc.cbAdminEntryPoint#.users.remove";
		prc.xehAuthorCreate        = "#prc.cbAdminEntryPoint#.users.new";
		prc.xehAuthorsearch        = "#prc.cbAdminEntryPoint#.users";
		prc.xehGlobalPasswordReset = "#prc.cbAdminEntryPoint#.users.doGlobalPasswordReset";

		// Get Roles
		prc.aRoles            = roleService.getAll( sortOrder = "role" );
		prc.aPermissionGroups = permissionGroupService.getAll( sortOrder = "name" );
		prc.statusReport      = userService.getStatusReport();

		prc.roles = [];
		// View
		event.setView( "authors/index" );
	}

	/**
	 * Issue a global password reset for all users in the system.
	 */
	function doGlobalPasswordReset( event, rc, prc ){
		// announce event
		announce( "cbadmin_onGlobalPasswordReset" );
		// Get All Authors and reset the heck out of all of them.
		var allAuthors = userService.getAll();

		for ( var thisAuthor in allAuthors ) {
			// Issue a password reset for a user
			thisAuthor.setIsPasswordReset( true );
			securityService.sendPasswordReminder(
				author      = thisAuthor,
				adminIssued = true,
				issuer      = prc.ocurrentUser
			);
			// announce individual event
			announce( "cbadmin_onPasswordReset", { author : thisAuthor } );
		}

		// Bulk Save
		userService.saveAll( allAuthors );

		// relocate
		cbMessagebox.info( "Global password reset issued!" );
		relocate( prc.xehAuthors );
	}

	/**
	 * Build out system author's table + filters
	 * @return html
	 */
	function indexTable( event, rc, prc ){
		// paging
		event
			.paramValue( "page", 1 )
			.paramValue( "showAll", false )
			.paramValue( "searchAuthors", "" )
			.paramValue( "isFiltering", false, true )
			.paramValue( "fStatus", "true" )
			.paramValue( "f2FactorAuth", "any" )
			.paramValue( "fRole", "any" )
			.paramValue( "fGroups", "any" )
			.paramValue( "sortOrder", "lastname_asc" );

		// prepare paging object
		prc.oPaging    = variables.paging;
		prc.paging     = prc.oPaging.getBoundaries();
		prc.pagingLink = "javascript:contentPaginate( @page@ )";

		// exit Handlers
		prc.xehAuthorRemove  = "#prc.cbAdminEntryPoint#.users.remove";
		prc.xehExport        = "#prc.cbAdminEntryPoint#.users.export";
		prc.xehPasswordReset = "#prc.cbAdminEntryPoint#.users.doPasswordReset";

		// is Filtering?
		if (
			rc.fRole neq "any"
			OR rc.fStatus neq "any"
			OR rc.f2FactorAuth neq "any"
			OR rc.fGroups neq "any"
			OR rc.showAll
		) {
			prc.isFiltering = true;
		}

		// Determine Sort Order internally to avoid XSS
		var sortOrder = "lastName";
		switch ( rc.sortOrder ) {
			case "lastname_asc": {
				sortOrder = "lastName asc";
				break;
			}
			case "lastLogin_desc": {
				sortOrder = "lastLogin desc";
				break;
			}
			case "lastLogin_asc": {
				sortOrder = "lastLogin asc";
				break;
			}
			case "createdDate_desc": {
				sortOrder = "createdDate desc";
				break;
			}
			case "createdDate_asc": {
				sortOrder = "createdDate asc";
				break;
			}
			case "modifiedDate_desc": {
				sortOrder = "modifiedDate desc";
				break;
			}
			case "modifiedDate_asc": {
				sortOrder = "modifiedDate asc";
				break;
			}
		}

		// Get all authors or search
		var results = userService.search(
			searchTerm       = rc.searchAuthors,
			offset           = ( rc.showAll ? 0 : prc.paging.startRow - 1 ),
			max              = ( rc.showAll ? 0 : 10 ),
			sortOrder        = sortOrder,
			isActive         = rc.fStatus,
			role             = rc.fRole,
			permissionGroups = rc.fGroups,
			twoFactorAuth    = rc.f2FactorAuth
		);

		prc.users     = results.users;
		prc.userCount = results.count;

		// View
		event.setView( view = "authors/indexTable", layout = "ajax" );
	}

	/**
	 * System username checks
	 * @return json
	 */
	function usernameCheck( event, rc, prc ){
		var found = true;

		event.paramValue( "username", "" );

		// only check if we have a username
		if ( len( username ) ) {
			found = userService.usernameFound( rc.username );
		}

		event.renderData( type = "json", data = found );
	}

	/**
	 * System email checks
	 * @return json
	 */
	function emailCheck( event, rc, prc ){
		var found = true;

		event.paramValue( "email", "" );

		// only check if we have a email
		if ( len( email ) ) {
			found = userService.emailFound( rc.email );
		}

		event.renderData( type = "json", data = found );
	}

	/**
	 * Issue a password reset for the user
	 */
	function doPasswordReset( event, rc, prc ){
		event.paramValue( "editing", false );

		// get new or persisted author
		var oUser = userService.get( event.getValue( "userId", 0 ) );
		// viewlets only if editing a user
		if ( oUser.isLoaded() ) {
			// Issue a password reset for a user
			oUser.setIsPasswordReset( true );
			userService.saveUser( oUser );
			securityService.sendPasswordReminder(
				author      = oUser,
				adminIssued = true,
				issuer      = prc.ocurrentUser
			);
			// announce event
			announce( "cbadmin_onPasswordReset", { author : oUser } );
			cbMessagebox.info(
				"User marked for password reset upon login and email notification sent!"
			);
		} else {
			cbMessagebox.error( "Invalid User Sent!" );
		}

		// relocate
		relocate(
			event       = ( rc.editing ? prc.xehAuthorEditor : prc.xehAuthors ),
			queryString = ( rc.editing ? "userId=#oUser.getUserID()#" : "" )
		);
	}

	/**
	 * new user wizard
	 * You must have the AUTHOR_ADMIN permission to execute
	 */
	function new( event, rc, prc ){
		// exit handlers
		prc.xehAuthorsave    = "#prc.cbAdminEntryPoint#.users.doNew";
		prc.xehUsernameCheck = "#prc.cbAdminEntryPoint#.users.usernameCheck";
		prc.xehEmailCheck    = "#prc.cbAdminEntryPoint#.users.emailCheck";

		// get new user for form
		prc.user            = userService.new();
		// get all roles
		prc.roles             = roleService.list( sortOrder = "role", asQuery = false );
		// Get all permission groups
		prc.aPermissionGroups = permissionGroupService.list( sortOrder = "name", asQuery = false );
		// get editors for preferences

		// view
		event.setView( "authors/new" );
	}

	/**
	 * Create a new user in the system
	 * You must have the AUTHOR_ADMIN permission to execute
	 */
	function doNew( event, rc, prc ){
		// Get new user with defaults
		var oUser = userService.new( {
			isActive        : true,
			isPasswordReset : true,
			password        : hash( createUUID() & now() )
		} );

		// get and populate author
		populateModel(
			model                = oUser,
			composeRelationships = true,
			exclude              = "preference"
		);

		// iterate rc keys that start with "preference."
		var allPreferences = {};
		for ( var key in rc ) {
			if ( reFindNoCase( "^preference\.", key ) ) {
				allPreferences[ listLast( key, "." ) ] = rc[ key ];
			}
		}
		// Store Preferences for saving
		oUser.setPreferences( allPreferences );

		// validate it
		var vResults = validateModel( target = oUser, excludes = "password" );
		if ( !vResults.hasErrors() ) {
			// announce event
			announce( "cbadmin_preNewUserSave", { author : oUser } );
			// save author
			userService.createNewUser( oUser );
			// announce event
			announce( "cbadmin_postNewUserSave", { author : oUser } );
			// message
			cbMessagebox.setMessage( "info", "new user Created and Notified!" );
			// relocate
			relocate( prc.xehAuthors );
		} else {
			cbMessagebox.warn( messageArray = vResults.getAllErrors() );
			return new ( argumentCollection = arguments );
		}
	}

	/**
	 * Author editor panel
	 * @return html
	 */
	function editor( event, rc, prc ){
		event.paramValue( "userId", 0 );

		// HTML Title
		prc.htmlTitle               = "Author Editor";
		// exit handlers
		prc.xehAuthorsave           = "#prc.cbAdminEntryPoint#/authors/save";
		prc.xehAuthorPreferences    = "#prc.cbAdminEntryPoint#/authors/savePreferences";
		prc.xehAuthorRawPreferences = "#prc.cbAdminEntryPoint#/authors/saveRawPreferences";
		prc.xehAuthorChangePassword = "#prc.cbAdminEntryPoint#/authors/passwordChange";
		prc.xehAuthorPermissions    = "#prc.cbAdminEntryPoint#/authors/permissions";
		prc.xehUsernameCheck        = "#prc.cbAdminEntryPoint#/authors/usernameCheck";
		prc.xehEmailCheck           = "#prc.cbAdminEntryPoint#/authors/emailCheck";
		prc.xehEntriesManager       = "#prc.cbAdminEntryPoint#.entries/index";
		prc.xehPagesManager         = "#prc.cbAdminEntryPoint#/pages/index";
		prc.xehContentStoreManager  = "#prc.cbAdminEntryPoint#/contentStore/index";
		prc.xehExport               = "#prc.cbAdminEntryPoint#/authors/export";
		prc.xehPasswordReset        = "#prc.cbAdminEntryPoint#/authors/doPasswordReset";
		prc.xehEnrollTwoFactor      = "#prc.cbAdminEntryPoint#/security/twofactorEnrollment/process";
		prc.xehUnenrollTwoFactor    = "#prc.cbAdminEntryPoint#/security/twofactorEnrollment/unenroll";
		prc.xehTwoFactorRelocation  = "#prc.cbAdminEntryPoint#/authors/editor/userId/#rc.userId###twofactor";

		// get new or persisted author
		prc.user            = userService.get( rc.userId );
		// get roles
		prc.roles             = roleService.list( sortOrder = "role", asQuery = false );
		// get two factor provider
		//prc.twoFactorProvider = twoFactorService.getDefaultProviderObject();
		// Markdown Editor Availability

		// viewlets only if editing a user
		if ( prc.user.isLoaded() ) {
			// Preferences Viewlet
			var args = {
				userId   : rc.userId,
				sorting    : false,
				max        : 5,
				pagination : false,
				latest     : true
			};
			prc.preferencesViewlet = listPreferences( event, rc, prc );


		}
		// view
		event.setView( "authors/editor" );
	}

	/**
	 * Shortcut to author profile
	 * @return html
	 */
	function myprofile( event, rc, prc ){
		rc.userId = prc.ocurrentUser.getUserID();
		editor( argumentCollection = arguments );
	}

	/**
	 * change user editor preferences
	 */
	function changeEditor( event, rc, prc ){
		var results = { "ERROR" : false, "MESSAGES" : "" };
		try {
			// store the new user preference
			prc.ocurrentUser.setPreference( name = "editor", value = rc.editor );
			// save Author preference
			userService.saveUser( prc.ocurrentUser );
			results[ "MESSAGES" ] = "Editor changed to #rc.editor#";
		} catch ( Any e ) {
			log.error( "Error saving preferences.", e );
			results[ "ERROR" ]    = true;
			results[ "MESSAGES" ] = e.detail & e.message;
		}
		// return preference saved
		event.renderData( type = "json", data = results );
	}

	/**
	 * Save user preference async
	 */
	function saveSinglePreference( event, rc, prc ){
		event.paramvalue( "preference", "" ).paramValue( "value", "" );
		var results = { "ERROR" : false, "MESSAGES" : "" };

		// Check preference value
		if ( len( rc.preference ) ) {
			// store the new user preference
			prc.ocurrentUser.setPreference( name = rc.preference, value = rc.value );
			// save Author preference
			userService.saveUser( prc.ocurrentUser );
			results[ "MESSAGES" ] = "Preference saved";
		} else {
			results[ "ERROR" ]    = true;
			results[ "MESSAGES" ] = "No preference sent!";
		}

		// return preference saved
		event.renderData( type = "json", data = results );
	}

	/**
	 * Save user preferences
	 */
	function savePreferences( event, rc, prc ){
		var oUser        = userService.get( id = rc.userId );
		var allPreferences = {};

		// iterate rc keys that start with "preference."
		for ( var key in rc ) {
			if ( reFindNoCase( "^preference\.", key ) ) {
				allPreferences[ listLast( key, "." ) ] = rc[ key ];
			}
		}
		// Store Preferences
		oUser.setPreferences( allPreferences );
		// announce event
		announce(
			"cbadmin_preAuthorPreferencesSave",
			{ author : oUser, preferences : allPreferences }
		);
		// save Author
		userService.saveUser( oUser );
		// announce event
		announce(
			"cbadmin_postAuthorPreferencesSave",
			{ author : oUser, preferences : allPreferences }
		);
		// message
		cbMessagebox.setMessage( "info", "Author Preferences Saved!" );
		// relocate
		relocate(
			event       = prc.xehAuthorEditor,
			queryString = "userId=#oUser.getUserID()###preferences"
		);
	}

	/**
	 * Save raw preferences
	 */
	function saveRawPreferences( event, rc, prc ){
		var oUser = userService.get( id = rc.userId );
		// Validate raw preferences
		var vResult = validateModel(
			target      = rc,
			constraints = { preferences : { required : true, type : "json" } }
		);
		if ( !vResult.hasErrors() ) {
			// store preferences
			oUser.setPreferences( rc.preferences );
			// announce event
			announce(
				"cbadmin_preAuthorPreferencesSave",
				{ author : oUser, preferences : rc.preferences }
			);
			// save Author
			userService.saveUser( oUser );
			// announce event
			announce(
				"cbadmin_postAuthorPreferencesSave",
				{ author : oUser, preferences : rc.preferences }
			);
			// message
			cbMessagebox.setMessage( "info", "Author Preferences Saved!" );
			// relocate
			relocate(
				event       = prc.xehAuthorEditor,
				queryString = "userId=#oUser.getUserID()###preferences"
			);
		} else {
			// message
			cbMessagebox.error( messageArray = vResult.getAllErrors() );
			// relocate
			relocate(
				event       = prc.xehAuthorEditor,
				queryString = "userId=#oUser.getUserID()###preferences"
			);
		}
	}

	/**
	 * Save user
	 */
	function save( event, rc, prc ){
		// Get new or persisted user
		var oUser = userService.get( id = rc.userId );
		// get and populate author
		populateModel( oUser );
		// Tag new or updated user
		var newAuthor = ( NOT oUser.isLoaded() );

		// role assignment if permission allows it
		if ( prc.ocurrentUser.checkPermission( "ADMIN" ) ) {
			oUser.setRole( roleService.get( rc.roleId ) );
		}

		// validate it
		var vResults = validateModel(
			target   = oUser,
			excludes = ( structKeyExists( rc, "password" ) ? "" : "password" )
		);
		if ( !vResults.hasErrors() ) {
			// announce event
			announce(
				"cbadmin_preAuthorSave",
				{
					author   : oUser,
					userId : rc.userId,
					isNew    : newAuthor
				}
			);
			// save Author
			userService.saveUser( oUser );
			// announce event
			announce( "cbadmin_postAuthorSave", { author : oUser, isNew : newAuthor } );
			// message
			cbMessagebox.setMessage( "info", "Author saved!" );
			// relocate
			relocate( prc.xehAuthors );
		} else {
			cbMessagebox.warn( messageArray = vResults.getAllErrors() );
			relocate(
				event       = prc.xehAuthorEditor,
				queryString = "userId=#oUser.getUserID()#"
			);
		}
	}

	/**
	 * Change user password
	 */
	function passwordChange( event, rc, prc ){
		if ( prc.ocurrentUser.getUserID() != rc.userId ) {
			cbMessagebox.error(
				"You cannot change passwords for other users. Please start a password reset instead."
			);
			return relocate( event = prc.xehAuthorEditor, queryString = "userId=#rc.userId#" );
		}
		var oUser = userService.get( id = rc.userId );

		// validate passwords
		if ( compareNoCase( rc.password, rc.password_confirm ) EQ 0 ) {
			// set new password
			oUser.setPassword( rc.password );
			userService.saveUser( author = oUser, passwordChange = true );
			// announce event
			announce(
				"cbadmin_onAuthorPasswordChange",
				{ author : oUser, password : rc.password }
			);
			// message
			cbMessagebox.info( "Password Updated!" );
		} else {
			// message
			cbMessagebox.error( "Passwords do not match, please try again!" );
		}

		// relocate
		relocate( event = prc.xehAuthorEditor, queryString = "userId=#rc.userId#" );
	}

	/**
	 * Remove a user
	 */
	function remove( event, rc, prc ){
		event.paramValue( "targetUserID", 0 );

		var oUser = userService.get( rc.targetUserID );

		if ( isNull( oUser ) ) {
			cbMessagebox.setMessage( "warning", "Invalid Author!" );
			relocate( prc.xehAuthors );
		}
		// announce event
		announce( "cbadmin_preAuthorRemove", { author : oUser, userId : rc.targetUserID } );
		// remove
		userService.deleteUser( oUser );
		// announce event
		announce( "cbadmin_postAuthorRemove", { userId : rc.targetUserID } );
		// message
		cbMessagebox.setMessage( "info", "Author Removed!" );
		// redirect
		relocate( prc.xehAuthors );
	}

	/**
	 * Display permissions tab
	 */
	function permissions( event, rc, prc ){
		// exit Handlers
		prc.xehPermissionRemove = "#prc.cbAdminEntryPoint#.users.removePermission";
		prc.xehPermissionSave   = "#prc.cbAdminEntryPoint#.users.savePermission";
		prc.xehRolePermissions  = "#prc.cbAdminEntryPoint#.users.permissions";
		prc.xehGroupRemove      = "#prc.cbAdminEntryPoint#.users.removePermissionGroup";
		prc.xehGroupSave        = "#prc.cbAdminEntryPoint#.users.savePermissionGroup";

		// Get all permissions
		prc.aPermissions      = permissionService.list( sortOrder = "permission", asQuery = false );
		prc.aPermissionGroups = permissionGroupService.list( sortOrder = "name", asQuery = false );

		// Get author
		prc.user = userService.get( rc.userId );

		// view
		event.setView( view = "authors/permissions", layout = "ajax" );
	}

	/**
	 * Save permission to the author and gracefully end.
	 */
	function savePermission( event, rc, prc ){
		var oUser     = userService.get( rc.userId );
		var oPermission = permissionService.get( rc.permissionId );

		// Assign it
		if ( !oUser.hasPermission( oPermission ) ) {
			oUser.addPermission( oPermission );
			// Save it
			userService.saveUser( oUser );
		}
		// Saved
		event.renderData( data = "true", type = "json" );
	}

	/**
	 * Remove permission to a author and gracefully end.
	 *
	 * @return json
	 */
	function removePermission( event, rc, prc ){
		var oUser     = userService.get( rc.userId );
		var oPermission = permissionService.get( rc.permissionId );

		// Remove it
		oUser.removePermission( oPermission );
		// Save it
		userService.saveUser( oUser );
		// Saved
		event.renderData( data = "true", type = "json" );
	}

	/**
	 * Save permission groups to the author and gracefully end.
	 *
	 * @return json
	 */
	function savePermissionGroup( event, rc, prc ){
		var oUser = userService.get( rc.userId );
		var oGroup  = permissionGroupService.get( rc.permissionGroupId );

		// Assign it
		if ( !oUser.hasPermissionGroup( oGroup ) ) {
			oUser.addPermissionGroup( oGroup );
			// Save it
			userService.saveUser( oUser );
		}

		// Saved
		event.renderData( data = "true", type = "json" );
	}

	/**
	 * Remove permission to a author and gracefully end.
	 *
	 * @return json
	 */
	function removePermissionGroup( event, rc, prc ){
		var oUser = userService.get( rc.userId );
		var oGroup  = permissionGroupService.get( rc.permissionGroupId );

		if ( oUser.hasPermissionGroup( oGroup ) ) {
			// Remove it
			oUser.removePermissionGroup( oGroup );
			// Save it
			userService.saveUser( oUser );
		}

		// Saved
		event.renderData( data = "true", type = "json" );
	}

	/**
	 * Export a user
	 */
	function export( event, rc, prc ){
		event.paramValue( "format", "json" );
		// get user
		prc.user = userService.get( event.getValue( "userId", 0 ) );

		// relocate if not existent
		if ( !prc.user.isLoaded() ) {
			cbMessagebox.warn( "userId sent is not valid" );
			relocate( "#prc.cbAdminEntryPoint#.users" );
		}

		switch ( rc.format ) {
			case "xml":
			case "json": {
				var filename = "#prc.user.getUsername()#." & ( rc.format eq "xml" ? "xml" : "json" );
				event
					.renderData(
						data        = prc.user.getMemento(),
						type        = rc.format,
						xmlRootName = "user"
					)
					.setHTTPHeader(
						name  = "Content-Disposition",
						value = " attachment; filename=#fileName#"
					);
				break;
			}
			default: {
				event.renderData( data = "Invalid export type: #rc.format#" );
			}
		}
	}

	/**
	 * Export all users
	 */
	function exportAll( event, rc, prc ){
		event.paramValue( "format", "json" );
		// get all prepared content objects
		var data = userService.getAllForExport();

		switch ( rc.format ) {
			case "xml":
			case "json": {
				var filename = "Users." & ( rc.format eq "xml" ? "xml" : "json" );
				event
					.renderData(
						data        = data,
						type        = rc.format,
						xmlRootName = "users"
					)
					.setHTTPHeader(
						name  = "Content-Disposition",
						value = " attachment; filename=#fileName#"
					);
				break;
			}
			default: {
				event.renderData( data = "Invalid export type: #rc.format#" );
			}
		}
	}

	/**
	 * Import all users
	 */
	function importAll( event, rc, prc ){
		event.paramValue( "importFile", "" );
		event.paramValue( "overrideContent", false );
		try {
			if ( len( rc.importFile ) and fileExists( rc.importFile ) ) {
				var importLog = userService.importFromFile(
					importFile = rc.importFile,
					override   = rc.overrideContent
				);
				cbMessagebox.info( "Users imported sucessfully!" );
				flash.put( "importLog", importLog );
			} else {
				cbMessagebox.error(
					"The import file is invalid: #rc.importFile# cannot continue with import"
				);
			}
		} catch ( any e ) {
			var errorMessage = "Error importing file: #e.message# #e.detail# #e.stackTrace#";
			log.error( errorMessage, e );
			cbMessagebox.error( errorMessage );
		}
		relocate( prc.xehAuthors );
	}

	/******************************************** PRIVATE ****************************************************/

	/**
	 * List author preferences
	 * @return view
	 */
	private function listPreferences( event, rc, prc ){
		// get editors for preferences
		// render out view
		return renderView( view = "authors/listPreferences", module = "cbadmin" );
	}

}
