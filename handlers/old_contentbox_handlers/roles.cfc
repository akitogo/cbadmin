/**
 * ContentBox - A Modular Content Platform
 * Copyright since 2012 by Ortus Solutions, Corp
 * www.ortussolutions.com/products/contentbox
 * ---
 * Manage roles
 */
component {

	// Dependencies
	property name="roleService" inject="roleService@cbadmin";
	property name="permissionService" inject="permissionService@cbadmin";

	/**
	 * Pre handler
	 *
	 * @event
	 * @action
	 * @eventArguments
	 * @rc
	 * @prc
	 */
	function preHandler( event, action, eventArguments, rc, prc ){
		// Tab control
		prc.tabUsers = true;
	}

	/**
	 * Manage roles
	 *
	 * @event
	 * @rc
	 * @prc
	 */
	function index( event, rc, prc ){
		// exit Handlers
		prc.xehRoleRemove      = "#prc.cbAdminEntryPoint#.roles.remove";
		prc.xehRoleEditor      = "#prc.cbAdminEntryPoint#.roles.editor";
		prc.xehRoleSave        = "#prc.cbAdminEntryPoint#.roles.save";
		prc.xehRolePermissions = "#prc.cbAdminEntryPoint#.roles.permissions";
		prc.xehExport          = "#prc.cbAdminEntryPoint#.roles.export";
		prc.xehExportAll       = "#prc.cbAdminEntryPoint#.roles.exportAll";
		prc.xehImportAll       = "#prc.cbAdminEntryPoint#.roles.importAll";

		// Get all roles
		prc.roles          = roleService.list( sortOrder = "role", asQuery = false );
		// Tab
		prc.tabUsers_roles = true;
		// view
		event.setView( "roles/index" );
	}

	/**
	 * Save Roles
	 *
	 * @event
	 * @rc
	 * @prc
	 */
	function save( event, rc, prc ){
		// Inflate the right Permissions according to toggle pattern: permissions_id_toggle
		rc.permissions = rc
			.filter( function( key, value ){
				return key.findNoCase( "permissions_" );
			} )
			.reduce( function( results, key, value ){
				results.append( getToken( key, "2", "_" ) );
				return results;
			}, [] );

		// populate and get
		var oRole = populateModel(
			model               : roleService.get( id = rc.roleId ),
			composeRelationships: true
		);


		// Validate
		var vResults = validateModel( oRole );
		if ( !vResults.hasErrors() ) {
			// announce event
			announce( "cbadmin_preRoleSave", { role : oRole, roleId : rc.roleId } );
			// save role
			roleService.save( oRole );
			// announce event
			announce( "cbadmin_postRoleSave", { role : oRole } );
			// messagebox
			cbMessagebox.setMessage( "info", "Role saved!" );
		} else {
			// messagebox
			cbMessagebox.warning( messageArray = vResults.getAllErrors() );
		}
		// relocate
		relocate( prc.xehroles );
	}

	/**
	 * Remove Roles
	 *
	 * @event
	 * @rc
	 * @prc
	 */
	function remove( event, rc, prc ){
		// announce event
		announce( "cbadmin_preRoleRemove", { roleId : rc.roleId } );
		// Get requested role and remove permissions
		var oRole = roleService.get( id = rc.roleId ).clearPermissions();
		// finally delete
		roleService.delete( oRole );
		// announce event
		announce( "cbadmin_postRoleRemove", { roleId : rc.roleId } );
		// Message
		cbMessagebox.setMessage( "info", "Role Removed!" );
		// relocate
		relocate( prc.xehroles );
	}

	/**
	 * Create or Edit Roles
	 */
	function editor( event, rc, prc ){
		param rc.roleId  = 0;
		// Get or fail
		prc.oRole        = variables.roleService.get( rc.roleId );
		// Load permissions
		prc.aPermissions = variables.permissionService.list(
			sortOrder = "permission",
			asQuery   = false
		);
		// Exit handlers
		prc.xehRoleSave = "#prc.cbAdminEntryPoint#.roles.save";
		// View
		event.setView( "roles/editor" );
	}

	/**
	 * Export a role
	 *
	 * @event
	 * @rc
	 * @prc
	 */
	function export( event, rc, prc ){
		event.paramValue( "format", "json" );
		// get role
		prc.role = roleService.get( event.getValue( "roleId", 0 ) );

		// relocate if not existent
		if ( !prc.role.isLoaded() ) {
			cbMessagebox.warn( "roleId sent is not valid" );
			relocate( "#prc.cbAdminEntryPoint#.roles" );
		}
		// writeDump( prc.role.getMemento() );abort;
		switch ( rc.format ) {
			case "xml":
			case "json": {
				var filename = "#prc.role.getRole()#." & ( rc.format eq "xml" ? "xml" : "json" );
				event
					.renderData(
						data        = prc.role.getMemento(),
						type        = rc.format,
						xmlRootName = "role"
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
	 * Export all roles
	 *
	 * @event
	 * @rc
	 * @prc
	 */
	function exportAll( event, rc, prc ){
		event.paramValue( "format", "json" );
		// get all prepared content objects
		var data = roleService.getAllForExport();

		switch ( rc.format ) {
			case "xml":
			case "json": {
				var filename = "Roles." & ( rc.format eq "xml" ? "xml" : "json" );
				event
					.renderData(
						data        = data,
						type        = rc.format,
						xmlRootName = "roles"
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
	 * Import roles
	 *
	 * @event
	 * @rc
	 * @prc
	 */
	function importAll( event, rc, prc ){
		event.paramValue( "importFile", "" );
		event.paramValue( "overrideContent", false );
		try {
			if ( len( rc.importFile ) and fileExists( rc.importFile ) ) {
				var importLog = roleService.importFromFile(
					importFile = rc.importFile,
					override   = rc.overrideContent
				);
				cbMessagebox.info( "Roles imported sucessfully!" );
				flash.put( "importLog", importLog );
			} else {
				cbMessagebox.error(
					"The import file is invalid: #encodeForHTML( rc.importFile )# cannot continue with import"
				);
			}
		} catch ( any e ) {
			var errorMessage = "Error importing file: #e.message# #e.detail# #e.stackTrace#";
			log.error( errorMessage, e );
			cbMessagebox.error( errorMessage );
		}
		relocate( prc.xehRoles );
	}

}
