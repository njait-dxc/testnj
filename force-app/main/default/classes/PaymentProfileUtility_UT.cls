@IsTest
public with sharing class PaymentProfileUtility_UT {

    @TestSetup static void setUpData()
    {
        LP_BillingAPI_Resource__c billngAPI = new LP_BillingAPI_Resource__c();
        billngAPI.Name='test123';
        insert billngAPI;
        
        LP_BillingAPI_Payment_Profile__c payProf = new LP_BillingAPI_Payment_Profile__c();
        payProf.Name='test456';
        insert payProf;
    }
    
    @IsTest static void getBillingAPIResc()
    {
        LP_BillingAPI_Resource__c billingAPIresource = [SELECT Id, Name FROM LP_BillingAPI_Resource__c];
        String resourceName = PaymentProfileUtility.getBillingAPIResosource();
        System.assertEquals(resourceName, 'test123');
    }
    
    @IsTest static void getPaymentProfileResource()
    {
        LP_BillingAPI_Payment_Profile__c payProfResource = [SELECT Id, Name FROM LP_BillingAPI_Payment_Profile__c];
        String ppResourceName = PaymentProfileUtility.getPaymentProfileResource();
        System.debug(ppResourceName);
        System.assertEquals(ppResourceName, 'test456');
    }
    
    @IsTest static void getIDAMToken()
    {          
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        String IDAMToken = PaymentProfileUtility.getIDAMToken('test123');
        System.assertEquals(IDAMToken, 'abcde');
    }
    
    @IsTest static void createRequestURL()
    {          
        String reqURL = PaymentProfileUtility.createRequestURL('abc@xyz.com/','12345');
        System.assertEquals(reqURL, 'abc@xyz.com/accounts/12345/payment-profiles');
    }
    
    @IsTest static void getPaymentProfileData()
    {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('PPResponse');
        mock.setStatusCode(200); // Or other appropriate HTTP status code
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        
		Test.startTest();
        String response = PaymentProfileUtility.getPaymentProfileData('abc@xyz.com/accounts/12345/payment-profiles','12345');
        System.assertNotEquals(response,null);
    }
    
    @IsTest static void parseResponse()
    {          
        String responseJSON = '[{"id": "1-DZVXCLM", "contact": {"id": "1-W5CCT3"},"payment_schedule": "Quarterly","payment_method": "Direct Debit","status": "Active","primary_profile": false,"direct_debit": {"bank_name": "ANZ","bsb": "013260","account_number": "9876543210"}}]';
        String paymentProfId = PaymentProfileUtility.parseResponse(responseJSON);
        System.assertEquals(paymentProfId, '1-DZVXCLM');
    }
}