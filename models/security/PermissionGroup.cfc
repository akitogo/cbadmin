/**
 * ContentBox - A Modular Content Platform
 * Copyright since 2012 by Ortus Solutions, Corp
 * www.ortussolutions.com/products/contentbox
 * ---
 * This entity groups permissions for logical groupings
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
		,defaultExcludes = ['users.permissionGroups', 'permissions.permissionGroups' , 'permissions.roles']
  };

	/* *********************************************************************
	 **							DI
	 ********************************************************************* */



	/* *********************************************************************
	 **							PROPERTIES
	 ********************************************************************* */

	property
		name     ="permissionGroupId"
		fieldtype="id"
		generator="native"
		setter   ="false"
		params   ="{ allocationSize = 1, sequence = 'permissionGroupId_seq' }";

	property
		name   ="name"
		ormtype="string"
		notnull="true"
		length ="255"
		unique ="true"
		default=""
		index  ="idx_permissionGroupName";

	property
		name   ="description"
		ormtype="string"
		notnull="false"
		default=""
		length ="500";

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
		inversejoincolumn="FK_permissionId";

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
						 where groupPermissions.FK_permissionGroupId = permissionGroupId";

	property
		name   ="numberOfUsers"
		formula="select count(*) from cbadmin_userPermissionGroups as pg where pg.FK_permissionGroupId = permissionGroupId";

	/* *********************************************************************
	 **							NON PERSISTED PROPERTIES
	 ********************************************************************* */

	property name="permissionList" persistent="false";

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
