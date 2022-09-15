# Welcome to cbadmin
Cbadmin is a headless ColdBox module which provides a JWT-secured, back-end API for user, role and permission management, intended for ColdBox applications.

If you are looking for a frontend, install afterwards https://github.com/akitogo/cbadmin-vue-argon

## Important copyright notice
A large part of this module is based on contentbox (https://www.forgebox.io/view/contentbox)

## License
Apache License, Version 2.0.

## Important Links
* Source Code - https://github.com/akitogo/cbadmin
* Documentation - https://akitogo.github.io/cbadmin/

## Quick Installation
### 1. Include cbadmin in your project
Cbadmin contains a `box.json` file, so it can leverage [CommandBox](http://www.ortussolutions.com/products/commandbox) for its dependencies. To include cbadmin in your Coldbox project, go to your project root and type:

```bash
box install cbadmin
```

This will download cbadmin along with all required dependencies, but requires a basic Coldbox app structure.

If you start from scratch, please install a Coldbox app template first, e.g.

```bash
box install cbtemplate-advanced-script
```

### 2. Set up a database, create a datasource and configure ORM
Set up a database for your project and create a datasource for it. Update your Application.cfc file to use this datasource. If your project is already using a database, you can use that one.

In Application.cfc:
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
	dialect               : "MySQLDialect", // SQL Server Dialect
	// DO NOT REMOVE THE FOLLOWING LINE OR AUTO-UPDATES MIGHT FAIL.
	// if the tables are not created automaticaly, use 'dropcreate' and then revert to 'update'
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

NOTE: If the database structure is not created for you automatically after server (re)start, you might need to use `dbcreate: "dropcreate"` to force the creation of the tables, then revert back to `dbcreate: "update"`.

### 3. Other setup required in your main Application.cfc file
1. Add a mapping for cbadmin:
```
this.mappings[ "cbadmin" ] = COLDBOX_APP_ROOT_PATH & "/modules/cbadmin";
```
2. You might also need to add this little bit if you fall into an error with a missing `cbBootstrap` key on `onRequestStart()` or `onSessionStart()`:
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
### 5. (re)Start your server to create the database structure
Now you should be ready to (re)start your server, and all the required tables in the database should be created automatically.
If you happen to see a `could not execute query` error, check if the database tables got created in the database. If they didn't, you might need to use `dbcreate: "dropcreate"` in your Application.cfc config file (see comment in the "Set up a dabase" section above).
```
box server restart
```

Once your tables are created in the database, make sure you have the following keys in the `cbadmin_setting` table:
* `cbadmin_mail_server` - IP address of email server which will be used to send out emails
* `cbadmin_outgoingEmail` - email address used as the sender of outgoing emails
* `cbadmin_email` - email address of the admin of your application for contact purposes (the one you would show on a 'contact us' page)

Once you complete these steps, you should be able to use the API provided by cbadmin in your application.


## Available API methods

All available API methods can be found in the documentation: https://akitogo.github.io/cbadmin/
