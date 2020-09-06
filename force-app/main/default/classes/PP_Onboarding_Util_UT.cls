@IsTest
public with sharing class PP_Onboarding_Util_UT {

    
    @IsTest static void postData()
    {          
        String requestJSON = '[{"id": "1-DZVXCLM", "contact": {"id": "1-W5CCT3"},"payment_schedule": "Quarterly","payment_method": "Direct Debit","status": "Active","primary_profile": false,"direct_debit": {"bank_name": "ANZ","bsb": "013260","account_number": "9876543210"}}]';
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('PPResponse');
        mock.setStatusCode(200); // Or other appropriate HTTP status code
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        
        Integer statusCode = PP_Onboarding_Util.postData('POST','abc@xyz.com/accounts/12345/payment-profiles','12345',requestJSON);
        System.assertEquals(statusCode, 200);
    }
    
    @IsTest static void getData()
    {              
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('PPResponse');
        mock.setStatusCode(200); // Or other appropriate HTTP status code
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        
        String responseData = PP_Onboarding_Util.getData('GET','abc@xyz.com/accounts/12345/payment-profiles','12345');
        System.assertNotEquals(responseData,null);
    }
}