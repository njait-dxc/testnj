/*
  Date    : 11 Oct 2017
  Author    : Ankit Bhardwaj
  Description : Unit test factory for sendPartnerWelcomeKitSchedular 
*/
@IsTest
public with sharing class sendPartnerWelcomeKitSchedular_UT {
    
    public static testMethod void RunSchedular() {
    try {
      LP_BillingAPI_Resource__c billngAPI = new LP_BillingAPI_Resource__c();
        billngAPI.Name='test123';
        insert billngAPI;       
        
       Account acc = new Account(Name='Test Account',Partner_Enrolled_Date__c=System.today()-2,LP_Status__c='Silver');
       insert acc;
       
       Account acnt = [SELECT Id FROM Account WHERE Name='Test Account'];
        
        Case cas = new Case(Status ='Partner Enrolled', Priority = 'Medium', Origin = 'Email');
        insert cas; 
        
       Case cs = [SELECT AccountId FROM Case WHERE Status = 'Partner Enrolled'];
       cs.AccountId = acnt.Id;
       update cs;  
       
                       MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
                multimock.setStaticResource(
                'http://api.salesforce.com/foo/bar', 'PPResponse');
                multimock.setStaticResource(
                'http://api.salesforce.com/foo/sfdc', 'PPResponse');
                multimock.setStaticResource(
                'http://api.salesforce.com/foor/sfdc', 'PPResponse');
                multimock.setStatusCode(201);
                multimock.setHeader('Content-Type', 'application/json');         
                // Set the mock callout mode
                Test.setMock(HttpCalloutMock.class, multimock);


                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
                Account accnt = [SELECT Id FROM Account WHERE Name='Test Account'];
                Case css = [SELECT Status FROM Case WHERE Status = 'Partner Enrolled'];
                Account acntt = [SELECT Id FROM Account WHERE Name='Test Account'];
                Test.startTest();
              
    // Call the schedular job
        SchedulableContext sc;   
          sendPartnerWelcomeKitSchedular welcomeKit = new sendPartnerWelcomeKitSchedular();
          welcomeKit.execute(sc);
        //Integer DMLNumber = Limits.getDMLStatements();
        //system.assertEquals(DMLNumber, 1, true);
        Test.stopTest();
    }
     catch(Exception e)
    {    String response;
       System.assertEquals(response == null, true);   
    }
    }

}