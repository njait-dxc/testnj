/**
 * Created by Ankit.Bhardwaj on 25/06/2020.
 */

public with sharing class MYOBService_VictorOpsEmailUtility {
    private static final String API_NAME = 'VictorOps Email Endpoint';

    @InvocableMethod
    public static void sendVictorOpsAlert(List<messageInputs> inputs)
    {
        String sub;
        String body;

        for(messageInputs inp : inputs)
        {
            sub = inp.subject;
            body = inp.body;
        }
        //retrieve API details
        MYOB_Service_API__mdt myobServiceAPI = MYOBService.getMYOBService(API_NAME);
        // below code will send an email to victorops
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toaddress = new String[] {myobServiceAPI.Endpoint__c};
        mail.setToAddresses(toaddress);
       // mail.setReplyTo('SFSupportEnquiries@myob.com');
        mail.setSenderDisplayName('Salesforce VictorOps Alert');
        mail.setSubject(sub);
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage [] {mail});

    }

    //input details that comes to apex from flows
    public class messageInputs{

        @InvocableVariable
        public String subject;

        @InvocableVariable
        public String body;

    }

}