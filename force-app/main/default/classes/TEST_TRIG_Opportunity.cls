/**
 * @author alexvolkov
 * @date 7/1/20
 * @description 
 */
@IsTest
private with sharing class TEST_TRIG_Opportunity
{
	@TestSetup
	static void setupData()
	{
		Account vAcc = (Account) TestDataFactory.createSObject(new Account(Legal_Entity__c = 'MYOB Australia Pty Ltd'), true);
		Contact vContact = (Contact) TestDataFactory.createSObject(new Contact(AccountId = vAcc.Id, Email = 'abc@xyz.com', Contact_Siebel_Row_Id__c = '1-12345', STS_GUID__c = 'jhasdh-dajda-adsads'), true);
		List<Product2> vProducts = (List<Product2>) TestDataFactory.createSObjectList(new Product2(Product_Type__c = 'Software'), 2, true);
		PricebookEntry vPE1 = (PricebookEntry) TestDataFactory.createSObject(new PricebookEntry(Product2Id = vProducts[0].Id), false);
		PricebookEntry vPE2 = (PricebookEntry) TestDataFactory.createSObject(new PricebookEntry(Product2Id = vProducts[1].Id), false);
		Database.insert(new List<PricebookEntry>
		{
				vPE1, vPE2
		});
		//define the wholsealse bulk opportunity
		Opportunity vOpp = (Opportunity) TestDataFactory.createSObject(new Opportunity(Name = 'Bulk Opty', AccountId = vAcc.Id, StageName = 'Prospect', CloseDate = Date.newInstance(2020, 10, 10), Main_Contact__c = vContact.Id, RecordTypeId = Constants.OPP_SME_RT, Type = Constants.OPP_TYPE, Payment_Profile_Id__c = '1-6789'), true);
		TRIG_OpportunityLineItem_Handler.showErrorForSMEOP = true;
		Database.insert(new List<OpportunityLineItem>
		{
				(OpportunityLineItem)TestDataFactory.createSObject(new OpportunityLineItem(OpportunityId = vOpp.Id, PricebookEntryId = vPE1.Id, Quantity = 1), false),
				(OpportunityLineItem)TestDataFactory.createSObject(new OpportunityLineItem(OpportunityId = vOpp.Id, PricebookEntryId = vPE2.Id, Quantity = 1), false)
		});
		//define the trial to paid conversion opportunity
		Opportunity vOpp1 = (Opportunity) TestDataFactory.createSObject(new Opportunity(Name = 'Trial Opty', AccountId = vAcc.Id, StageName = 'Trial', CloseDate = Date.newInstance(2020, 10, 10), Main_Contact__c = vContact.Id, RecordTypeId = Constants.OPP_SME_PURCHASE_RT, Payment_Profile_Id__c = '1-6789',Subscription_Serial_Number__c = '54646464'), true);
		TRIG_OpportunityLineItem_Handler.showErrorForSMEOP = false;
		Database.insert(new List<OpportunityLineItem>
		{
				(OpportunityLineItem)TestDataFactory.createSObject(new OpportunityLineItem(OpportunityId = vOpp1.Id, PricebookEntryId = vPE1.Id, Quantity = 1), false)
		});
	}

	static testMethod void testProductProvisioning()
	{
		Opportunity vOpp1 = [SELECT StageName FROM Opportunity where Name = 'Bulk Opty'];
		vOpp1.StageName = Constants.OPP_FOR_PROVISIONING;
		Test.setMock(HttpCalloutMock.class, new MYOBServicesMockResponse());
		Test.startTest();
		Database.update(vOpp1);
		Test.stopTest();
		System.assertEquals(2, [SELECT COUNT() FROM Order_Item__c], 'Order Items were not created');
	}

	static testMethod void testProductProvisioningforTrialOpty()
	{
		Opportunity vOpp2 = [SELECT StageName FROM Opportunity where Name = 'Trial Opty'];
		vOpp2.StageName = Constants.OPP_FOR_PROVISIONING;
		Test.setMock(HttpCalloutMock.class, new MYOBServicesMockResponse());
		Test.startTest();
		Database.update(vOpp2);
		Opportunity op = [SELECT StageName FROM Opportunity where Name = 'Trial Opty'];
		System.debug('Stage Name After Update'+op.StageName);
		Test.stopTest();
		System.assertEquals(1, [SELECT COUNT() FROM Order_Item__c], 'Order Items were not created');
	}

	static testMethod void testOppPracticeValition()
	{    
		/*Account vAcc = (Account) TestDataFactory.createSObject(new Account(Legal_Entity__c = 'MYOB Australia Pty Ltd'), true);
		Contact vContact = (Contact) TestDataFactory.createSObject(new Contact(AccountId = vAcc.Id), true);
		List<Product2> vProducts = (List<Product2>) TestDataFactory.createSObjectList(new Product2(Product_Type__c = 'Software', Environment_Check_EC__c= 'Y'), 2, true);
		PricebookEntry vPE1 = (PricebookEntry) TestDataFactory.createSObject(new PricebookEntry(Product2Id = vProducts[0].Id), false);
		PricebookEntry vPE2 = (PricebookEntry) TestDataFactory.createSObject(new PricebookEntry(Product2Id = vProducts[1].Id), false);
		Database.insert(new List<PricebookEntry>
		{
				vPE1, vPE2
		});
		Opportunity vOpp = (Opportunity) TestDataFactory.createSObject(new Opportunity(Name= 'Practice Opp 1', AccountId = vAcc.Id, StageName = 'Prospect', CloseDate = Date.newInstance(2020, 10, 10), Main_Contact__c = vContact.Id, RecordTypeId = Constants.OPP_CM_RT), true);
		Database.insert(new List<OpportunityLineItem>
		{
				(OpportunityLineItem)TestDataFactory.createSObject(new OpportunityLineItem(OpportunityId = vOpp.Id, PricebookEntryId = vPE1.Id, Quantity = 1), false),
				(OpportunityLineItem)TestDataFactory.createSObject(new OpportunityLineItem(OpportunityId = vOpp.Id, PricebookEntryId = vPE2.Id, Quantity = 1), false)
		}); 

        Case vECCase1 = (Case) TestDataFactory.createSObject(new Case(Subject= 'Client System Environment Check Request', Opportunity__c = vOpp.Id,AccountId=vAcc.Id, ContactId=vContact.id, Primary_Category__c ='Administrative Request', Categ__c = 'Technical Services Request',Sub_Category__c = 'IT Assessment', Status = 'Open' ), true);
        Case vECCase2 = (Case) TestDataFactory.createSObject(new Case(Subject= 'Client System Environment Check Request', Opportunity__c = vOpp.Id,AccountId=vAcc.Id, ContactId=vContact.id, Primary_Category__c ='Administrative Request', Categ__c = 'Technical Services Request',Sub_Category__c = 'IT Assessment', Status = 'Closed' ), true);
		*/	
        TestDataFactory.createOpportunityData();
        
        Opportunity vOpp1 = [SELECT StageName FROM Opportunity  WHERE Name = 'Practice Opp 1' LIMIT 1];
		vOpp1.StageName = 'Closed Won';
		Test.startTest();
		Database.update(vOpp1);
        Opportunity tempOpp = [SELECT StageName FROM Opportunity  WHERE Name = 'Practice Opp 1' LIMIT 1];
        system.assertEquals('Closed Won', tempOpp.StageName);
		Test.stopTest();        
    }
    
    static testMethod void testPublishOpportunityPlatformEvent_Delete()
	{
		Opportunity vOpp1 = [SELECT StageName FROM Opportunity where Name = 'Bulk Opty'];

		Test.startTest();
		delete vOpp1; 
		Test.stopTest();
	}

	static testMethod void testPublishOpportunityPlatformEvent_Undelete()
	{
		Opportunity vOpp1 = [SELECT StageName FROM Opportunity where Name = 'Bulk Opty'];
		delete vOpp1; 
		
		Test.startTest();
		undelete vOpp1;
		Test.stopTest();
	}
}