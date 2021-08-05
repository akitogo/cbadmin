component extends="Base"
{
    property name="bCrypt"                      inject = "BCrypt@BCrypt";
    // todo
    //property name="cryptlib"                      inject = "cryptlib@cbadmin";
    property name="roleSerivce"                 inject = "roleService@cbadmin";
    property name="languageService"             inject = "CfgLanguageService@cbadmin";
    property name="permissionGroupService"      inject = "permissionGroupService@cbadmin";
    property name="ormService"                  inject = "userService@cbadmin";

    // The name of the entity this resource handler controls. Singular name please.
    variables.entity 	= "User";

    // used by our base handler
    variables.filter    = ['username','firstName','lastName'];

    function prehandler(event, rc, prc)
    {
        // it seems that there is a bug with parametername
        // the base handler expects the id to be named id and not whatever you specify in parametername
        if (structKeyExists(rc,'userid'))
            rc.id = rc.userId;

        rc.excludes ='permissionGroups.users,permissionGroups.permissions';

    }

    // handlers are provided by the base handler
    // see: https://coldbox-orm.ortusbooks.com/orm-events/automatic-rest-crud

    function index(event, rc, prc)
    {
        super.index(event, rc, prc);
    }

    function update(event, rc, prc)
    {
        var oUser = ormService.get(rc.userId);
        /*
        // check if the current user has permissons to access another user's data
        if (!prc.jwtUser.checkPermission("ADMIN") OR (rc.userId NEQ prc.jwtUser.getId())) {
            throw(type = 'PermissionDenied');
        }
        */

        populateModel(
            model                = oUser,
            composeRelationships = true,
            exclude              = "preference,permissions,role,password,permissionGroups"
        );

        var aoPermissionGroups = arrayMap(rc.permissionGroups, function(pg){ return permissionGroupService.get(pg.permissionGroupId); });
        oUser.updatePermissionGroups(aoPermissionGroups);
        //if( isArray(rc.permissionGroups) ) {
        //    for (var ae in rc.permissionGroups) {
        //        var pg = permissionGroupService.get(ae.permissionGroupId);
        //        oUser.addPermissionGroup(pg);
        //    }
        //}

        var sErrors = {};
        // validate password change
        if (StructKeyExists(rc, 'oldpass') && StructKeyExists(rc, 'newpass') && StructKeyExists(rc, 'newpass2')) {
            // check if old password matches
            if (bCrypt.checkPassword(rc.oldpass, oUser.getPassword())) {
                // check if the new passwords match
                if (!Compare(rc.newpass, rc.newpass2)) {
                    oUser.setPassword(bCrypt.hashPassword(rc.newpass));
                } else {
                    // todo: error - new password mismatch, try again
                    sErrors['newpass'] = {'valid': false ,'error': 'New passwords do not match'};
                }
            } else {
                // todo: error - old password does not match, try again
                sErrors['oldpass'] = {'valid': false ,'error': 'Wrong password'};
            }
        }

        // validate user model
        var vResults = validateModel( target = oUser, excludes = "password" );
        if ( vResults.hasErrors() ) {
            for (var el in vResults.getErrors() ){
                sErrors[lcase(el.getField())] = {'valid': false ,'error': el.getMessage()};
            }
        }

        // TODO: check if roles have changed, and if user has permissions to change role
        if (structKeyExists(rc, 'role') && isStruct(rc.role)){
            var role = roleSerivce.get( rc.role.roleId);
            oUser.setRole(role);
        }

        // Saving language.
        if (structKeyExists(rc, 'language') && isStruct(rc.language)){
            var language = languageService.get(rc.language.languageId);
            oUser.setLanguage(language);
        }

        // check if there are any validation errors
        if ( !structIsEmpty(sErrors) ) {
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