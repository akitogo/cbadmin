/**
 * ContentBox - A Modular Content Platform
 * Copyright since 2012 by Ortus Solutions, Corp
 * www.ortussolutions.com/products/contentbox
 * ---
 * Setting Service for ContentBox apps.
 * All settings are cached as a struct constructed using the following format:
 * - global : { name : value } // global settings
 */
component
	extends  ="cborm.models.VirtualEntityService"
	accessors="true"
	threadsafe
	singleton
{

	// DI properties
	property name="cachebox" inject="cachebox";
	property name="moduleSettings" inject="coldbox:setting:modules";
	property name="appMapping" inject="coldbox:setting:appMapping";
	property name="requestService" inject="coldbox:requestService";
	property name="coldbox" inject="coldbox";
	property name="dateUtil" inject="DateUtil@cbadmin";
	property name="log" inject="logbox:logger:{this}";

	/**
	 * The cache provider name to use for settings caching. Defaults to 'template' cache.
	 * This can also be set in the global ContentBox settings page to any CacheBox cache.
	 */
	property name="cacheProviderName" default="template";

	/**
	 * Bit that detects if CB has been installed or not
	 */
	property
		name   ="CBReadyFlag"
		default="false"
		type   ="boolean";

	// Global Setting Defaults
	this.DEFAULTS = {
		// Installation security salt
		"cbadmin_salt"                              : hash( createUUID() & getTickCount() & now(), "SHA-512" ),
		// Global Notifications
		"cbadmin_notify_author"                     : "true",
		"cbadmin_notify_entry"                      : "true",
		"cbadmin_notify_page"                       : "true",
		"cbadmin_notify_contentstore"               : "true",
		// Outgoing email
		// Blog Entry Point
		// Security Settings
		"cbadmin_security_min_password_length"      : "8",
		"cbadmin_security_login_blocker"            : "true",
		"cbadmin_security_max_attempts"             : "5",
		"cbadmin_security_blocktime"                : "5",
		"cbadmin_security_max_auth_logs"            : "500",
		"cbadmin_security_latest_logins"            : "10",
		"cbadmin_security_rate_limiter"             : "true",
		"cbadmin_security_rate_limiter_logging"     : "true",
		"cbadmin_security_rate_limiter_count"       : "4",
		"cbadmin_security_rate_limiter_duration"    : "1",
		"cbadmin_security_rate_limiter_bots_only"   : "true",
		"cbadmin_security_rate_limiter_message"     : "<p>You are making too many requests too fast, please slow down and wait {duration} seconds</p>",
		"cbadmin_security_rate_limiter_redirectURL" : "",
		"cbadmin_security_2factorAuth_force"        : "false",
		"cbadmin_security_2factorAuth_provider"     : "email",
		"cbadmin_security_2factorAuth_trusted_days" : "30",
		"cbadmin_security_login_signout_url"        : "",
		"cbadmin_security_login_signin_text"        : "",
		// Admin settings
		"cbadmin_admin_ssl"                         : "false",
		"cbadmin_admin_quicksearch_max"             : "5",
		"cbadmin_admin_theme"                       : "contentbox-default",
		// Paging Defaults
		"cbadmin_paging_maxrows"                    : "20",
		"cbadmin_paging_bandgap"                    : "5",
		"cbadmin_paging_maxentries"                 : "10",
		"cbadmin_paging_maxRSSComments"             : "10",
		// Gravatar
		"cbadmin_gravatar_display"                  : "true",
		"cbadmin_gravatar_rating"                   : "PG",

		// Editor Manager
		// Search Settings
		"cbadmin_search_adapter"                : "contentbox.models.search.DBSearch",
		"cbadmin_search_maxResults"             : "20",
		// Site Maintenance
		// Versioning
		"cbadmin_versions_max_history"          : "",
		"cbadmin_versions_commit_mandatory"     : "false"
	};

	// Site Defaults
	this.SITE_DEFAULTS = {
		// Global HTML: Panel Section
		"cbadmin_html_beforeHeadEnd"         : "",
		"cbadmin_html_afterBodyStart"        : "",
		"cbadmin_html_beforeBodyEnd"         : "",
		"cbadmin_html_beforeContent"         : "",
		"cbadmin_html_afterContent"          : "",
		"cbadmin_html_beforeSideBar"         : "",
		"cbadmin_html_afterSideBar"          : "",
		"cbadmin_html_afterFooter"           : "",
		"cbadmin_html_preEntryDisplay"       : "",
		"cbadmin_html_postEntryDisplay"      : "",
		"cbadmin_html_preIndexDisplay"       : "",
		"cbadmin_html_postIndexDisplay"      : "",
		"cbadmin_html_preArchivesDisplay"    : "",
		"cbadmin_html_postArchivesDisplay"   : "",
		"cbadmin_html_preCommentForm"        : "",
		"cbadmin_html_postCommentForm"       : "",
		"cbadmin_html_prePageDisplay"        : "",
		"cbadmin_html_postPageDisplay"       : "",
		// Site Comment Settings
		"cbadmin_comments_maxDisplayChars"   : "500",
		"cbadmin_comments_enabled"           : "true",
		"cbadmin_comments_urltranslations"   : "true",
		"cbadmin_comments_notify"            : "true",
		"cbadmin_comments_moderation_notify" : "true",
		"cbadmin_comments_notifyemails"      : ""
	};

	/**
	 * Constructor
	 */
	SettingService function init(){
		variables.oSystem     		= createObject( "java", "java.lang.System" );
		variables.CBReadyFlag 		= false;
		variables.cacheProviderName = "template";

		// init it
		super.init( entityName = "cbSetting" );

		return this;
	}

	/**
	 * This method will go over all system settings and make sure that there are no missing default core settings.
	 * If they are, we will create the core settings with the appropriate defaults: this.DEFAULTS
	 */
	SettingService function preFlightCheck(){
		var missingSettings = false;

		// Iterate over default core settings and check they exist
		lock
			name              ="contentbox-pre-flight",
			timeout           = "10"
			throwOnTimeout    ="true"
			type              ="exclusive" {
			var loadedSettings= getAllSettings( force: true );

			transaction {
				this.DEFAULTS
					// only load defaults that do not exist
					.filter( function( key, value ){
						return !loadedSettings.keyExists( key );
					} )
					// Create the missing setting
					.each( function( key, value ){
						log.info( "Missing setting in pre-flight: #key#, adding it!" );
						missingSettings = true;
						save( new ( { name : key, value : trim( value ), isCore : true } ) );
					} );
			}

			// if we added new ones, flush caches
			if ( missingSettings ) {
				flushSettingsCache();
			}
		}

		log.info( "ContentBox Global Settings pre-flight checks passed!" );

		// load cache provider now that everyting is pre-flighted
		loadCacheProviderName();

		return this;
	}

	/**
	 * Get Real IP, by looking at clustered, proxy headers and locally.
	 */
	function getRealIP(){
		var headers = getHTTPRequestData().headers;

		// Very balanced headers
		if ( structKeyExists( headers, "x-cluster-client-ip" ) ) {
			return headers[ "x-cluster-client-ip" ];
		}
		if ( structKeyExists( headers, "X-Forwarded-For" ) ) {
			return headers[ "X-Forwarded-For" ];
		}

		return len( cgi.remote_addr ) ? cgi.remote_addr : "127.0.0.1";
	}

	/**
	 * Retrieve a multi-tenant settings cache key
	 */
	string function getSettingsCacheKey(){
		return "cb-settings-#CGI.SERVER_NAME#";
	}

	/**
	 * Check if the installer and dsn creator modules are present
	 */
	struct function isInstallationPresent(){
		var results = { installer : false, dsncreator : false };

		if (
			structKeyExists( moduleSettings, "contentbox-installer" ) AND
			directoryExists( moduleSettings[ "contentbox-installer" ].path )
		) {
			results.installer = true;
		}

		if (
			structKeyExists( moduleSettings, "contentbox-dsncreator" ) AND
			directoryExists( moduleSettings[ "contentbox-dsncreator" ].path )
		) {
			results.dsncreator = true;
		}

		return results;
	}

	/**
	 * Delete the installer module
	 */
	boolean function deleteInstaller(){
		if (
			structKeyExists( moduleSettings, "contentbox-installer" ) AND
			directoryExists( moduleSettings[ "contentbox-installer" ].path )
		) {
			directoryDelete( moduleSettings[ "contentbox-installer" ].path, true );
			return true;
		}
		return false;
	}

	/**
	 * Delete the dsn creator module
	 */
	boolean function deleteDSNCreator(){
		if (
			structKeyExists( moduleSettings, "contentbox-dsncreator" ) AND
			directoryExists( moduleSettings[ "contentbox-dsncreator" ].path )
		) {
			directoryDelete( moduleSettings[ "contentbox-dsncreator" ].path, true );
			return true;
		}
		return false;
	}

	/**
	 * Check if contentbox has been installed by checking if there are no settings and no cbadmin_active ONLY
	 * If the query comes back with active, it will not run it again.
	 */
	boolean function isCBReady(){
		// Short circuit caching
		if ( variables.CBReadyFlag ) {
			return true;
		}
		try {
			// Not active yet, discover it
			var thisCount = newCriteria().isEq( "name", "cbadmin_active" ).count();

			// Store it
			if ( thisCount > 0 ) {
				variables.CBReadyFlag = true;
			}

			return ( thisCount > 0 ? true : false );

		} catch (any e) {

		}
		return false;
	}

	/**
	 * Mark cb as ready to serve
	 */
	SettingService function activateCB(){
		save( this.new( { name : "cbadmin_active", value : "true" } ) );
		return this;
	}

	/**
	 * Get a global setting
	 *
	 * @name The name of the seting
	 * @defaultValue The default value if setting not found.
	 *
	 * @throws SettingNotFoundException
	 * @return The setting value or default value if not found
	 */
	function getSetting( required name, defaultValue ){
		var allSettings = getAllSettings();

		// verify it exists
		if ( structKeyExists( allSettings, arguments.name ) ) {
			return allSettings[ arguments.name ];
		}

		// default value
		if ( !isNull( arguments.defaultValue ) ) {
			return arguments.defaultValue;
		}

		// nothing we can do
		throw(
			message: "Setting #arguments.name# not found in settings collection",
			detail : "Registered settings are: #structKeyList( allSettings )#",
			type   : "SettingNotFoundException"
		);
	}

	/**
	 * Get all global settings
	 *
	 * @force To force clear the cache
	 */
	struct function getAllSettings( boolean force = false ){
		return getSettingsContainer( arguments.force ).global;
	}

	/**
	 * Get the entire settings container from cache or build it out.
	 *
	 * @force Force build
	 */
	struct function getSettingsContainer( boolean force = false ){
		// Force Clear
		if ( arguments.force ) {
			flushSettingsCache();
		}
		// Get or set
		return getSettingsCacheProvider().getOrSet(
			getSettingsCacheKey(),
			function(){
				log.info( "Settings container not cached, rebuilding from DB!" );
				return buildSettingsContainer();
			},
			7200
		);
	}


	/**
	 * Build out a settings container by global 
	 *
	 * @return struct of { global : {} }
	 */
	struct function buildSettingsContainer(){
		var container = { "global" : {} };


		// Populate containers
		newCriteria()
			.isFalse( "isDeleted" )
			.list( sortOrder = "name" )
			.each( function( item ){
					container.global[ item.getName() ] = item.getValue();
			} );

		return container;
	}

	/**
	 * This will store the incoming structure as the settings in cache.
	 * Usually this method is used for major overrides.
	 */
	SettingService function storeSettings( struct settings ){
		// cache them for 5 days, usually app timeout
		getSettingsCacheProvider().set(
			getSettingsCacheKey(),
			arguments.settings,
			7200
		);
		return this;
	}

	/**
	 * flush settings cache for current multi-tenant host
	 */
	SettingService function flushSettingsCache(){
		// Info
		log.info( "Settings Flush Executed!" );
		// Clear out the settings cache
		getSettingsCacheProvider().clear( getSettingsCacheKey() );
		// Re-load cache provider name, in case user changed it
		loadCacheProviderName();
		// Loadup Config Overrides
		loadConfigOverrides();
		// Load Environment Overrides Now, they take precedence
		loadEnvironmentOverrides();
		return this;
	}

	/**
	 * Bulk saving of options using a memento structure of options
	 * This is usually done from the settings display manager
	 *
	 * @memento The struct of settings
	 * @site Optional site to attach the settings to
	 *
	 * @return SettingService
	 */
	SettingService function bulkSave( struct memento ){
		var settings = getAllSettings();
		var newSettings = [];

		arguments.memento
			// Only save, saveable keys
			.filter( function( key, value ){
				return settings.keyExists( key );
			} )
			// Build out array of settings to save
			.each( function( key, value ){
				var thisSetting = findWhere( { name : key } );

				// Maybe it's a new setting :)
				if ( isNull( thisSetting ) ) {
					thisSetting = new ( { name : key } );
				}

				thisSetting.setValue( toString( value ) );

				newSettings.append( thisSetting );
			} );

		// save new settings and flush cache
		saveAll( newSettings );
		flushSettingsCache();

		return this;
	}

	/**
	 * Build file browser settings structure so you can execute multiple containers
	 *
	 * @return struct
	 */
	struct function buildFileBrowserSettings(){
		var cbSettings = getAllSettings();
		var settings   = {
			directoryRoot   : expandPath( cbSettings.cbadmin_media_directoryRoot ),
			createFolders   : cbSettings.cbadmin_media_createFolders,
			deleteStuff     : cbSettings.cbadmin_media_allowDelete,
			allowDownload   : cbSettings.cbadmin_media_allowDownloads,
			allowUploads    : cbSettings.cbadmin_media_allowUploads,
			acceptMimeTypes : cbSettings.cbadmin_media_acceptMimeTypes,
			quickViewWidth  : cbSettings.cbadmin_media_quickViewWidth,
			loadJQuery      : false,
			useMediaPath    : true,
			html5uploads    : {
				maxFileSize : cbSettings.cbadmin_media_html5uploads_maxFileSize,
				maxFiles    : cbSettings.cbadmin_media_html5uploads_maxFiles
			}
		};

		// Base MediaPath
		var mediaPath = "";
		// I don't think this is needed anymore. As we use build link for everything.
		// var mediaPath = ( len( AppMapping ) ? AppMapping : "" ) & "/";
		// if( findNoCase( "index.cfm", requestService.getContext().getSESBaseURL() ) ){
		// mediaPath = "index.cfm" & mediaPath;
		// }

		// add the entry point
		var entryPoint = moduleSettings[ "contentbox-ui" ].entryPoint;
		mediaPath &= ( len( entryPoint ) ? "#entryPoint#/" : "" ) & "__media";
		// Store it
		mediaPath          = ( left( mediaPath, 1 ) == "/" ? mediaPath : "/" & mediaPath );
		settings.mediaPath = mediaPath;

		return settings;
	}

	/**
	 * Setting search with filters
	 *
	 * @search The search term for the name
	 * @max The max records
	 * @offset The offset to tuse
	 * @sortOrder The sort order
	 *
	 * @return struct of { count, settings }
	 */
	struct function search(
		search    = "",
		max       = 0,
		offset    = 0,
		sortOrder = "name asc",
	){
		var results = { "count" : 0, "settings" : [] };
		var c       = newCriteria();

		// Search Criteria
		if ( len( arguments.search ) ) {
			c.like( "name", "%#arguments.search#%" );
		}


		// run criteria query and projections count
		results.count    = c.count( "settingID" );
		results.settings = c
			.resultTransformer( c.DISTINCT_ROOT_ENTITY )
			.list(
				offset   : arguments.offset,
				max      : arguments.max,
				sortOrder: arguments.sortOrder,
				asQuery  : false
			);

		return results;
	}

	/**
	 * Get all data prepared for export
	 */
	array function getAllForExport(){
		return newCriteria()
			.withProjections(
				property = "settingID,name,value,createdDate,modifiedDate,isDeleted,isCore"
			)
			.asStruct()
			.list( sortOrder = "name" );
	}

	/**
	 * Import data from a ContentBox JSON file. Returns the import log
	 *
	 * @importFile The import file location
	 * @override Are we override previous values or not
	 *
	 * @return The import log
	 */
	string function importFromFile( required importFile, boolean override = false ){
		var data      = fileRead( arguments.importFile );
		var importLog = createObject( "java", "java.lang.StringBuilder" ).init(
			"Starting import with override = #arguments.override#...<br>"
		);

		if ( !isJSON( data ) ) {
			throw(
				message = "Cannot import file as the contents is not JSON",
				type    = "InvalidImportFormat"
			);
		}

		// deserialize packet: Should be array of { settingID, name, value }
		return importFromData(
			deserializeJSON( data ),
			arguments.override,
			importLog
		);
	}

	/**
	 * Import data from an array of structures of settings
	 */
	string function importFromData(
		required importData,
		boolean override = false,
		importLog
	){
		var allSettings = [];

		// iterate and import
		for ( var thisSetting in arguments.importData ) {
			var args     = { name : thisSetting.name };
			var oSetting = findWhere( criteria = args );

			// date cleanups, just in case.
			var badDateRegex         = " -\d{4}$";
			thisSetting.createdDate  = reReplace( thisSetting.createdDate, badDateRegex, "" );
			thisSetting.modifiedDate = reReplace( thisSetting.modifiedDate, badDateRegex, "" );
			// Epoch to Local
			thisSetting.createdDate  = dateUtil.epochToLocal( thisSetting.createdDate );
			thisSetting.modifiedDate = dateUtil.epochToLocal( thisSetting.modifiedDate );

			// if null, then create it
			if ( isNull( oSetting ) ) {
				oSetting = this.new( {
					name         : thisSetting.name,
					value        : javacast( "string", thisSetting.value ),
					createdDate  : thisSetting.createdDate,
					modifiedDate : thisSetting.modifiedDate,
					isDeleted    : thisSetting.isDeleted,
					isCore       : ( isNull( thisSetting.isCore ) ? false : thisSetting.isCore )
				} );

				arrayAppend( allSettings, oSetting );

				// logs
				importLog.append( "New setting imported: #thisSetting.name#<br>" );
			}
			// else only override if true
			else if ( arguments.override ) {
				oSetting.setValue( javacast( "string", thisSetting.value ) );
				oSetting.setIsDeleted( thisSetting.isDeleted );
				oSetting.setIsCore( thisSetting.isCore );


				arrayAppend( allSettings, oSetting );
				importLog.append( "Overriding setting: #thisSetting.name#<br>" );
			} else {
				importLog.append( "Skipping setting: #thisSetting.name#<br>" );
			}
		}

		// Save them?
		if ( arrayLen( allSettings ) ) {
			saveAll( allSettings );
			importLog.append( "Saved all imported and overriden settings!" );
		} else {
			importLog.append(
				"No settings imported as none where found or able to be overriden from the import file."
			);
		}

		return importLog.toString();
	}

	/**
	 * Get the cache provider object to be used for settings
	 * @return coldbox.system.cache.ICacheProvider
	 */
	function getSettingsCacheProvider(){
		// Return the cache to use
		return cacheBox.getCache( variables.cacheProviderName );
	}

	/**
	 * Load up config overrides
	 */
	function loadConfigOverrides(){
		var oConfig       = coldbox.getSetting( "ColdBoxConfig" );
		var configStruct  = coldbox.getConfigSettings();
		var contentboxDSL = oConfig.getPropertyMixin( "contentbox", "variables", structNew() );

		// Global Settings
		if (
			structKeyExists( contentboxDSL, "settings" )
			&&
			structKeyExists( contentboxDSL.settings, "global" )
		) {
			var settingsContainer = getSettingsContainer();

			// Append and override
			structAppend(
				settingsContainer.global,
				contentboxDSL.settings.global,
				true
			);

			// Store them back in
			storeSettings( settingsContainer );

			// Log it
			variables.log.info(
				"ContentBox global config overrides loaded.",
				contentboxDSL.settings.global
			);
		}

	}

	/**
	 * Load up java environment overrides for ContentBox settings
	 * The pattern to look is `contentbox.{site}.{setting}`
	 * Example: contentbox.default.cbadmin_media_directoryRoot
	 */
	function loadEnvironmentOverrides(){
		var environmentSettings = variables.oSystem.getEnv();
		var overrides           = {};

		// iterate and override
		for ( var thisKey in environmentSettings ) {
			if ( reFindNoCase( "^contentbox\_", thisKey ) ) {
				overrides[ reReplaceNoCase( thisKey, "^contentbox\_", "" ) ] = environmentSettings[
					thisKey
				];
			}
		}

		// If empty, exit out.
		if ( structIsEmpty( overrides ) ) {
			return;
		}

		// Append and override
		var settingsContainer = getSettingsContainer();

		// Append and override
		structAppend( settingsContainer.global, overrides, true );

		// Store them back in
		storeSettings( settingsContainer );

		// Log it
		variables.log.info( "ContentBox environment overrides loaded.", overrides );
	}

	/******************************** PRIVATE ************************************************/

	/**
	 * Load the cache provider name from DB or default value
	 */
	private SettingService function loadCacheProviderName(){
			// default cache provider name
			variables.cacheProviderName = "template";
		return this;
	}

}
