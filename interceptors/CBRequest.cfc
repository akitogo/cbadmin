/**
 * ContentBox - A Modular Content Platform
 * Copyright since 2012 by Ortus Solutions, Corp
 * www.ortussolutions.com/products/contentbox
 * ---
 * This simulates the onRequest start for the admin interface
 */
component extends="coldbox.system.Interceptor"{

	// DI
	property name="securityService"  inject="securityService@cbadmin";
	property name="settingService"   inject="settingService@cbadmin";
	property name="adminMenuService" inject="adminMenuService@cbadmin";

	/**
	 * Configure CB Request
	 */
	function configure(){
	}

	/**
	 * Fired on contentbox requests
	 */
	function preProcess( event, data, rc, prc ){


		/************************************** SETUP CONTEXT REQUEST *********************************************/

		// store module root
		prc.cbRoot                  = getContextRoot() & event.getModuleRoot( "cbadmin" );
		// cb helper
		prc.CBHelper                = getInstance( "CBHelper@cbadmin" );
		// store admin module entry point
		prc.cbAdminEntryPoint       = getModuleConfig( "cbadmin" ).entryPoint;
		// store site entry point
		prc.cbEntryPoint            = getModuleConfig( "cbadmin" ).entryPoint;
		// store filebrowser entry point
		prc.cbFileBrowserEntryPoint = getModuleConfig( "cbadmin" ).entryPoint;
		// Place user in prc
		prc.oUser          = securityService.getUserSession();
		// Place all settings in prc for usage by the UI switcher
		// Place global cb options on scope
		prc.cbSettings              = settingService.getAllSettings();
		// Place widgets root location
		// store admin menu service
		prc.adminMenuService        = adminMenuService;
		// Sidemenu collapsed
		prc.sideMenuClass           = "";
		// Is sidemenu collapsed for user?
		if( prc.oUser.getPreference( "sidemenuCollapse", false ) == "true" ){
			prc.sideMenuClass = "sidebar-mini";
		}

		/************************************** FORCE SSL *********************************************/


		/************************************** FORCE PASSWORD RESET *********************************************/

		if(
			!findNoCase( "contentbox-security:security", event.getCurrentEvent() )
			&&
			prc.oUser.getIsPasswordReset()
		){
			var token = securityService.generatePasswordResetToken( prc.oUser );
			getInstance( "messagebox@cbMessagebox" ).info(
				prc.CBHelper.r( "messages.password_reset_detected@security" )
			);
			relocate(
				event       = "#prc.cbAdminEntryPoint#.security.verifyReset",
				queryString = "token=#token#"
			);
			return;
		}

		/************************************** NAVIGATION EXIT HANDLERS *********************************************/

		// Global Admin Exit Handlers
		prc.xehDashboard = "#prc.cbAdminEntryPoint#.dashboard";
		prc.xehAbout     = "#prc.cbAdminEntryPoint#.dashboard.about";

		// Entries Tab
		prc.xehEntries      = "#prc.cbAdminEntryPoint#.entries";
		prc.xehEntriesEditor= "#prc.cbAdminEntryPoint#.entries.editor";
		prc.xehCategories   = "#prc.cbAdminEntryPoint#.categories";

		// Content Tab
		prc.xehPages             = "#prc.cbAdminEntryPoint#.pages";
		prc.xehPagesEditor       = "#prc.cbAdminEntryPoint#.pages.editor";
		prc.xehContentStore      = "#prc.cbAdminEntryPoint#.contentStore";
		prc.xehContentStoreEditor= "#prc.cbAdminEntryPoint#.contentStore.editor";
		prc.xehMediaManager      = "#prc.cbAdminEntryPoint#.mediamanager";
		prc.xehMenuManager       = "#prc.cbAdminEntryPoint#.menus";
		prc.xehMenuManagerEditor = "#prc.cbAdminEntryPoint#.menus.editor";

		// Comments Tab
		prc.xehComments       = "#prc.cbAdminEntryPoint#.comments";
		prc.xehCommentsettings= "#prc.cbAdminEntryPoint#.comments.settings";

		// Look and Feel Tab
		prc.xehThemes    = "#prc.cbAdminEntryPoint#.themes";
		prc.xehWidgets   = "#prc.cbAdminEntryPoint#.widgets";
		prc.xehGlobalHTML= "#prc.cbAdminEntryPoint#.globalHTML";

		// Modules
		prc.xehModules	= "#prc.cbAdminEntryPoint#.modules";

		// Authors Tab
		prc.xehAuthors         = "#prc.cbAdminEntryPoint#.users";
		prc.xehAuthorNew       = "#prc.cbAdminEntryPoint#.users.new";
		prc.xehAuthorEditor    = "#prc.cbAdminEntryPoint#.users.editor";
		prc.xehPermissions     = "#prc.cbAdminEntryPoint#.permissions";
		prc.xehPermissionGroups= "#prc.cbAdminEntryPoint#.permissionGroups";
		prc.xehRoles           = "#prc.cbAdminEntryPoint#.roles";
		prc.xehSavePreference  = "#prc.cbAdminEntryPoint#.users.saveSinglePreference";

		// Tools
		prc.xehToolsImport	= "#prc.cbAdminEntryPoint#.tools.importer";

		// System
		prc.xehSettings     = "#prc.cbAdminEntryPoint#.settings";
		prc.xehSitesManager = "#prc.cbAdminEntryPoint#.sites";
		prc.xehChangeSite   = "#prc.cbAdminEntryPoint#.sites.changeSite";
		prc.xehSecurityRules= "#prc.cbAdminEntryPoint#.securityrules";
		prc.xehRawSettings  = "#prc.cbAdminEntryPoint#.settings.raw";

		// Stats
		prc.xehSubscribers  = "#prc.cbAdminEntryPoint#.subscribers";

		// Login/Logout
		prc.xehDoLogout = "#prc.cbAdminEntryPoint#.security.doLogout";
		prc.xehLogin    = "#prc.cbAdminEntryPoint#.security.login";

		// CK Editor Integration Handlers For usage with the Quick Post
		prc.xehCKFileBrowserURL     = "#prc.cbAdminEntryPoint#/ckfilebrowser/";
		prc.xehCKFileBrowserURLImage= "#prc.cbAdminEntryPoint#/ckfilebrowser/";
		prc.xehCKFileBrowserURLFlash= "#prc.cbAdminEntryPoint#/ckfilebrowser/";

		// Search global
		prc.xehSearchGlobal = "#prc.cbAdminEntryPoint#.content.search";

		// Prepare Admin Actions
		prc.xehAdminActionData = [
			{ name="Clear RSS Caches",          value="rss-purge" },
			{ name="Clear Content Caches",      value="content-purge" },
			{ name="Reload Application",        value="app" },
			{ name="Reload ORM",                value="orm" },
			{ name="Reload Admin Module",       value="contentbox-admin" },
			{ name="Reload FileBrowser Module", value="contentbox-filebrowser" },
			{ name="Reload Security Module",    value="contentbox-security" },
			{ name="Reload Site Module",        value="contentbox-ui" }
		];
		prc.xehAdminAction = "#prc.cbAdminEntryPoint#.dashboard.reload";
		// Installer Check
		prc.installerCheck = settingService.isInstallationPresent();
	}

}
