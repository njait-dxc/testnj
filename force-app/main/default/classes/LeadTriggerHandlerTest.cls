@IsTest
public class LeadTriggerHandlerTest {
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

        
        
    }
    
    @IsTest
    static void testLeadTrigger1(){
        Test.startTest();
        Support_Setting__mdt MCuserId = [SELECT DeveloperName, Value__c FROM Support_Setting__mdt WHERE DeveloperName = 'Marketing_Cloud_Integration_User' LIMIT 1];
		User u = [SELECT Id FROM User WHERE Id = :MCuserId.Value__c LIMIT 1];
        
        System.runAs(u){
            System.debug('user is ' + UserInfo.getUserName());
            List <Account> accList = new List <Account>();
            accList.add(new Account(Name = 'Test1', Client_ID__c = 'CID1'));
            insert accList;
            List <Contact> conList = new List <Contact>();
            conList.add(new Contact(LastName = 'Contact0', Contact_Siebel_Row_Id__c = 'CRID00000', AccountId = accList[0].Id));
            conList.add(new Contact(LastName = 'Contact1', Contact_Siebel_Row_Id__c = 'CRID11111', AccountId = accList[0].Id));
            conList.add(new Contact(LastName = 'Contact2', Contact_Siebel_Row_Id__c = 'CRID22222', AccountId = accList[0].Id));
            conList.add(new Contact(LastName = 'Contact3', Contact_Siebel_Row_Id__c = 'CRID33333', AccountId = accList[0].Id));
            insert conList;
            List <Lead> leadList = new List <Lead> ();
            //Insert Lead
            leadList.add(new Lead(LastName = 'LN22222', FirstName = 'FN22222', Company = 'test0', Archie_Contact_Row_ID__c = 'CRID00000', Lookup_Client_ID__c = 'CID0', Lead_Convert_in_Marketing_Cloud__c = false, Email = 'test1@test.com.invalid'));
            leadList.add(new Lead(LastName = 'LN33333', FirstName = 'FN33333', Company = 'test1', Archie_Contact_Row_ID__c = 'CRID11111', Lookup_Client_ID__c = 'CID1', Lead_Convert_in_Marketing_Cloud__c = true, Email = 'test1@test.com.invalid'));
            //Update Lead
            leadList.add(new Lead(LastName = 'LN44444', FirstName = 'FN44444', Company = 'test2', Archie_Contact_Row_ID__c = 'CRID22222', Lookup_Client_ID__c = 'CID1', Lead_Convert_in_Marketing_Cloud__c = false, Email = 'test@test.com.invalid'));
            leadList.add(new Lead(LastName = 'LN55555', FirstName = 'FN55555', Company = 'test3', Archie_Contact_Row_ID__c = 'CRID33333', Lookup_Client_ID__c = 'CID1', Lead_Convert_in_Marketing_Cloud__c = false, Email = 'test@test.com.invalid'));
			//Convert Lead No Matching Account and Contact            
            leadList.add(new Lead(LastName = 'LN66666', FirstName = 'FN66666', Company = 'test4', Archie_Contact_Row_ID__c = 'CRID44444', Lookup_Client_ID__c = 'CID2', Lead_Convert_in_Marketing_Cloud__c = false, Email = 'test2@test.com.invalid'));
            leadList.add(new Lead(LastName = 'LN77777', FirstName = 'FN77777', Company = 'test5', Archie_Contact_Row_ID__c = 'CRID44444', Lookup_Client_ID__c = 'CID2', Lead_Convert_in_Marketing_Cloud__c = true, Email = 'test2@test.com.invalid'));
            //Update Lead No Matching Account and Contact
            leadList.add(new Lead(LastName = 'LN88888', FirstName = 'FN88888', Company = 'test6', Archie_Contact_Row_ID__c = 'CRID55555', Lookup_Client_ID__c = 'CID3', Lead_Convert_in_Marketing_Cloud__c = false, Email = 'test3@test.com.invalid'));
            leadList.add(new Lead(LastName = 'LN99999', FirstName = 'FN99999', Company = 'test7', Archie_Contact_Row_ID__c = 'CRID66666', Lookup_Client_ID__c = 'CID4', Lead_Convert_in_Marketing_Cloud__c = false, Email = 'test3@test.com.invalid'));



            insert leadList;
            List <Lead> leadList2 = [SELECT Id, LastName, Lead_Convert_in_Marketing_Cloud__c FROM Lead WHERE LastName = 'LN44444' OR LastName = 'LN99999'];
            leadList2[0].Lead_Convert_in_Marketing_Cloud__c = true;
            leadList2[1].Lead_Convert_in_Marketing_Cloud__c = true;
            update leadList2;
            System.assertEquals([SELECT COUNT() FROM Lead WHERE LastName = 'LN22222' AND IsConverted = TRUE] , 1, 'Test leadConvert Trigger: Lead LastName = LN33333, IsConverted = true is not found');
            System.assertEquals([SELECT COUNT() FROM Lead WHERE LastName = 'LN33333' AND IsConverted = TRUE] , 1, 'Test leadConvert Trigger: Lead LastName = LN33333, IsConverted = true is not found');
        	System.assertEquals([SELECT COUNT() FROM Lead WHERE LastName = 'LN44444' AND IsConverted = TRUE] , 1, 'Test leadConvert Trigger: Lead LastName = LN44444, IsConverted = true is not found');
            System.assertEquals([SELECT COUNT() FROM Lead WHERE LastName = 'LN55555' AND IsConverted = TRUE] , 1, 'Test leadConvert Trigger: Lead LastName = LN55555, IsConverted = true is not found');
            System.assertEquals([SELECT COUNT() FROM Lead WHERE LastName = 'LN66666' AND IsConverted = FALSE] , 1, 'Test leadConvert Trigger: Lead LastName = LN66666, IsConverted = false is not found');
            System.assertEquals([SELECT COUNT() FROM Lead WHERE LastName = 'LN77777' AND IsConverted = FALSE] , 1, 'Test leadConvert Trigger: Lead LastName = LN77777, IsConverted = false is not found');
            System.assertEquals([SELECT COUNT() FROM Lead WHERE LastName = 'LN88888' AND IsConverted = FALSE] , 1, 'Test leadConvert Trigger: Lead LastName = LN88888, IsConverted = false is not found');
            System.assertEquals([SELECT COUNT() FROM Lead WHERE LastName = 'LN99999' AND IsConverted = FALSE] , 1, 'Test leadConvert Trigger: Lead LastName = LN99999, IsConverted = false is not found');
        }
        
        Test.stopTest();
    }
}