/**
* ContentBox - A Modular Content Platform
* Copyright since 2012 by Ortus Solutions, Corp
* www.ortussolutions.com/products/contentbox
* ---
* Security rules manager
*/
component extends="cborm.models.VirtualEntityService" singleton
{
	/**
	* Constructor
	*/
	CfgLanguageService function init(){
		// init it
		super.init( entityName="CfgLanguage" );

		return this;
	}

	/**
	 * This method will check that the default 'en_EN' language is present in the database.
	 * If not, the entry will be created.
	 */
	CfgLanguageService function preFlightCheck()
	{
		var lang = this.findWhere( { locale : 'en_EN' } );
		if (isNull(lang)) {
			var defaultLang = new({
				locale: 'en_EN',
				name: 'English'
			});
			save(defaultLang);
		}

		return this;
	}
}