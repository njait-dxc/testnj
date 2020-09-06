/**
 * Created by Ankit.Bhardwaj on 6/02/2020.
 */

global class MYOBService_PubSubMessageDeleteUtility implements Database.Batchable<sobject>, Database.AllowsCallouts, Database.Stateful
{

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String Query = 'SELECT Id,Provisioning_Status__c,PubSub_Message_Receipt_Id__c FROM OpportunityLineItem WHERE Bulk_Purchase_Id__c != NULL AND Provisioning_Status__c != \'In Progress\'';
        return Database.getQueryLocator(Query);
    }

    global void execute(Database.BatchableContext bc, List<OpportunityLineItem> scope)
    {
        for (OpportunityLineItem opl: scope)
        {
            if (opl.PubSub_Message_Receipt_Id__c != null)
            {
                String API_NAME = 'PubSub Order Tracking Service';
                MYOB_Service_API__mdt myobServiceAPI = MYOBService.getMYOBService(API_NAME);
                MYOBService_AuthorisationAPI.AccessToken_Response accessTokenResponse= MYOBService_AuthorisationAPI.getAccessToken(myobServiceAPI.Resource_Id__c);

                HttpRequest httpRequest = new HttpRequest();
                httpRequest.setEndpoint(myobServiceAPI.Endpoint__c + '?receiptId=' + opl.PubSub_Message_Receipt_Id__c);
                httpRequest.setMethod('DELETE');
                Map <String, String> requestHeaders = new Map <String, String>();
                requestHeaders.put('Content-Type', 'application/json');
                if(Test.IsRunningTest())
                {
                    requestHeaders.put('Authorization', 'Bearer ' + 'abcde');
                }
                else {
                    requestHeaders.put('Authorization', 'Bearer ' + accessTokenResponse.access_token);
                }
                for (String key : requestHeaders.keySet()) {
                    httpRequest.setHeader(key, requestHeaders.get(key));
                }

                HttpResponse httpResponse = APICallLogger.send(httpRequest, requestHeaders);
                opl.PubSub_Message_Receipt_Id__c = null;
            }

        }

        Database.SaveResult[] saveOptyLines = Database.update(scope, false);
        APICallLogger.insertLogs();
    }

    global void finish(Database.BatchableContext bc)
    {

    }
}