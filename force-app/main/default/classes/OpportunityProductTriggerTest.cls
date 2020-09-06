@IsTest
public class OpportunityProductTriggerTest {

	@TestSetup
	static void init() {
	}

	@IsTest
	static void test() {
		Double[] expectedConsultingValues = new Double[]{5060, 0, 5060, 5060, 0, 5060, 0, 5566, 5566, 5566, 0, 5566, 0};
		Double[] expectedSoftwareValues = new Double[]{3930, 36.39, 2500, 2500, 0, 0, 2500, 4323, 2750, 2750, 0, 0, 2750};
		Double[] expectedMaintenanceValues = new Double[]{3240, 10, 2916, 2916, 2916, 0, 0, 3564, 3207.6, 3207.6, 3207.6, 0, 0};

		//insert products
		Product2 consultingProduct = new Product2(Name='AE Client Accounting Assisted Implementation', Product_Type__c = 'Consulting',
				Weighting__c = 1.0);
		Product2 softwareProduct = new Product2(Name='AE Client Accounting Plus', Product_Type__c = 'Software',
				Weighting__c = 1.0);
		Product2 maintenanceProduct = new Product2(Name='AE Client Accounting Plus Maintenance', Product_Type__c = 'Maintenance',
				Weighting__c = 1.0);
		insert consultingProduct;
		insert softwareProduct;
		insert maintenanceProduct;

		//define the standart price for the product
		String stdPbId = Test.getStandardPricebookId();

		// insert price book entries
		PricebookEntry consultingPbe = new PricebookEntry(Pricebook2Id=stdPbId, Product2Id=consultingProduct.Id, UnitPrice=1.0, IsActive=true,
				Initial_Purchase_Price_Ex_GST__c = 5060, Per_User_Purchase_Price_Ex_GST__c = 0);
		PricebookEntry softwarePbe = new PricebookEntry(Pricebook2Id=stdPbId, Product2Id=softwareProduct.Id, UnitPrice=2.0, IsActive=true,
				Initial_Purchase_Price_Ex_GST__c = 1230, Per_User_Purchase_Price_Ex_GST__c = 540);
		PricebookEntry maintenancePbe = new PricebookEntry(Pricebook2Id=stdPbId, Product2Id=maintenanceProduct.Id, UnitPrice=3.0, IsActive=true,
				Initial_Purchase_Price_Ex_GST__c = 1230, Per_User_Purchase_Price_Ex_GST__c = 540);
		insert consultingPbe;
		insert softwarePbe;
		insert maintenancePbe;

		// create account
		Account account = new Account(Name = 'Acc', Type = 'Customer', Industry = 'Automotive', Legal_Entity__c = 'MYOB Australia Pty Ltd');
		insert account;

		// create GST
		GST__c ausGST = new GST__c(Name='AUS GST Percent', Currency_Iso_Code__c='AUD', GST_Percent__c=10);
		insert ausGST;

		Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Client Manager April.2017').getRecordTypeId();

		// create opportunity
		Opportunity opp = new Opportunity(AccountId = account.Id, Pricebook2Id = stdPbId, Name = 'Opp', StageName = 'Open',
				CloseDate = Date.newInstance(2017,10,10), CurrencyIsoCode='AUD', RecordTypeId = recordTypeId, Discount_Reasons_for_Software__c = 'Licence Transfers',
				Discount_Reason_for_Maintenance__c = 'Retention Offer', Retention_Offer_Explanation__c = 'Test');
		insert opp;
		/* Workaround for PB/workflows changing Pricebook after insert */
		delete [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
		update opp;

		// create opportunity products
		OpportunityLineItem consultingOli = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = consultingPbe.Id,
				Initial_Purchase__c = true, Discount_Percent__c = 0, Discount_Value__c = 0, UnitPrice = 1.0, Number_of_Users__c = 1);
		OpportunityLineItem softwareOli = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = softwarePbe.Id,
				Initial_Purchase__c = true, Discount_Percent__c = 0, Discount_Value__c = 2500, UnitPrice = 1.0, Number_of_Users__c = 5);
		OpportunityLineItem maintenanceOli = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = maintenancePbe.Id,
				Initial_Purchase__c = false, Discount_Percent__c = 10, Discount_Value__c = 0, UnitPrice = 1.0, Number_of_Users__c = 6);
		insert consultingOli;
		insert softwareOli;
		insert maintenanceOli;

		update opp;

		List<OpportunityLineItem> olis = [SELECT Id, PB_Initial_Purchase_Price_Ex_GST__c, PB_Per_User_Purchase_Price_Ex_GST__c,
				Initial_Purchase_Price_Ex_GST__c, Per_User_Purchase_Price_Ex_GST__c, PricebookEntry.Product2.Product_Type__c,
				Total_List_Value__c, Discount_Percent__c, Discount_Value__c, Total_Value__c, AMV_Value__c, Services_Value__c,
				Software_Value__c, Total_List_Value_Inc_GST__c, Discount_Value_inc_GST__c, Total_Value_Inc_GST__c,
				AMV_Value_Inc_GST__c, Services_Value_Inc_GST__c, Software_Value_Inc_GST__c, Initial_Purchase__c, Number_of_Users__c,
				Product_Type__c, CurrencyIsoCode, Services_Discounted_Value__c, PricebookEntry.Initial_Purchase_Price_Ex_GST__c
		FROM OpportunityLineItem];

		// test before insert
		for (OpportunityLineItem oli : olis) {
			if (oli.PricebookEntry.Product2.Product_Type__c == 'Consulting') {
				System.assertEquals(5060, oli.PricebookEntry.Initial_Purchase_Price_Ex_GST__c);
				System.assertEquals(5060, oli.PB_Initial_Purchase_Price_Ex_GST__c);
				System.assertEquals(5060, oli.Initial_Purchase_Price_Ex_GST__c);
				System.assertEquals(0, oli.Per_User_Purchase_Price_Ex_GST__c);
			} else if (oli.PricebookEntry.Product2.Product_Type__c == 'Software') {
				System.assertEquals(1230, oli.Initial_Purchase_Price_Ex_GST__c);
				System.assertEquals(540, oli.Per_User_Purchase_Price_Ex_GST__c);
			} else if (oli.PricebookEntry.Product2.Product_Type__c == 'Maintenance') {
				System.assertEquals(1230, oli.Initial_Purchase_Price_Ex_GST__c);
				System.assertEquals(540, oli.Per_User_Purchase_Price_Ex_GST__c);
			}
		}

		// update OpportunityLineItem records
		for (OpportunityLineItem oli : olis) {
			oli.Weighted_Units__c = 3;
			oli.Repriced__c = true;
		}

		update olis;

		// test before update
		for (OpportunityLineItem oli : olis) {
			if (oli.PricebookEntry.Product2.Product_Type__c == 'Consulting') {
				//assert(expectedConsultingValues, oli);
				System.assertEquals(0, oli.Services_Discounted_Value__c);
				System.assertEquals(expectedConsultingValues[0], oli.Total_List_Value__c);
				System.assertEquals(expectedConsultingValues[1], oli.Discount_Percent__c.setScale(2));
				System.assertEquals(expectedConsultingValues[2], oli.Discount_Value__c);
				System.assertEquals(expectedConsultingValues[3], oli.Total_Value__c);
				System.assertEquals(expectedConsultingValues[4], oli.AMV_Value__c);
				System.assertEquals(expectedConsultingValues[5], oli.Services_Value__c);
				System.assertEquals(expectedConsultingValues[6], oli.Software_Value__c);
				System.assertEquals(expectedConsultingValues[7], oli.Total_List_Value_Inc_GST__c);
				System.assertEquals(expectedConsultingValues[8], oli.Discount_Value_inc_GST__c);
				System.assertEquals(expectedConsultingValues[9], oli.Total_Value_Inc_GST__c);
				System.assertEquals(expectedConsultingValues[10], oli.AMV_Value_Inc_GST__c);
				System.assertEquals(expectedConsultingValues[11], oli.Services_Value_Inc_GST__c);
				System.assertEquals(expectedConsultingValues[12], oli.Software_Value_Inc_GST__c);
			} else if (oli.PricebookEntry.Product2.Product_Type__c == 'Software') {
				//assert(expectedSoftwareValues, oli);
				System.assertEquals(expectedSoftwareValues[0], oli.Total_List_Value__c);
				System.assertEquals(expectedSoftwareValues[1], oli.Discount_Percent__c.setScale(2));
				System.assertEquals(expectedSoftwareValues[2], oli.Discount_Value__c);
				System.assertEquals(expectedSoftwareValues[3], oli.Total_Value__c);
				System.assertEquals(expectedSoftwareValues[4], oli.AMV_Value__c);
				System.assertEquals(expectedSoftwareValues[5], oli.Services_Value__c);
				System.assertEquals(expectedSoftwareValues[6], oli.Software_Value__c);
				System.assertEquals(expectedSoftwareValues[7], oli.Total_List_Value_Inc_GST__c);
				System.assertEquals(expectedSoftwareValues[8], oli.Discount_Value_inc_GST__c);
				System.assertEquals(expectedSoftwareValues[9], oli.Total_Value_Inc_GST__c);
				System.assertEquals(expectedSoftwareValues[10], oli.AMV_Value_Inc_GST__c);
				System.assertEquals(expectedSoftwareValues[11], oli.Services_Value_Inc_GST__c);
				System.assertEquals(expectedSoftwareValues[12], oli.Software_Value_Inc_GST__c);
			} else if (oli.PricebookEntry.Product2.Product_Type__c == 'Maintenance') {
				//assert(expectedMaintenanceValues, oli);
				System.assertEquals(expectedMaintenanceValues[0], oli.Total_List_Value__c);
				System.assertEquals(expectedMaintenanceValues[1], oli.Discount_Percent__c.setScale(2));
				System.assertEquals(expectedMaintenanceValues[2], oli.Discount_Value__c);
				System.assertEquals(expectedMaintenanceValues[3], oli.Total_Value__c);
				System.assertEquals(expectedMaintenanceValues[4], oli.AMV_Value__c);
				System.assertEquals(expectedMaintenanceValues[5], oli.Services_Value__c);
				System.assertEquals(expectedMaintenanceValues[6], oli.Software_Value__c);
				System.assertEquals(expectedMaintenanceValues[7], oli.Total_List_Value_Inc_GST__c);
				System.assertEquals(expectedMaintenanceValues[8], oli.Discount_Value_inc_GST__c);
				System.assertEquals(expectedMaintenanceValues[9], oli.Total_Value_Inc_GST__c);
				System.assertEquals(expectedMaintenanceValues[10], oli.AMV_Value_Inc_GST__c);
				System.assertEquals(expectedMaintenanceValues[11], oli.Services_Value_Inc_GST__c);
				System.assertEquals(expectedMaintenanceValues[12], oli.Software_Value_Inc_GST__c);
			}
		}
	}

	/*
	private static void assert(Double[] expectedValues, OpportunityLineItem oli) {
		System.assertEquals(expectedValues[0], oli.Total_List_Value__c);
		System.assertEquals(expectedValues[1], oli.Discount_Percent__c.setScale(2));
		System.assertEquals(expectedValues[2], oli.Discount_Value__c);
		System.assertEquals(expectedValues[3], oli.Total_Value__c);
		System.assertEquals(expectedValues[4], oli.AMV_Value__c);
		System.assertEquals(expectedValues[5], oli.Services_Value__c);
		System.assertEquals(expectedValues[6], oli.Software_Value__c);
		System.assertEquals(expectedValues[7], oli.Total_List_Value_Inc_GST__c);
		System.assertEquals(expectedValues[8], oli.Discount_Value_Inc_GST__c);
		System.assertEquals(expectedValues[9], oli.Total_Value_Inc_GST__c);
		System.assertEquals(expectedValues[10], oli.AMV_Value_Inc_GST__c);
		System.assertEquals(expectedValues[11], oli.Services_Value_Inc_GST__c);
		System.assertEquals(expectedValues[12], oli.Software_Value_Inc_GST__c);
	}
*/

}