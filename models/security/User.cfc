/**
* ContentBox - A Modular Content Platform
* Copyright since 2012 by Ortus Solutions, Corp
* www.ortussolutions.com/products/contentbox
* ---
* I am a ContentBox User/Author entity
*/
component
	persistent	="true"
	entityName	="cbUser"
	table				="cbadmin_user"
	extends			="cbadmin.models.BaseEntity"
	cachename		="cbUser"
	cacheuse		="read-write"
	batchsize		="25"
{
	this.memento = {
		defaultIncludes = [ "*" ]
		, defaultExcludes = [ "password", "permissions", "permissionGroups.users", "permissionGroups.permissions", "role.permissions" ]
	};

	// DI
	property name="UserService" inject="UserService@cbadmin" persistent="false";

	/* *********************************************************************
	**							PROPERTIES
	********************************************************************* */

	property
		name					="userId"
		fieldtype			="id"
		generator			="native"
		setter				="false"
		params				="{ allocationSize = 1, sequence = 'userId_seq' }"
		openapidocs		="{
			type = 'integer',
			description = 'ID of the user (this field is required for PUT/PATCH requests)',
			example = '18364',
			exclude_post = true
		}";

	property
		name					="firstName"
		length				="100"
		notnull				="true"
		default				=""
		openapidocs		="{
			type = 'string',
			description = 'First name of the user',
			example = 'John'
		}";

	property
		name					="lastName"
		length				="100"
		notnull				="true"
		default				=""
		openapidocs		="{
			type = 'string',
			description = 'Last name of the user',
			example = 'Doe'
		}";

	property
		name					="email"
		length				="255"
		notnull				="true"
		index					="idx_email"
		default				=""
		openapidocs		="{
			type = 'string',
			description = 'E-mail address of the user',
			example = 'email@example.com'
		}";

	property
		name					="username"
		length				="100"
		notnull				="true"
		index					="idx_login"
		unique				="true"
		default				=""
		openapidocs		="{
			type = 'string',
			description = 'Username of the user. This is used for logging in',
			example = 'akiuser'
		}";

	// password is excluded from Memento
	property
		name				="password"
		length			="100"
		notnull			="true"
		index				="idx_login"
		default			="";

	property
		name					="isActive"
		ormtype				="boolean"
		notnull				="true"
		default				="false"
		index					="idx_login,idx_activeAuthor"
		openapidocs		="{
			type = 'boolean',
			description = 'Flag marking if a user is active. Inactive users won\'t be able to log in',
			example = true
		}";

	property
		name					="lastLogin"
		ormtype				="timestamp"
		notnull				="false"
		openapidocs		="{
			type = 'string',
			description = 'Date and time of the last log in',
			example = '2021-10-50 15:12:22',
			exclude_post = true
		}";

	property
		name					="preferences"
		ormtype				="text"
		notnull				="false"
		length				="8000"
		default				=""
		openapidocs		="{
			type = 'string',
			description = 'Custom user preferences stored in JSON format',
			example = '{\'color\':\'red\',\'car\':\'mercedes\'}'
		}";

	property
		name					="isPasswordReset"
		ormtype				="boolean"
		notnull				="true"
		default				="false"
		dbdefault			="0"
		index					="idx_passwordReset"
		openapidocs		="{
			type = 'boolean',
			description = 'Flag indicating that the user is resetting their password',
			example = false
		}";

	property
		name					="is2FactorAuth"
		ormtype				="boolean"
		notnull				="true"
		default				="false"
		dbdefault			="0"
		index					="idx_2factorauth"
		openapidocs		="{
			type = 'boolean',
			description = 'Flag indicating if the user account uses two factor authentication',
			example = false
		}";

	/* *********************************************************************
	**							RELATIONSHIPS
	********************************************************************* */

	// M2O -> Role
	property
		name							= "role"
		notnull 					= "false"
		fieldtype					= "many-to-one"
		//cascade						= "save-update"
		cfc								= "cbadmin.models.security.Role"
		fkcolumn					= "FK_roleId"
		lazy							= "true"
		openapidocs				= "{
			type = 'string',
			description = 'Role object which is assigned to this user (for POST/PUT/PATCH requests this should be a struct with a roleId field)',
			get_example = '{ role object }',
			post_example = '{ \'roleId\':some_role_id }'
		}";
		//missingrowIgnored	= "true";

	// direct permissions are excluded from Memento (use roles and permission groups instead)
	// M2M -> A-la-carte Author Permissions
	property
		name							= "permissions"
		singularName			= "permission"
		fieldtype					= "many-to-many"
		cascade						= "save-update"
		type							= "array"
		lazy							= "extra"
		cfc								= "cbadmin.models.security.Permission"
		fkcolumn					= "FK_userId"
		linktable					= "cbadmin_userPermissions"
		inversejoincolumn	= "FK_permissionId"
		orderby						= "permission";

	// M2M -> A-la-carte Author Permission Groups
	property
		name							= "permissionGroups"
		singularName			= "permissionGroup"
		fieldtype					= "many-to-many"
		type							= "array"
		lazy							= "extra"
		inverse						= "true"
		cfc								= "cbadmin.models.security.PermissionGroup"
		cascade						= "save-update"
		fkcolumn					= "FK_userId"
		linktable					= "cbadmin_userPermissionGroups"
		inversejoincolumn	= "FK_permissionGroupId"
		orderby						= "name"
		openapidocs				= "{
			type = 'array',
			description = 'Array of permission groups that are assigned to this user (for POST/PUT/PATCH requests this should be an array of permission group IDs)',
			get_example = [ '{ permission group object 1 }', '{ permission group object 2 }', '{ permission group object 3 }' ],
			post_example = [ 15, 49, 36 ]
		}";

	// M2O -> Language
	property
		name							= "language"
		//notnull						="true"
		fieldtype					= "many-to-one"
		cfc								= "cbadmin.models.system.CfgLanguage"
		fkcolumn					= "FK_LanguageId"
		lazy							= "true"
		openapidocs				= "{
			type = 'string',
			description = 'Language of the user unterface. GET requests return the language object, for POST/PUT/PATCH requests this should be a struct with a languageId field)',
			get_example = '{ language object }',
			post_example = '{ \'languageId\':some_language_id }'
		}";

	/* *********************************************************************
	**							NON PERSISTED PROPERTIES
	********************************************************************* */

	// Non-persisted properties
	property
		name							= "loggedIn"
		persistent				= "false"
		default						= "false"
		type							= "boolean"
		openapidocs				= "{
			type = 'boolean',
			description = 'Flag showing if the user is currently logged in',
			example = true,
			exclude_post = true
		}";

	property
		name							= "permissionList"
		persistent				= "false"
		openapidocs				= "{
			type = 'string',
			description = 'List of permissions of this user',
			exclude_post = true
		}";

	/* *********************************************************************
	**							PK + CONSTRAINTS
	********************************************************************* */

	this.pk = "userId";

	this.constraints ={
		"firstName"= { required=true, size="1..100" },
		"lastName" = { required=true, size="1..100" },
		"email"    = { required=true, size="1..255", type="email" },
		"username" = { required=true, size="1..100", validator: "UniqueValidator@cborm" },
		"password" = { required=true, size="1..100" }
	};

	/* *********************************************************************
	**							PUBLIC FUNCTIONS
	********************************************************************* */

	/**
	* Constructor
	*/
	function init(){
		variables.permissionList  = "";
		variables.loggedIn        = false;
		variables.isActive        = true;
		variables.permissionGroups= [];
		variables.isPasswordReset = false;
		variables.is2FactorAuth   = false;

		// Setup empty preferences
		setPreferences( {} );

		super.init();

		return this;
	}

	/**
	* Listen to postLoad's from the ORM
	*/
	function postLoad(){
	}

	/**
	* Check for permission
	* @slug The permission slug or list of slugs to validate the user has. If it's a list then they are ORed together
	*/
	boolean function checkPermission( required slug ){
		// cache permission list
		if( !len( permissionList ) AND hasPermission() ){
			var q          = entityToQuery( getPermissions() );
			permissionList = valueList( q.permission );
		}

		// checks via role, then group permissions and then local permissions
		if(
			( hasRole() && getRole().checkPermission( arguments.slug ) )
			OR
			checkGroupPermissions( arguments.slug )
			OR
			inPermissionList( arguments.slug )
		){
			return true;
		}

		return false;
	}

	/**
	* This utility function checks if a slug is in any permission group this user belongs to.
	* @slug The slug to check
	*/
	boolean function checkGroupPermissions( required slug ){
		// If no groups, just return false
		if( !hasPermissionGroup() ){
			return false;
		}

		// iterate and check, break if found, short-circuit approach.
		for( var thisGroup in variables.permissionGroups ){
			if( thisGroup.checkPermission( arguments.slug ) ){
				return true;
			}
		}
		// nada found
		return false;
	}

	/**
	* Verify that a passed in list of perms the user can use
	*/
	public function inPermissionList( required list ){
		var aList   = listToArray( arguments.list );
		var isFound = false;

		for( var thisPerm in aList ){
			if( listFindNoCase( permissionList, trim( thisPerm ) ) ){
				isFound = true;
				break;
			}
		}

		return isFound;
	}

	/**
	* Clear all permissions
	*/
	User function clearPermissions(){
		permissions = [];
		return this;
	}

	/**
	* Override the setPermissions
	* @permissions The permissions array to override
	*/
	User function setPermissions( required array permissions ){
		if( hasPermission() ){
			variables.permissions.clear();
			variables.permissions.addAll( arguments.permissions );
		} else {
			variables.permissions = arguments.permissions;
		}
		return this;
	}

	/**
	* Shortcut Utlity function to get a list of all the permission groups this user belongs to.
	*/
	string function getPermissionGroupsList( delimiter = "," ){
		if( hasPermissionGroup() ){
			var aGroups = [];
			for( var thisGroup in variables.permissionGroups ){
				arrayAppend( aGroups, thisGroup.getName() );
			}
			return arrayToList( aGroups, arguments.delimiter );
		}
		return "";
	}
	/**
	 * Add both sides of this relationship: PermissionGroup <-> Author
	 *
	 * @group Full list of permission groups to merge
	 */
	User function updatePermissionGroups( required array groups ){
		// if has groups and update has no groups
		// then remove all existing groups
		if (arrayLen(variables.permissionGroups) && !arrayLen(arguments.groups)){
			for (var g in variables.permissionGroups) {
				removePermissionGroup(g);
			}
			return this;
		}
		// add groups from arguments
		for (var g in arguments.groups) {
			addPermissionGroup(g);
		}

		for (var g in variables.permissionGroups) {
			var found = false;
			for (var newGroup in arguments.groups) {
				if (newGroup.getpermissionGroupId() == g.getpermissionGroupId() ){
					found = true;
					break;
				}
			}
			// if group doesn't exist in updated groups list
			// then remove
			if(!found)
				removePermissionGroup(g);
		}

		return this;
	}

	/**
	 * Add both sides of this relationship: PermissionGroup <-> Author
	 *
	 * @group The permission group to add
	 */
	User function addPermissionGroup( required group ){
		// Only add if not already there.
		if ( !hasPermissionGroup( arguments.group ) ){
			arrayAppend( variables.permissionGroups, arguments.group );
			arguments.group.addUser( this );
		}
		return this;
	}

	/**
	 * Remove both sides of this relationship: PermissionGroup <-> Author
	 *
	 * @group The permission group to add
	 */
	User function removePermissionGroup( required group ){
		// Only remove if there.
		if ( hasPermissionGroup( arguments.group ) ){
			arrayDelete( variables.permissionGroups, arguments.group );
			arguments.group.removeUser( this );
		}
		return this;
	}

	/**
	* Utility method to verify if an author has been logged in to the system or not.
	* This method does not account for permissions.  Only for logged in status.
	*/
	function isLoggedIn(){
		return getLoggedIn();
	}

	/**
	* Retrieve user id (needed by cbsecurity).
	*/
	function getId()
	{
		return getUserId();
	}

	/**
	* Retrieve full name
	*/
	string function getName(){
		return getFirstName() & " " & getLastName();
	}

	/**
	* Get a flat representation of this entry
	* @excludes 			Exclude properties, by default it does pages and entries
	* @showRole 			Show Roles
	* @showPermissions 		Show permissions
	* @showPermissionGroups Show permission groups
	*/
