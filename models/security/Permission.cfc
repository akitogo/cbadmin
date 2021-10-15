/**
 * ContentBox - A Modular Content Platform
 * Copyright since 2012 by Ortus Solutions, Corp
 * www.ortussolutions.com/products/contentbox
 * ---
 * A cool Permission entity
 *
 * *********************************************
 *
 * The 'openapidocs' attribute of properties is
 * used by cbswagger to generate documentation.
 *
 */
component
	persistent	="true"
	entityName	="cbPermission"
	table				="cbadmin_permission"
	extends			="cbadmin.models.BaseEntity"
	cachename		="cbPermission"
	cacheuse		="read-write"
{
	this.memento = {
		defaultIncludes = [ "*" ]
		,defaultExcludes = ['permissionGroups.permissions', 'permissionGroups.users', 'roles.permissions']
	};

	/* *********************************************************************
	**							PROPERTIES
	********************************************************************* */

	property
		name="permissionId"
		fieldtype="id"
		generator="native"
		setter="false"
		params="{ allocationSize = 1, sequence = 'permissionId_seq' }"
		openapidocs="{
			type = 'integer',
			description = 'ID of the permission (this field is required for PUT/PATCH requests)',
			example = '56',
			exclude_post = true
		}";

	property
		name="permission"
		ormtype="string"
		notnull="true"
		length="255"
		unique="true"
		default=""
		index="idx_permissionName"
		openapidocs="{
			type = 'string',
			description = 'Name of the permission',
			example = 'create user'
		}";

	property
		name="description"
		ormtype="string"
		notnull="false"
		default=""
		length="500"
		openapidocs="{
			type = 'string',
			description = 'Description of the permission',
			example = 'Allows creating new users'
		}";

	/* *********************************************************************
	**							RELATIONSHIPS
	********************************************************************* */

	// M2M -> PermissionGroups
	property
		name								="permissionGroups"
		singularName				="permissionGroup"
		fieldtype						="many-to-many"
		type								="array"
		lazy								="extra"
		cascade							="save-update"
		cacheuse						="read-write"
		cfc									="cbadmin.models.security.PermissionGroup"
		fkcolumn						="FK_permissionId"
		linktable						="cbadmin_groupPermissions"
		inversejoincolumn		="FK_permissionGroupId"
		openapidocs="{
			type = 'array',
			description = 'Array of permission groups that this permission is assigned to (for POST/PUT/PATCH requests this should be an array of permission group IDs)',
			get_example = [ '{ permissionGroup object 1 }', '{ permissionGroup object 2 }', '{ permissionGroup object 3 }' ],
			post_example = [ 147, 258, 369]
		}";

	// M2M -> Roles
	property
		name								="roles"
		singularName				="role"
		fieldtype						="many-to-many"
		type								="array"
		lazy								="extra"
		cascade							="save-update"
		cacheuse						="read-write"
		cfc									="cbadmin.models.security.Role"
		fkcolumn						="FK_permissionId"
		linktable						="cbadmin_rolePermissions"
		inversejoincolumn		="FK_roleId"
		openapidocs="{
			type = 'array',
			description = 'Array of roles that this permission is assigned to (for POST/PUT/PATCH requests this should be an array of role IDs)',
			get_example = [ '{ role object 1 }', '{ role object 2 }', '{ role object 3 }' ],
			post_example = [ 15, 49, 36 ]
		}";

	/* *********************************************************************
	**							CALCULATED FIELDS
	********************************************************************* */

	// Calculated Fields
	property
		name="numberOfRoles"
		formula="select count(*) from cbadmin_rolePermissions as rolePermissions
			where rolePermissions.FK_permissionId=permissionId"
		openapidocs="{
			type = 'integer',
			description = 'Number of roles to which this permission is assigned',
			example = 5,
			exclude_post = true
		}";

	property
		name="numberOfGroups"
		formula="select count(*) from cbadmin_groupPermissions as groupPermissions
			where groupPermissions.FK_permissionId=permissionId"
		openapidocs="{
			type = 'integer',
			description = 'Number of permission groups to which this permission is assigned',
			example = 8,
			exclude_post = true
		}";

	/* *********************************************************************
	**							PK + CONSTRAINTS
	********************************************************************* */

	this.pk = "permissionId";

	this.constraints = {
		"permission"		= { required = true, size = "1..255", validator = "UniqueValidator@cborm" },
		"description"		= { required = false, size = "1..500" }
	};

	/* *********************************************************************
	**							PUBLIC FUNCITONS
	********************************************************************* */

	/**
	* Constructor
	*/
	function init(){
		super.init();
		return this;
	}

	/**
	* Get memento representation
	*/
	/*
	function getMemento( excludes="" ){
		var pList = listToArray( "permission,description,numberOfRoles,numberOfGroups" );
		var result 	= getBaseMemento( properties=pList, excludes=arguments.excludes );

		return result;
	}
	*/
}