public with sharing class PaymentProfileCtrl {
	/**
	* @description Method which is called from PaymentProfile lightning component to get payment profiles '
	* from Billing API.
	* @param recordId ID of the record being fetched
	* @return List of payment profiles
	*/
	@AuraEnabled
	public static List<PaymentProfileWrapper> getPaymentProfiles(String recordId) {
		if(String.isNotBlank(recordId)) {
			Opportunity opportunity = [SELECT Id, Client_Id__c, Payment_Profile_Id__c
			                           FROM   Opportunity 
                                       WHERE  Id = :recordId];
			List<MYOBService_BillingAPI.PaymentProfile> paymentProfiles =
					MYOBService_BillingAPI.getPaymentProfiles(opportunity.Client_Id__c);
			List<PaymentProfileWrapper> profileWrappers = new List<PaymentProfileWrapper>();

			for(MYOBService_BillingAPI.PaymentProfile profile : paymentProfiles) {
                
                if(profile.status.equals('Active')) {
					PaymentProfileWrapper wrapper = new PaymentProfileWrapper();
					//if (profile.id.equals(opportunity.Payment_Profile_Id__c)) {
					
					if(opportunity.Payment_Profile_Id__c  != null){
                        if( profile.id.equals(opportunity.Payment_Profile_Id__c)){
                            wrapper.selected = true;
                        }
					} else if (profile.primary_profile == true) {
                        wrapper.selected = true;
                        opportunity.Payment_Profile_Id__c = profile.id;
                    } else {
                        wrapper.selected = false;
                    }
                    wrapper.paymentProfile = profile;
                    profileWrappers.add(wrapper);
				}
			}
			update opportunity;

			return profileWrappers;
		}
		return null;
	}

	/**
	* @description Method called from PaymentProfile lightning component to update payment profile id
	* field in Opportunity
	* @param recordId ID of the record being fetched
	* @param profileId Payment Profile Id of the selected item in PaymentProfile lightning component
	* @return Boolean
	*/
	@AuraEnabled
	public static Boolean updateOpportunityPaymentProfileId(String recordId, string profileId) {
		System.debug('It entered the method to update Payment Profiles');
		Boolean isSuccess = true;
		try {
			if(String.isNotBlank(recordId) && String.isNotBlank(profileId)) {
				Opportunity opportunity = new Opportunity(Id=recordId, Payment_Profile_Id__c=profileId);
				Database.SaveResult saveResult = Database.update(opportunity, false);
				LogUtilityException.logSaveResults('PaymentProfileCtrl', 'updateOpportunityPaymentProfileId',
						new List<Opportunity> {opportunity}, new List<Database.SaveResult>{saveResult});
			} else {
				isSuccess = false;
			}
		} catch(Exception ex) {
			isSuccess = false;
		}
		return isSuccess;
	}

	public class PaymentProfileWrapper {
		@AuraEnabled
		public Boolean selected{get;set;}
		@AuraEnabled
		public MYOBService_BillingAPI.PaymentProfile paymentProfile{get;set;}
	}
}