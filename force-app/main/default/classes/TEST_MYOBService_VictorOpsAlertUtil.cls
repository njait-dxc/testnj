/**
 * Created by Ankit.Bhardwaj on 1/07/2020.
 */

@IsTest
public with sharing class TEST_MYOBService_VictorOpsAlertUtil {

    @IsTest static void sendVictorOpsAlertByAPI()
    {
        List<Exception_Log__c> logs = new List<Exception_Log__c>();
        Exception_Log__c exceptionLog = new Exception_Log__c();
        exceptionLog.Exception_Details__c = 'Test';
        exceptionLog.Exception_Description__c = 'Test Description';
        logs.add(exceptionLog);

        insert logs;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MYOBServicesMockResponse());
        System.enqueueJob(new MYOBService_VictorOpsScheduleWrapper(logs));
        Integer count = Limits.getQueueableJobs();
        System.assertEquals(1,count);
        Test.stopTest();

    }
}