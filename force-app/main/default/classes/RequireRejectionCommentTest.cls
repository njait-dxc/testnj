@IsTest
public class RequireRejectionCommentTest {
    
    @TestSetup
    public static void init() {        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User user = new User(Alias = 'standt2', Email='standarduser2@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', Username='standarduser2@testorg.com');
        //insert user;
        
        // create account
        Account account = new Account(Name = 'Acc', Type = 'Customer', Industry = 'Automotive');
        insert account; 
		Id CMOptyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Client Manager April.2017').getRecordTypeId();
        // create opportunity
        Opportunity opp = new Opportunity(AccountId = account.Id, Name = 'Opp', StageName = 'Open',
                                          CloseDate = Date.newInstance(2017,10,10), CurrencyIsoCode='AUD', Approval_Status__c = 'None' ,RecordTypeId = CMOptyRecordTypeId);
        insert opp;

        // Create an approval request for the opp
        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
        request.setComments('Submitting request for approval.');
        request.setObjectId(opp.Id);

        // Submit on behalf of a specific submitter
        request.setSubmitterId(user.Id); 

        // Submit the record to specific process and skip the criteria evaluation
        request.setProcessDefinitionNameOrId('Opportunity_Approval_Process_5');
        request.setSkipEntryCriteria(true);

        // Submit the approval request for the opp, and we should get a ProcessInstance record
        Approval.ProcessResult result = Approval.process(request);
    }
    
    @IsTest
    public static void test() {
        // update opp
        Opportunity opp = [SELECT Id, Approval_Status__c FROM Opportunity LIMIT 1];
        opp.Approval_Status__c = 'Rejected';
        
        try {
        	update opp;   
        } catch (Exception ex) {
    		System.assertEquals('Operation Cancelled: Please provide a rejection reason!', ex.getMessage());
        }      
    }

}