/**
 * ContentBox - A Modular Content Platform
 * Copyright since 2012 by Ortus Solutions, Corp
 * www.ortussolutions.com/products/contentbox
 * ---
 * This entity groups permissions for logical groupings
 *
 * *********************************************
 *
 * The 'openapidocs' attribute of properties is
 * used by cbswagger to generate documentation.
 *
 */
component
	persistent="true"
	entityName="cbPermissionGroup"
	table     ="cbadmin_permissionGroup"
	extends   ="cbadmin.models.BaseEntity"
	cachename ="cbPermissionGroup"
	cacheuse  ="read-write"
{
	this.memento = {
		defaultIncludes = [ "*" ]
		, defaultExcludes = [ "users", "permissions.permissionGroups" , "permissions.roles" ]
  };

	/* *********************************************************************
	 **							DI
	 ********************************************************************* */



	/* *********************************************************************
	 **							PROPERTIES
	 ********************************************************************* */

	property
		name       ="permissionGroupId"
		fieldtype  ="id"
		generator  ="native"
		setter     ="false"
		params     ="{ allocationSize = 1, sequence = 'permissionGroupId_seq' }"
		openapidocs="{
			type = 'integer',
			description = 'ID of the permission group (this field is required for PUT/PATCH requests)',
			example = '49',
			exclude_post = true
		}";

	property
		name   ="name"
		ormtype="string"
		notnull="true"
		length ="255"
		unique ="true"
		default=""
		index  ="idx_permissionGroupName"
		openapidocs="{
			type = 'string',
			description = 'Name of the permission group',
			example = 'user management'
		}";

	property
		name   ="description"
		ormtype="string"
		notnull="false"
		default=""
		length ="500"
		openapidocs="{
			type = 'string',
			description = 'Description of the permission group',
			example = 'Permissions related to user management (view, edit, create, delete etc.)'
		}";

	/* *********************************************************************
	 **							RELATIONSHIPS
	 ********************************************************************* */

	// M2M -> Permissions
	property
		name             ="permissions"
		singularName     ="permission"
		fieldtype        ="many-to-many"
		type             ="array"
		lazy             ="extra"
		orderby          ="permission"
		cascade          ="save-update"
		cacheuse         ="read-write"
		cfc              ="cbadmin.models.security.Permission"
		fkcolumn         ="FK_permissionGroupId"
		linktable        ="cbadmin_groupPermissions"
		inversejoincolumn="FK_permissionId"
		openapidocs="{
			type = 'array',
			description = 'Array of permissions that belong to this psermission group (for POST/PUT/PATCH requests this should be an array of permission IDs)',
			get_example = [ '{ permission object 1 }', '{ permission object 2 }', '{ permission object 3 }' ],
			post_example = [ 23, 94, 15]
		}";

	// M2M -> users
	property
		name             ="users"
		singularName     ="user"
		fieldtype        ="many-to-many"
		type             ="array"
		lazy             ="extra"
		cascade          ="save-update"
		cacheuse         ="read-write"
		cfc              ="cbadmin.models.security.User"
		fkcolumn         ="FK_permissionGroupId"
		linktable        ="cbadmin_userPermissionGroups"
		inversejoincolumn="FK_userId";

	/* *********************************************************************
	 **							CALCULATED FIELDS
	 ********************************************************************* */

	property
		name   ="numberOfPermissions"
		formula="select count(*) from cbadmin_groupPermissions as groupPermissions
			where groupPermissions.FK_permissionGroupId = permissionGroupId"
		openapidocs="{
			type = 'integer',
			description = 'Number of permissions assigned to this permission group',
			example = '4',
			exclude_post = true
		}";

	property
		name   ="numberOfUsers"
		formula="select count(*) from cbadmin_userPermissionGroups as pg where
			pg.FK_permissionGroupId = permissionGroupId"
		openapidocs="{
			type = 'integer',
			description = 'Number of users assigned to this permission group',
			example = '2',
			exclude_post = true
		}";

	/* *********************************************************************
	 **							NON PERSISTED PROPERTIES
	 ********************************************************************* */

	property
		name="permissionList"
		persistent="false"
		openapidocs="{
			exclude_post = true
		}";

	/* *********************************************************************
	 **							PK + CONSTRAINTS
	 ********************************************************************* */

	this.pk = "permissionGroupId";

	this.constraints = {
		"name" : {
			required  : true,
			size      : "1..255",
			validator : "UniqueValidator@cborm"
		},
		"description" : { required : false, size : "1..500" }
	};

	/* *********************************************************************
	 **							PUBLIC FUNCTIONS
	 ********************************************************************* */

	/**
	 * Constructor
	 */
	function init(){
		variables.permissions   	= [];
		variables.users        		= [];
		variables.permissionList 	= "";
		super.init();

		return this;
	}

	/**
	 * Check for permission
	 *
	 * @slug The permission slug or list of slugs to validate the role has. If it's a list then they are ORed together
	 */
	boolean function checkPermission( required slug ){
		// cache list
		if ( !len( variables.permissionList ) AND hasPermission() ) {
			var q                    = entityToQuery( getPermissions() );
			variables.permissionList = valueList( q.permission );
		}

		// Do verification checks
		var aList   = listToArray( arguments.slug );

		for ( var thisPerm in aList ) {
			if ( listFindNoCase( variables.permissionList, trim( thisPerm ) ) ) {
				return true;
			}
		}

		return false;
	}

	/**
	 * Clear all permissions
	 */
	PermissionGroup function clearPermissions(){
		variables.permissions = [];
		return this;
	}

	/**
	 * Clear all users
	 */
	PermissionGroup function clearUsers(){
		variables.users = [];
		return this;
	}

	/**
	 * Override the setPermissions
	 *
	 * @permissions The permissions array
	 */
	PermissionGroup function setPermissions( required array permissions ){
		if ( hasPermission() ) {
			variables.permissions.clear();
			variables.permissions.addAll( arguments.permissions );
		} else {
			variables.permissions = arguments.permissions;
		}
		return this;
	}

	/**
	 * Override the setUsers
	 *
	 * @users The permissions array
	 */
	PermissionGroup function setUsers( required array users ){
		if ( hasUser() ) {
			variables.users.clear();
			variables.users.addAll( arguments.users );
		} else {
			variables.users = arguments.users;
		}
		return this;
	}

	/**
	 * Get memento representation
	 *
	 * @excludes Exclude properties
	 * @showPermissions Show permissions or not
	 */
/*
	function getMemento( excludes = "", boolean showPermissions = true ){
		var pList  = listToArray( "name,description" );
		var result = getBaseMemento( properties = pList, excludes = arguments.excludes );

		// Do Permissions
		if ( arguments.showPermissions && hasPermission() ) {
			result[ "permissions" ] = [];
			for ( var thisPerm in variables.permissions ) {
				arrayAppend( result[ "permissions" ], thisPerm.getMemento() );
			}
		} else if ( arguments.showPermissions ) {
			result[ "permissions" ] = [];
		}

		return result;
	}
*/
}
