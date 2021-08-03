<cfoutput>
    <cfset ETH = getInstance( "EmailTemplateHelper@cbadmin" )>
    #ETH.text( "
        <p>Dear @name@,</p>

        <p>
            Your <em>@siteName@</em> account has been activated.
        </p>

        <p>
            You can log into the system using the following link:<br />
            @linkLogin@
        </p>

    " )#
</cfoutput>
