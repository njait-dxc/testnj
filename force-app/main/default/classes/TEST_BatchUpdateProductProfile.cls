@IsTest
private class TEST_BatchUpdateProductProfile
{
	@TestSetup
	static void setupData()
	{
		Account vAcc = (Account)TestDataFactory.createSObject(new Account(), true);
		List<Product_Profile__c> vPPList = (List<Product_Profile__c>)TestDataFactory.createSObjectList(new Product_Profile__c(Practice_Name__c = vAcc.Id), 10,true);
		List <Product_Profile_Product_Set__c> vPPPSList = new List<Product_Profile_Product_Set__c>();
		for (Integer ppIndex = 0; ppIndex<9; ppIndex++)
		{
			vPPPSList.add((Product_Profile_Product_Set__c)TestDataFactory.createSObject(new Product_Profile_Product_Set__c(Product_Profile_Name__c = vPPList[ppIndex].Name, Product_Set__c = 'Client Accounting'),false));
		}
		Database.insert(vPPPSList);
	}

	@IsTest
	static void testUpdateProductSet()
	{
		Test.startTest();
		List<Product_Profile__c> ps = [Select Id, Name, Product_Set__c FROM Product_Profile__c];
		BatchUpdateProductProfile bupp = new BatchUpdateProductProfile();
		Database.executeBatch(bupp);
		Test.stopTest();
		System.assertEquals(0, [SELECT COUNT() FROM Product_Profile__c WHERE Product_Set__c = NULL], 'Product Set missing');
		System.assertEquals(9, [SELECT COUNT() FROM Product_Profile__c WHERE Product_Set__c = 'Client Accounting'], 'Product Set Client Accounting');
		System.assertEquals(1, [SELECT COUNT() FROM Product_Profile__c WHERE Product_Set__c = 'Unknown'], 'UnknownProduct Set missing');
		Product_Profile__c ps1 = [SELECT Id,Product_Set__c FROM Product_Profile__c WHERE Product_Set__c = 'Unknown'];
	}
}