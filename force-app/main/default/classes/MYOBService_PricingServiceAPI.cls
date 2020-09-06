public with sharing class MYOBService_PricingServiceAPI
{
    /*
    Available methods
    =================
    [1] MYOBService_PricingServiceAPI.getPromoCodes(String clientId, Integer productId);
    */

    private static final String API_NAME = 'Pricing Service API';
    private static final String ENDPOINT_PATH_GETPROMOCODES = '/api/promotions';

    public static List <Promotion> getPromoCodes(String clientId, Integer productId, String channel)
    {
        // Retrive API details for custom metadata
        MYOB_Service_API__mdt myobServiceAPI = MYOBService.getMYOBService(API_NAME);

        // Retrieve access token from Authorisation API
        MYOBService_AuthorisationAPI.AccessToken_Response accessTokenResponse = MYOBService_AuthorisationAPI.getAccessToken(myobServiceAPI.Resource_Id__c);

        // Define HTTP Request
        HttpRequest httpRequest = new HttpRequest();
        
        // Set HTTP Request parameters
        httpRequest.setMethod('GET');
        
        // Set HTTP Request Timeout
        httpRequest.setTimeout(30000);
        
        // Set HTTP Request endpoint
        String endpoint = myobServiceAPI.Endpoint__c;
        endpoint += ENDPOINT_PATH_GETPROMOCODES;
        endpoint += '?clientId=' + EncodingUtil.urlEncode(clientId, 'UTF-8');
        endpoint += '&productId=' + EncodingUtil.urlEncode(String.valueOf(productId), 'UTF-8');
        endpoint += '&Channel=' + EncodingUtil.urlEncode(channel, 'UTF-8');
        httpRequest.setEndpoint(endpoint);

        // Set HTTP Request headers
        Map <String, String> requestHeaders = new Map <String, String>();
        requestHeaders.put('X-MYOBAPI-VERSION', 'v2');
        requestHeaders.put('Content-Type', 'application/json');
        requestHeaders.put('Authorization', 'Bearer ' + accessTokenResponse.access_token);
        for (String key : requestHeaders.keySet())
        {
            httpRequest.setHeader(key, requestHeaders.get(key));
        }

        // Send HTTP Request via APICallLogger
        HttpResponse httpResponse = APICallLogger.send(httpRequest, requestHeaders);

        // Insert API Call Logs
        APICallLogger.insertLogs();

        // Deserialise JSON Response
        List <Promotion> promotions = (List <Promotion>) JSON.deserialize(httpResponse.getBody(), List <Promotion>.class);
        
        // Return deserialised JSON Response
        return promotions;
    }

    public class Promotion
    {
        public Deal deal;
        public String displayName;
        public Integer id;
        public String name;
        public String promoCode;
        public String status;
        public String promotionTerms;
    }

    private class Deal
    {
      public Date availableUntil;
      public Date effectiveUntil;
      public Integer freePeriod;
      public String name;
    }
}