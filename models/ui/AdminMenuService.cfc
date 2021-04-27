/**
* ContentBox - A Modular Content Platform
* Copyright since 2012 by Ortus Solutions, Corp
* www.ortussolutions.com/products/contentbox
* ---
* Manages the admin menu services for the header and top menu
*/
component accessors="true" threadSafe singleton{

	/**
	* This holds the top menu structure
	*/
	property name="topMenu"			type="array";
	/**
	* This is a reference map of the topMenu array
	*/
	property name="topMenuMap"		type="struct";
	/**
	* This holds the header menu structure
	*/
	property name="headerMenu"		type="array";
	/**
	* This holds the support menu structure
	*/
	property name="supportMenu"		type="array";
	/**
	* This holds the utils menu structure
	*/
	property name="utilsMenu"		type="array";
	/**
	* This holds the profile menu structure
	*/
	property name="profileMenu"		type="array";
	/**
	* This is a reference map of the headerMenu array
	*/
	property name="headerMenuMap"	type="struct";

	/**
	* Injected Avatar
	*/
	property name="avatar"			type="any" inject="Avatar@cbadmin";

	// Top Menu Slugs
	this.DASHBOARD 		= "dashboard";
	this.USERS			= "users";
	this.TOOLS			= "tools";
	this.SYSTEM			= "system";
	this.STATS			= "stats";
	this.ADMIN_ENTRYPOINT = "";

	// Header Menu Slugs
	this.HEADER_PROFILE = "profile";

	/**
	* Constructor
	* @requestService.inject coldbox:requestService
	* @coldbox.inject coldbox
	*/
	AdminMenuService function init( required requestService, required coldbox ){
		// init menu array
		variables.topMenu = [];
		// init top menu structure holders
		variables.topMenuMap = {};
		// init header menu array
		variables.headerMenu = [];
		// init header menu array
		variables.supportMenu = [];
		// init header menu array
		variables.utilsMenu = [];
		// init header menu array
		variables.profileMenu = [];
		// init profile menu structure
		variables.headerMenuMap = {};
		// top menu pointer
		variables.thisTopMenu = "";
		// header menu pointer
		variables.thisHeaderMenu = "";
		// store request service
		variables.requestService = arguments.requestService;
		// store coldbox
		variables.coldbox = arguments.coldbox;
		// Store admin entry point
		this.ADMIN_ENTRYPOINT = arguments.coldbox.getSetting( "modules" )[ "cbadmin" ].entryPoint;
		// store module info
		variables.moduleConfig = arguments.coldbox.getSetting( "modules" )[ "cbadmin" ];
		// create default menus
		createHeaderMenu();
		createDefaultMenu();
		return this;
	}

	function buildLIAttributes( required any event, required any menu ) {
        var attributes = {
            "class" = "#menu.class#",
            "data-name" = "#menu.name#"
        };
        if( structKeyExists( menu, "id" ) && len( menu.id ) ) {
    		attributes[ "id" ] = menu.id;
    	}
        if( event.getValue( name='tab#menu.name#', defaultValue=false, private=true ) ) {
            listAppend( attributes.class, "active", " " );
        }
        return createAttributeList( attributes );
    }

    function buildItemAttributes( required any event, required any menu, structDefaults={} ) {
    	var attributes = {
    		"class" = structKeyExists( structDefaults, "class" ) ? structDefaults.class : ""
    	};
    	if( len( menu.itemClass ) ) {
    		attributes.class &= " #menu.itemClass#";
    	}
    	if( len( menu.itemId ) ) {
    		attributes[ "id" ] = menu.itemId;
    	}
    	if( structKeyExists( menu, "subMenu" ) && arrayLen( menu.subMenu ) ) {
    		attributes[ "data-toggle" ] = "dropdown";
    	}
    	if( menu.itemType=="a" ) {
    		attributes[ "href" ] = "#( isCustomFunction( menu.href ) ? menu.href() : menu.href )#";
    	}
    	if( menu.itemType=="button" ) {
    		attributes[ "onclick" ] = "#( isCustomFunction( menu.href ) ? menu.href() : menu.href )#";
    	}
    	if( len( menu.title ) ) {
    		attributes[ "title" ] = "#menu.title#";
    	}
    	if( menu.itemType=="a" && len( menu.target ) ) {
    		attributes[ "target" ] = "#menu.target#";
    	}
    	var attributeList = createAttributeList( attributes );
    	if( structKeyExists( menu, "data" ) && structCount( menu.data ) ) {
    		attributeList &= " " & parseADataAttributes( menu.data );
    	}
    	return attributeList;
	}

    function createAttributeList( required struct attributes ) {
        var attributeList = "";
        for( var key in arguments.attributes ) {
            attributeList &= '#key#="#attributes[ key ]#"';
        }
        return attributeList;
    }

	/**
	* Create the default ContentBox header menu contributions
	*/
	AdminMenuService function createHeaderMenu(){
		var event = requestService.getContext();

		// Exit Handlers
		var xehMyProfile		= "#this.ADMIN_ENTRYPOINT#.users.myprofile";
		var xehDoLogout			= "#this.ADMIN_ENTRYPOINT#.login.doLogout";
		var xehAdminAction		= "#this.ADMIN_ENTRYPOINT#.dashboard.reload";



		// Register Profile Menu
		addHeaderMenu(
			name="profile",
			label="",
			class="dropdown settings"
		)
		.addHeaderSubMenu(
			name="myprofile",
			title="ctrl+shift+A",
			label="<i class='fa fa-camera'></i> My Profile",
			href="#event.buildLink( xehMyProfile )#",
			data={ keybinding="ctrl+shift+a" }
		)
		.addHeaderSubMenu(
			name="logout",
			title="ctrl+shift+L",
			label="<i class='fa fa-power-off'></i> Logout",
			href="#event.buildLink( xehDoLogout )#",
			data={ keybinding="ctrl+shift+l" }
		);
		// Register modules reload menu
		addHeaderMenu(
			name="utils",
			label='<i class="fa fa-cog"></i>',
			class="dropdown settings",
			itemType="button",
			itemClass="btn btn-default options toggle",
			permissions="RELOAD_MODULES",
			data={ placement = "right" },
			title="Admin Actions"
		)
		.addHeaderSubMenu(
			name="rsscache",
			label="Clear RSS Caches",
			href="javascript:adminAction( 'rss-purge', '#event.buildLink( xehAdminAction )#' )"
		)
		.addHeaderSubMenu(
			name="contentpurge",
			label="Clear Content Caches",
			href="javascript:adminAction( 'content-purge', '#event.buildLink( xehAdminAction )#' )"
		)
		.addHeaderSubMenu(
			name="app",
			label="Reload Application",
			href="javascript:adminAction( 'app', '#event.buildLink( xehAdminAction )#' )"
		)
		.addHeaderSubMenu(
			name="orm",
			label="Reload ORM",
			href="javascript:adminAction( 'orm', '#event.buildLink( xehAdminAction )#' )"
		)
		.addHeaderSubMenu(
			name="contentboxadmin",
			label="Reload Admin Module",
			href="javascript:adminAction( 'cbadmin', '#event.buildLink( xehAdminAction )#' )"
		)
		.addHeaderSubMenu(
			name="contentboxfilebrowser",
			label="Reload FileBrowser Module",
			href="javascript:adminAction( 'contentbox-filebrowser', '#event.buildLink( xehAdminAction )#' )"
		)
		.addHeaderSubMenu(
			name="contentboxsecurity",
			label="Reload Security Module",
			href="javascript:adminAction( 'contentbox-security', '#event.buildLink( xehAdminAction )#' )"
		);
		return this;
	}



	/**
	* Create the default ContentBox menu
	*/
	AdminMenuService function createDefaultMenu(){
		var event 	= requestService.getContext();
		var prc 	= {};

		// Global Admin Exit Handlers
		prc.xehDashboard 	= "#this.ADMIN_ENTRYPOINT#.dashboard";


		// Authors Tab
		prc.xehAuthors		= "#this.ADMIN_ENTRYPOINT#.users";
		prc.xehAuthorEditor	= "#this.ADMIN_ENTRYPOINT#.users.editor";
		prc.xehPermissions		= "#this.ADMIN_ENTRYPOINT#.permissions";
		prc.xehRoles			= "#this.ADMIN_ENTRYPOINT#.roles";


		// System
		prc.xehSettings			= "#this.ADMIN_ENTRYPOINT#.settings";
		prc.xehSecurityRules	= "#this.ADMIN_ENTRYPOINT#.securityrules";
		prc.xehRawSettings		= "#this.ADMIN_ENTRYPOINT#.settings.raw";
		prc.xehAuthLogs			= "#this.ADMIN_ENTRYPOINT#.settings.authLogs";
		prc.xehAutoUpdater	    = "#this.ADMIN_ENTRYPOINT#.autoupdates";


		// Dashboard
		addTopMenu( name=this.DASHBOARD, label="<i class='fa fa-dashboard'></i> Dashboard" )
			.addSubMenu( name="home", label="Home", href="#event.buildLink(prc.xehDashboard)#" );




		// User
		addTopMenu( name=this.USERS, label="<i class='fa fa-user'></i> Users" )
			.addSubMenu( name="Manage", label="Manage", href="#event.buildLink(prc.xehAuthors)#", permissions="ADMIN" )
			.addSubMenu( name="Permissions", label="Permissions", href="#event.buildLink(prc.xehPermissions)#", permissions="PERMISSIONS_ADMIN" )
			.addSubMenu( name="Roles", label="Roles", href="#event.buildLink(prc.xehRoles)#", permissions="ROLES_ADMIN" );


		// SYSTEM
		addTopMenu( name=this.SYSTEM, label="<i class='fa fa-briefcase'></i> System", permissions="SYSTEM_TAB" )
			.addSubMenu( name="Settings", label="Settings", href="#event.buildLink(prc.xehSettings)#", data={ "keybinding"="ctrl+shift+c" }, title="ctrl+shift+C" )
			.addSubMenu( name="SecurityRules", label="Security Rules", href="#event.buildLink(prc.xehSecurityRules)#", permissions="SECURITYRULES_ADMIN" )
			.addSubMenu( name="GeekSettings", label="Geek Settings", href="#event.buildLink(prc.xehRawSettings)#", permissions="SYSTEM_RAW_SETTINGS" )
			.addSubMenu( name="AuthLogs", label="Auth Logs", href="#event.buildLink(prc.xehAuthLogs)#", permissions="SYSTEM_AUTH_LOGS" );


		return this;
	}

	/**
	* Build out ContentBox module links
	*/
	function buildModuleLink( required string module, required string linkTo, queryString="", boolean ssl=false ){
		var event = requestService.getContext();
		return event.buildLink( linkto="#this.ADMIN_ENTRYPOINT#.module.#arguments.module#.#arguments.linkTo#",
							    queryString=arguments.queryString,
							    ssl=arguments.ssl );
	}

	/**
	* @name.hint The name of the top menu
	*/
	AdminMenuService function withTopMenu( required name ){
		thisTopMenu = arguments.name;
		return this;
	}

	/**
	* Use a header menu
	* @name.hint The name of the header menu
	*/
	AdminMenuService function withHeaderMenu( required name ){
		thisHeaderMenu = arguments.name;
		return this;
	}

	/**
	* Add top level menus
	* @name.hint The unique name for this top level menu
	* @label.hint The label for the menu item, this can be a closure/udf and it will be called at generation
	* @title.hint The optional title element
	* @href.hint The href, if any to locate when clicked, this can be a closure/udf and it will be called at generation
	* @target.hint The target to execute the link in, default is same page.
	* @permissions.hint The list of permissions needed to view this menu
	* @data.hint A structure of data attributes to add to the link
	* @class.hint A CSS class list to append to the element
	* @id.hint An id to apply to the element
	* @itemType.hint The type of element to create (e.g., a tag, button, etc.)
	* @itemClass.hint A CSS class list to append to the element
	* @itemId.hint An id to apply to the item element
	*/
	AdminMenuService function addTopMenu( required name, required label, title="", href="##", target="", permissions="", data=structNew(), class="", id="", itemType="a", itemClass="", itemId=""  ){
		// stash pointer
		variables.thisTopMenu = arguments.name;
		// store new top menu in reference map
		variables.topMenuMap[ arguments.name ] = { submenu = [] };
		structAppend( variables.topMenuMap[ arguments.name ], arguments, true );
		// store in menu container
		arrayAppend( variables.topMenu, variables.topMenuMap[ arguments.name ] );
		// return it
		return this;
	}

	/**
	* Add header top level menu
	* @name.hint The unique name for this header level menu
	* @label.hint The label for the menu item, this can be a closure/udf and it will be called at generation
	* @title.hint The optional title element
	* @href.hint The href, if any to locate when clicked, this can be a closure/udf and it will be called at generation
	* @target.hint The target to execute the link in, default is same page.
	* @permissions.hint The list of permissions needed to view this menu
	* @data.hint A structure of data attributes to add to the link
	* @class.hint A CSS class list to append to the element
	* @id.hint An id to apply to the element
	* @itemType.hint The type of element to create (e.g., a tag, button, etc.)
	* @itemClass.hint A CSS class list to append to the element
	* @itemId.hint An id to apply to the item element
	*/
	AdminMenuService function addHeaderMenu( required name, required label, title="", href="javascript:void( null )", target="", permissions="", data=structNew(), class="", id="", itemType="a", itemClass="", itemId="" ){
		// stash pointer
		variables.thisHeaderMenu = arguments.name;
		// store new top menu in reference map
		variables.headerMenuMap[ arguments.name ] = { submenu = [] };

		structAppend( variables.headerMenuMap[ arguments.name ], arguments, true );
		// store in menu container
		arrayAppend( variables.headerMenu, variables.headerMenuMap[ arguments.name ] );
		// return it
		return this;
	}

	/**
	* Add a sub level menu
	* @topMenu.hint The optional top menu name to add this sub level menu to or if concatenated then it uses that one.
	* @name.hint The unique name for this sub level menu
	* @label.hint The label for the menu item, this can be a closure/udf and it will be called at generation
	* @title.hint The optional title element
	* @href.hint The href, if any to locate when clicked, this can be a closure/udf and it will be called at generation
	* @target.hint The target to execute the link in, default is same page.
	* @permissions.hint The list of permissions needed to view this menu
	* @data.hint A structure of data attributes to add to the link
	* @class.hint A CSS class list to append to the element
	* @id.hint An id to apply to the element
	* @itemType.hint The type of element to create (e.g., a tag, button, etc.)
	* @itemClass.hint A CSS class list to append to the element
	* @itemId.hint An id to apply to the item element
	*/
	AdminMenuService function addSubMenu(topMenu, required name, required label, title="", href="##", target="", permissions="", data=structNew(), class="", id="", itemType="a", itemClass="", itemId="" ){
		// Check if thisTopMenu set?
		if( !len(thisTopMenu) AND !structKeyExists(arguments,"topMenu" ) ){ throw( "No top menu passed or concatenated with" ); }
		// check this pointer
		if( len(thisTopMenu) AND !structKeyExists(arguments,"topMenu" )){ arguments.topmenu = thisTopMenu; }
		// store in top menu
		try {
			arrayAppend( topMenuMap[ arguments.topMenu ].submenu, arguments );
		} catch ( any ex ) {
			writedump( arguments.topMenu );
			writedump( topMenuMap );abort;


			writedump(ex);abort;
		}
		// return
		return this;
	}

	/**
	* Add a sub level header menu
	* @headerMenu.hint The optional header menu name to add this sub level menu to or if concatenated then it uses that one.
	* @name.hint The unique name for this sub level menu
	* @label.hint The label for the menu item
	* @title.hint The optional title element
	* @href.hint The href, if any to locate when clicked
	* @target.hint The target to execute the link in, default is same page.
	* @permissions.hint The list of permissions needed to view this menu
	* @data.hint A structure of data attributes to add to the link
	* @class.hint A CSS class list to append to the element
	* @id.hint An id to apply to the element
	* @itemType.hint The type of element to create (e.g., a tag, button, etc.)
	* @itemClass.hint A CSS class list to append to the element
	* @itemId.hint An id to apply to the item element
	*/
	AdminMenuService function addHeaderSubMenu( headerMenu, required name, required label, title="", href="##", target="", permissions="", data=structNew(), class="", iid="", itemType="a", itemClass="", itemId="" ){
		// Check if thisTopMenu set?
		if( !len( thisHeaderMenu ) AND !structKeyExists( arguments, "headerMenu" ) ){ throw( "No header menu passed or concatenated with" ); }
		// check this pointer
		if( len( thisHeaderMenu ) AND !structKeyExists( arguments, "headerMenu" )){ arguments.headerMenu = thisHeaderMenu; }
		// store in top menu
		arrayAppend( headerMenuMap[ arguments.headerMenu ].submenu, arguments );
		// return
		return this;
	}

	/**
	* Remove a sub level menu
	* @topMenu.hint The optional top menu name to add this sub level menu to or if concatenated then it uses that one.
	* @name.hint The unique name for this sub level menu
	*/
	AdminMenuService function removeSubMenu( required topMenu, required name ){

		for( var x=1; x lte arrayLen( variables.topMenuMap[ arguments.topMenu ].subMenu ); x++){
			if( variables.topMenuMap[ arguments.topMenu ].subMenu[ x ].name eq arguments.name ){
				arrayDeleteAt( variables.topMenuMap[ arguments.topMenu ].subMenu, x );
				break;
			}
		}

		// return
		return this;
	}

	/**
	* Remove a sub level menu from the header
	* @headerMenu.hint The optional header menu name to remove from
	* @name.hint The sub menu to remove
	*/
	AdminMenuService function removeHeaderSubMenu( required headerMenu, required name ){

		for( var x=1; x lte arrayLen( variables.headerMenuMap[ arguments.headerMenu ].subMenu ); x++){
			if( variables.headerMenuMap[ arguments.headerMenu ].subMenu[ x ].name eq arguments.name ){
				arrayDeleteAt( variables.headerMenuMap[ arguments.headerMenu ].subMenu, x );
				break;
			}
		}

		// return
		return this;
	}

	/**
	* Remove a top level menu
	* @topMenu.hint The optional top menu name to add this sub level menu to or if concatenated then it uses that one.
	*/
	AdminMenuService function removeTopMenu(required topMenu){

		for( var x=1; x lte arrayLen( variables.topMenu ); x++ ){
			if( variables.topMenu[ x ].name eq arguments.topMenu ){
				arrayDeleteAt( variables.topMenu, x );
				structDelete( variables.topMenuMap, arguments.topMenu );
				break;
			}
		}

		// return
		return this;
	}

	/**
	* Remove a header top level menu
	* @headerMenu.hint The header menu unique name to remove
	*/
	AdminMenuService function removeHeaderMenu( required headerMenu ){

		for( var x=1; x lte arrayLen( variables.headerMenu ); x++ ){
			if( variables.headerMenu[ x ].name eq arguments.headerMenu ){
				arrayDeleteAt( variables.headerMenu, x );
				structDelete( variables.headerMenuMap, arguments.headerMenu );
				break;
			}
		}

		// return
		return this;
	}

	/**
	*  Generate menu from cache or newly generated menu
	*/
	any function generateMenu(){
		var event 		= requestService.getContext();
		var prc			= event.getCollection( private=true );
		var genMenu 	= "";
		var thisMenu 	= variables.topMenu;

		savecontent variable="genMenu"{
			include "templates/navAdminMenu.cfm";
		}

		// return it
		return genMenu;
	}

	/**
	* Generate the header menu
	*/
	any function generateHeaderMenu(){
		var event 		= requestService.getContext();
		var prc			= event.getCollection( private=true );
		var genMenu 	= "";
		var thisMenu 	= variables.headerMenu;

		savecontent variable="genMenu"{
			include "templates/nav.cfm";
		}

		// return it
		return genMenu;
	}



	any function generateUtilsMenu() {
		var event 		= requestService.getContext();
		var prc			= event.getCollection( private=true );
		var genMenu 	= "";
		var thisMenu 	= variables.headerMenuMap[ "utils" ];

		savecontent variable="genMenu"{
			include "templates/subNav.cfm";
		}

		// return it
		return genMenu;
	}

	any function generateProfileMenu() {
		var event 		= requestService.getContext();
		var prc			= event.getCollection( private=true );
		var genMenu 	= "";
		var thisMenu 	= variables.headerMenuMap[ "profile" ];

		savecontent variable="genMenu"{
			include "templates/subNav.cfm";
		}

		// return it
		return genMenu;
	}

	/**
	* Generate a flat representation of data elements
	* @data.hint The data struct
	*/
	string function parseADataAttributes( required struct data ) {
		var dataString = "";

		for( var dataKey in arguments.data ){
			if( isSimplevalue( arguments.data[ dataKey ] ) ){
				dataString &= ' data-#lcase( dataKey )#="#arguments.data[ datakey ]#"';
			}
		}

		return dataString;
	}
}
