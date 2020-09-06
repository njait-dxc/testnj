@IsTest
public class ProductLicenseExtensionTest {
	@IsTest
	static void testExtension(){
		Account ac = new Account(Name = 'TestAccount');
		insert ac;
		Id vCMOptyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Client Manager April.2017').getRecordTypeId();

		Opportunity op = new Opportunity (AccountId=ac.Id, Name='TestOpty', StageName='Open', CloseDate=Date.newInstance(2018,10,10), CurrencyIsoCode='AUD', RecordTypeId = vCMOptyRecordTypeId);
		insert op;

		Case ce = new Case(AccountId=ac.Id, Opportunity__c = op.Id, Categ__c = 'General Service Request');
		insert ce;

		Product_License__c osq = new Product_License__c(Case__c =ce.Id);
		insert osq;

		Test.startTest();
		PageReference pageRef1 = Page.ProductLicenseNewRecordPage;
		Test.setCurrentPage(pageRef1);
		ApexPages.StandardController sc = new ApexPages.StandardController(osq);
		ProductLicenseExtension ec = new ProductLicenseExtension(sc);
		System.assertEquals(ce.Categ__c, ec.CaseCategory);
		Test.stopTest();
	}
}