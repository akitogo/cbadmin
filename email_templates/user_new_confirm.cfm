<cfoutput>
    <cfset ETH = getInstance( "EmailTemplateHelper@cbadmin" )>
    #ETH.text( "
        <p>Dear @name@,</p>

        <p>
            A new <em>@siteName@</em> account has been created for you with username <strong>@username@</strong>.
        </p>

        <p>
            You must confirm this email belongs to you before you can log in.
            Please note that your activation link will only be active for the next @linkTimeout@ minutes.<br /><br />
            <a href='@linkToken@'>Click here to confirm your email and activate your account</a>
        </p>

        <p>Activation Link: @linkToken@</p>

        <div style='padding:20px; margin:20px; background-color: ##f2dede; border: 1px dotted gray;clear:both'>
            If your activation link expires, you will have to register once again.
        </div>

    " )#
</cfoutput>
