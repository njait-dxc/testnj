/**
 * @author
 * @date
 * @description
 */

global class PP_Onboard_Place_Order {

	// Definitions
	global String partnerPresentmentToken;
	global String accountId;
	global Integer statusCode;


	@InvocableMethod public static void PP_Onboard_Place_Order (List<Case> caseObj)
	{
		String errorMessage;
		String legalEntity;
		String accntId;
		String caseNumber;
		Boolean newPartner = false;


		try {
			Map<Id, Case> caseMap = new Map<Id, Case>(caseObj);

			List<Case> cases = [SELECT Account.Client_ID__c,Account.Legal_Entity__c,Brand_New_Partner__c, CaseNumber FROM Case WHERE Id IN: caseMap.keySet()];

			for (Case c : cases){
				legalEntity = c.Account.Legal_Entity__c;
				accntId = c.Account.Client_ID__c;
				caseNumber = c.CaseNumber;
				newPartner = c.Brand_New_Partner__c;

			}

			String region = checkLegalEntity(legalEntity);
			if (region == null)
			{  throw new HTTPException('Unsupported Legal Entitiy, please check the legal entity');   }
			processOrderRequest(accntId,region,newPartner,caseNumber);

		}

		catch(Exception e) {
			throw (e);
		}
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

	global static String getPaymentProfileId(String accountId)
	{
		String paymentProfileId = PaymentProfileUtility.getPaymentProfileId(accountId);
		return paymentProfileId;
	}

	global static String getProductId(String region,Boolean newPartner)
	{
		String productId;
		if(newPartner == true)
		{
			productId = ProductPresentmentUtility.GetProductId(region, 'OPWHB', 'catalog=PARTNER_PROGRAM');
		}
		else
		{
			productId = ProductPresentmentUtility.GetProductId(region, 'OP', 'catalog=PARTNER_PROGRAM');
		}
		return productId;
	}

	global static String getRequestString(String productId, String accountId, String paymentProfileId)
	{
		String  jsonDataString =  '{"items": [ { "product_id": "'+ productId + '" , "quantity": 1 } ], "account": { "id": "'+ accountId + '" }, "recurring_payment_profile": {  "id": "'+ paymentProfileId + '" } }';
		return jsonDataString;
	}


	global static String checkLegalEntity(String legalEntity)
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
		else { region = null;
		}
		return region;
	}


	@Future(Callout=true) webService static void processOrderRequest (String accntId, String region, Boolean newPartner, String caseNumber)
	{
		try {
			//get the billing API resource
			String resourceName = getBillingAPIResosource();

			//get the IDAM Token
			String billingAPIToken = getIDAMToken(resourceName);

			String paymentProfileId = getPaymentProfileId(accntId);
			if (paymentProfileId == '' || paymentProfileId == null)
			{            throw new HTTPException('Payment Profile is invalid for this account. Order cannot be processed.');        }

			String productId = getProductId(region,newPartner);

			if (productId == '' || productId == null)
			{            throw new HTTPException('Could not get onbarding product, please contact system admin.');        }

			String reqString = getRequestString(productId, accntId, paymentProfileId);
			Integer statusCode = PP_Onboarding_Util.postData('POST','callout:BillingAPI', billingAPIToken, reqString);
			String errorMessage = getReturnMessage(statusCode);
			updateCase(caseNumber, statusCode);
			updatePartnerEnrolledDate(accntId, statusCode);
		}
		catch(Exception e) {
			throw (e);
		}
	}
	global static void updateCase(String caseNumber, Integer statusCode)
	{
		List<Case> CaseObj =new List<Case>();
		CaseObj = [SELECT Id, Status FROM Case WHERE CaseNumber =: caseNumber];
		for (Case CaseInstance: CaseObj)
		{
			if(statusCode == 201) { // Every status other than 201-OK is logged as an error
				CaseInstance.Status = 'Partner Enrolled'; } else { CaseInstance.Status = 'Enrollment Failed';}
			//update CaseObj;

			try
			{

				List<Database.SaveResult> updateCaseResults = Database.update(CaseObj,true);
			}
			catch(Exception e){
				LogUtilityException.throwException('PP_Onboard_Place_Order', 'updateCase', e,CaseObj);
			}
		}
	}

	global static String getReturnMessage(Integer statusCode)
	{
		String errorMessage;
		if(statusCode == 201) { // Every status other than 201-OK is logged as an error
			return 'Partner enrolment request has been successfully placed.';
		} else {
			errorMessage = 'Unknown Exception. Please contact system admin.';
			if(statusCode == 500) {
				errorMessage = 'Server experiencing a timeout, please try after sometime. Please contact system admin if the problem persists';
			}
			return errorMessage;
		}
	}

	public static void updatePartnerEnrolledDate(String accntId, Integer statusCode)
	{
		if (statusCode == 201)
		{
			Account acnt = [SELECT Partner_Enrolled_Date__c FROM Account WHERE Client_ID__c=:accntId];
			acnt.Partner_Enrolled_Date__c = System.today();
			//update acnt;

			try
			{
				Database.SaveResult updateAccountResult = Database.update(acnt,true);
			}
			catch(Exception e)
			{
				LogUtilityException.throwException('PP_Onboard_Place_Order', 'updatePartnerEnrolledDate', e,new List<Account>{acnt});
			}
		}
	}


	// Custom exception
	class HTTPException extends Exception {}
}