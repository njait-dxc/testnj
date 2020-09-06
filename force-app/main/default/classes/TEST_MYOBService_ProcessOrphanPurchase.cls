/**
 * Created by Ankit.Bhardwaj on 1/06/2020.
 */

@IsTest
private class TEST_MYOBService_ProcessOrphanPurchase {
    @TestSetup static void setUpData()
    {
        Orphan_Purchases__c op = new Orphan_Purchases__c();
        op.Item_Id__c = '12345';
        op.Account_Id__c = '007007';
        op.Contact_Id__c = '1-12345';
        op.Serial_Number__c = '61987654321';
        op.End_Date__c = '2050-06-19T00:12:47.000+00:00';
        op.Product_Id__c = '5';
        op.Type__c = 'free';
        op.Status__c = 'active';

        insert op;

        Account a = TestDataFactory.createAccount('Test Account 007007','Partner_Success_Accounts','007007',true);
        Contact c = TestDataFactory.createContact('Partner_Success_Contacts',a.Id,true);

        c.Contact_Siebel_Row_Id__c = '1-12345';
        update c;

        //Create your product
        Product2 prod = new Product2(Name = 'AccountRight Basics', ProductCode = 'ARB', Weighting__c = 100, ProductCatalogueID__c = 5, IsActive = true);
        insert prod;

        Pricebook2 customPB = new Pricebook2(Name = 'SME Purchase Pricebook', Description = 'SME Purchase Pricebook Record', IsActive = true);
        insert customPB;

        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 0, IsActive = true);
        insert standardPBE;

        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prod.Id, UnitPrice = 0, IsActive = true);
        insert pbEntry;
    }

    @IsTest static void runBatchJob(){
        List<Orphan_Purchases__c> opRecord = [SELECT Id,Serial_Number__c,Account_Id__c,Contact_Id__c,End_Date__c,Product_Id__c,Status__c,Type__c,Item_Id__c FROM Orphan_Purchases__c];
        Test.startTest();
        // Call the batch job
        MYOBService_ProcessOrphanPurchaseUtility BS = new MYOBService_ProcessOrphanPurchaseUtility();
        Database.BatchableContext bc;
        BS.start(bc);
        BS.execute(bc,opRecord);
        Test.stopTest();
        List<Opportunity> o = [SELECT Id from Opportunity where Subscription_Serial_Number__c = '61987654321'];
        List<Orphan_Purchases__c> opFinal = [SELECT Id from Orphan_Purchases__c];
        System.assertEquals(o.size(),1);
        System.assertEquals(opFinal.size(),0);

    }
}