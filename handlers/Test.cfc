component
{
    property name="ormService"       inject = "baseORMService@cborm";
    property name="roleService"      inject = "roleService@cbadmin";
    property name="userService"      inject = "userService@cbadmin";
    property name="languageService"  inject = "CfgLanguageService@cbadmin";

    function index(event, rc, prc)
    {
        //ORMReload();

        // Get language.
        /*
        var language = languageService.get(2);
        dump(language.getMemento());
        abort;
        */

        /*
        // Get user / update / save.
        var user = userService.findWhere({
            username: 'slawek'
        });
        //user.setLastLogin( now() );
        //user.setFirstName('test123');
        //userService.save(user);
        dump(user);
        abort;
        */

        // Deleting role.
        /*
        entity = roleService.getOrFail(3);
        roleService.delete(entity);
        */

        // Get role list.
        /*
        var tmp = ormService.list(
            entityName = "cbRole"
        );
        dump(ArrayLen(tmp));
        dump(tmp[1].getMemento());
        */
        event.setView(view = 'test', layout = 'main');
    }
}