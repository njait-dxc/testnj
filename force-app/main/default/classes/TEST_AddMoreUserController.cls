@IsTest
private class TEST_AddMoreUserController
{
	@TestSetup
	static void setupData()
	{
		TestDataFactory.createOpportunityData();
	}

	@IsTest
	static void testAddMoreUserController()
	{
		Opportunity vOpp = [SELECT AccountId, Pricebook2Id, Name, StageName, CloseDate, CurrencyIsoCode, RecordTypeId, Main_Contact__c, (SELECT PricebookEntryId FROM OpportunityLineItems) FROM Opportunity LIMIT 1];
		Set<Id> vExistingItemPB = new Set<Id>();
		for(OpportunityLineItem oli: vOpp.OpportunityLineItems)
		{
			vExistingItemPB.add(oli.Id);
		}
		PricebookEntry vProdAETaxPBE = [SELECT Id FROM PricebookEntry WHERE Product2.Product_Type__c = 'Software' AND Id NOT IN :vExistingItemPB LIMIT 1];
		PricebookEntry vProdAEDMRISPBE = [SELECT Id FROM PricebookEntry WHERE Product2.Product_Type__c = 'Maintenance' LIMIT 1];

		Test.startTest();
		PageReference pageOppProdProfile = Page.OpportunityProductProfile;
		Test.setCurrentPage(pageOppProdProfile);
		ApexPages.StandardController sc = new ApexPages.StandardController(vOpp);
		AddMoreUserController vAddMoreUserControllerInstance = new AddMoreUserController(sc);

		vAddMoreUserControllerInstance.directToAddMoreUserPage();
		vAddMoreUserControllerInstance.directToAddRecommededProductPage();
		vAddMoreUserControllerInstance.addSelected();


		List <OpportunityLineItem> listAddSelected = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :vOpp.Id AND PricebookEntryId = :vProdAETaxPBE.Id];
		System.assertEquals(1, listAddSelected.size());

		vAddMoreUserControllerInstance.addSelectedRecommendedProduct();
		Test.stopTest();

		List <OpportunityLineItem> listAddSelectedRec = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :vOpp.Id AND PricebookEntryId = :vProdAEDMRISPBE.Id];
		System.assertEquals(1, listAddSelectedRec.size());
	}
}