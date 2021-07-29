/**
* ContentBox - A Modular Content Platform
* Copyright since 2012 by Ortus Solutions, Corp
* www.ortussolutions.com/products/contentbox
* ---
* ContentBox Admin Module
*/
component {

	// Module Properties
	this.title 				= "";
	this.author 			= "";
	this.webURL 			= "";
	this.description 		= "";
	this.version			= "";
	this.viewParentLookup 	= true;
	this.layoutParentLookup = true;
	this.entryPoint			= "cbadmin";
	this.dependencies 		= [ "cbi18n","cbmailservices","cbSecurity","cbmessagebox","bcrypt"];

	/**
	* Configure Module
	*/
	function configure(){

		// Layout Settings
		layoutSettings = { defaultLayout = "admin.cfm" };

		// Module Settings
		settings = {
			// ForgeBox Settings
			forgeBoxURL 	 = "",
			forgeBoxEntryURL = "",
			using_i18n			= true,
			languages 			= [ "de_DE", "en_US", "es_SV", "it_IT", "pt_BR" ]

		};


		// i18n
		cbi18n = {
			resourceBundles = {
		    	"cbcore" = "#moduleMapping#/i18n/cbcore",
		    	"login" = "#moduleMapping#/i18n/login"

		  	},
		  	defaultLocale = "en_US",
		  	localeStorage = "cookie"
		};


		// Parent Settings
		parentSettings = {
			messagebox = {
				template = "#moduleMapping#/models/ui/templates/messagebox.cfm"
			}
		};

		// SES Routes
		routes = [
			{ pattern="/login/:action?", handler="login", action="login" },

			{ pattern="/:handler/:action?" },
		];

		// for route generation, resources see:
		// https://coldbox-orm.ortusbooks.com/orm-events/automatic-rest-crud#register-the-resource
		resources = [
			{resource = 'api/user', handler = 'api.user',parameterName='userId'},
			{resource = 'api/role', handler = 'api.role',parameterName='roleId'},
			{resource = 'api/permission', handler = 'api.permission',parameterName='permissionId'},
			{resource = 'api/permissiongroup', handler = 'api.permissiongroup',parameterName='permissiongroupId'}
		];

		// Custom Declared Points
		interceptorSettings = {
			// CB Admin Custom Events
			customInterceptionPoints = arrayToList([
				// Author Events
				"cbadmin_preAuthorSave","cbadmin_postAuthorSave","cbadmin_onAuthorPasswordChange","cbadmin_preAuthorRemove","cbadmin_postAuthorRemove",
				"cbadmin_preAuthorPreferencesSave" , "cbadmin_postAuthorPreferencesSave", "cbadmin_UserPreferencePanel",
				"cbadmin_onAuthorEditorNav", "cbadmin_onAuthorEditorContent", "cbadmin_onAuthorEditorSidebar", "cbadmin_onAuthorEditorActions",
				// Permission events
				"cbadmin_prePermissionSave", "cbadmin_postPermissionSave", "cbadmin_prePermissionRemove" , "cbadmin_postPermissionRemove" ,
				// Roles events
				"cbadmin_preRoleSave", "cbadmin_postRoleSave", "cbadmin_preRoleRemove" , "cbadmin_postRoleRemove" ,
				// Security events
				"cbadmin_preLogin","cbadmin_onLogin","cbadmin_onBadLogin","cbadmin_onLogout","cbadmin_onPasswordReminder","cbadmin_onInvalidPasswordReminder", "cbadmin_onPasswordReset", "cbadmin_onInvalidPasswordReset",
				// Settings events
				"cbadmin_preSettingsSave","cbadmin_postSettingsSave","cbadmin_preSettingRemove","cbadmin_postSettingRemove","cbadmin_onSettingsNav","cbadmin_onSettingsContent",
				// Security Rules Events
				"cbadmin_preSecurityRulesSave", "cbadmin_postSecurityRulesSave", "cbadmin_preSecurityRulesRemove", "cbadmin_postSecurityRulesRemove", "cbadmin_onResetSecurityRules"
			])
		};

		// Custom Declared Interceptors
		interceptors = [
			{ class="#moduleMapping#.interceptors.cbrequest" },
			{ class="#moduleMapping#.interceptors.ApiSecurity" },

			// CB Admin Request Interceptor
			// Login Tracker and Preventer
			{ class="#moduleMapping#.models.security.LoginTracker", name="LoginTracker@cbAdmin" }
		];

		binder.map( "SystemUtil@cbadmin" ).to( "coldbox.system.core.util.Util" );
		
	}

	/*
	* On Module Load
	*/
	function onLoad(){

		// Startup localization settings
		//if( controller.getSetting( 'using_i18n' ) ){
			// Load resource bundles here when ready
		//} else{
			// Parent app does not have i18n configured, so add settings manually
			controller.setSetting( 'LocaleStorage', 'cookie' );
			// Add Back when Ready -> controller.setSetting( 'defaultResourceBundle', moduleMapping & '/includes/i18n/main' );
			controller.setSetting( 'defaultLocale', "en_US" );
		//}

		var settings = controller.getSetting('moduleSettings')['cbsecurity'];
		controller.getInterceptorService()
			.registerInterceptor(
				interceptorClass		= "cbsecurity.interceptors.Security",
				interceptorProperties	= settings,
				interceptorName			= "cbsecurity@global"
		);		

	}


}