/**
* ContentBox - A Modular Content Platform
* Copyright since 2012 by Ortus Solutions, Corp
* www.ortussolutions.com/products/contentbox
* ---
* I am a system setting. A system setting can be core or non-core.  The difference is that core
* settings cannot be deleted from the geek settings UI to prevent caos.  Admins would have
* to remove core settings via the DB only as a precautionary measure.
*/
component  	persistent="true"
			entityname="CfgLanguage"
			table     ="cbadmin_cfgLanguage"
			extends   ="modules.cbadmin.models.BaseEntity"
			cachename ="cfgLanguage"
			cacheuse  ="read-write"{

	/* *********************************************************************
	**							PROPERTIES
	********************************************************************* */

	property 	name		= "languageId"
				fieldtype	= "id"
				generator	= "native"
				setter		= "false"
				params		= "{ allocationSize = 1, sequence = 'languageId_seq' }";

	property	name   		= "locale"
				ormtype		= "string"
				notnull		= "true"
				length 		= "5";

	property	name   ="name"
				ormtype="string"
				notnull="true"
				length ="20";




	/* *********************************************************************
	**							PK + CONSTRAINTS
	********************************************************************* */

	this.pk = "languageId";

	this.constraints ={
		"name"  = { required=true, size="1..20" }
	};

	/* *********************************************************************
	**							PUBLIC METHODS
	********************************************************************* */

	/**
	* Constructor
	*/
	function init(){

		super.init();

		return this;
	}

}
