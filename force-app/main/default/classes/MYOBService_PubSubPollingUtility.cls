/**
 * Created by Ankit.Bhardwaj on 22/Jan/2020.
 */

global class MYOBService_PubSubPollingUtility {

    public static final String API_NAME = 'PubSub Order Tracking Service';
    public static Integer lastStatusCode = 200;

      public static void pollPubSubQueue(){
        List<Support_Setting__mdt> supportSetting = [SELECT Value__c, Id FROM Support_Setting__mdt WHERE MasterLabel = 'PubSubPollingCounter'];

          Integer Count = 0;
          Integer submitCount = Integer.valueof(supportSetting.get(0).Value__c);
              if(Test.IsRunningTest())
              {
                  submitCount = 1;
              }

            do {
                processMessageFromPubSubQueue();
                Count++;
            } while (Count < submitCount);

    }

    @future (callout=true) webService static void processMessageFromPubSubQueue () {
        MYOB_Service_API__mdt myobServiceAPI = MYOBService.getMYOBService(API_NAME);
        MYOBService_AuthorisationAPI.AccessToken_Response accessTokenResponse = MYOBService_AuthorisationAPI.getAccessToken(myobServiceAPI.Resource_Id__c);

        if(Test.IsRunningTest())
        {

            Map<String,String> resultMap = new Map<String, String>();
            String removeMessageFlag = 'N';
            resultMap = getMessageFromQueue('abcde',myobServiceAPI.Endpoint__c);
            removeMessageFlag = updateOpyLineItem(statusMapper(resultMap.get('status')),resultMap.get('id'),resultMap.get('messageReceiptId'));
            if (removeMessageFlag == 'N')
            {
                removeMessageFromQueue(resultMap.get('messageReceiptId'), resultMap.get('endPoint'),'abcde');
            }
        }
        else {
            Map<String, String> resultMap = new Map<String, String>();
            String removeMessageFlag = 'N';
            resultMap = getMessageFromQueue(accessTokenResponse.access_token, myobServiceAPI.Endpoint__c);
            if(resultMap.get('status') != null && resultMap.get('status') != '') {
                removeMessageFlag = updateOpyLineItem(statusMapper(resultMap.get('status')), resultMap.get('id'),resultMap.get('messageReceiptId'));
                if (removeMessageFlag == 'N')
                {
                    removeMessageFromQueue(resultMap.get('messageReceiptId'), myobServiceAPI.Endpoint__c,accessTokenResponse.access_token);
                }
            }
            APICallLogger.insertLogs();
        }

    }

    // callout to pubsub queue to fetch the message
    public static Map<String,String> getMessageFromQueue (String accessToken, String endPoint){
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('GET');
        httpRequest.setTimeout(30000);
        httpRequest.setEndpoint(endPoint);
        Map <String, String> requestHeaders = new Map <String, String>();
        requestHeaders.put('Content-Type', 'application/json');
        requestHeaders.put('Authorization', 'Bearer ' + accessToken);
        for (String key : requestHeaders.keySet())
        {
            httpRequest.setHeader(key, requestHeaders.get(key));
        }
        HttpResponse httpResponse = APICallLogger.send(httpRequest, requestHeaders);
        lastStatusCode = httpResponse.getStatusCode();
        PubSubResponse responseBody = new PubSubResponse();
        Map<String, String> responseMap = new Map<String, String>();
        if (lastStatusCode == 200) {

            responseBody = (PubSubResponse) JSON.deserialize(httpResponse.getBody(), PubSubResponse.class);
            responseMap.put('status', responseBody.data[0].message.status);
            responseMap.put('id', responseBody.data[0].message.id);
            responseMap.put('messageReceiptId', responseBody.data[0].receiptId);
        }
        return responseMap;
    }

    //delete the message from the pubsub queue

    public static void removeMessageFromQueue(String receiptId, String endPoint, String accessToken)
    {
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint(endPoint + '?receiptId=' + receiptId);
        httpRequest.setMethod('DELETE');
        Map <String, String> requestHeaders = new Map <String, String>();
        requestHeaders.put('Content-Type', 'application/json');
        requestHeaders.put('Authorization', 'Bearer ' + accessToken);
        for (String key : requestHeaders.keySet())
        {
            httpRequest.setHeader(key, requestHeaders.get(key));
        }

        HttpResponse httpResponse = APICallLogger.send(httpRequest, requestHeaders);

    }

//update line item status by querying with the bulk purchase id
    private static String updateOpyLineItem(String status, String bulkPurchaseId, String receiptId){
            String optyFound = 'Y';
            List<OpportunityLineItem> optyLineItems = [SELECT Id,Provisioning_Status__c,PubSub_Message_Receipt_Id__c FROM OpportunityLineItem WHERE Bulk_Purchase_Id__c = :bulkPurchaseId AND Provisioning_Status__c = 'In Progress'];
            if (optyLineItems.size() > 0) {
                for (OpportunityLineItem opl : optyLineItems) {
                    opl.Provisioning_Status__c = status;
                    System.debug(receiptId);
                    opl.PubSub_Message_Receipt_Id__c = receiptId;
                }
                update optyLineItems;
            } else {
                optyFound = 'N';
            }
        return optyFound;
    }

    public static String statusMapper(String provisioningStatus)
    {
        if (provisioningStatus == 'PURCHASE_COMPLETE')
        {
            provisioningStatus = 'Complete';
        }
        else
        {
            provisioningStatus = 'Error';

        }
        System.debug(provisioningStatus);
        return provisioningStatus;
    }

    //create wrapper for pubsub message response
    private class PubSubResponse
    {
        public List<PubSubResponseData> data;
    }
    private class PubSubResponseData
    {
        public PubSubResponseMessage message;
        public String receiptId;
        public String messageId;
    }
    private class PubSubResponseMessage
    {
        public String id;
        public String status;
        public String type;
    }
}