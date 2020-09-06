@IsTest
public class TEST_AddRecommendedProductController
{
	@TestSetup
	static void setupData()
	{
		TestDataFactory.createOpportunityData();
	}

	@IsTest
	static void testAddRecProductController()
	{
		Opportunity vOpp = [SELECT AccountId, Pricebook2Id, Name, StageName, CloseDate, CurrencyIsoCode, RecordTypeId, Main_Contact__c FROM Opportunity LIMIT 1];
		PricebookEntry vProdConsulting = [SELECT Id FROM PricebookEntry WHERE Product2.Product_Type__c = 'Consulting' LIMIT 1];
		PricebookEntry vProdMaintenance = [SELECT Id FROM PricebookEntry WHERE Product2.Product_Type__c = 'Maintenance' LIMIT 1];

		Test.startTest();
		PageReference vPageAddOppRecommendedProduct = Page.AddOppRecommededProduct;
		Test.setCurrentPage(vPageAddOppRecommendedProduct);
		ApexPages.StandardController sc = new ApexPages.StandardController(vOpp);
		AddRecommendedProductController vAddRecInstance = new AddRecommendedProductController(sc);
		vAddRecInstance.addSelectedRecommendedProduct();
		Test.stopTest();

		List <OpportunityLineItem> listAddSelected = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :vOpp.Id AND PricebookEntryId = :vProdMaintenance.Id];
		System.assertEquals(1, listAddSelected.size());
		List <OpportunityLineItem> listAddSelected2 = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :vOpp.Id AND PricebookEntryId = :vProdConsulting.Id];
		System.assertEquals(1, listAddSelected2.size());
	}
}