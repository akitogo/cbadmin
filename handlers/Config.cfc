component extends="coldbox.system.RestHandler"
{
    property name="cbadminSettings" inject="coldbox:modulesettings:cbadmin";

    this.allowedMethods = {
        'index'         = "GET",
    };

    function index(event, rc, prc)
    {
        event.getResponse()
            .setData({
                'registration': {
                    'privacyPolicyRequired': cbadminSettings.privacy_policy_required
                }
            });
    }
}