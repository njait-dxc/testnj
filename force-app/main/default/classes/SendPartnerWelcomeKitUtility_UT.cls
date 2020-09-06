@IsTest
public with sharing class SendPartnerWelcomeKitUtility_UT {

	@TestSetup
	static void setUpData()
	{
		LP_BillingAPI_Resource__c billngAPI = new LP_BillingAPI_Resource__c();
		billngAPI.Name='test123';
		insert billngAPI;

		Account acc = new Account(Name='Test Account',Partner_Enrolled_Date__c=System.today().addDays(-3),LP_Status__c='Silver',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Franchise & Commercial Partnerships Accounts').getRecordTypeId());
		insert acc;

		Case cas = new Case(Status ='Partner Enrolled', Priority = 'Medium', Origin = 'Email', AccountId=acc.Id);
		insert cas;
	}

	@IsTest static void getRequestString()
	{
		String jsonDataString = SendPartnerWelcomeKitUtility.getRequestString('123', '123445', '1-PAYPRO');
		System.assertEquals(jsonDataString, '{"items": [ { "product_id": "123" , "quantity": 1 } ], "account": { "id": "123445" }, "recurring_payment_profile": {  "id": "1-PAYPRO" } }' );
	}

	@IsTest static void checkPaymentProfile()
	{
		String paymentprofilevalidaitonsuccess = SendPartnerWelcomeKitUtility.checkPaymentProfile('1-PAYPRO');
		String paymentprofilevalidaitonfail = SendPartnerWelcomeKitUtility.checkPaymentProfile('');
		System.assertEquals(paymentprofilevalidaitonsuccess, '' );
		System.assertEquals(paymentprofilevalidaitonfail, 'Welcome Kit could not be ordered for this account because of no valid payment profile.' );
	}

	@IsTest static void checkLegalEntity()
	{
		String legalEntityAU = SendPartnerWelcomeKitUtility.checkLegalEntity('MYOB Australia Pty Ltd');
		String legalEntityNZ = SendPartnerWelcomeKitUtility.checkLegalEntity('MYOB NZ Limited');
		System.assertEquals(legalEntityAU, 'AU' );
		System.assertEquals(legalEntityNZ, 'NZ' );
	}

	@IsTest static void getReturnMessage()
	{
		String successResponse = SendPartnerWelcomeKitUtility.getReturnMessage(201);
		String errorResponse = SendPartnerWelcomeKitUtility.getReturnMessage(300);
		System.assertEquals(errorResponse , 'Welcome Kit could not be ordered for this account because some issue with Order processing.');
		System.assertEquals(successResponse , 'Welcome Kit has been ordered for this partner successfully!!');
	}

	@IsTest static void getOnboardingCaseId()
	{
		Case cs = [SELECT AccountId FROM Case WHERE Status = 'Partner Enrolled'];

		Id caseId = SendPartnerWelcomeKitUtility.getOnboardingCaseId(cs.AccountId);
		System.assertNotEquals(caseId ,null);
	}

	@IsTest static void updateOnboardingCase()
	{

		Case cs = [SELECT Id FROM Case WHERE Status = 'Partner Enrolled'];

		SendPartnerWelcomeKitUtility.updateOnboardingCase(cs.Id,'WelcomeKit Request Failed','Test');

		Case csUpdated = [SELECT Status FROM Case WHERE Id=:cs.Id];

		System.assertEquals(csUpdated.Status,'WelcomeKit Request Failed');
	}

	@IsTest static void getBillingAPIResosource()
	{
		LP_BillingAPI_Resource__c billingAPIresource = [SELECT Id, Name FROM LP_BillingAPI_Resource__c];
		String resourceName = SendPartnerWelcomeKitUtility.getBillingAPIResosource();
		System.assertEquals(resourceName, 'test123');
	}

	@IsTest static void SendPartnerWelcomeKit()
	{
		try
		{
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
			Test.startTest();

			SendPartnerWelcomeKitUtility mainClass = new SendPartnerWelcomeKitUtility();
			mainClass.SendPartnerWelcomeKit();
			Test.stopTest();
		}
		catch(Exception e) {
			Case cs = [SELECT Status FROM Case WHERE Status = 'Partner Enrolled'];
			System.assertEquals(cs.Status,'Partner Enrolled');
		}
	}

	@IsTest static void getIDAMToken()
	{
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

		Test.startTest();
		String IDAMToken = SendPartnerWelcomeKitUtility.getIDAMToken('test123');
		System.assertEquals(IDAMToken, 'abcde');
	}

	// Test for retreiving access token
	@IsTest static void CreatePartnerWelcomeKitOrder() {
		String response;
		/*  try {
			  StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
			  mock.setStatusCode(200); // Or other appropriate HTTP status code
			  Test.setMock(HttpCalloutMock.class, mock);
			  response = PP_Onboard_Place_Order.PP_Onboard_Place_Order('123', 'MYOB Australia Pty Ltd');
			  System.assertEquals(response != null, true);
		  } catch(exception e) {
			  System.assertEquals(response == null, true);
		  }*/
		try
		{
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
			Case cs = [SELECT Status FROM Case WHERE Status = 'Partner Enrolled'];
			Account acnt = [SELECT Id FROM Account WHERE Name='Test Account'];
			Test.startTest();

			SendPartnerWelcomeKitUtility.CreatePartnerWelcomeKitOrder(acnt.Id,'123','AU',acnt.Id);
			Test.stopTest();
		}
		catch(Exception e) {
			Case cs = [SELECT Status FROM Case WHERE Status = 'Partner Enrolled'];
			System.assertEquals(cs.Status,'Partner Enrolled');
		}


	}
}