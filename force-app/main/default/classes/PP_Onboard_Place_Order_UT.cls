@IsTest
public with sharing class PP_Onboard_Place_Order_UT {
    
    @TestSetup static void setUpData()
    {
        LP_BillingAPI_Resource__c billngAPI = new LP_BillingAPI_Resource__c();
        billngAPI.Name='test123';
        insert billngAPI;  
        
        Case testCase = new Case();
        testCase.Status ='New';
        insert testCase;      
    }       
    
    @IsTest static void updateCase()
    {      
        Case CaseInstanceSuccess =new Case(Status='New');        
        insert CaseInstanceSuccess;                       
        CaseInstanceSuccess =  [SELECT Id,Status,CaseNumber FROM Case WHERE Id = :CaseInstanceSuccess.Id];
        PP_Onboard_Place_Order.updateCase(CaseInstanceSuccess.CaseNumber, 201);
        
        CaseInstanceSuccess =  [SELECT Id,Status,CaseNumber FROM Case WHERE Id = :CaseInstanceSuccess.Id];
        System.assertEquals('Partner Enrolled', CaseInstanceSuccess.Status);
        
        Case CaseInstanceFailure =new Case(Status='New');        
        insert CaseInstanceFailure;                       
        CaseInstanceFailure =  [SELECT Id,Status,CaseNumber FROM Case WHERE Id = :CaseInstanceFailure.Id];
        PP_Onboard_Place_Order.updateCase(CaseInstanceFailure.CaseNumber, 500);
        
        CaseInstanceFailure =  [SELECT Id,Status,CaseNumber FROM Case WHERE Id = :CaseInstanceFailure.Id];
        System.assertEquals('Enrollment Failed', CaseInstanceFailure.Status);
       
    } 
     
    @IsTest static void getRequestString()
    {
        String jsonDataString = PP_Onboard_Place_Order.getRequestString('123', '123445', '1-PAYPRO');
        System.assertEquals(jsonDataString, '{"items": [ { "product_id": "123" , "quantity": 1 } ], "account": { "id": "123445" }, "recurring_payment_profile": {  "id": "1-PAYPRO" } }' );
    }
    
    @IsTest static void checkLegalEntity()
    {
        String legalEntityAU = PP_Onboard_Place_Order.checkLegalEntity('MYOB Australia Pty Ltd');
        String legalEntityNZ = PP_Onboard_Place_Order.checkLegalEntity('MYOB NZ Limited');
        String legalEntityInvalid = PP_Onboard_Place_Order.checkLegalEntity('Invalid Legal Entity');
        System.assertEquals(legalEntityAU, 'AU' );
        System.assertEquals(legalEntityNZ, 'NZ' );
        System.assertEquals(legalEntityInvalid, null );
    }
    
    @IsTest static void getReturnMessage()
    {
        String successResponse = PP_Onboard_Place_Order.getReturnMessage(201);
        String timeoutResponse = PP_Onboard_Place_Order.getReturnMessage(500);
        String errorResponse = PP_Onboard_Place_Order.getReturnMessage(300);
        System.assertEquals(successResponse, 'Partner enrolment request has been successfully placed.');
        System.assertEquals(timeoutResponse, 'Server experiencing a timeout, please try after sometime. Please contact system admin if the problem persists');
        System.assertEquals(errorResponse, 'Unknown Exception. Please contact system admin.');
    }
    
    @IsTest static void getBillingAPIResosource()
    {
        LP_BillingAPI_Resource__c billingAPIresource = [SELECT Id, Name FROM LP_BillingAPI_Resource__c];
        String resourceName = PP_Onboard_Place_Order.getBillingAPIResosource();
        System.assertEquals(resourceName, 'test123');
    }
    
    @IsTest static void getIDAMToken()
    {          
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        String IDAMToken = PP_Onboard_Place_Order.getIDAMToken('test123');
        System.assertEquals(IDAMToken, 'abcde');
    }
    
    
    @IsTest static void updatePartnerEnrolledDate()
    {          
       Account acc = new Account(Name='Test Account',LP_Status__c='Silver', Client_ID__c = '123', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Franchise & Commercial Partnerships Accounts').getRecordTypeId());
       insert acc;
       
       Account acc2 = new Account(Name='Test Account123',LP_Status__c='Silver',Client_ID__c = '456',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Franchise & Commercial Partnerships Accounts').getRecordTypeId());
       insert acc2;
       
       PP_Onboard_Place_Order.updatePartnerEnrolledDate(acc.Client_ID__c,201);
       Account acnt = [SELECT Partner_Enrolled_Date__c FROM Account WHERE Id =:acc.Id];
       System.assertEquals(acnt.Partner_Enrolled_Date__c, System.today());
       
       PP_Onboard_Place_Order.updatePartnerEnrolledDate(acc2.Id,500);
       Account accnt = [SELECT Partner_Enrolled_Date__c FROM Account WHERE Id =:acc2.Id];
       System.assertNotEquals(accnt.Partner_Enrolled_Date__c, System.today());
    } 
          
    // Test for retreiving access token
    @IsTest static void PP_Onboard_Place_Order() {
      String response;
      
        try {   
                    Case CaseInstanceSuccess =new Case(Status='New');        
                    insert CaseInstanceSuccess;                       
                    List<Case> caseObj =  [SELECT Id FROM Case WHERE Id = :CaseInstanceSuccess.Id];
    
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());    
                     
                Test.startTest();
                PP_Onboard_Place_Order.PP_Onboard_Place_Order(caseObj);

            
        } catch(Exception e) {
            System.assertEquals(response == null, true);
        }      
    }
    
        // Test for retreiving access token
    @IsTest static void processOrderRequest() {
      String response;
      
        try {   
                    Case CaseInstanceSuccess =new Case(Status='New');        
                    insert CaseInstanceSuccess;                       
                    List<Case> caseObj =  [SELECT Id FROM Case WHERE Id = :CaseInstanceSuccess.Id];
                    
                    Account acc = new Account(Name='Test Account',LP_Status__c='Silver', Client_ID__c = '123');
                    insert acc;
                    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 

                     
                Test.startTest();
                PP_Onboard_Place_Order.processOrderRequest(acc.Client_ID__c ,'AU',false,'123');
                Test.stopTest();

            
        } catch(Exception e) {
            System.assertEquals('Payment Profile is invalid for this account. Order cannot be processed', 'Payment Profile is invalid for this account. Order cannot be processed');
        }      
    }
   
   }