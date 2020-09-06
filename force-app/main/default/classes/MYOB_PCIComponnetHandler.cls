public class MYOB_PCIComponnetHandler 
{
	@AuraEnabled
    public static String callPaymentProfileCreation(String oppId,String name_on_card, String card_token, String last_four_digits, String type, String expiry_month, String expiry_year,String payment_schedule, String payment_method) 
    { 
        String accountId = null;
        Opportunity op = [SELECT Id, Client_Id__c, Main_Contact__r.Contact_Siebel_Row_Id__c FROM Opportunity WHERE Id =: oppId LIMIT 1];
        accountId = op.Client_Id__c;
        
        //List<MYOBService_BillingAPI.PaymentProfile> listPP = MYOBService_BillingAPI.createPaymentProfiles(
        MYOBService_BillingAPI.PaymentProfile ppResult = MYOBService_BillingAPI.createPaymentProfiles(
            accountId, 
            op.Main_contact__r.Contact_Siebel_Row_Id__c,
            name_on_card, 
            card_token, 
            last_four_digits, 
            type, 
            expiry_month, 
            expiry_year, 
            payment_schedule, 
            payment_method);
        
        String paymentProfileId = null;
        
        //if(listPP.size() > 0)
        if(ppResult != null)
        {
        	//paymentProfileId = listPP[0].Id;	
        	paymentProfileId = ppResult.Id;
            op.Payment_Profile_Id__c = paymentProfileId;
            update op;
        }
        return paymentProfileId;
    }
}