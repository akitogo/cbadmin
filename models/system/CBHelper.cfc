/**
* ContentBox - A Modular Content Platform
* Copyright since 2012 by Ortus Solutions, Corp
* www.ortussolutions.com/products/contentbox
* ---
* This is the ContentBox UI helper class that is injected by the CBRequest interceptor
*/
component accessors="true" singleton threadSafe{

	// DI
	property name="resourceService"		inject="resourceService@cbi18n";
	property name="requestService"		inject="coldbox:requestService";
	
	/**
	* Constructor 
	*/
	function init(){
		return this;
	}

	/**
	* Retrieve i18n resources
	* @resource.hint The resource (key) to retrieve from a loaded bundle or pass a @bundle
	* @defaultValue.hint A default value to send back if the resource (key) not found
	* @locale.hint Pass in which locale to take the resource from. By default it uses the user's current set locale
	* @values.hint An array, struct or simple string of value replacements to use on the resource string
	* @bundle.hint The bundle alias to use to get the resource from when using multiple resource bundles. By default the bundle name used is 'default'
	*/
	any function r( 
		required string resource,
		string defaultValue,
		string locale,
		any values,
		string bundle
	){
		// check for resource@bundle convention:
		if( find( "@", arguments.resource ) ){
			arguments.bundle 	= listLast( arguments.resource, "@" );
			arguments.resource 	= listFirst( arguments.resource, "@" );
		}
		// Stupid CF9 Hack.
		if( structKeyExists( arguments, "defaultValue" ) ){ arguments.default = arguments.defaultValue; }
		return resourceService.getResource( argumentCollection=arguments );
	}

	/**
	* Link to the frontent
	* @event An optional event to link to
	* @ssl	Use SSL or not, defaults to false.
	*/
	function linkFrontend( event="", boolean ssl=false )
	{
		return getRequestContext().buildLink( to="#arguments.event#", ssl=arguments.ssl );
	}

	/**
	* Link to the admin
	* @event An optional event to link to
	* @ssl	Use SSL or not, defaults to false.
	*/
	function linkAdmin( event="", boolean ssl=false ){
		return getRequestContext().buildLink( to=adminRoot() & ".#arguments.event#", ssl=arguments.ssl );
	}

	/**
	* Get the current request context
	* @return coldbox.system.web.context.RequestContext
	*/
	function getRequestContext(){
		return variables.requestService.getContext();
	}	
	/**
	* Get the admin site root location using the configured module's entry point
	*/
	function adminRoot(){
		var prc = getRequestCollection(private=true);
		return prc.cbAdminEntryPoint;
	}
	/**
	* Get the RC or PRC collection reference
	* @private The boolean bit that says give me the RC by default or true for the private collection (PRC)
	*/
	struct function getRequestCollection( boolean private=false ){
		return getRequestContext().getCollection( private=arguments.private );
	}

	/**
	* Link to the admin login
	* @ssl	Use SSL or not, defaults to false.
	*/
	function linkAdminLogin( boolean ssl=false ){
		return getRequestContext().buildLink( linkto=adminRoot() & "/security/login", ssl=arguments.ssl );
	}

	/**
	* Link to the frontend login
	* @ssl	Use SSL or not, defaults to false.
	*/
	function linkFrontendLogin( boolean ssl=false ){
		return getRequestContext().buildLink( to="login", ssl=arguments.ssl );
	}

}