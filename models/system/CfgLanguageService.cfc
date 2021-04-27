/**
* ContentBox - A Modular Content Platform
* Copyright since 2012 by Ortus Solutions, Corp
* www.ortussolutions.com/products/contentbox
* ---
* Security rules manager
*/
component extends="cborm.models.VirtualEntityService" singleton{
	
	/**
	* Constructor
	*/
	CfgLanguageService function init(){
		// init it
		super.init( entityName="CfgLanguage" );

		return this;
	}

}
