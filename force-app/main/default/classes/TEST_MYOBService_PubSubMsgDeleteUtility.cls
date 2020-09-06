/**
 * Created by Ankit.Bhardwaj on 11/02/2020.
 */

@IsTest
private class TEST_MYOBService_PubSubMsgDeleteUtility {
    @TestSetup static void setUpData()
    {
        Id pricebookId = Test.getStandardPricebookId();

        //create account
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;

        //create contact
        Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'Contact';
        c.Email = 'test@mailinator.com';

        insert c;

        Opportunity opp = new Opportunity(Name='test opp',StageName='Prospect', Probability = 95,Main_Contact__c = c.Id, CloseDate=system.today());
        insert opp;

        //Create your product
        Product2 prod = new Product2(
                Name = 'Essentials Starter',
                ProductCode = 'EA-STARTER',
                Weighting__c = 100,
                IsActive = true
        );
        insert prod;

        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = prod.Id,
                UnitPrice = 100.00,
                IsActive = true
        );
        insert pbEntry;

//create your opportunity line item.  This assumes you already have an opportunity created, called opp
        OpportunityLineItem oli = new OpportunityLineItem(
                OpportunityId = opp.Id,
                Quantity = 5,
                Provisioning_Status__c = 'Complete',
                Bulk_Purchase_Id__c = '3456-0987654876',
                PubSub_Message_Receipt_Id__c = '123456abcdef78910ghijk',
                PricebookEntryId = pbEntry.Id,
                TotalPrice = 5 * pbEntry.UnitPrice
        );
        TRIG_OpportunityLineItem_Handler.showErrorForSMEOP = false;
        insert oli;
    }

    @IsTest static void runBatchJob(){
        List<OpportunityLineItem> optyLineItems = [SELECT Id,OpportunityId,Provisioning_Status__c,Bulk_Purchase_Id__c,PubSub_Message_Receipt_Id__c FROM OpportunityLineItem];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MYOBServicesMockResponse());
        // Call the batch job
        MYOBService_PubSubMessageDeleteUtility BS = new MYOBService_PubSubMessageDeleteUtility();
        Database.BatchableContext bc;
        BS.start(bc);
        BS.execute(bc,optyLineItems);
        Test.stopTest();
      /*  OpportunityLineItem optyLineItemUpdated = [SELECT Id,OpportunityId,Provisioning_Status__c FROM OpportunityLineItem];
        Opportunity optyUpdated = [SELECT Id,StageName,Provisioning_Status__c FROM Opportunity];
        System.assertEquals(optyLineItemUpdated.Provisioning_Status__c,'Complete');
        System.assertEquals(optyUpdated.StageName,'Closed Won');
        System.assertEquals(optyUpdated.Provisioning_Status__c,'Complete');*/

    }
}