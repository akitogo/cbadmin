/**
 * ContentBox - A Modular Content Platform
 * Copyright since 2012 by Ortus Solutions, Corp
 * www.ortussolutions.com/products/contentbox
 * ---
 * This is the base class for all persistent entities
 */
component
	mappedsuperclass="true"
	accessors       ="true"
	extends         ="BaseEntityMethods"
{

	/* *********************************************************************
	 **							PROPERTIES
	 ********************************************************************* */

	property
		name   ="createdDate"
		type   ="date"
		ormtype="timestamp"
		notnull="true"
		update ="false"
		index  ="idx_createDate"
		openapidocs = "{
			type = 'string',
			description = 'Date when the object was created.',
			example = '2021-05-29 07:31:06',
			exclude_post = true
		}";

	property
		name   ="modifiedDate"
		type   ="date"
		ormtype="timestamp"
		notnull="true"
		index  ="idx_modifiedDate"
		openapidocs = "{
			type = 'string',
			description = 'Date when the object was last modified.',
			example = '2021-04-22 23:59:59',
			exclude_post = true
		}";

	property
		name     ="isDeleted"
		ormtype  ="boolean"
		notnull  ="true"
		default  ="false"
		dbdefault="0"
		index    ="idx_deleted"
		openapidocs = "{
			type = 'boolean',
			description = 'Flag which marks the entry as removed.',
			example = false
		}";
}