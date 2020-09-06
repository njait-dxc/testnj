global class SendPartnerWelcomeKitUtility {

	static String status;
	static String provisioningMsg;

	public void SendPartnerWelcomeKit()
	{
//  List<Account> acnt = [select Id,LP_Status__c, Legal_Entity__c,Client_ID__c,Partner_Enrolled_Date__c from Account where Partner_Enrolled_Date__c >= LAST_N_DAYS:15 and Partner_Enrolled_Date__c < LAST_N_DAYS:2 and LP_Status__c <> null limit 49];
		List<Case> caseRecs = [SELECT Id,Account.Id,Account.Legal_Entity__c,Account.Client_ID__c,Account.LP_Status__c,Account.Partner_Enrolled_Date__c FROM Case WHERE Status = 'Partner Enrolled' AND Account.Partner_Enrolled_Date__c < LAST_N_DAYS:2 AND Account.LP_Status__c <> NULL LIMIT 49];

		for (Case caseRec: caseRecs) {
			//nullify msg and status string
			provisioningMsg = '';
			status = '';
			String region = checkLegalEntity(caseRec.Account.Legal_Entity__c);

			Id caseId = caseRec.Id;

			if (caseId <> null)
			{
				System.debug('+++++++++LP Status+++++++' + caseRec.Account.LP_Status__c);
				if (caseRec.Account.LP_Status__c <> 'Purple')
				{
					System.debug('+++++++++LP Status+++++++' + caseRec.Account.LP_Status__c);
					CreatePartnerWelcomeKitOrder(caseRec.Account.Client_ID__c, caseRec.Account.LP_Status__c, region, caseId );
				}
			}
		}
	}

	@Future(Callout=true) webService static void CreatePartnerWelcomeKitOrder(String accntId, String accntStatus, String region, Id caseId){
//nullify msg and status string
		provisioningMsg = '';
		status = '';

		//get the billing API resource
		String resourceName = getBillingAPIResosource();
		System.debug('+++++++++resourceName+++++++' + resourceName);

		//get the IDAM Token
		String billingAPIToken = getIDAMToken(resourceName);
		System.debug('+++++++++billingAPIToken+++++++' + billingAPIToken);

		String paymentProfileId = PaymentProfileUtility.getPaymentProfileId(accntId);
		System.debug('+++++++++paymentProfileId+++++++' + paymentProfileId);

		String productId = ProductPresentmentUtility.GetProductId(region, accntStatus.toUpperCase() , 'catalog=PARTNER_PROGRAM');
		System.debug('+++++++++productId+++++++' + productId);

		provisioningMsg = checkPaymentProfile(paymentProfileId);
		System.debug('+++++++++provisioningMsg+++++++' + provisioningMsg);

		if (provisioningMsg != null && provisioningMsg != '')
		{
			System.debug('+++++++++provisioningMsgINSIDE+++++++');
			updateOnboardingCase(caseId,'WelcomeKit Request Failed',provisioningMsg);
		}
		else
		{
			String reqString = getRequestString(productId, accntId, paymentProfileId);
			System.debug('+++++++++reqString+++++++' + reqString);
			//Call BillingAPI to create order in Archie
			provisioningMsg  =  getReturnMessage(PP_Onboarding_Util.postData('POST','callout:BillingAPI', billingAPIToken, reqString));
			System.debug('+++++++++provisioningMsg+++++++'+ provisioningMsg);

			if (provisioningMsg != null && provisioningMsg != '')
			{
				updateOnboardingCase(caseId,status,provisioningMsg);
			}
		}
	}


	public static String getBillingAPIResosource()
	{
		LP_BillingAPI_Resource__c billAPIResource = LP_BillingAPI_Resource__c.getOrgDefaults();
		return billAPIResource.Name;
	}

	public static String checkPaymentProfile(String paymentProfileId)
	{

		if (paymentProfileId == '' || paymentProfileId == null)  {
			return 'Welcome Kit could not be ordered for this account because of no valid payment profile.';
		}
		else
		{ return ''; }
	}

	public static String getIDAMToken(String Name)
	{
		String billingAPIToken;
		billingAPIToken = IDAM_Utilities.getToken(Name);
		return billingAPIToken;
	}

	public static String getRequestString(String productId, String accountId, String paymentProfileId)
	{
		String  jsonDataString =  '{"items": [ { "product_id": "'+ productId + '" , "quantity": 1 } ], "account": { "id": "'+ accountId + '" }, "recurring_payment_profile": {  "id": "'+ paymentProfileId + '" } }';
		return jsonDataString;
	}

	public static String checkLegalEntity(String legalEntity)
	{
		String region;
		if (legalEntity == 'MYOB Australia Pty Ltd')
		{
			region = 'AU';
		}
		else if (legalEntity == 'MYOB NZ Limited')
		{
			region = 'NZ';
		}

		return region;
	}

	public static String getReturnMessage(Integer statusCode)
	{
		String getReturnMessage;
		if (statusCode == 201)
		{
			status = 'Closed';
			getReturnMessage= 'Welcome Kit has been ordered for this partner successfully!!';
		}
		else
		{
			status = 'WelcomeKit Request Failed';
			getReturnMessage= 'Welcome Kit could not be ordered for this account because some issue with Order processing.';
		}
		return getReturnMessage;
	}

	public static Id getOnboardingCaseId(Id accntId)
	{
		Id recId;
		Case[] recordId = [SELECT Id FROM Case WHERE Account.Id=:accntId AND Status = 'Partner Enrolled'];
        if (recordId.size() > 0)
        {
            recId = recordId[0].Id;
        }
		return recId;
	}

	public static void updateOnboardingCase(Id caseId,String status,String message)
	{
		List<Case> caseToUpdate = [SELECT Status,Provisioning_Message__c FROM Case WHERE Id=:caseId];

		for(Case cs: caseToUpdate)
		{
			cs.Status = status;
			cs.Provisioning_Message__c = message;
		}
		//update caseToUpdate;
		try
		{
			List<Database.SaveResult> updateCasesResults = Database.update(caseToUpdate, true);
		}
		catch(Exception e)
		{
			LogUtilityException.throwException('SendPartnerWelcomeKitUtility', 'updateCasesResults', e,caseToUpdate);
		}
	}
}