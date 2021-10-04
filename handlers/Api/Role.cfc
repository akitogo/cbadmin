component extends="Base"
{
    property name="ormService" inject="roleService@cbadmin";
    // The name of the entity this resource handler controls. Singular name please.
    variables.entity 	= "Role";

    // used by our base handler
    variables.filter    = ['role'];

    function prehandler(event, rc, prc)
    {
        // it seems that there is a bug with parametername
        // the base handler expects the id to be named id and not whatever you specify in parametername
        if (structKeyExists(rc,'roleId'))
            rc.id = rc.roleId;
    }

    /**
     * @hint Get a list of existing roles
     * @param-qs ~params/queryString.json
     * @response-200 ~Role/responseMany.json
     */
    function index(event, rc, prc)
    {
        rc.ignoreDefaults = true;
        rc.includes ='description,numberOfPermissions,numberOfUsers,permissionList,role,roleId';
        super.index(event, rc, prc);
    }

    /**
     * @hint Create a new role
     * @requestBody ~Role/requestBody.json
     */
    function create(event, rc, prc)
    {
        super.create(event, rc, prc);
    }

    /**
     * @hint Get details of a specific role
     * @response-200 ~Role/responseOne.json
     */
    function show(event, rc, prc)
    {
        if(rc.id == 0) {
            return emtpy(event, rc, prc);
        }
        super.show(event, rc, prc);
    }

    /**
     * @hint Update an exising role
     * @requestBody ~Role/requestBody.json
     */
    function update(event, rc, prc)
    {
        if (rc.id == 0){
            super.create(event, rc, prc);
            return;
        }
        super.update(event, rc, prc);
    }

    /**
     * @hint Delete an existing role
     */
    function delete(event, rc, prc)
    {
        super.delete(event, rc, prc);
    }

    /**
     * returns emtpy data for newly generate record
     *
     */
    function emtpy(event, rc, prc)
    {
        var data = {
            'role':                 '',
            'description':          '',
            'permissions':          [],
            'roleId':    0
        }
        prc.response.setData( data );
    }
}