/*
	function getMemento(
		excludes                    ="",
		boolean showRole            =true,
		boolean showPermissions     =true,
		boolean showPermissionGroups=true
	){
		// Do this to convert native Array to CF Array for content properties
		var pList  = listToArray( arrayToList( userService.getPropertyNames() ) );
		var result = getBaseMemento( properties=pList, excludes=arguments.excludes );

		// Do Role Relationship
		if( arguments.showRole && hasRole() ){
			result[ "role" ] = getRole().getMemento();
		}

		// Permissions
		if( arguments.showPermissions && hasPermission() ){
			result[ "permissions" ] = [];
			for( var thisPerm in variables.permissions ){
				arrayAppend( result[ "permissions" ], thisPerm.getMemento() );
			}
		} else if( arguments.showPermissions ) {
			result[ "permissions" ] = [];
		}

		// Permission Groups
		if( arguments.showPermissionGroups && hasPermissionGroup() ){
			result[ "permissiongroups" ] = [];
			for( var thisGroup in variables.permissiongroups ){
				arrayAppend( result[ "permissiongroups" ], thisGroup.getMemento() );
			}
		} else if( arguments.showPermissionGroups ) {
			result[ "permissiongroups" ] = [];
		}

		return result;
	}
*/
	/**
	* Required for jwt tokens.
	*/
	array function getJwtScopes()
	{
		return [];
	}

	/**
	* Required for jwt tokens.
	*/
	struct function getJwtCustomClaims()
	{
		// todo: check which fields are really required here
		return getMemento();
	}
	/************************************** PREFERENCE FUNCTIONS *********************************************/

	/**
	* Store a preferences structure or JSON data in the user prefernces
	* @preferences.hint A struct of data or a JSON packet to store
	*/
	User function setPreferences(required any preferences){
		lock name="user.#getUserID()#.preferences" type="exclusive" throwontimeout="true" timeout="5"{
			if( isStruct( arguments.preferences ) ){
				arguments.preferences = serializeJSON( arguments.preferences );
			}
			// store as JSON
			variables.preferences = arguments.preferences;
		}
		return this;
	}

	/**
	* Get all user preferences in inflated format
	*/
	struct function getAllPreferences(){
		lock name="user.#getUserID()#.preferences" type="readonly" throwontimeout="true" timeout="5"{
			return ( !isNull( preferences ) AND isJSON( preferences ) ? deserializeJSON( preferences ) : structnew() );
		}
	}

	/**
	* Get a preference, you can pass a default value if preference does not exist
	*/
	any function getPreference(required name, defaultValue){
		// get preference
		lock name="user.#getUserID()#.preferences" type="readonly" throwontimeout="true" timeout="5"{
			var allPreferences = getAllPreferences();
			if( structKeyExists( allPreferences, arguments.name ) ){
				return allPreferences[ arguments.name ];
			}
		}
		// default values
		if( structKeyExists( arguments, "defaultValue" ) ){
			return arguments.defaultValue;
		}
		// exception
		throw(message="The preference you requested (#arguments.name#) does not exist",
			  type  ="User.PreferenceNotFound",
			  detail="Valid preferences are #structKeyList( allPreferences )#" );
	}

	/**
	* Set a preference in the user preferences
	*/
	User function setPreference(required name, required value){
		var allPreferences               = getAllPreferences();
		allPreferences[ arguments.name ] = arguments.value;
		// store in lock mode
		return setPreferences( allPreferences );
	}

}