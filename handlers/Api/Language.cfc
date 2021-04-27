component extends="Base"
{
    property name="ormService" inject="cfgLanguageService@cbadmin";
    // The name of the entity this resource handler controls. Singular name please.
    variables.entity 	= "CfgLanguage";

    // used by our base handler
    variables.filter    = [''];

    function prehandler(event, rc, prc)
    {
        // it seems that there is a bug with parametername
        // the base handler expects the id to be named id and not whatever you specify in parametername
        if (structKeyExists(rc,'languageId'))
            rc.id = rc.languageId;

        rc.ignoreDefaults = true;
        rc.includes ='languageId,locale,name';
                        
    }

}