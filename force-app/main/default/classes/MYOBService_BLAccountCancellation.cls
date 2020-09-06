/**
 * Created by Ankit.Bhardwaj on 12/02/2020.
 */

global class MYOBService_BLAccountCancellation {
    public static final String API_NAME = 'BankLink Cancellation API';

    public static void callBanklinkCancellator(String caseNumber)
    {
        cancelBankLinkAccount(caseNumber);
    }

    @future (callout=true) webService static void cancelBankLinkAccount(String caseNumber)
    {
        MYOB_Service_API__mdt myobServiceAPI = MYOBService.getMYOBService(API_NAME);
        MYOBService_AuthorisationAPI.AccessToken_Response accessTokenResponse = MYOBService_AuthorisationAPI.getAccessToken(myobServiceAPI.Resource_Id__c);

        bankLinkCancelRequest requestBody = new bankLinkCancelRequest();
        requestBody.case_id = caseNumber;

        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('PUT');
        httpRequest.setTimeout(30000);
        httpRequest.setEndpoint(myobServiceAPI.Endpoint__c);
        Map <String, String> requestHeaders = new Map <String, String>();
        requestHeaders.put('Content-Type', 'application/json');
        requestHeaders.put('Authorization', 'Bearer ' + accessTokenResponse.access_token);
        for (String key : requestHeaders.keySet())
        {
            httpRequest.setHeader(key, requestHeaders.get(key));
        }
        System.debug(requestHeaders);
        httpRequest.setBody(JSON.serialize(requestBody));
        HttpResponse httpResponse = APICallLogger.send(httpRequest, requestHeaders);

        APICallLogger.insertLogs();
    }

    public class bankLinkCancelRequest
    {
        public String case_id;
    }
}