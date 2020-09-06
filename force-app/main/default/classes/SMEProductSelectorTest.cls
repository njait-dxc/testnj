@IsTest
public class SMEProductSelectorTest
{

	@TestSetup
	static void setupTestData()
	{
		Id standardPricebookId = Test.getStandardPricebookId();
		Account account = TestDataFactory.createAccount('Alpha', 'Partner_Success_Accounts', '8131725', true);

		Contact contact = TestDataFactory.createContact('Partner_Success_Contacts', account.Id, true);

		Pricebook2 pricebook = TestDataFactory.createPriceBook('SME Solution Sales Processing Price book', true, true);

		//Create list of products
		List<Product2> productList = new List<Product2>();
		for (Integer i = 0; i < 10; i++)
		{
			productList.add(TestDataFactory.createProduct('ProductNumber - ' + i, i, Double.valueOf(i), false));
		}
		insert productList;

		TestDataFactory.createPricebookEntry(productList, standardPricebookId, 'AUD', true);
		TestDataFactory.createPricebookEntry(productList, pricebook.Id, 'AUD', true);

		Opportunity opportunity = TestDataFactory.createOpportunity('SME Test Opportunity', 'SME_Solution_Sales_Processing',
				'Prospect', pricebook.Id, 'Wholesale',
				Date.today(), account.Id, contact.Id, true);
	}

	@IsTest
	static void verifySMEProductSelectorController()
	{

		Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name = 'SME Test Opportunity' LIMIT 1][0];

		//Set the mock response for MYOB Services
		Test.setMock(HttpCalloutMock.class, new MYOBServicesMockResponse());
		/*Test Start*/
		Test.startTest();
		//Initialising of the controller
		List<SMEProductSelector.SMEProductWrapperClass> wrapperLst =
				SMEProductSelector.getOpportunityLineItems(opportunity.Id);
		System.assertEquals(wrapperLst.size(), 10);
		//Testing the promo code test for 0th index of wrapper class
		List<SMEProductSelector.promoCodeClass> promoWrapper = new List<SMEProductSelector.promoCodeClass>();
		promoWrapper = SMEProductSelector.getPromoCodeList(wrapperLst[0]);
		System.assertEquals(promoWrapper.size(), 6);
		System.assertEquals(promoWrapper[1].promoCode, 'ONLINEONLY25PCTOFF');
		System.assertEquals(promoWrapper[1].tncLink, 'http://www.myob.com/');
		//Putting dummy quantity and promo code from the retrieved values
		wrapperLst[0].quantity = 3;
		wrapperLst[1].quantity = 4;
		wrapperLst[0].promoCode = promoWrapper[1].promoCode;
		wrapperLst[0].tnc = promoWrapper[1].tncLink;
		wrapperLst[1].promoCode = promoWrapper[1].promoCode;
		wrapperLst[1].tnc = promoWrapper[1].tncLink;
		wrapperLst[0].netPrice = 36;
		wrapperLst[1].netPrice = 25;
		//Calling the save function to save the line items
		SMEProductSelector.updateOpportunityProducts(wrapperLst, opportunity.Id);

		List<OpportunityLineItem> lineitemList = [SELECT Id,Promotion_Terms__c FROM OpportunityLineItem WHERE OpportunityId = :opportunity.Id];
		System.assertEquals(lineitemList.size(), 2);
		System.assertEquals(lineitemList[0].Promotion_Terms__c,'http://www.myob.com/');

		//Reload the wrapperlist and delete one of the line items
		wrapperLst = new List<SMEProductSelector.SMEProductWrapperClass>();
		wrapperLst = SMEProductSelector.getOpportunityLineItems(opportunity.Id);

		//Put 0 as the new quantity and call save function
		wrapperLst[0].quantity = 0;
		wrapperLst[0].promoCode = 'BLBS160DAYFREE';
		SMEProductSelector.updateOpportunityProducts(wrapperLst, opportunity.Id);
		lineitemList = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opportunity.Id];
		System.assertEquals(lineitemList.size(), 1);

		Test.stopTest();
		/*Test Stop*/
	}

	@IsTest
	static void verifySMEProductSelectorControllerUnitPrice()
	{
		Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name = 'SME Test Opportunity' LIMIT 1][0];

		//Set the mock response for MYOB Services
		Test.setMock(HttpCalloutMock.class, new MYOBServicesMockResponse());
		/*Test Start*/
		Test.startTest();
		//Initialising of the controller
		List<SMEProductSelector.SMEProductWrapperClass> wrapperLst =
				SMEProductSelector.getOpportunityLineItems(opportunity.Id);
		System.assertEquals(wrapperLst.size(), 10);
		//Testing the changing the quantity and calling the product presentment service
		wrapperLst[0].quantity = 3;
		wrapperLst[0].promoCode = '--Select--';
		SMEProductSelector.unitPriceWrapperClass unitpriceWrapper = SMEProductSelector.getUnitPrice(wrapperLst[0]);
		Double unitPrice = unitpriceWrapper.unitPrice;
		System.assertEquals(unitPrice, 36);
		SMEProductSelector.updateOpportunityProducts(wrapperLst, opportunity.Id);
		List<OpportunityLineItem> lineitemList = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opportunity.Id];
		System.assertEquals(lineitemList.size(), 1);

		Test.stopTest();
		/*Test Stop*/
	}

	@IsTest
	static void verifyProductPresentmentService()
	{
		Test.setMock(HttpCalloutMock.class, new MYOBServicesMockResponse());

		Account account = [SELECT Id, Archie_Client_ID__c FROM Account WHERE Name = 'Alpha' LIMIT 1][0];
		Test.startTest();
		MYOBService_ProductPresentmentAPI.getProductsForAccount(account.Archie_Client_ID__c);
		//Not added any asserts as not currently in use
		Test.stopTest();
	}

	@IsTest
	static void verifyBillingService()
	{
		Test.setMock(HttpCalloutMock.class, new MYOBServicesMockResponse());

		Account account = [SELECT Id, Archie_Client_ID__c FROM Account WHERE Name = 'Alpha' LIMIT 1][0];
		Test.startTest();
		List<MYOBService_BillingAPI.PaymentProfile> paymentProfileList =
				MYOBService_BillingAPI.getPaymentProfiles(account.Archie_Client_ID__c);
		//Verify the number of payment profile returned
		System.assertEquals(paymentProfileList.size(), 3);
		Test.stopTest();
	}
}