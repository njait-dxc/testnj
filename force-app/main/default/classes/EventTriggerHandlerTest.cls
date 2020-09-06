@IsTest
public class EventTriggerHandlerTest {
    @IsTest
    static void testEventTrigger1(){
        Profile p = [SELECT Id FROM Profile WHERE Name='~ Client Manager April.2017']; 
        User u = new User(Alias = 'UL', Email='u@test.com', 
            EmailEncodingKey='UTF-8', LastName='UL', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', Username='testingmyob@myob.com', FederationIdentifier = 'testingmyob@myob.com');
        insert u;
        
        Test.startTest();
        
        System.runAs(u){
        	Event event1 = new Event(Subject = 'Test', StartDateTime = System.now(), EndDateTime = System.now() + 1 );
        	insert event1;  
        	Event eventResult1 = [SELECT Id, Sync_Status__c FROM Event WHERE Id =: event1.Id];
      
        	System.assertEquals('Pending', eventResult1.Sync_Status__c);      
            
            event1.Description = 'test';
            
            update event1;
            Event eventResult2 = [SELECT Id, Sync_Status__c FROM Event WHERE Id =: event1.Id];
      
        	System.assertEquals('Pending', eventResult2.Sync_Status__c); 
            
        }
         Test.stopTest();

        
    }
}