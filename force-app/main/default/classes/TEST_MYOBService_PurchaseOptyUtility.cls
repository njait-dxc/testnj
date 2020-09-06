/**
 * Created by Ankit.Bhardwaj on 26/05/2020
 */

@IsTest
private class TEST_MYOBService_PurchaseOptyUtility {

    @TestSetup static void setUpData()
    {
        //create account11
        Account a1 = new Account();
        a1.Name = 'Test Account1';
        a1.Client_ID__c = '808088';
        insert a1;

        //create contact1
        Contact c1 = new Contact();
        c1.FirstName = 'Test';
        c1.LastName = 'Contact1';
        c1.Email = 'test@mailinator1.com';
        c1.Contact_Siebel_Row_Id__c = '1-12345';
        c1.AccountId = a1.Id;

        insert c1;

        //create account2
        Account a2 = new Account();
        a2.Name = 'Test Account2';
        a2.Client_ID__c = '909099';
        insert a2;

        //create contact2
        Contact c2 = new Contact();
        c2.FirstName = 'Test';
        c2.LastName = 'Contact2';
        c2.Email = 'test@mailinator2.com';
        c2.Contact_Siebel_Row_Id__c = '1-6789';
        c2.AccountId = a2.Id;

        insert c2;

        //Create your product
        Product2 prod = new Product2(
                Name = 'AccountRight Basics',
                ProductCode = 'ARB',
                Weighting__c = 100,
                ProductCatalogueID__c = 5,
                IsActive = true
        );
        insert prod;

        //Create your product
        Product2 prod2 = new Product2(
                Name = 'AccountRight Plus',
                ProductCode = 'ARB',
                Weighting__c = 100,
                ProductCatalogueID__c = 3,
                IsActive = true
        );
        insert prod2;

        //Create your product
        Product2 prod3 = new Product2(
                Name = 'AccountRight Premier',
                ProductCode = 'ARB',
                Weighting__c = 100,
                CurrencyIsoCode = 'NZD',
                ProductCatalogueID__c = 8,
                IsActive = true
        );
        insert prod3;

        Pricebook2 customPB = new Pricebook2(Name = 'SME Purchase Pricebook', Description = 'SME Purchase Pricebook Record', IsActive = true);
        insert customPB;

        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 0, IsActive = true);
        insert standardPBE;
        PricebookEntry standardPBE2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod2.Id, UnitPrice = 0, IsActive = true);
        insert standardPBE2;
        PricebookEntry standardPBE3 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod3.Id, UnitPrice = 0, IsActive = true, CurrencyIsoCode = 'NZD');
        insert standardPBE3;

        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
                Pricebook2Id = customPB.Id,
                Product2Id = prod.Id,
                UnitPrice = 0,
                IsActive = true

        );
        insert pbEntry;

        //Create your pricebook entry
        PricebookEntry pbEntry2 = new PricebookEntry(
                Pricebook2Id = customPB.Id,
                Product2Id = prod2.Id,
                UnitPrice = 0,
                IsActive = true

        );
        insert pbEntry2;

        //Create your pricebook entry
        PricebookEntry pbEntry3 = new PricebookEntry(
                Pricebook2Id = customPB.Id,
                Product2Id = prod3.Id,
                CurrencyIsoCode ='NZD',
                UnitPrice = 0,
                IsActive = true

        );
        insert pbEntry3;
    }

    @IsTest static void createTrialOpportunities()
    {
        List<MYOBService_PurchaseOpportunityUtility.SubscriptionResponse> subs = new List<MYOBService_PurchaseOpportunityUtility.SubscriptionResponse>();

        Account a1 = [SELECT Id,Client_ID__c from Account where Client_ID__c = '808088'];
        Account a2 = [SELECT Id,Client_ID__c from Account where Client_ID__c = '909099'];
        Contact c1 = [SELECT  Id,Contact_Siebel_Row_Id__c from Contact where AccountId = :a1.Id];
        Contact c2 = [SELECT  Id,Contact_Siebel_Row_Id__c from Contact where AccountId = :a2.Id];

        for (Integer i= 0;i < 2; i++)
        {
            MYOBService_PurchaseOpportunityUtility.SubscriptionResponse s = new MYOBService_PurchaseOpportunityUtility.SubscriptionResponse();
            if(i == 1) {
                s.contactId = c2.Contact_Siebel_Row_Id__c;
                s.accountId = a2.Client_ID__c;
                s.serialNumber = '61000'+a2.Client_ID__c;
            }
            else{
                s.contactId = c1.Contact_Siebel_Row_Id__c;
                s.accountId = a1.Client_ID__c;
                s.serialNumber = '61000'+a1.Client_ID__c;
            }
            s.endDate = '2050-06-19T22:22:47.000+00:00';
            s.productId = '5';
            s.type = 'free';
            s.status = 'active';
            s.id = '090909';
            subs.add(s);
        }

        MYOBService_PurchaseOpportunityUtility.createPurchaseOpportunities(subs);
        List<Opportunity> opps = [SELECT Id from Opportunity where Subscription_Serial_Number__c in ('61000808088','61000909099')];
        System.assertEquals(opps.size(),2);
        List<OpportunityLineItem> lines = [SELECT Id,Product2.ProductCatalogueID__c from OpportunityLineItem where OpportunityId in :opps];
        System.assertEquals(lines.size(),2);

        //resend the same opportunities to see if it does not create duplicate records and orphan record
        MYOBService_PurchaseOpportunityUtility.createPurchaseOpportunities(subs);
        List<Opportunity> opps1 = [SELECT Id from Opportunity where Subscription_Serial_Number__c in ('61000808088','61000909099')];
        System.assertEquals(opps1.size(),2);
        List<OpportunityLineItem> lines1 = [SELECT Id,Product2.ProductCatalogueID__c from OpportunityLineItem where OpportunityId in :opps];
        System.assertEquals(lines1.size(),2);
        List<Orphan_Purchases__c> orphanPurchases = [SELECT Id from Orphan_Purchases__c];
        System.assertEquals(orphanPurchases.size(),0);
    }

    @IsTest static void updateTrialOpportunities()
    {
        List<MYOBService_PurchaseOpportunityUtility.SubscriptionResponse> subs = new List<MYOBService_PurchaseOpportunityUtility.SubscriptionResponse>();

        Account a1 = [SELECT Id,Client_ID__c from Account where Client_ID__c = '808088'];
        Account a2 = [SELECT Id,Client_ID__c from Account where Client_ID__c = '909099'];
        Contact c1 = [SELECT  Id,Contact_Siebel_Row_Id__c from Contact where AccountId = :a1.Id];
        Contact c2 = [SELECT  Id,Contact_Siebel_Row_Id__c from Contact where AccountId = :a2.Id];

        for (Integer i= 0;i < 3; i++)
        {
            MYOBService_PurchaseOpportunityUtility.SubscriptionResponse s = new MYOBService_PurchaseOpportunityUtility.SubscriptionResponse();
            if(i == 1) {
                s.contactId = c2.Contact_Siebel_Row_Id__c;
                s.accountId = a2.Client_ID__c;
                s.serialNumber = '61000'+a2.Client_ID__c;
            }
            else{
                s.contactId = c1.Contact_Siebel_Row_Id__c;
                s.accountId = a1.Client_ID__c;
                s.serialNumber = '61000'+a1.Client_ID__c;
            }
            s.endDate = '2050-06-19T00:12:47.000+00:00';
            s.productId = '5';
            s.type = 'free';
            s.status = 'active';
            s.id = '090909';
            subs.add(s);
        }

        MYOBService_PurchaseOpportunityUtility.createPurchaseOpportunities(subs);
        List<Opportunity> opps = [SELECT Id from Opportunity];
        System.assertEquals(opps.size(),2);
        List<OpportunityLineItem> lines = [SELECT Id,Product2.ProductCatalogueID__c from OpportunityLineItem where OpportunityId in :opps];
        System.assertEquals(lines.size(),2);

        // reset the product id on the response to update the line items.
        for (MYOBService_PurchaseOpportunityUtility.SubscriptionResponse sr : subs)
        {
            if(sr.serialNumber == '61000808088') {
                sr.type = 'paid';
                sr.status = 'active';
                sr.productId = '3';
            }
            else{
                sr.type = 'free';
                sr.status = 'expired';
            }
        }
        System.debug(subs);
        MYOBService_PurchaseOpportunityUtility.updateExistingOpportunities(subs);
        list<Opportunity> optyLost = [SELECT Id from Opportunity where StageName = 'Closed Lost'];
        List<OpportunityLineItem> oli = [SELECT Id from OpportunityLineItem where Product2.ProductCatalogueID__c = 3 and Opportunity.StageName = 'Closed Won'];
        System.assertEquals(oli.size(),1);
        System.assertEquals(optyLost.size(),1);

    }

    @IsTest static void subsWrapper()
    {
        MYOBService_PurchaseOpportunityUtility.SubscriptionResponse s = new MYOBService_PurchaseOpportunityUtility.SubscriptionResponse();
        s.status = 'active';
        s.type = 'free';
        s.serialNumber = '12345';
        s.productId = '5';
        s.accountId = '23232';
        s.contactId = '1-1234';
        s.endDate = '2050-06-19T00:12:47.000+00:00';
        s.id = '90909';
        System.assertEquals(s.productId,'5');
    }

    @IsTest static void createOrphanOpportunities()
    {
        List<MYOBService_PurchaseOpportunityUtility.SubscriptionResponse> subs = new List<MYOBService_PurchaseOpportunityUtility.SubscriptionResponse>();

        Account a1 = [SELECT Id,Client_ID__c from Account where Client_ID__c = '808088'];
        Account a2 = [SELECT Id,Client_ID__c from Account where Client_ID__c = '909099'];
        Contact c1 = [SELECT  Id,Contact_Siebel_Row_Id__c from Contact where AccountId = :a1.Id];
        Contact c2 = [SELECT  Id,Contact_Siebel_Row_Id__c from Contact where AccountId = :a2.Id];

        for (Integer i= 0;i < 4; i++)
        {
            MYOBService_PurchaseOpportunityUtility.SubscriptionResponse s = new MYOBService_PurchaseOpportunityUtility.SubscriptionResponse();
            if(i == 1) {
                s.contactId = c2.Contact_Siebel_Row_Id__c;
                s.accountId = a2.Client_ID__c;
                s.serialNumber = '64000'+a2.Client_ID__c;
                s.id = '090909';
            }
            else{
                s.contactId = '123';
                s.accountId = '456';
                s.serialNumber = '64000'+a2.Client_ID__c;
                s.id = '090909';
            }
            s.endDate = '2050-06-19T00:12:47.000+00:00';
            s.productId = '8';
            s.type = 'free';
            s.status = 'active';
            subs.add(s);
        }

        MYOBService_PurchaseOpportunityUtility.createPurchaseOpportunities(subs);
        List<Opportunity> opps = [SELECT Id from Opportunity where Opportunity.CurrencyIsoCode = 'NZD'];
        System.assertEquals(opps.size(),1);
        List<OpportunityLineItem> lines = [SELECT Id,Product2.ProductCatalogueID__c from OpportunityLineItem where OpportunityId in :opps];
        List<Orphan_Purchases__c> orphanPurchases = [SELECT Id from Orphan_Purchases__c];
        System.assertEquals(orphanPurchases.size(),1);
        System.assertEquals(lines.size(),1);
    }

    @IsTest static void ignoreProductIdNull()
    {
        List<MYOBService_PurchaseOpportunityUtility.SubscriptionResponse> subs = new List<MYOBService_PurchaseOpportunityUtility.SubscriptionResponse>();

        Account a1 = [SELECT Id,Client_ID__c from Account where Client_ID__c = '808088'];
        Account a2 = [SELECT Id,Client_ID__c from Account where Client_ID__c = '909099'];
        Contact c1 = [SELECT  Id,Contact_Siebel_Row_Id__c from Contact where AccountId = :a1.Id];
        Contact c2 = [SELECT  Id,Contact_Siebel_Row_Id__c from Contact where AccountId = :a2.Id];

        for (Integer i= 0;i < 4; i++)
        {
            MYOBService_PurchaseOpportunityUtility.SubscriptionResponse s = new MYOBService_PurchaseOpportunityUtility.SubscriptionResponse();
            if(i == 1) {
                s.contactId = c2.Contact_Siebel_Row_Id__c;
                s.accountId = a2.Client_ID__c;
                s.serialNumber = '64000'+a2.Client_ID__c;
                s.id = '090909';
            }
            else{
                s.contactId = '123';
                s.accountId = '456';
                s.serialNumber = '64000'+a2.Client_ID__c;
                s.id = '090909';
            }
            s.endDate = '2050-06-19T00:12:47.000+00:00';
            s.productId = null;
            s.type = 'free';
            s.status = 'active';
            subs.add(s);
        }

        MYOBService_PurchaseOpportunityUtility.createPurchaseOpportunities(subs);
        List<Opportunity> opps = [SELECT Id from Opportunity where Opportunity.CurrencyIsoCode = 'NZD'];
        System.assertEquals(opps.size(),0);
        List<OpportunityLineItem> lines = [SELECT Id,Product2.ProductCatalogueID__c from OpportunityLineItem where OpportunityId in :opps];
        List<Orphan_Purchases__c> orphanPurchases = [SELECT Id from Orphan_Purchases__c];
        System.assertEquals(orphanPurchases.size(),0);
        System.assertEquals(lines.size(),0);
    }

    @IsTest static void ignoreUnknownProductId()
    {
        List<MYOBService_PurchaseOpportunityUtility.SubscriptionResponse> subs = new List<MYOBService_PurchaseOpportunityUtility.SubscriptionResponse>();

        Account a1 = [SELECT Id,Client_ID__c from Account where Client_ID__c = '808088'];
        Account a2 = [SELECT Id,Client_ID__c from Account where Client_ID__c = '909099'];
        Contact c1 = [SELECT  Id,Contact_Siebel_Row_Id__c from Contact where AccountId = :a1.Id];
        Contact c2 = [SELECT  Id,Contact_Siebel_Row_Id__c from Contact where AccountId = :a2.Id];

        for (Integer i= 0;i < 4; i++)
        {
            MYOBService_PurchaseOpportunityUtility.SubscriptionResponse s = new MYOBService_PurchaseOpportunityUtility.SubscriptionResponse();
            if(i == 1) {
                s.contactId = c2.Contact_Siebel_Row_Id__c;
                s.accountId = a2.Client_ID__c;
                s.serialNumber = '64000'+a2.Client_ID__c;
                s.id = '090909';
            }
            else{
                s.contactId = '123';
                s.accountId = '456';
                s.serialNumber = '64000'+a2.Client_ID__c;
                s.id = '090909';
            }
            s.endDate = '2050-06-19T00:12:47.000+00:00';
            s.productId = '35';
            s.type = 'free';
            s.status = 'active';
            subs.add(s);
        }

        MYOBService_PurchaseOpportunityUtility.createPurchaseOpportunities(subs);
        List<Opportunity> opps = [SELECT Id from Opportunity where Opportunity.CurrencyIsoCode = 'NZD'];
        System.assertEquals(opps.size(),0);
        List<OpportunityLineItem> lines = [SELECT Id,Product2.ProductCatalogueID__c from OpportunityLineItem where OpportunityId in :opps];
        List<Orphan_Purchases__c> orphanPurchases = [SELECT Id from Orphan_Purchases__c];
        System.assertEquals(orphanPurchases.size(),0);
        System.assertEquals(lines.size(),0);
    }

}