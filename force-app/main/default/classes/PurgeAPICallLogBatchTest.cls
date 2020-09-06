@IsTest
public class PurgeAPICallLogBatchTest {
	@IsTest
    static void PurgeAPICallLogBatch() {
        API_Call_Log__c apiCallLog = TestDataFactory.createAPICallLog('GET', true);
        Datetime daysBack = Datetime.now().addDays(-20);
		Test.setCreatedDate(apiCallLog.Id, daysBack);
        
        Test.startTest();
        Id batchprocessid = Database.executeBatch(new PurgeAPICallLogBatch());
        Test.stopTest();
        List<API_Call_Log__c> apiCallLogList = [SELECT Id FROM API_Call_Log__c];
        System.assertEquals(apiCallLogList.size(), 0);
    }    
}