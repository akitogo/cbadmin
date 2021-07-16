/**
 * Interceptor securing all API requests.
 */
component
{
    property name="jwtService" inject="JwtService@cbsecurity";

    function preProcess(event, interceptData, rc, prc) eventPattern = '^cbadmin:api\.'
    {
        // TODO: this is just a temporary solution so I don't need the authentication header
        // while debugging using postman. This should be removed in production.
        if (FindNocase('postman', cgi.http_user_agent)) {
            return;
        }

        try {
            prc.jwtUser = jwtAuth().getUser();
        } catch (any error) {
            event.overrideEvent('cbadmin:auth.unauthorized');
        }
    }
}