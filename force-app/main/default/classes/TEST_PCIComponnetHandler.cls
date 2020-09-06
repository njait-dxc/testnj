@IsTest
public class TEST_PCIComponnetHandler 
{
    @TestSetup static void setUpData()
    {
        Account ac = new Account (Name= 'Test AC', Client_ID__c = '10131271');
        insert ac;
        Contact con = new Contact (AccountId = ac.id, Contact_Siebel_Row_Id__c = '1-4ZX1403', FirstName='First1', LastName='Last1');
        insert con;
        Id pricebookId = Test.getStandardPricebookId();
        Id SMEOptyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SME Purchase Opportunity').getRecordTypeId();
        Opportunity opp = new Opportunity(AccountId = ac.id, Main_Contact__c = con.id, Name='test purchase opp',StageName='Prospect', Probability = 95, CloseDate=system.today(), RecordTypeId = SMEOptyRecordTypeId);
        insert opp;    
    } 
    
    @IsTest
    static void testExecution()
    {
        Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name='test purchase opp'];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TEST_CreditCardPaymentProfileMock());
		String paymentProfileId = MYOB_PCIComponnetHandler.callPaymentProfileCreation(
			testOpp.Id,
            'RR', 
            'C4NDGLAM1YA1C5HK', 
            '1111', 
            'Visa', 
            '12', 
            '2030', 
            'Monthly', 
            'Credit Card');
        Test.stopTest();
        
        System.assertNotEquals(null, paymentProfileId);
        
    } 
}