public with sharing class TRIG_LogEvent_TriggerHandler extends TriggerHandler
 {

public override void afterInsert(){

	LogEvent((List<LogEvent__e>) Trigger.new);

}
public static void LogEvent(List<LogEvent__e> logEventList)
{

// List to hold all cases to be created.
    List<Exception_Log__c> logList = new List<Exception_Log__c>();

// Iterate through each notification.

    System.debug('\n\nTRIGGER: ' + logEventList);

    for (LogEvent__e event : logEventList) {
        Exception_Log__c nLog = new Exception_Log__c();
        nLog.Current_User__c = event.CurrentUser__c;
        nLog.Exception_Details__c = event.Stack__c;
        nLog.Input__c = event.Input__c;
        nLog.Exception_Description__c = event.Message__c;
        nLog.Exception_Type__c = event.Type__c;
        nLog.Priority__c = event.Priority__c;
        nLog.Class_Name__c = event.Class_Name__c;
        nLog.Method_Name__c = event.Method_Name__c;
        nLog.JobId__c = event.JobId__c;
        logList.add(nLog);
    }
    System.debug('\n\nTRIGGER logList: ' + logList);
    // Insert all cases in the list.
    if (logList.size() > 0) {
        insert logList;
        //send alert
        if(!Test.isRunningTest()) {
            ID jobId = System.enqueueJob(new MYOBService_VictorOpsScheduleWrapper(logList));
        }
    }
}
}