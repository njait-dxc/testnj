@IsTest
public class TEST_SMESalesConfirmationExtension 
{
    @TestSetup static void setUpData()
    {
        Id pricebookId = Test.getStandardPricebookId();
        Id SMEOptyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SME Solution Sales Processing').getRecordTypeId();
        
        //Opportunity opp = new Opportunity(Name='test SME opp testing class',StageName='Prospect', Probability = 95, CloseDate=system.today(), RecordTypeId = SMEOptyRecordTypeId);
        Opportunity opp = new Opportunity(Name='test SME opp testing class',StageName='Prospect', Probability = 95, CloseDate=system.today());
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
                Provisioning_Status__c = 'In Progress',
                Bulk_Purchase_Id__c = '3456-0987654876',
                PricebookEntryId = pbEntry.Id,
                TotalPrice = 5 * pbEntry.UnitPrice
        );
        TRIG_OpportunityLineItem_Handler.showErrorForSMEOP = false;
        insert oli;
        
        Order_Item__c ol1 = new Order_Item__c (
            Opportunity__c = opp.id, 
            File_Name__c =  'Essential 1111', 
            Link__c = 'Link1', 
            Opportunity_Line_Item_Id__c = oli.id, 
            Product_Instance_ID__c = 'product instance id1', 
            Purchase_ID__c = 'purchase id1', 
            Serial_Number__c = 'serial number1', 
            Status__c ='Pending'
        );
        insert ol1;
        
        Order_Item__c ol2 = new Order_Item__c (
            Opportunity__c = opp.id, 
            File_Name__c =  'Essential 2222', 
            Link__c = 'Link2', 
            Opportunity_Line_Item_Id__c = oli.id, 
            Product_Instance_ID__c = 'product instance id2', 
            Purchase_ID__c = 'purchase id2', 
            Serial_Number__c = 'serial number2', 
            Status__c ='Pending'
        );
        insert ol2;        
    }  
    
    @IsTest
    static void testExtension()
    {
        Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name='test SME opp testing class'];
        Test.startTest();
        PageReference pageRef1 = Page.SMESalesConfirmation;
        Test.setCurrentPage(pageRef1);
        ApexPages.StandardController sc = new ApexPages.StandardController(testOpp);
        SMESalesConfirmationExtension smeSalesConfirmationExtensionInstance = new SMESalesConfirmationExtension(sc);
        Integer countMap = smeSalesConfirmationExtensionInstance.SizeOfMap;
        Test.stopTest();
        
        System.assertEquals(1, smeSalesConfirmationExtensionInstance.listOppLineItems.size()); 
        
    }    
}