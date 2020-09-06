@IsTest
public class OpportunityScopingQuestionTriggerTest {
    
    @TestSetup
    static void init() {            
        //define the standart price for the product 
        String stdPbId = Test.getStandardPricebookId();
                        
        // create account
        Account account = new Account(Name = 'Acc', Type = 'Customer', Industry = 'Automotive');
        insert account; 
		Id CMOptyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Client Manager April.2017').getRecordTypeId();
        // create opportunity
        Opportunity opp = new Opportunity(AccountId = account.Id, Pricebook2Id = stdPbId, Name = 'Opp', StageName = 'Open',
                                          CloseDate = Date.newInstance(2017,10,10), CurrencyIsoCode='AUD' ,RecordTypeId = CMOptyRecordTypeId);
        insert opp; 
    }
    
    @IsTest
    public static void test() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Opportunity_Scoping_Question__c psq = new Opportunity_Scoping_Question__c(Opportunity__c=opp.Id);
        insert psq;
        
        Opportunity oppUpdated = [SELECT Id, Scoping_Required__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(true, oppUpdated.Scoping_Required__c);  
        
        Opportunity_Scoping_Question__c psqDeleted = [SELECT Id FROM Opportunity_Scoping_Question__c WHERE Id = :psq.Id];
        delete psqDeleted;
        
        oppUpdated = [SELECT Id, Scoping_Required__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(false, oppUpdated.Scoping_Required__c);
    }

}