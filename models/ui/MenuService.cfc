component accessors="true" threadSafe singleton
{
    property name="wirebox"         inject="wirebox";
    property name="menus"           type="struct";

    MenuService function init()
    {
        variables.menus = {};
        return this;
    }

    Menu function addOrReturnRegion( region = '')
    {
        if ( structKeyExists(variables.menus,arguments.region) ) {
            return variables.menus[arguments.region];
        }
        variables.menus[arguments.region] =  wirebox.getInstance('menu@cbadmin');

        return variables.menus[arguments.region];
    }

    Menu function getRegion( region = '')
    {
        if ( !structKeyExists(variables.menus,arguments.region) ) {
            throw('Region does not exist','MenuService');
        }
        
        return variables.menus[arguments.region];
    }

    MenuItem function getNewMenuItem( )
    {
        return wirebox.getInstance('menuitem@cbadmin');
    }
}