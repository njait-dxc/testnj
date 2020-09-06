/**
 * Created by Ankit.Bhardwaj on 1/07/2020.
 */

public with sharing class MYOBService_VictorOpsAPIAlertUtil {

    private static final String API_NAME = 'VictorOps Endpoint';
    @InvocableMethod
    public static void sendVictorOpsAlertByAPI(List<alertInputs> inputs)
    {
        String subject;
        String payload;
        String alertType;

        if(inputs.size() > 0)
        {
            for(alertInputs ai: inputs)
            {
                subject = ai.subject;
                payload = ai.payload;
                alertType = ai.alertType;
            }
        }
        Map<String,String> data = new Map<String, String>();
        Map <String, String> requestHeaders = new Map <String, String> { 'Content-Type' => 'application/json'};
        MYOB_Service_API__mdt myobServiceAPI = MYOBService.getMYOBService(API_NAME);
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('POST');
        data.put('message_type',alertType);
        data.put('entity_id',subject);
        data.put('subject',subject);
        data.put('monitoring_tool', 'SalesForce');
        data.put('state_message', payload);
        String body = JSON.serialize(data);
        httpRequest.setBody(body);
        httpRequest.setEndpoint(myobServiceAPI.Endpoint__c);
        httpRequest.setHeader('Content-Type','application/json');

        HttpResponse resp = APICallLogger.send(httpRequest,requestHeaders);
    }

    //input details that comes to class
    public class alertInputs{

        @InvocableVariable
        public String subject;

        @InvocableVariable
        public String payload;

        @InvocableVariable
        public String alertType;

    }
}