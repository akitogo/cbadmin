component extends="coldbox.system.RestHandler"
{
    property name="cbadminSettings" inject="coldbox:modulesettings:cbadmin";

    this.allowedMethods = {
        'index'         = "GET",
    };

    /**
     * @hint Get the module configuration (ex. settings required on the registration page)
     * @operationId configGet
     * @tags Config
     */
    function index(event, rc, prc) allowedMethods="GET"
    {
        event.getResponse()
            .setData({
                'registration': {
                    'privacyPolicyRequired': cbadminSettings.privacy_policy_required
                }
            });
    }
}