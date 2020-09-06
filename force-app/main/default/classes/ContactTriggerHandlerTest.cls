@IsTest
public class ContactTriggerHandlerTest {
	@TestSetup
    static void setupTestData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='~ Client Manager April.2017']; 
        User u = new User(Alias = 'UL', Email='u@test.com', 
            EmailEncodingKey='UTF-8', LastName='UL', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', Username='testingmyob@myob.com', FederationIdentifier = 'testingmyob@myob.com');
        insert u;
      
        User u2 = new User(Alias = 'UL2', Email='u2@test.com', 
            EmailEncodingKey='UTF-8', LastName='UL2', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', Username='testingmyob2@myob.com', FederationIdentifier = 'testingmyob2@myob.com');
        insert u2;        
        /*
        Support_Setting__mdt cs = new Support_Setting__mdt();
        cs.DeveloperName = 'TWS_User';
        cs.Value__c = u2.id;
        insert cs;
		*/
    }
    
    @IsTest
    static void testContactTrigger1(){
        Test.startTest();
        Contact con1 = new Contact(LastName = 'LN11111', FirstName = 'FN11111');
        insert con1;   
        
        //system.runAs(user, block)
        Contact con2 = new Contact(LastName = 'LN12222', FirstName = 'FN22222');
        insert con2;        
        
        
        Contact tc = [SELECT Id, Sync_Status__c FROM Contact WHERE LastName = 'LN11111' AND FirstName = 'FN11111' LIMIT 1][0];
      
        System.assertEquals('Pending', tc.Sync_Status__c);
        
    }
    
    @IsTest
    static void testContactTrigger2(){
        
        Contact con1 = new Contact(LastName = 'LN11111', FirstName = 'FN11111');
        insert con1;   
        
        Contact con2 = new Contact(LastName = 'LN12222', FirstName = 'FN22222');
        insert con2;        

       	Test.startTest();
        Contact tc2 = [SELECT Id, Sync_Status__c FROM Contact WHERE Id =: con2.Id LIMIT 1][0];
        tc2.LastName = 'LN122223';
        /*
        tc2.Phone = '11111';
        tc2.DoNotCall = true;
        tc2.HasOptedOutOfEmail = true;
        tc2.Do_Not_Mail__c= true;
        tc2.Do_Not_SMS__c= true;
        tc2.HasOptedOutOfFax= true;
        tc2.Do_Not_Survey__c= true;
        tc2.Special_Offers__c= true;
        tc2.Send_Promotions__c= true;
        tc2.Tips_and_Tricks__c= true;
        tc2.Training_Events__c= true;
        tc2.Opt_out_my_MYOB_Invoice__c= true;
        tc2.Opt_in_to_MYOB_Research__c= true;
        tc2.Reason_for_Leaving__c= '';*/
        update tc2;
        
        Contact temp = [SELECT Id, Sync_Status__c FROM Contact WHERE Id =: con2.Id LIMIT 1][0];
        
        System.assertEquals('Pending', temp.Sync_Status__c); 
        Test.stopTest();
    }    
}