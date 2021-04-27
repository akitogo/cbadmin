component extends="Base"
{
    property name="ormService" inject="permissionService@cbadmin";

    // The name of the entity this resource handler controls. Singular name please.
    variables.entity 	= "Permission";

    // used by our base handler
    variables.filter    = ['permission'];

    function prehandler(event, rc, prc)
    {
        // it seems that there is a bug with parametername
        // the base handler expects the id to be named id and not whatever you specify in parametername
        if (structKeyExists(rc,'permissionId')) {
            rc.id = rc.permissionId;
        }
    }

    function updateBak(event, rc, prc)
    {
        var oUser = ormService.get(rc.userId);
        populateModel(
            model                = oUser,
            composeRelationships = true,
            exclude              = "preference,permissions,role,password"
        );

        // validate it
        var vResults = validateModel( target = oUser, excludes = "password" );
        if ( vResults.hasErrors() ) {
            var sErrors = {};
            for (var el in vResults.getErrors() ){
                sErrors[lcase(el.getField())] = {'valid': false ,'error': el.getMessage()};
            }
            event.getResponse().setError(true).setData(sErrors);
            return;
        }

        // announce event
        announce( "cbadmin_preUserSave", { author : oUser } );
        // save user
        ormService.save(oUser);
        // announce event
        announce( "cbadmin_postUserSave", { author : oUser } );
        // message
        event.getResponse()
            .setData(oUser.getMemento());
    }
}