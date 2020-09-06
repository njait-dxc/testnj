/**
 * @Author : Nikhil Jaitly
 * @Created Date : 02/06/2020
 * @Description : Test class for MYOBService_SubscriptionUpdateBatch
 */
@isTest
public with sharing class TEST_MYOBService_UpdProvStatBatch {
  @TestSetup static void setUpData()
    {
        Id pricebookId = Test.getStandardPricebookId();
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

        //create SME Purchase Opportunity
        Id recTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SME Purchase Opportunity').getRecordTypeId();

        Opportunity opp = new Opportunity(Name='test opp',StageName='Trial', Probability = 95, Main_Contact__c = c.Id, CloseDate=system.today(), RecordTypeId = recTypeId);
        insert opp;

//create your opportunity line item.  This assumes you already have an opportunity created, called opp
        OpportunityLineItem oli = new OpportunityLineItem(
                OpportunityId = opp.Id,
                Quantity = 1,
                Provisioning_Status__c = 'In Progress',
                Bulk_Purchase_Id__c = '3456-0987654878',
                PricebookEntryId = pbEntry.Id,
                TotalPrice = 1 * pbEntry.UnitPrice
        );
        TRIG_OpportunityLineItem_Handler.showErrorForSMEOP = false;
        insert oli;

        //create SME Bulk Purchase Opportunity
        Id recTypeId1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SME_Solution_Sales_Processing').getRecordTypeId();

        Opportunity opp1 = new Opportunity(Name='test opp',StageName='Prospect', Probability = 95, Main_Contact__c = c.Id, CloseDate=system.today(), RecordTypeId = recTypeId1);
        insert opp1;


//create your opportunity line item.  This assumes you already have an opportunity created, called opp
        OpportunityLineItem oli1 = new OpportunityLineItem(
                OpportunityId = opp1.Id,
                Quantity = 5,
                Provisioning_Status__c = 'In Progress',
                Bulk_Purchase_Id__c = '3456-0987654879',
                PricebookEntryId = pbEntry.Id,
                TotalPrice = 5 * pbEntry.UnitPrice
        );
        TRIG_OpportunityLineItem_Handler.showErrorForSMEOP = false;
        insert oli1;
    }

  @isTest
  static void testProvStatusUpdateBatch() {
        List<MYOBService_UpdateOptyLinesProvStatus.OrderTrackingResponseWrapper> respWrapper = new List<MYOBService_UpdateOptyLinesProvStatus.OrderTrackingResponseWrapper>();
        MYOBService_UpdateOptyLinesProvStatus.OrderTrackingResponseWrapper wrapper1 = new MYOBService_UpdateOptyLinesProvStatus.OrderTrackingResponseWrapper();
        MYOBService_UpdateOptyLinesProvStatus.OrderTrackingResponseWrapper wrapper2 = new MYOBService_UpdateOptyLinesProvStatus.OrderTrackingResponseWrapper();
        wrapper1.receiptId = '1234';
        wrapper1.purchaseId = '3456-0987654878';
        wrapper1.provisioningStatus ='PURCHASE_COMPLETE';
        respWrapper.add(wrapper1);

        wrapper2.receiptId = '5678';
        wrapper2.purchaseId = '3456-0987654879';
        wrapper2.provisioningStatus ='PURCHASE_COMPLETE';
        respWrapper.add(wrapper2);

        Test.startTest();
        try {
          Database.executeBatch(new MYOBService_UpdateProvStatusBatch(respWrapper, 'PubSub Order Tracking Service'));
        } catch(Exception ex) {

        }
        Test.stopTest();
          List<OpportunityLineItem> lines = [Select Id, Provisioning_Status__c from OpportunityLineItem where Provisioning_Status__c = 'Complete'];
          List<Opportunity> opties = [Select Id,StageName, Provisioning_Status__c from Opportunity where StageName = 'Closed Won'];
          System.assertEquals(lines.size(),2);
          System.assertEquals(opties.size(),2);
      }
}