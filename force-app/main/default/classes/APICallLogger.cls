/**
 * @author
 * @date
 * @description
 */

public with sharing class APICallLogger
{
	public static List <API_Call_Log__c> apiCallLogs = new List <API_Call_Log__c>();

	/**
	 * @param httpRequest
	 * @param requestHeaderMap
	 * @return
	 * @description
	 */

	public static HttpResponse send(HttpRequest httpRequest, Map <String, String> requestHeaderMap)
	{
		// Initialise HTTP
		Http http = new Http();

		// Initialise API Call Log Record
		API_Call_Log__c apiCallLog = new API_Call_Log__c();

		// Populate API Call Log Details
		apiCallLog.Request_Endpoint__c = httpRequest.getEndpoint();
		apiCallLog.Request_Method__c = httpRequest.getMethod();
		apiCallLog.Request_Body__c = httpRequest.getBody();

		// Populate API Call Log Request Headers
		if (requestHeaderMap != null)
		{
			String requestHeaders = '';
			for (String headerKey : requestHeaderMap.keySet())
			{
				if (headerKey == 'Authorization')
				{
					requestHeaders = headerKey + ': [Hidden] ' + '\n';
					continue;
				}

				String headerValue = requestHeaderMap.get(headerKey);
				requestHeaders = headerKey + ': ' + headerValue + '\n';
			}
			requestHeaders.removeEnd('\n');
			apiCallLog.Request_Headers__c = requestHeaders;
		}

		// Record HTTP Request send time
		apiCallLog.Request_Sent__c = System.now();

		// Send HTTP Request
		HttpResponse httpResponse = http.send(httpRequest);

		// Record HTTP Response time
		apiCallLog.Response_Received__c = System.now();

		// Calculate Execution time
		apiCallLog.Execution_Time__c = (apiCallLog.Response_Received__c.getTime() - apiCallLog.Request_Sent__c.getTime()) / 1000.0;

		// Populate HTTP response details
		apiCallLog.Response_Status__c = httpResponse.getStatus();
		apiCallLog.Response_Status_Code__c = httpResponse.getStatusCode();

		// Populate HTTP response headers
		String responseHeaders = '';
		for (String headerKey : httpResponse.getHeaderKeys())
		{
			String value = httpResponse.getHeader(headerKey);
			responseHeaders = headerKey + ': ' + value + '\n';
		}
		responseHeaders.removeEnd('\n');
		apiCallLog.Response_Headers__c = responseHeaders;

		// Populate HTTP Response Body
		try
		{
			String prettyJSONBody = JSON.serializePretty(JSON.deserializeUntyped(httpResponse.getBody()));
			apiCallLog.Response_Body__c = prettyJSONBody;
		}
		catch (Exception exceptionObject)
		{
			apiCallLog.Response_Body__c = httpResponse.getBody();
			apiCallLogs.add(apiCallLog);
		}

		// Insert API Call Log
		apiCallLogs.add(apiCallLog);

		// Return HTTP Response
		return httpResponse;
	}
	/**
	 *
	 * @return
	 * @description
	 */
	public static API_Call_Log__c getCurrentLog()
	{
		if (apiCallLogs.size() > 0)
		{   return apiCallLogs.get(apiCallLogs.size() - 1);
		}
		return null;
	}

	/**
	 * @description
	 */
	public static void insertLogs()
	{
		insert apiCallLogs;
	}
}