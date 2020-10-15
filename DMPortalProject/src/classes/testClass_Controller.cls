public with sharing class testClass_Controller {
	public String sessionId {get;set;}

	private static String issuer = 'wsgc.com';
	private static String issueInstant = formatDateTimeAsString(system.now().addSeconds(1));
	private static String authInstant = formatDateTimeAsString(system.now());
	private static String notBefore = formatDateTimeAsString(system.now().addSeconds(-30));
	private static String NotOnOrAfter = formatDateTimeAsString(system.now().addSeconds(90));

	private static String salesforceLoginURL = 'https://cs4.salesforce.com/?saml=MgoTx78aEP32sTSjdajgjk6LQysYMKrhtxEueYShMMOH1JImnuv6Xj1Sp3';
						//ResponseDestination= "https://login.salesforce.com/?saml=EK03Almz90RPX1sk0F3gL_UQYTUnDzlvpUFiii6CkZKlxbr67y7HYzOqcz"

	private static String dsx509Certificate = 'MIIEijCCA/OgAwIBAgIQPn+ClEjH2V3Jynt7u3v+XzANBgkqhkiG9w0BAQUFADCBujEfMB0 GA1UEChMWVmVyaVNpZ24gVHJ1c3QgTmV0d29yazEXMBUGA1UECxMOVmVyaVNpZ24sIEluYy 4xMzAxBgNVBAsTKlZlcmlTaWduIEludGVybmF0aW9uYWwgU2VydmVyIENBIC0gQ2xhc3MgM zFJMEcGA1UECxNAd3d3LnZlcmlzaWduLmNvbS9DUFMgSW5jb3JwLmJ5IFJlZi4gTElBQklM SVRZIExURC4oYyk5NyBWZXJpU2lnbjAeFw0xMDEyMTQwMDAwMDBaFw0xMjAxMDcyMzU5NTl aMIGOMQswCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTEWMBQGA1UEBxQNU2FuIE ZyYW5jaXNjbzEdMBsGA1UEChQUU2FsZXNmb3JjZS5jb20sIEluYy4xFDASBgNVBAsUC0Fwc GxpY2F0aW9uMR0wGwYDVQQDFBRwcm94eS5zYWxlc2ZvcmNlLmNvbTCBnzANBgkqhkiG9w0B AQEFAAOBjQAwgYkCgYEAzKElluHQYlUnFm156Nwup9vqkf9DvnhOJc09GNYKOdz5PkpJ/bF LuN2frmfJTlw6pi4knE2geN3j26iAFGIpqgkfWmAi5knjcIbOvHbMXMg1apuVyK9jmbKy4p ITZCj56PtH7qMjlmwN+ZEcQRVy+urRGJRfBEyE+ht5KrewhlcCAwEAAaOCAbkwggG1MAkGA 1UdEwQCMAAwCwYDVR0PBAQDAgWgMDwGA1UdHwQ1MDMwMaAvoC2GK2h0dHA6Ly9TVlJJbnRs LWNybC52ZXJpc2lnbi5jb20vU1ZSSW50bC5jcmwwRAYDVR0gBD0wOzA5BgtghkgBhvhFAQc XAzAqMCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy52ZXJpc2lnbi5jb20vcnBhMDQGA1UdJQ QtMCsGCWCGSAGG+EIEAQYKKwYBBAGCNwoDAwYIKwYBBQUHAwEGCCsGAQUFBwMCMHEGCCsGA QUFBwEBBGUwYzAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AudmVyaXNpZ24uY29tMDsGCCsG AQUFBzAChi9odHRwOi8vU1ZSSW50bC1haWEudmVyaXNpZ24uY29tL1NWUkludGwtYWlhLmN lcjBuBggrBgEFBQcBDARiMGChXqBcMFowWDBWFglpbWFnZS9naWYwITAfMAcGBSsOAwIaBB RLa7kolgYMu9BSOJsprEsHiyEFGDAmFiRodHRwOi8vbG9nby52ZXJpc2lnbi5jb20vdnNsb 2dvMS5naWYwDQYJKoZIhvcNAQEFBQADgYEAHP9jTz8c1r9YoOhVxbGwdPx/YU4OaEaiJFqR KrdXu4m6tHp2iW7o/7Kc8IxksDB4siloTOcJ25/NsfPRoWDyvwax0aXDzsBRwJ5Qpr+ii3b UI1+QByEdxH4gZVHHu9fMG/+ePr9SHhil20oycE7oe0xvQEad1Hs6xHCRDbJVIr4=';
											//'MIIERzCCAy+gAwIBAgILAQAAAAABIX6aGX4wDQYJKoZIhvcNAQEFBQAwUDEXMBUGA1UEChMOQ3liZXJ0cnVzdCBJbmMxNTAzBgNVBAMTLEN5YmVydHJ1c3QgU3VyZVNlcnZlciBTdGFuZGFyZCBWYWxpZGF0aW9uIENBMB4XDTA5MDUyNjE5MzAyM1oXDTEyMDUyNjE5MzAyM1owgfExFzAVBgNVBAMTDlNBUyBGZWRlcmF0aW9uMRwwGgYDVQQEExNJZGVudGl0eSBGZWRlcmF0aW9uMSAwHgYDVQQqExdTQVMgRmVkZXJhdGlvbiBQcm92aWRlcjELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAkFaMRAwDgYDVQQHEwdQaG9lbml4MRkwFwYDVQQKExBBbWVyaWNhbiBFeHByZXNzMSAwHgYDVQQLExdJbnRlci9JbnRyYW5ldCBTZWN1cml0eTEtMCsGCSqGSIb3DQEJARYedGVjaG5pY2FsLnNzby5zdXBwb3J0QGFleHAuY29tMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDig+SHwHzMj5bXwX/Zm3KXs0v0dnIrJhtr2PJSpYh2/gvvDIVRh4wInE2RaTM5bDNc4wg1WxuCa4BKpqtfGvzZpPpLl3GXRA+8QjxWqBbsHXpE/zD6rC5BJbY5rkkgS7+KL+Lw8M4gJFzVBlHemusBKW+zO5Fs+viZnuFsDQIJowIDAQABo4IBAjCB/zAfBgNVHSMEGDAWgBTNOpafrm4PQFwcSPhLLbhxAeuJ2jA5BgNVHR8EMjAwMC6gLKAqhihodHRwOi8vY3JsLm9tbmlyb290LmNvbS9TdXJlU2VydmVyRzIuY3JsMB0GA1UdDgQWBBSsICr0lE734pSba+oEiK9xYYgvujAMBgNVHRMBAf8EAjAAMA4GA1UdDwEB/wQEAwIFoDATBgNVHSUEDDAKBggrBgEFBQcDAjBPBgNVHSAESDBGMEQGCSsGAQQBsT4BMjA3MDUGCCsGAQUFBwIBFilodHRwOi8vY3liZXJ0cnVzdC5vbW5pcm9vdC5jb20vcmVwb3NpdG9yeTANBgkqhkiG9w0BAQUFAAOCAQEAbHHbrP1SM8TVosWicOuihB1BzJexdfbFGJPoSWhpz3nRcVm+G/q3tUOuTZfRVDTUVlu2MT0PU8YDk4KSI29GMQwXuEhDp5KKA5f2sgBrYJHS1bx0n42SVRpN6bbascFkpe4I8bGkatRk6j+GBleFozFCNiZeex64meBNX68Rvy+JtCTQVVxcZHj/I+aGw+ZknAeI0UL7J96xuE0IY6dcIK+36bWdE17Vsnxgwi39VijAbRBb41ZnKvs5lSf94qWEE2ikIOKD4ZHTSFWpcnbYaoiDDSFZJZpTD0RsijQu4pcnVYsoQGDNIEO/6EFhFSQHRTW0sOo2ZbxeBpommEEDpg==';



	private static String orgId = userInfo.getOrganizationId();
	private static String portalId = '060P0000000D0W7';
	private static String userName = 'test.contact@cadalys.com';
	private static String federationid = 'mkpartners';


	public String SAMLAssertion {get;set;}
	public String SAMLAssertionBlob {get;set;}

	public testClass_Controller(){
		sessionId = userInfo.getSessionId();
		SAMLAssertion = getSAMLAssertionString3();
		
	}

	private static String formatDateTimeAsString(datetime d){
		//NotBefore 	2009-09-30T20:07:07Z
		//AuthInstant	2009-09-30T20:07:36Z
		//IssueInstant	2009-09-30T20:07:37Z;
		//NotOnOrAfter	2009-09-30T20:09:07Z
		String s = '';
		s += string.valueOf(d.yearGmt());
		s += '-';
		s += string.valueOf(d.monthGmt());
		s += '-';
		s += string.valueOf(d.dayGmt());
		s += 'T';
		s += string.valueOf(d.hourGMT());
		s += ':';
		s += string.valueOf(d.minuteGMT());
		s += ':';
		s += string.valueOf(d.secondGMT());
		s += 'Z';
		return s;
	}
	
	public String getSAMLAssertionString3(){
		String body = '';
		body += '<Response xmlns="urn:oasis:names:tc:SAML:2.0:protocol" Destination="'+salesforceLoginURL+'" ID="_7eb309180a7ecca5e8aa585f28cbdfe39e6f" IssueInstant="'+issueInstant+'" Version="2.0">'; 
		body += '	<ns1:Issuer xmlns:ns1="urn:oasis:names:tc:SAML:2.0:assertion" Format="urn:oasis:names:tc:SAML:2.0:nameid-format:entity">'+issuer+'</ns1:Issuer>';
		body += '	<Status> ';
		body += '        <StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Success"/>'; 
		body += '    </Status> ';
		body += '    <ns2:Assertion xmlns:ns2="urn:oasis:names:tc:SAML:2.0:assertion" ID="_3a3d0167a97b60515d1e34a2d412ff271ac6" IssueInstant="'+issueInstant+'" Version="2.0">'; 
		body += '		<ns2:Issuer Format="urn:oasis:names:tc:SAML:2.0:nameid-format:entity">'+issuer+'</ns2:Issuer>';
		body += '		<ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#">'; 

		body += '			<ds:SignedInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#"> ';
		body += '				<ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#" xmlns:ds="http://www.w3.org/2000/09/xmldsig#"/>'; 
		body += '				<ds:SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1" xmlns:ds="http://www.w3.org/2000/09/xmldsig#"/>'; 
		body += '				<ds:Reference URI="#_3a3d0167a97b60515d1e34a2d412ff271ac6" xmlns:ds="http://www.w3.org/2000/09/xmldsig#">'; 
		body += '					<ds:Transforms xmlns:ds="http://www.w3.org/2000/09/xmldsig#"> ';
		body += '						<ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature" xmlns:ds="http://www.w3.org/2000/09/xmldsig#"/>'; 
		body += '						<ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#" xmlns:ds="http://www.w3.org/2000/09/xmldsig#"/>'; 
		body += '					</ds:Transforms> ';
		body += '					<ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1" xmlns:ds="http://www.w3.org/2000/09/xmldsig#"/>'; 
		body += '					<ds:DigestValue xmlns:ds="http://www.w3.org/2000/09/xmldsig#">ex7zmBjvM0wMmImMJOIqFILJBlU=</ds:DigestValue>'; 
		body += '				</ds:Reference>';
		body += '			</ds:SignedInfo> ';

		body += '			<ds:SignatureValue xmlns:ds="http://www.w3.org/2000/09/xmldsig#">PX7j4coCVBymjz+tG/Xy+0IvgDYNU5/rfoOWFZecf3eKF5oXKUm1YBK/2uuHZ1nDb5AWb8zgLaF/NpjLkJ5lfJmN+M2cyd0fgm4XGd2Eu+P/7mmG9+HYGrik/SCKWibQab8x3ZDCt5znDbQyakVTeE4oAtzxcHW/blGJ0mtqmyU=</ds:SignatureValue>'; 

		body += '			<ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#"> ';
		body += '				<ds:X509Data xmlns:ds="http://www.w3.org/2000/09/xmldsig#">'; 
		body += '					<ds:X509Certificate xmlns:ds="http://www.w3.org/2000/09/xmldsig#">'+dsx509Certificate+'</ds:X509Certificate>';
		body += '				</ds:X509Data> ';
		body += '			</ds:KeyInfo> ';

		body += '		</ds:Signature> ';

		body += '		<ns2:Subject>'; 
		body += '			<ns2:NameID Format="urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified">C1466791</ns2:NameID>'; 
		body += '			<ns2:SubjectConfirmation Method="urn:oasis:names:tc:SAML:2.0:cm:bearer"> ';
		body += '				<ns2:SubjectConfirmationData NotOnOrAfter="'+notOnOrAfter+'" Recipient="'+salesforceLoginURL+'"/>'; 
		body += '			</ns2:SubjectConfirmation>'; 
		body += '        </ns2:Subject> ';

		body += '        <ns2:Conditions NotBefore="'+notBefore+'" NotOnOrAfter="'+notOnOrAfter+'">'; 
		body += '            <ns2:AudienceRestriction> ';
		body += '                <ns2:Audience>salesforcetravel</ns2:Audience>'; 
		body += '            </ns2:AudienceRestriction> ';
		body += '            <ns2:AudienceRestriction> ';
		body += '                <ns2:Audience>https://saml.salesforce.com</ns2:Audience>'; 
		body += '            </ns2:AudienceRestriction>'; 
		body += '        </ns2:Conditions> ';
		body += '        <ns2:AuthnStatement AuthnInstant="'+AuthInstant+'" SessionIndex="Q+pzvs+8Rr7Z6tlt8IIpmRVDFdY=zIabKw==" SessionNotOnOrAfter="'+notOnOrAfter+'">'; 

		body += '            <ns2:AuthnContext> ';
		body += '                <ns2:AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:Password</ns2:AuthnContextClassRef>'; 
		body += '            </ns2:AuthnContext> ';
		body += '        </ns2:AuthnStatement> ';

		body += '        <ns2:AttributeStatement> ';
		body += '            <ns2:Attribute Name="federationId" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified">'; 
		body += '                <ns2:AttributeValue>mkpartners</ns2:AttributeValue>'; 
		body += '            </ns2:Attribute> ';

		body += '            <ns2:Attribute Name="portal_id">';
		body += '                <ns2:AttributeValue>060D00000000SHZ</ns2:AttributeValue>'; 
		body += '            </ns2:Attribute> ';

		body += '            <ns2:Attribute Name="organization_id">';
		body += '                <ns2:AttributeValue>00DD0000000F7Z5</ns2:AttributeValue>'; 
		body += '            </ns2:Attribute> ';

		body += '            <ns2:Attribute Name="ssoStartPage" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified">'; 
		body += '                <ns2:AttributeValue>http://www.defweb.com/travelforcelogin</ns2:AttributeValue>'; 
		body += '            </ns2:Attribute> ';
		body += '            <ns2:Attribute Name="logoutURL" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified"> ';
		body += '                <ns2:AttributeValue>https://central101.intra.abc.com/portal/site/defweb/menuitem.daa2dd4f4649fd301aae0ff54c2bda49/&amp;level=1?epi-content=CMU&amp;cmu_page=10002295&amp;format=leftmidwithoutcolor&amp;leftnav=false</ns2:AttributeValue>'; 
		body += '            </ns2:Attribute> ';
		body += '        </ns2:AttributeStatement>'; 
		body += '    </ns2:Assertion>'; 
		body += '</Response>'; 
		return body;
	}


	public Blob getSAMLAssertion2(){
		String body = '';
		body += '<samlp:Response  ID="_257f9d9e9fa14962c0803903a6ccad931245264310738" IssueInstant="2009-06-17T18:45:10.738Z"  Version="2.0">';
		body += '<saml:Issuer  Format="urn:oasis:names:tc:SAML:2.0:nameid-format:entity">https://www.salesforce.com</saml:Issuer>';
		body += '<samlp:Status>';
		body += '	<samlp:StatusCode  Value="urn:oasis:names:tc:SAML:2.0:status:Success"/>';
		body += '</samlp:Status>';
		body += '<saml:Assertion  ID="_3c39bc0fe7b13769cab2f6f45eba801b1245264310738" IssueInstant="2009-06-17T18:45:10.738Z"  Version="2.0">';
		body += '<saml:Issuer  Format="urn:oasis:names:tc:SAML:2.0:nameid-format:entity">https://www.salesforce.com</saml:Issuer>';
		body += '<saml:Subject>';
		body += '<saml:NameID  Format="urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified">saml01@salesforce.com</saml:NameID>';
		body += '<saml:SubjectConfirmation  Method="urn:oasis:names:tc:SAML:2.0:cm:bearer">';
		body += '<saml:SubjectConfirmationData  NotOnOrAfter="2009-06-17T18:50:10.738Z" Recipient="https://login.www.salesforce.com"/>';
		body += '</saml:SubjectConfirmation>';
		body += '</saml:Subject>';
		body += '<saml:Conditions  NotBefore="2009-06-17T18:45:10.738Z" NotOnOrAfter="2009-06-17T18:50:10.738Z">';
		body += '<saml:AudienceRestriction>';
		body += '<saml:Audience>https://saml.salesforce.com</saml:Audience>';
		body += '</saml:AudienceRestriction>';
		body += '</saml:Conditions>';
		body += '<saml:AuthnStatement  AuthnInstant="2009-06-17T18:45:10.738Z">';
		body += '<saml:AuthnContext>';
		body += '<saml:AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:unspecified</saml:AuthnContextClassRef>';
		body += '</saml:AuthnContext>';
		body += '</saml:AuthnStatement>';
		body += '<saml:AttributeStatement>';
		body += '<saml:Attribute  Name="portal_id">';
		body += '<saml:AttributeValue  xsi:type="xs:anyType">060D00000000SHZ';
		body += '</saml:AttributeValue>';
		body += '			</saml:Attribute>';
		body += '			<saml:Attribute  Name="organization_id">';
		body += '				<saml:AttributeValue  xsi:type="xs:anyType">00DD0000000F7L5</saml:AttributeValue>';
		body += '			</saml:Attribute>';
		body += '			<saml:Attribute  Name="ssostartpage" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified">';
		body += '				<saml:AttributeValue  xsi:type="xs:anyType">http://www.salesforce.com/security/saml/saml20-gen.jsp</saml:AttributeValue>';
		body += '			</saml:Attribute>';
		body += '			<saml:Attribute  Name="logouturl" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri">';
		body += '				<saml:AttributeValue  xsi:type="xs:string">http://www.salesforce.com/security/del_auth/SsoLogoutPage.html</saml:AttributeValue>';
		body += '			</saml:Attribute>';
		body += '		</saml:AttributeStatement>';
		body += '	</saml:Assertion>';
		body += '</samlp:Response>';
		return blob.valueOf(body);
	}

	public String getSAMLAssertion1(){
		String body = '';
		body += '<samlp:Response ID="_f97faa927f54ab2c1fef230eee27cba21245264205456" IssueInstant="' + system.now() + '" Version="2.0">';

		body += '	<saml:Issuer Format="urn:oasis:names:tc:SAML:2.0:nameid-format:entity">https://www.salesforce.com</saml:Issuer>';

		body += '	<samlp:Status>';
		body += '		<samlp:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Success"/>';
		body += '	</samlp:Status>';

		body += '	<saml:Assertion ID="_f690da2480a8df7fcc1cbee5dc67dbbb1245264205456" IssueInstant="' + system.now() + '" Version="2.0">';
		body += '		<saml:Issuer Format="urn:oasis:names:tc:SAML:2.0:nameid-format:entity">https://www.salesforce.com</saml:Issuer>';

		body += '		<saml:Subject>';
		body += '			<saml:NameID Format="urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified">' + userName + '</saml:NameID>';
		body += '			<saml:SubjectConfirmation Method="urn:oasis:names:tc:SAML:2.0:cm:bearer">';
		body += '				<saml:SubjectConfirmationData NotOnOrAfter="' + (system.now()+1.5) + '" Recipient="https://www.salesforce.com/?saml=02HKiPoin4f49GRMsOdFmhTgi_0nR7BBAflopdnD3gtixujECWpxr9klAw"/>';
		body += '			</saml:SubjectConfirmation>';
		body += '		</saml:Subject>';

		body += '		<saml:Conditions NotBefore="' + (system.now()-1.5) + '" NotOnOrAfter="' + (system.now()+1.5) + '">';
		body += '			<saml:AudienceRestriction>';
		body += '				<saml:Audience>https://saml.salesforce.com</saml:Audience>';
		body += '			</saml:AudienceRestriction>';
		body += '		</saml:Conditions>';

		body += '		<saml:AuthnStatement AuthnInstant="' + system.now() + '">';
		body += '			<saml:AuthnContext>';
		body += '				<saml:AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:unspecified</saml:AuthnContextClassRef>';
		body += '			</saml:AuthnContext>';
		body += '		</saml:AuthnStatement>';

		body += '		<saml:AttributeStatement>';

		body += '         <saml:Attribute FriendlyName="Friendly Name" Name="federationId" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified">';
		body += '            <saml:AttributeValue xsi:type="xs:string">'+federationId+'</saml:AttributeValue>';
//		body += '            <saml:AttributeValue xsi:type="xs:string">SomeOtherValue</saml:AttributeValue>';
		body += '         </saml:Attribute>';

		body += '         <saml:Attribute Name="portal_id">';
		body += '            <saml:AttributeValue xsi:type="xs:anyType">'+portalId+'</saml:AttributeValue>';
		body += '         </saml:Attribute>';

		body += '         <saml:Attribute Name="organization_id">';
		body += '            <saml:AttributeValue xsi:type="xs:anyType">'+orgId+'</saml:AttributeValue>';
		body += '         </saml:Attribute>';

		body += '         <saml:Attribute Name="ssostartpage" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified">';
		body += '            <saml:AttributeValue xsi:type="xs:anyType">http://www.salesforce.com/qa/security/saml/saml20-gen.jsp</saml:AttributeValue>';
		body += '         </saml:Attribute>';

		body += '         <saml:Attribute Name="logouturl" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri">';
		body += '            <saml:AttributeValue xsi:type="xs:string">http://www.salesforce.com/qa/security/del_auth/SsoLogoutPage.html</saml:AttributeValue>';
		body += '         </saml:Attribute>';

		body += '      </saml:AttributeStatement>';
		body += '   </saml:Assertion>';
		body += '</samlp:Response>';
		return body;
	}



}