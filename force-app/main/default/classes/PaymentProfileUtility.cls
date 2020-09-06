/**
 * @author
 * @date
 * @description
 */

global class PaymentProfileUtility {
    
    global static String getPaymentProfileId(String accountId)
    {
        //get PaymentProfile Resource
        String paymentProfileResource = getPaymentProfileResource();
        
        //get the billing API resource
        String resourceName = getBillingAPIResosource();
        
        //get the IDAM Token
        String IDAMToken = getIDAMToken(resourceName);
        
        //create url to call
        String reqEndPoint = createRequestURL(paymentProfileResource, accountId);
        
        //fetch the data from billingAPI call
        String responeString = getPaymentProfileData(reqEndPoint,IDAMToken);
        
        //get the PaymentProfileId from the reponseString
        String paymentProfileId = parseResponse(responeString);
        
        return paymentProfileId;      
    }
    
    global static String createRequestURL(String URLName, String accountId) {
        String paymentProfileEndpoint = URLName + 'accounts/' + accountId +'/payment-profiles';
        return paymentProfileEndpoint;
    }
    
    webService static String getPaymentProfileData(String paymentProfileEndpoint, String billingAPIToken)
    {
        String paymentProfileResponseString = PP_Onboarding_Util.getData('GET', paymentProfileEndpoint , billingAPIToken);
        return paymentProfileResponseString;
    }
    
    global static String parseResponse(String paymentProfileResponseString){
        String paymentProfileId;
        JSONParser parser = JSON.createParser(paymentProfileResponseString);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                String fieldName = parser.getText();
                parser.nextToken();
                if(fieldName == 'id') {
                    paymentProfileId = parser.getText();
                }
                if(fieldName == 'contact') {
                    parser.nextToken();
                }                  
                if(fieldName == 'status') {
                    if (parser.getText() == 'Active')
                    {
                        break;
                    }
                    else
                    {
                        paymentProfileId = '';
                    }
                }               
                
            }
        }
        return paymentProfileId;   
    }
    
    global static String getBillingAPIResosource()
    {    
        LP_BillingAPI_Resource__c billAPIResource = LP_BillingAPI_Resource__c.getOrgDefaults();
        return billAPIResource.Name;
    }
    global static String getIDAMToken(String Name)
    {
        String billingAPIToken;
        billingAPIToken = IDAM_Utilities.getToken(Name);
        return billingAPIToken;
    }
    global static String getPaymentProfileResource()
    {
        LP_BillingAPI_Payment_Profile__c paymentProfileURL = LP_BillingAPI_Payment_Profile__c.getOrgDefaults();
        return paymentProfileURL.Name;
    }
}