/*
    Date        : 19 Dec 2016
    Author      : SMS Management & Technology
    Description : Unit test factory for LP_RelatePartnerToParentBatch
*/
@IsTest
public with sharing class LP_RelatePartnerToParentBatch_UT {
    
    // Test for list of partners to get associated to thier 
    // parent partner
    public static testMethod void testRelatePartners() {
        
        // List of partners 
        List<Account> lstAccount = new List<Account>();
        
        // Create partner 1
        Account objPartner1 = LP_UnitTestFactory.buildTestPartner();
        objPartner1.Client_ID__c = 'ARCH-ID-1001';
        objPartner1.LP_Partner_GUID__c = 'GUID-ID-1001';
        lstAccount.add(objPartner1);
        insert objPartner1;
        
        // Create partner 2
        Account objPartner2 = LP_UnitTestFactory.buildTestPartner();
        objPartner2.Client_ID__c = 'ARCH-ID-1002';
        objPartner2.LP_Partner_GUID__c = 'GUID-ID-1002';
        objPartner2.LP_Parent_Archie_Client_Id__c= objPartner1.Client_ID__c;
        lstAccount.add(objPartner2);
        insert objPartner2;
        
        try {
            insert lstAccount;
            List<Account> lstAct = [SELECT Id FROM Account];
            System.assertEquals(lstAct.size(),2,true);
        } catch(Exception e) {
        }
        
        // Create custom setting that stores the email group
        LS_Email_Group__c objEmail = new LS_Email_Group__c();
        objEmail.Name = 'test_support_group@myob.com';
        insert objEmail;
        
        // Setting the user - for manual trigger email 
        User runningUser = LP_UnitTestFactory.createUser();
        insert runningUser;
        
        // Create error
        LP_ErrorLogHandler.log('ErrorMessage','ExceptionMessage','Element');   
        List<LP_Error_Log__c> lstNewErr = [SELECT Id FROM LP_Error_Log__c];
        
        // Call the batch job
        System.runAs(runningUser) {
            LP_RelatePartnerToParentBatch con = new LP_RelatePartnerToParentBatch();
            Database.BatchableContext  bc;
            con.start(bc);
            con.lstError = lstNewErr;
            con.execute(bc, lstAccount);
            
            System.assertEquals(objPartner1.Parent == null, true);  
            System.assertEquals(objPartner2.ParentId == objPartner1.Id, true);
        }   
    }
}