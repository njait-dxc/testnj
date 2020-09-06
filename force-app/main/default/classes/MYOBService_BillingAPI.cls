/**
 * @File Name          : MYOBService_BillingAPI.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 12/19/2019, 2:50:08 PM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    12/18/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public with sharing class MYOBService_BillingAPI
{
    /*
    Available methods
    =================
    [1] MYOBService_BillingAPI.getPaymentProfiles(String accountId);
    */
    private static final String API_NAME = 'Billing API';
    private static final String API_PATH_PAYMENTPROFILES = '/api/accounts/[accountId]/payment-profiles';
    public static List <PaymentProfile> getPaymentProfiles(String accountId)
    {
        // Retrive API details for custom metadata
        MYOB_Service_API__mdt myobServiceAPI = MYOBService.getMYOBService(API_NAME);
        // Retrieve access token from Authorisation API
        MYOBService_AuthorisationAPI.AccessToken_Response accessTokenResponse = MYOBService_AuthorisationAPI.getAccessToken(myobServiceAPI.Resource_Id__c);
        // Define HTTP Request
        HttpRequest httpRequest = new HttpRequest();
        // Set HTTP Request Method
        httpRequest.setMethod('GET');
        // Set HTTP Request Timeout
        httpRequest.setTimeout(30000);
        // Set HTTP Request Endpoint
        String endpoint = myobServiceAPI.Endpoint__c;
        endpoint += API_PATH_PAYMENTPROFILES;
        endpoint = endpoint.replace('[accountId]', EncodingUtil.urlEncode(accountId, 'UTF-8'));
        httpRequest.setEndpoint(endpoint);
        // Set HTTP Request Headers
        Map <String, String> requestHeaders = new Map <String, String>();
        requestHeaders.put('X-MYOBAPI-VERSION', 'v2');
        requestHeaders.put('Content-Type', 'application/json');
        requestHeaders.put('Authorization', 'Bearer ' + accessTokenResponse.access_token);
        for (String key : requestHeaders.keySet())
        {
            httpRequest.setHeader(key, requestHeaders.get(key));
        }
        // Send HTTP Request via APICallLogger
        HttpResponse httpResponse = APICallLogger.send(httpRequest, requestHeaders);
        System.debug('Response Body for Payment Profiles1'+httpResponse.getBody());
        // Insert API Call Logs
        APICallLogger.insertLogs();
        // Deserialise JSON Response
        List <PaymentProfile> paymentProfiles = (List <PaymentProfile>) JSON.deserialize(httpResponse.getBody(), List <PaymentProfile>.class);
        // Return deserialised JSON Response
        return paymentProfiles;
    }
    //  RV 31/0/2020 Added new method to create payment profile through billingapi
    //public static List <PaymentProfile> createPaymentProfiles(String accountId, String contactId, String name_on_card, String card_token, String last_four_digits, String type, String expiry_month, String expiry_year,String payment_schedule, String payment_method)
    public static PaymentProfile createPaymentProfiles(String accountId, String contactId, String name_on_card, String card_token, String last_four_digits, String type, String expiry_month, String expiry_year,String payment_schedule, String payment_method)
    {
        // Retrive API details for custom metadata
        MYOB_Service_API__mdt myobServiceAPI = MYOBService.getMYOBService(API_NAME);
        // Retrieve access token from Authorisation API
        MYOBService_AuthorisationAPI.AccessToken_Response accessTokenResponse = MYOBService_AuthorisationAPI.getAccessToken(myobServiceAPI.Resource_Id__c);
        // Define HTTP Request
        HttpRequest httpRequest = new HttpRequest();
        // Set HTTP Request Method
        httpRequest.setMethod('POST');
        // Set HTTP Request Timeout
        httpRequest.setTimeout(30000);
        // Set HTTP Request Endpoint
        String endpoint = myobServiceAPI.Endpoint__c;
        endpoint += API_PATH_PAYMENTPROFILES;
        endpoint = endpoint.replace('[accountId]', EncodingUtil.urlEncode(accountId, 'UTF-8'));

        String httpRequestBody = '{"contact": { "id" : "' + contactId + '"}, ' +
              ' "payment_schedule": "'+ payment_schedule + '",' +
              ' "payment_method": "'+ payment_method + '",' +
              ' "primary_profile": "false",' +
              ' "credit_card":  ' +
              '        { ' +
              '            "name_on_card": "' + name_on_card + '", ' +
              '            "card_token": "' + card_token + '", ' +
              '            "last_four_digits": "' + last_four_digits + '", ' +
              '            "type": "' + type + '", ' +
              '            "expiry_month": "' + expiry_month + '", ' +
              '            "expiry_year": "' + expiry_year + '"' +            
              '        }' +
              '      }';
        system.debug('request body:'+ httpRequestBody);
        httpRequest.setBody(httpRequestBody);
        httpRequest.setEndpoint(endpoint);
        // Set HTTP Request Headers
        Map <String, String> requestHeaders = new Map <String, String>();
        requestHeaders.put('X-MYOBAPI-VERSION', 'v2');
        requestHeaders.put('Content-Type', 'application/json');
        requestHeaders.put('Authorization', 'Bearer ' + accessTokenResponse.access_token);
        System.debug('token:'+accessTokenResponse.access_token);
        for (String key : requestHeaders.keySet())
        {
            httpRequest.setHeader(key, requestHeaders.get(key));
        }
        System.debug('Request:'+httpRequest);
        // Send HTTP Request via APICallLogger
        HttpResponse httpResponse = APICallLogger.send(httpRequest, requestHeaders);
        System.debug('Response Body for Payment Profiles:'+httpResponse.getBody());
        // Insert API Call Logs
        APICallLogger.insertLogs();
        // Deserialise JSON Response
        //List <PaymentProfile> paymentProfiles = (List <PaymentProfile>) JSON.deserialize(httpResponse.getBody(), List <PaymentProfile>.class);
        
        PaymentProfile ppResult = (PaymentProfile) JSON.deserialize(httpResponse.getBody(), PaymentProfile.class);
        system.debug('ppResult:' + ppResult);
        system.debug('response body: '+ httpResponse.getBody());
        //String paymentProfileId = httpResponse.getBody();
        
        //return paymentProfileId;
        // Return deserialised JSON Response
        //List <PaymentProfile> paymentProfiles = new List <PaymentProfile>();
        //system.debug('paymentprofile' + paymentProfiles);
        //return paymentProfiles;
        return ppResult;
    }
    // Method end here 
    // 
    public class PaymentProfile
    {
        @AuraEnabled
        public PaymentProfile_Contact contact;
        @AuraEnabled
        public PaymentProfile_BankDetail direct_debit;
        @AuraEnabled
        public PaymentProfile_CCDetail credit_card;
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String payment_method;
        @AuraEnabled
        public String payment_schedule;
        @AuraEnabled
        public Boolean payment_profile;
        @AuraEnabled
        public Boolean primary_profile;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String error;
        @AuraEnabled
        public String error_description;
        @AuraEnabled
        public String comments;
    }
    public class PaymentProfile_Contact
    {
        @AuraEnabled
        public String id;
    }
    public class PaymentProfile_BankDetail
    {
        @AuraEnabled
        public String account_number { get; set; }
        @AuraEnabled
        public String bank_name { get; set; }
        @AuraEnabled
        public String bsb { get; set; }
    }
    public class PaymentProfile_CCDetail
    {
        @AuraEnabled
        public String card_token { get; set; }
        @AuraEnabled
        public String expiry_month { get; set; }
        @AuraEnabled
        public String expiry_year { get; set; }
        @AuraEnabled
        public String last_four_digits { get; set; }
        @AuraEnabled
        public String name_on_card { get; set; }
        @AuraEnabled
        public String type { get; set; }
    }
}