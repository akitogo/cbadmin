component extends="coldbox.system.RestHandler" 
{
    javaSys = createObject("java", "java.lang.System");

    property name="menuService" inject="menuService@cbadmin";

    function sidebar( event, rc, prc )
    {
        var sidebar = menuService.getRegion('sidebar');
        event.getResponse().setData({'menu' : customSerializer(sidebar)  });
    };

    /*****************************************
    ******************************************
    *           Internal functions
    ******************************************
    ******************************************/

    private any function customSerializer( required Any object, ret = {}, returnDirectly = false )
    {
        var props   = getMetaData( arguments.object ).properties;
        var tmp     = {};

        for ( singleProp in props){
            if (singleProp.name == 'wirebox')
                continue;
            
            var val = invoke( arguments.object, "get#singleProp.name#" );
            var useName = singleProp.name;
            if ( isArray(val) && !arrayLen(val) )
                continue;
            if ( isArray(val) && arrayLen(val) ){
                var tmpArr = [];
                for (var arrElem in val){
                    arrayAppend(tmpArr, customSerializer(arrElem,{},true) );
                }
                tmp[useName] = tmpArr;

            } else {
                tmp[useName] = val;
            }
        }

        if(arguments.returnDirectly)
            return tmp;
        
        structAppend(ret,tmp);
        return ret;
    }
}