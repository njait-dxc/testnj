/**
 * Created by Ankit.Bhardwaj on 1/07/2020.
 */

public with sharing class MYOBService_VictorOpsScheduleWrapper implements Queueable,Database.AllowsCallouts {
    public List<Exception_Log__c> log = new List<Exception_Log__c>();

    public MYOBService_VictorOpsScheduleWrapper(List<Exception_Log__c> record)
    {
        this.log = record;
    }
    public void execute(QueueableContext context) {
        //get the details of inputs
        if(log.size() > 0) {
            Integer logSize = log.size();
            Id recordId = log[0].Id;
            String exceptionDetail = log[0].Exception_Details__c;
            String exceptionDescription = log[0].Exception_Description__c;

            //create url to the link
            String link = URL.getSalesforceBaseUrl().toExternalForm() + '/' + recordId;

            //Create Subject and Body
            String subject = 'Exception - ' + exceptionDetail + 'List Size - '+ logSize +' Link To Exception Log - ' + link;
            String body = exceptionDescription;
            String alertType = 'warning';
            if(!Test.isRunningTest()) {
                Support_Setting__mdt supportSetting = [SELECT Value__c, Id FROM Support_Setting__mdt WHERE MasterLabel = 'VictorOps AlertType'];
                alertType = supportSetting.Value__c;
            }
            //build the list to pass an input
            List<MYOBService_VictorOpsAPIAlertUtil.alertInputs> inputs = new List<MYOBService_VictorOpsAPIAlertUtil.alertInputs>();
            MYOBService_VictorOpsAPIAlertUtil.alertInputs i = new MYOBService_VictorOpsAPIAlertUtil.alertInputs();
            i.subject = subject;
            i.payload = body;
            i.alertType = alertType;
            inputs.add(i);

            MYOBService_VictorOpsAPIAlertUtil.sendVictorOpsAlertByAPI(inputs);
        }
    }

}