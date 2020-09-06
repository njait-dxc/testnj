public with sharing class MYOBService_AuthorisationAPI
{
	/*
	Available methods
	=================
	[1] MYOBService_AuthorisationAPI.AccessToken_Response getAccessToken(String resourceId)
	*/

	public static Boolean IS_SANDBOX
	{
		get
		{
			if(IS_SANDBOX == null)
			{
				IS_SANDBOX = [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
			}
			return IS_SANDBOX;
		}
		private set;
	}

	public static AccessToken_Response getAccessToken(String resourceId)
	{
		// Define HTTP Request
		HttpRequest httpRequest = new HttpRequest();

		// Set HTTP Request Method
		httpRequest.setMethod('POST');

		if (IS_SANDBOX)
		{
			httpRequest.setEndpoint('callout:IDAM_OAuthSIT');
			//httpRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
			//httpRequest.setHeader('Content-Length', '0');
			//httpRequest.setHeader('Authorization', 'Basic ODI2NzkyNjAtNjQ1ZC00ZjgwLTlkZGUtNzkxYzhhNDI5OGFlOjxOL29Ue21CYGpSN0hwJGQqZW4k');
		}
		else
		{
			// Set HTTP Request Endpoint
			httpRequest.setEndpoint('callout:IDAM_OAuth');
		}

		// Set HTTP Request Body
		String body = '';
		body += 'grant_type=client_credentials';
		body += '&resource=' + EncodingUtil.urlEncode(resourceId, 'UTF-8');
		httpRequest.setBody(body);

		// Send HTTP Request via APICallLogger
		HttpResponse httpResponse = APICallLogger.send(httpRequest, null);

		// Deserialise JSON Response
		AccessToken_Response accessToken = (AccessToken_Response)JSON.deserialize(httpResponse.getBody(), AccessToken_Response.class);

		// Return deserialised JSON Response
		return accessToken;
	}

	public class AccessToken_Response
	{
		public String access_token;
		public Integer expires_in;
		public Integer expires_on;
		public Integer issued_at;
		public String resource;
		public String scope;
		public String token_type;
		public String error;
		public String error_description;
	}
}