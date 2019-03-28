<cfset variables.InternetAddressObj = CreateObject("java", "javax.mail.internet.InternetAddress")/>
<cfset variables.examples = populateExamples()/>
<h1>Comparison of HTML5 Regex, IsValid() and CFMail validation of email address formats</h1>
<cfoutput>
	<table width="60%" border="1" cellpadding="5" cellspacing="0">
		<tr>
			<th>Example String</th>
			<th>HTML5 Regex</th>
			<th>CF IsValid</th>
			<th>Java Parse</th>
			<th>Java Parse reason</th>
		</tr>
		<cfloop array="#variables.examples#" item="email">
			<cfset variables.results = validate( email )/>
			<cfset variables.bgColor = ""/>
			<cfif variables.results.usingIsValid eq "NO" and variables.results.usingParseStrict eq "YES">
				<cfset variables.bgColor = "yellow"/>
			<cfelse>
				<cfif variables.results.usingIsValid eq "NO" and variables.results.usingHTML5Regex eq "YES">
					<cfset variables.bgColor = "##ddd"/>
				<cfelse>
					<cfif variables.results.usingParseStrict eq "NO" and variables.results.usingIsValid eq "YES">
						<cfset variables.bgColor = "red"/>
					</cfif>
				</cfif>
			</cfif>
			<tr style="background-color: #variables.bgColor#">
				<td>#htmlEditFormat(email)#</td>
				<td>#variables.results.usingHTML5Regex#</td>
				<td>#variables.results.usingIsValid#</td>
				<td>#variables.results.usingParseStrict#</td>
				<td>#variables.results.invalidReason#</td>
			</tr>
		</cfloop>
	</table>
</cfoutput>


<cffunction name="populateExamples" returntype="array">
	
	<cfset local.emails = arrayNew(1, true)/>
	<cfset arrayAppend( local.emails, 'email@example.com' )/>
	<cfset arrayAppend( local.emails, 'firstname.lastname@example.com' )/>
	<cfset arrayAppend( local.emails, 'email@subdomain.example.com' )/>
	<cfset arrayAppend( local.emails, 'firstname+lastname@example.com' )/>
	<cfset arrayAppend( local.emails, 'email@123.123.123.123' )/>
	<cfset arrayAppend( local.emails, 'email@[123.123.123.123]' )/>
	<cfset arrayAppend( local.emails, '"email"@example.com' )/>
	<cfset arrayAppend( local.emails, '1234567890@example.com' )/>
	<cfset arrayAppend( local.emails, 'email@example-one.com' )/>
	<cfset arrayAppend( local.emails, '_______@example.com' )/>
	<cfset arrayAppend( local.emails, 'email@example.name' )/>
	<cfset arrayAppend( local.emails, 'email@example.museum' )/>
	<cfset arrayAppend( local.emails, 'email@example.co.jp' )/>
	<cfset arrayAppend( local.emails, 'firstname-lastname@example.com' )/>

	<!--- List of Strange Valid Email Addresses --->
	<cfset arrayAppend( local.emails, 'much.”more\ unusual”@example.com' )/>
	<cfset arrayAppend( local.emails, 'very.unusual.”@”.unusual.com@example.com' )/>
	<cfset arrayAppend( local.emails, 'very.”(),:;<>[]”.VERY.”very@\\ "very”.unusual@strange.example.com' )/>

	<!--- List of Invalid Email Addresses --->

	<cfset arrayAppend( local.emails, 'plainaddress') />
	<cfset arrayAppend( local.emails, '##@%^%##$@##$@##.com') />
	<cfset arrayAppend( local.emails, '@example.com') />
	<cfset arrayAppend( local.emails, 'Joe Smith <email@example.com>') />
	<cfset arrayAppend( local.emails, 'email.example.com') />
	<cfset arrayAppend( local.emails, 'email@example@example.com') />
	<cfset arrayAppend( local.emails, '.email@example.com') />
	<cfset arrayAppend( local.emails, 'email.@example.com') />
	<cfset arrayAppend( local.emails, 'email..email@example.com') />
	<cfset arrayAppend( local.emails, 'あいうえお@example.com') />
	<cfset arrayAppend( local.emails, 'email@example.com (Joe Smith)') />
	<cfset arrayAppend( local.emails, 'email@example') />
	<cfset arrayAppend( local.emails, 'email@-example.com') />
	<cfset arrayAppend( local.emails, 'email@example.web') />
	<cfset arrayAppend( local.emails, 'email@111.222.333.44444') />
	<cfset arrayAppend( local.emails, 'email@example..com') />
	<cfset arrayAppend( local.emails, 'Abc..123@example.com') />

	<!--- List of Strange Invalid Email Addresses --->

	<cfset arrayAppend( local.emails, '”(),:;<>[\]@example.com')/>
	<cfset arrayAppend( local.emails, 'just”not”right@example.com')/>
	<cfset arrayAppend( local.emails, 'this\ is"really"not\allowed@example.com')/>

	<cfset arrayAppend( local.emails, '&nbsp;example@example.com') />
	<cfset arrayAppend( local.emails, 'Example Example <example@example.com>') />
	<cfset arrayAppend( local.emails, '<example@example.com>') />
	<cfset arrayAppend( local.emails, 'http://127.0.0.1') />
	<cfset arrayAppend( local.emails, '127.0.0.1') />
	<cfset arrayAppend( local.emails, 'www.google.com') />
	<cfset arrayAppend( local.emails, '')/>
	
	<!--- inject an ascii character into a known good value --->
	<cfloop index="i" from="0" to="255">
		<cfset arrayAppend( local.emails, 'email' & chr(i) &'@example.com')/>
	</cfloop>
	
	<!--- inject an ascii character at the beginning of a known good value --->
	<cfloop index="i" from="0" to="255">
		<cfset arrayAppend( local.emails, chr(i) & 'email@example.com')/>
	</cfloop>

	<cfreturn local.emails/>
</cffunction>

 <cffunction name="validate" returntype="struct">
 	<cfargument name="email" type="string" required="true"/>
 	<!--- the HML5Regex value comes from https://www.w3.org/TR/html5/sec-forms.html#email-state-typeemail --->
 	<cfset local.results = {
 		'usingParseStrict' = "YES",
 		'usingParseNonStrict' = "YES",
 		'usingHTML5Regex' = isValid("regex", arguments.email, "^[a-zA-Z0-9.!##$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"),
 		'usingIsValid' = isValid("email", arguments.email),
 		'invalidReason' = ""
 	}/>
	<cftry>
		<cfset local.parsed = variables.InternetAddressObj.parse( arguments.email, true )/> <!--- true = strict mode --->
		
		<cfcatch type="any">
			<cfset local.results.usingParseStrict = "NO"/>
			<!--- <cfdump var="#cfcatch#" abort="true"/> --->
			<cfset local.results.invalidReason = cfcatch.message/>
		</cfcatch>
	</cftry>
	
	<cfreturn local.results/>
 </cffunction>
