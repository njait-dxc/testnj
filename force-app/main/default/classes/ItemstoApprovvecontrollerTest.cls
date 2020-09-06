@IsTest
public class ItemstoApprovvecontrollerTest
{
	@IsTest
	static void Test()
	{
		Profile p1 = [SELECT Id FROM Profile WHERE Name = '~ Client Manager April.2017'];
		Profile p2 = [SELECT Id FROM Profile WHERE Name = '~ Standard User - AD'];
		Profile p3 = [SELECT Id FROM Profile WHERE Name = '~ Managers'];

		User userMgr1 = new User(Alias = 'userMgr1', Email = 'userMrg1@testorg.com',
				EmailEncodingKey = 'UTF-8', LastName = 'userMgr1', LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_AU', ProfileId = p3.Id,
				TimeZoneSidKey = 'Australia/Sydney', Username = 'userMrg1@testorg.com');
		insert userMgr1;

		User userCM1 = new User(Alias = 'userCM1', Email = 'userCM1@testorg.com',
				EmailEncodingKey = 'UTF-8', LastName = 'userCM1', LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_AU', ProfileId = p1.Id,
				TimeZoneSidKey = 'Australia/Sydney', Username = 'userCM1@testorg.com', ManagerId = userMgr1.Id, approver__c = userMgr1.Id);
		insert userCM1;

		User userPM1 = new User(Alias = 'userPM1', Email = 'userPM1@testorg.com',
				EmailEncodingKey = 'UTF-8', LastName = 'userPM1', LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_AU', ProfileId = p2.Id,
				TimeZoneSidKey = 'Australia/Sydney', Username = 'userPM1@testorg.com', ManagerId = userMgr1.Id, approver__c = userMgr1.Id);
		insert userPM1;

		Account a = new Account(Name = 'TestAccount', Legal_Entity__c = 'MYOB Australia Pty Ltd', OwnerId = userPM1.Id);
		insert a;
		Contact c = new Contact(FirstName = 'FN', LastName = 'LN', AccountId = a.Id);
		insert c;

		Product2 consultingProduct = new Product2(Name = 'AE Client Accounting Assisted Implementation', Product_Type__c = 'Consulting',
				Weighting__c = 1.0);
		Product2 softwareProduct = new Product2(Name = 'AE Client Accounting Plus', Product_Type__c = 'Software',
				Weighting__c = 1.0);
		Product2 maintenanceProduct = new Product2(Name = 'AE Client Accounting Plus Maintenance', Product_Type__c = 'Maintenance', Excluded_for_Discounting__c = false,
				Weighting__c = 1.0);
		Product2 maintenanceProductNoDiscount = new Product2(Name = 'Maintenance Reduction from cancellation', Product_Type__c = 'Maintenance', Excluded_for_Discounting__c = true,
				Weighting__c = 1.0);
		insert consultingProduct;
		insert softwareProduct;
		insert maintenanceProduct;
		insert maintenanceProductNoDiscount;

		String stdPbId = Test.getStandardPricebookId();

		PricebookEntry consultingPbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = consultingProduct.Id, UnitPrice = 1.0, IsActive = true,
				Initial_Purchase_Price_Ex_GST__c = 5060, Per_User_Purchase_Price_Ex_GST__c = 0);
		PricebookEntry softwarePbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = softwareProduct.Id, UnitPrice = 2.0, IsActive = true,
				Initial_Purchase_Price_Ex_GST__c = 1230, Per_User_Purchase_Price_Ex_GST__c = 540);
		PricebookEntry maintenancePbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = maintenanceProduct.Id, UnitPrice = 3.0, IsActive = true,
				Initial_Purchase_Price_Ex_GST__c = 1230, Per_User_Purchase_Price_Ex_GST__c = 540);
		PricebookEntry maintenanceNoDiscountPbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = maintenanceProductNoDiscount.Id, UnitPrice = 0.0, IsActive = true,
				Initial_Purchase_Price_Ex_GST__c = 0, Per_User_Purchase_Price_Ex_GST__c = 0);
		insert consultingPbe;
		insert softwarePbe;
		insert maintenancePbe;
		insert maintenanceNoDiscountPbe;

		Id CMOptyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Client Manager April.2017').getRecordTypeId();
		Opportunity opp = new Opportunity(AccountId = a.Id, Pricebook2Id = stdPbId, Name = 'Opp', StageName = 'Prospect',
				CloseDate = Date.newInstance(2020, 10, 10), CurrencyIsoCode = 'AUD', RecordTypeId = CMOptyRecordTypeId, OwnerId = userCM1.Id, Discount_Reasons_for_Software__c = 'Licence Transfers',
				Discount_Reason_for_Maintenance__c = 'Retention Offer', Retention_Offer_Explanation__c = 'Test');
		insert opp;
		/* Workaround for PB/workflows changing Pricebook after insert */
		delete [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
		update opp;

		OpportunityLineItem consultingOli = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = consultingPbe.Id,
				Initial_Purchase__c = true, Discount_Percent__c = 0, Discount_Value__c = 0, UnitPrice = 1.0, Number_of_Users__c = 1);
		OpportunityLineItem softwareOli = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = softwarePbe.Id,
				Initial_Purchase__c = true, Discount_Percent__c = 0, Discount_Value__c = 2500, UnitPrice = 1.0, Number_of_Users__c = 5);
		OpportunityLineItem maintenanceOli = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = maintenancePbe.Id,
				Initial_Purchase__c = false, Discount_Percent__c = 10, Discount_Value__c = 0, UnitPrice = 1.0, Number_of_Users__c = 6);
		OpportunityLineItem maintenanceNoDiscountOli = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = maintenanceNoDiscountPbe.Id,
				Initial_Purchase__c = false, Discount_Percent__c = 0, Discount_Value__c = -10, UnitPrice = 1.0, Number_of_Users__c = 1);
		insert consultingOli;
		insert softwareOli;
		insert maintenanceOli;
		insert maintenanceNoDiscountOli;

		update opp;

		Opportunity opp2 = new Opportunity(AccountId = a.Id, Pricebook2Id = stdPbId, Name = 'Opp2', StageName = 'Prospect',
				CloseDate = Date.newInstance(2070, 10, 10), CurrencyIsoCode = 'AUD', RecordTypeId = CMOptyRecordTypeId, OwnerId = userCM1.Id, Discount_Reasons_for_Software__c = 'Licence Transfers');
		insert opp2;
		/* Workaround for PB/workflows changing Pricebook after insert */
		delete [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opp2.Id];
		update opp2;

		OpportunityLineItem softwareOli2 = new OpportunityLineItem(OpportunityId = opp2.Id, PricebookEntryId = softwarePbe.Id,
				Initial_Purchase__c = true, Discount_Percent__c = 0, Discount_Value__c = 2500, UnitPrice = 1.0, Number_of_Users__c = 5);
		insert softwareOli2;
		update opp2;

		GST__c ausGST = new GST__c(Name = 'AUS GST Percent', Currency_Iso_Code__c = 'AUD', GST_Percent__c = 10);
		insert ausGST;

		List<Id> newWorkItemIds;


		System.runAs(userCM1)
		{
			Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
			req1.setComments('Submitting request for approval.');
			req1.setObjectId(opp.Id);
			req1.setSubmitterId(userCM1.Id);
			req1.setProcessDefinitionNameOrId('Opportunity_Approval_Process_5');
			req1.setSkipEntryCriteria(true);
			Approval.ProcessResult result = Approval.process(req1);
			newWorkItemIds = result.getNewWorkitemIds();
		}

		System.runAs(userPM1)
		{
			Case case1 = new Case (AccountId = a.Id, Primary_Category__c = 'Billing & Finance', Categ__c = 'Credit Note', Total_Value__c = 1000, Clear_Reason_For_the_Credit__c = 'Archie pricing incorrect');
			insert case1;
		}
		System.runAs(userMgr1)
		{
			Test.startTest();
			PageReference ItemToApprovePage = Page.ItemToApprovePage;
			Test.setCurrentPage(ItemToApprovePage);
			ApexPages.currentPage().getParameters().put('myParam', '12345');
			ItemstoApproveController ITA = new ItemstoApproveController();

			ITA.processSelected();
			String url = ItemstoApproveController.ApproveRejectnavigation();
			System.assert(url.contains('12345'));
			url = ItemstoApproveController.REASSIGNnavigation();
			System.assert(url.contains('12345'));
			System.assert(url.contains('REASSIGN'));
		}
	}
}