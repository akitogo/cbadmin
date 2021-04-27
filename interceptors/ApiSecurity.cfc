/**
 * Interceptor securing all API requests.
 */
component
{
    property name="jwtService" inject="JwtService@cbsecurity";

    function preProcess(event, interceptData, rc, prc) eventPattern = '^cbadmin:api\.'
    {
        try {
            prc.jwtUser = jwtAuth().getUser();
        } catch (any error) {
            event.overrideEvent('cbadmin:auth.unauthorized');
        }
    }
}