@IsTest
public class LDContactRecertificationScoreBatch_Test {
    @TestSetup static void dataSetUp()
    {
        /*learndot__Learndot_Account__c ldAccountRecord = new learndot__Learndot_Account__c();
        ldAccountRecord.learndot__ID__c = '12321';
        ldAccountRecord.Name = 'Test LdAccount';
        insert ldAccountRecord;
        //Creating SF Contact
        Contact conObj = new Contact();
        conObj.LastName = 'testSF Contact';
        conObj.Email = 'Test@email.com';
        insert conObj;
        //Creating Learndot Contact
        learndot__Learndot_Contact__c ldContactRecord = new learndot__Learndot_Contact__c();
        ldContactRecord.learndot__ID__c = '1231234';
        ldContactRecord.learndot__External_ID__c = conObj.Id;
        ldContactRecord.learndot__Salesforce_Contact__c = conObj.Id;
        ldContactRecord.learndot__ID__c = '4824';
        ldContactRecord.Name = 'Test LdContact';
        insert ldContactRecord;*/
    }
    public static testMethod void recertificationBatch()
    {
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new RecertificationMock());
        //LDContactRecertificationScoreBatch batch = new LDContactRecertificationScoreBatch();
        //Database.executeBatch(batch);
        Test.stopTest();
        
    }
}