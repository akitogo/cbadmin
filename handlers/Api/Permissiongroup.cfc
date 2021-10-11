component extends="Base"
{
    property name="ormService" inject="permissionGroupService@cbadmin";
    // The name of the entity this resource handler controls. Singular name please.
    variables.entity 	= "PermissionGroup";
    // used by our base handler
    variables.filter    = ['name'];

    function prehandler(event, rc, prc)
    {
        // it seems that there is a bug with parametername
        // the base handler expects the id to be named id and not whatever you specify in parametername
        if (structKeyExists(rc,'permissionGroupId')) {
            rc.id = rc.permissionGroupId;
        }

        if (structKeyExists(rc,'qs') && isSimpleValue(rc.qs)) {
           structDelete(rc,'qs');
        }
    }

    /**
     * @hint Get a list of existing permission groups
     * @param-qs ~params/queryString.json
     * @response-200 ~PermissionGroup/responseMany.json
     */
    function index(event, rc, prc)
    {
        rc.includes ='*';
        rc.excludes ='users,permissions';
        //rc.ignoreDefaults = true;
        super.index(event, rc, prc);
    }

    /**
     * @hint Create a new permission group
     * @requestBody ~PermissionGroup/requestBody.json
     */
    function create(event, rc, prc)
    {
        super.create(event, rc, prc);
    }

    /**
     * @hint Get details of a specific permission group
     * @response-200 ~PermissionGroup/responseOne.json
     */
    function show(event, rc, prc) {
        
        if(rc.id == 0) {
            return emtpy(event, rc, prc);
        }
        super.show(event, rc, prc);
    }

    /**
     * @hint Update an exising permission group
     * @requestBody ~PermissionGroup/requestBody.json
     */
    function update(event, rc, prc) {
        if (rc.id == 0){
            super.create(event, rc, prc);
            return;
        }
        super.update(event, rc, prc);
    }

    /**
     * @hint Delete an existing permission group
     */
    function delete(event, rc, prc)
    {
        super.delete(event, rc, prc);
    }

    /**
     * returns emtpy data for newly generate record
     *
     */
    function emtpy(event, rc, prc) {
        var data = {
            'name':                 '',
            'description':          '',
            'permissions':          [],
            'permissionGroupId':    0
        }
        prc.response.setData( data );
    }
}