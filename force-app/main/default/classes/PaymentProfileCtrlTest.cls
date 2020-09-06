@IsTest
public class PaymentProfileCtrlTest {
	@TestSetup
	static void setup() {
		Account testAccount = new Account(Name='test', Client_ID__c='12345',Phone='0000');
		insert testAccount;
		Contact testContact = new Contact(LastName='test', AccountId=testAccount.Id, Phone='6789');
		insert testContact;
		Opportunity opportunity = new Opportunity(Name='test',StageName='Prospecting',
				AccountId=testAccount.Id, Main_Contact__c=testContact.Id,Type='Wholesale',
		CloseDate=date.today().addDays(5),mti_pb__PriceBook_To_Use__c='SME Solution Sales Processing Price book');
		insert opportunity;
	}

	@isTest
	static void getPaymentProfilesWithValidRecordId() {
		Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
		Test.setMock(HttpCalloutMock.class, new MYOBServicesMockResponse());
		Test.startTest();
		List<PaymentProfileCtrl.PaymentProfileWrapper> paymentProfiles = PaymentProfileCtrl.getPaymentProfiles(testOpportunity.Id);
		Test.stopTest();
		system.assertEquals(2, paymentProfiles.size());
	}

	@isTest
	static void getPaymentProfilesWithBlankRecordId() {
		Test.startTest();
		List<PaymentProfileCtrl.PaymentProfileWrapper> paymentProfiles = PaymentProfileCtrl.getPaymentProfiles(null);
		Test.stopTest();
		System.assert(paymentProfiles == null);
	}

	@IsTest
	static void updateOpportunityPaymentProfileId() {
		Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
		Test.setMock(HttpCalloutMock.class, new MYOBServicesMockResponse());
		Test.startTest();
		PaymentProfileCtrl.updateOpportunityPaymentProfileId(testOpportunity.Id, '1-ABCD4');
		Test.stopTest();
		Opportunity opportunityToVerify = [SELECT Id, Payment_Profile_Id__c FROM Opportunity WHERE Id=:testOpportunity.Id];
		system.assertEquals('1-ABCD4', opportunityToVerify.Payment_Profile_Id__c);
	}

	@IsTest
	static void updateOpportunityPaymentProfileIdWithBlankProfileId() {
		Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
		Test.startTest();
		Boolean isSuccess = PaymentProfileCtrl.updateOpportunityPaymentProfileId(testOpportunity.Id, null);
		Test.stopTest();
		system.assertEquals(false, isSuccess );
	}

	@IsTest
	static void checkDDWrapperClass() {
		MYOBService_BillingAPI.PaymentProfile_BankDetail ddWrap = new MYOBService_BillingAPI.PaymentProfile_BankDetail();
		ddWrap.account_number = '123456';
		ddWrap.bank_name = 'CBA';
		ddWrap.bsb = '063000';
		System.assertEquals(ddWrap.bsb,'063000');

	}
	@IsTest
	static void checkCCWrapperClass() {
		MYOBService_BillingAPI.PaymentProfile_CCDetail ccWrap = new MYOBService_BillingAPI.PaymentProfile_CCDetail();
		//Test.setMock(HttpCalloutMock.class, new MYOBServicesMockResponse());
		ccWrap.card_token = '12345';
		ccWrap.expiry_month ='10';
		ccWrap.expiry_year ='2025';
		ccWrap.last_four_digits='1234';
		ccWrap.name_on_card='Test';
		ccWrap.type='Visa';
		System.assertEquals(ccWrap.name_on_card,'Test');
	}
}