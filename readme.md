# Welcome to cbadmin
Cbadmin is a ColdBox module which provides a JWT-secured, back-end API for user, role and permission management, intended for ColdBox applications.

## Important copyright notice
A large part of this module is based on contentbox (https://www.forgebox.io/view/contentbox)

## License
Apache License, Version 2.0.

## Important Links
* Source Code - https://github.com/akitogo/cbadmin
* Documentation - (in progress...)

## Quick Installation
### 1. Include cbadmin in your project
Cbadmin contains a `box.json` file, so it can leverage [CommandBox](http://www.ortussolutions.com/products/commandbox) for its dependencies. To include cbadmin in your project, go to your project root and type:

```bash
box install cbadmin
```

This will download cbadmin along with all required dependencies.

### 2. Set up a database and import the template table structure
Use the template sql file to create the required table structure in your database. You will find the sql file in the root directory of the module ("cbadmin-db-template.sql").

You should also set the following keys in the `cbadmin_setting` table:
* `CBADMIN_MAIL_SERVER` - IP address of email server which will be used to send out emails
* `cbadmin_outgoingEmail` - email address used as the sender of outgoing emails
* `cbadmin_email` - email address of the admin of your application for contact purposes (the one you would show on a 'contact us' page)

### 3. Setup required in your main Application.cfc file
1. First, you need to have your datasource defined and ORM enabled:
```
// Datasource definition
this.datasource = 'place-your-datasource-name-here';

// ORM SETTINGS
this.ormEnabled  = true;
this.ormSettings = {
	// ENTITY LOCATIONS, ADD MORE LOCATIONS AS YOU SEE FIT
	cfclocation : [
		// If you create your own app entities
		"models",
		"modules/cbadmin/models/",
		// Custom Module Entities
		"modules_app"
	],
	//dialect             : "MySQLDialect", // SQL Server Dialect
	// DO NOT REMOVE THE FOLLOWING LINE OR AUTO-UPDATES MIGHT FAIL.
	dbcreate              : "update",
	// FILL OUT: IF YOU WANT CHANGE SECONDARY CACHE, PLEASE UPDATE HERE
	secondarycacheenabled : false,
	cacheprovider         : "ehCache",
	// ORM SESSION MANAGEMENT SETTINGS, DO NOT CHANGE
	logSQL                : true,
	flushAtRequestEnd     : false,
	autoManageSession     : false,
	// ORM EVENTS MUST BE TURNED ON FOR CONTENTBOX TO WORK
	eventHandling         : true,
	eventHandler          : "cbadmin.modules.cborm.models.EventHandler",
	// THIS IS ADDED SO OTHER CFML ENGINES CAN WORK WITH CONTENTBOX
	skipCFCWithError      : true
};
```
2. Next, add a mapping for cbadmin:
```
this.mappings[ "cbadmin" ] = COLDBOX_APP_ROOT_PATH & "/modules/cbadmin";
```
3. You might also need to add this little bit if you fall into an error with a missing `cbBootstrap` key on `onRequestStart()` or `onSessionStart()`:
```
if (!structKeyExists(application, "cbBootstrap")) {
	onApplicationStart();
}
```
### 4. Module settings required in your config/Coldbox.cfc file
```
moduleSettings = {
	// the cbauth overrides for this module
	"cbauth" : {
		"userServiceClass" : "SecurityService@cbadmin"
	}
	, "cbsecurity" : {
		"userService" : "SecurityService@cbadmin"
	}
};
```

Once you complete these steps, you should be able to use the API provided by cbadmin in your application.

## Available API methods

### User management
...
### Permission management
...