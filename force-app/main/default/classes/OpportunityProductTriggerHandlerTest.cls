@IsTest
public class OpportunityProductTriggerHandlerTest {
    
	@TestSetup static void setupTestData() {
		Id standardPricebookId = Test.getStandardPricebookId();
        Account account = TestDataFactory.createAccount('Alpha', 'Partner_Success_Accounts', '8131725', true);
        
        Contact contact = TestDataFactory.createContact('Partner_Success_Contacts', account.Id, true);
        
        Pricebook2 pricebook = TestDataFactory.createPriceBook('SME Solution Sales Processing Price book', true, true);
       
        //Create list of products
        List<Product2> productList = new List<Product2>();
        for (Integer i = 0; i < 10; i++) {
            productList.add(TestDataFactory.createProduct('ProductNumber - ' + i, i, Double.valueOf(i), false));
        }
        insert productList;
        
        TestDataFactory.createPricebookEntry(productList, standardPricebookId, 'AUD', true);
        TestDataFactory.createPricebookEntry(productList, pricebook.Id, 'AUD', true);
        
        Opportunity opportunity = TestDataFactory.createOpportunity('SME Test Opportunity', 'SME_Solution_Sales_Processing', 
                                                                    	'Closing', pricebook.Id, 'Wholesale',
                                                                    	Date.today(), account.Id, contact.Id, true);
	}
    
    @IsTest
    static void verifyErrorOnOpportunityInsert() {
        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name = 'SME Test Opportunity' LIMIT 1][0];
        List<PricebookEntry> pbeList = [SELECT Id FROM PricebookEntry
                                        		WHERE Pricebook2.Name = 'SME Solution Sales Processing Price book'];
        List<OpportunityLineItem> opportunityLineItemList = TestDataFactory.createOpportunityLineItem(opportunity.Id,
                                                                                                     pbeList, false);
        Test.startTest();
        //No record will insert because of the rule defined in trigger
        Database.insert(opportunityLineItemList, false);
        List<OpportunityLineItem> lineitemList = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =: opportunity.Id];
        System.assertEquals(lineitemList.size(), 0);
        
        Test.stopTest();
    }   
    
    @IsTest
    static void verifyErrorOnOpportunityUpdate() {
        try {
            Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name = 'SME Test Opportunity' LIMIT 1][0];
            List<PricebookEntry> pbeList = [
                    SELECT Id
                    FROM PricebookEntry
                    WHERE Pricebook2.Name = 'SME Solution Sales Processing Price book'
            ];
            List<OpportunityLineItem> opportunityLineItemList = TestDataFactory.createOpportunityLineItem(opportunity.Id,
                    pbeList, false);
            TRIG_OpportunityLineItem_Handler.showErrorForSMEOP = false;
            insert opportunityLineItemList;
            TRIG_OpportunityLineItem_Handler.showErrorForSMEOP = true;

            Test.startTest();
            //Modify the quantity, promo code and unit price of the line items
            for (OpportunityLineItem lineItem : opportunityLineItemList) {
                lineItem.Quantity = 2;
                lineItem.UnitPrice = 20;
                lineItem.PromoCode__c = '20PRCTOFF';
            }
            TRIG_OpportunityLineItem_Handler.recursionFlag = true;
            Database.update(opportunityLineItemList, false);
            for (OpportunityLineItem lineItem : [
                    SELECT Id, Quantity, UnitPrice, PromoCode__c
                    FROM OpportunityLineItem
                    WHERE OpportunityId = :opportunity.Id
            ]) {
                //Verify none of the value has changed
                System.assertEquals(lineItem.Quantity, 1);
                System.assertEquals(lineItem.UnitPrice, 10);
                System.assertEquals(lineItem.PromoCode__c, '50PRCTOFF');
            }
            Test.stopTest();
        } catch(Exception ex) {
            System.assert(ex.getMessage().contains('You cannot add products for SME opportunities ' +
                    'using standard screen'));
        }
    }    

}