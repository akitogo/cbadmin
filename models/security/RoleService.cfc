/**
* ContentBox - A Modular Content Platform
* Copyright since 2012 by Ortus Solutions, Corp
* www.ortussolutions.com/products/contentbox
* ---
* Roles service for contentbox
*/
component extends="cborm.models.VirtualEntityService" singleton{
	
	// DI
	property name="populator" 			inject="wirebox:populator";
	property name="permissionService" 	inject="permissionService@cbadmin";
	property name="dateUtil"			inject="DateUtil@cbadmin";
	
	/**
	* Constructor
	*/
	RoleService function init(){
		// init it
		super.init(entityName="cbRole" );
		
		return this;
	}
	
	/**
	* Get all data prepared for export
	*/
	array function getAllForExport(){
		var result = [];
		var data = getAll();
		
		for( var thisItem in data ){
			arrayAppend( result, thisItem.getMemento() );	
		}
		
		return result;
	}
	
	/**
	* Import data from a ContentBox JSON file. Returns the import log
	*/
	string function importFromFile(required importFile, boolean override=false){
		var data 		= fileRead( arguments.importFile );
		var importLog 	= createObject( "java", "java.lang.StringBuilder" ).init( "Starting import with override = #arguments.override#...<br>" );
		
		if( !isJSON( data ) ){
			throw(message="Cannot import file as the contents is not JSON", type="InvalidImportFormat" );
		}
		
		// deserialize packet: Should be array of { settingID, name, value }
		return	importFromData( deserializeJSON( data ), arguments.override, importLog );
	}
	
	/**
	* Import data from an array of structures of roles or just one structure of roles 
	*/
	string function importFromData(required importData, boolean override=false, importLog){
		var allRoles = [];
		
		// if struct, inflate into an array
		if( isStruct( arguments.importData ) ){
			arguments.importData = [ arguments.importData ];
		}
		
		// iterate and import
		for( var thisRole in arguments.importData ){
			// Get new or persisted
			var oRole = this.findByRole( thisRole.role );
			oRole = ( isNull( oRole ) ? new() : oRole );
			
			// date cleanups, just in case.
			var badDateRegex  	= " -\d{4}$";
			thisRole.createdDate 	= reReplace( thisRole.createdDate, badDateRegex, "" );
			thisRole.modifiedDate 	= reReplace( thisRole.modifiedDate, badDateRegex, "" );
			// Epoch to Local
			thisRole.createdDate 	= dateUtil.epochToLocal( thisRole.createdDate );
			thisRole.modifiedDate 	= dateUtil.epochToLocal( thisRole.modifiedDate );

			// populate content from data
			populator.populateFromStruct( target=oRole, memento=thisRole, exclude="roleId", composeRelationships=false );
			
			// PERMISSIONS
			if( arrayLen( thisRole.permissions ) ){
				// Create permissions that don't exist first
				var allPermissions = [];
				for( var thisPermission in thisRole.permissions ){
					var oPerm = permissionService.findByPermission( thisPermission.permission );
					oPerm = ( isNull( oPerm ) ? populator.populateFromStruct( target=permissionService.new(), memento=thisPermission, exclude="permissionId" ) : oPerm );	
					// save oPerm if new only
					if( !oPerm.isLoaded() ){ permissionService.save( entity=oPerm ); }
					// append to add.
					arrayAppend( allPermissions, oPerm );
				}
				// detach permissions and re-attach
				oRole.setPermissions( allPermissions );
			}
			
			// if new or persisted with override then save.
			if( !oRole.isLoaded() ){
				arguments.importLog.append( "New role imported: #thisRole.role#<br>" );
				arrayAppend( allRoles, oRole );
			}
			else if( oRole.isLoaded() and arguments.override ){
				arguments.importLog.append( "Persisted role overriden: #thisRole.role#<br>" );
				arrayAppend( allRoles, oRole );
			}
			else{
				arguments.importLog.append( "Skipping persisted role: #thisRole.role#<br>" );
			}
		} // end import loop

		// Save them?
		if( arrayLen( allRoles ) ){
			saveAll( allRoles );
			arguments.importLog.append( "Saved all imported and overriden roles!" );
		}
		else{
			arguments.importLog.append( "No roles imported as none where found or able to be overriden from the import file." );
		}
		
		return arguments.importLog.toString(); 
	}

	/**
	 * Return an array of rule ids which use a specific permissionId
	 */
	function getAllUsingPermissionId(permissionId)
	{
		var r = newCriteria()
			.joinTo('permissions', 'p')
				.eq('p.permissionId', JavaCast('int', permissionId))
			.list();
		var roleIds = r.map(function(item){
			return item.getRoleId();
		});

		return roleIds;
	}

	/**
	 * This method will check that the default 'User' role is present in the database.
	 * If not, the role will be created.
	 */
	RoleService function preFlightCheck()
	{
		var role = this.findWhere( { role : 'User' } );
		if (isNull(role)) {
			var defaultUser = new({
				role: 'User',
				description: 'this is the standard user role'
			});
			save(defaultUser);
		}

		return this;
	}
}