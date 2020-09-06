@IsTest
public class OpportunityPMTriggerTest {
   @TestSetup
    static void init() { 
    } 
  
    @IsTest
     static void test() {
     //define the standart price for the product 
        String stdPbId = Test.getStandardPricebookId();
     // create account
        Account account = new Account(Name = 'Test Class', Type = 'Business', Legal_Entity__c = 'MYOB Australia Pty Ltd');
        insert account;   
         
         Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Partner Manager').getRecordTypeId();
    // create opportunity
        Opportunity opp = new Opportunity(AccountId = account.Id, Pricebook2Id = stdPbId, Name = 'Opp', StageName = 'Open',
                                          CloseDate = Date.newInstance(2018,10,10), CurrencyIsoCode='AUD', RecordTypeId = recordTypeId);
        insert opp; 
     //insert products
        Product2 connectedLed = new Product2(Name='Essentials Connected Ledger', Product_Type__c = 'DIFMO',
            Weighting__c = 1.0); 
         insert connectedLed;
     // insert price book entries
        PricebookEntry connectedLedPbe = new PricebookEntry(Pricebook2Id=stdPbId, Product2Id=connectedLed.Id, UnitPrice=1.0, IsActive=true);
         insert connectedLedPbe;
    // add a connected ledger product into opportunity 
    OpportunityLineItem connectedLedOli = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = connectedLedPbe.Id,
            Initial_Purchase__c = true, Discount_Percent__c = 0, Discount_Value__c = 0, UnitPrice = 1.0, Number_of_Users__c = 1); 
         insert connectedLedOli;
         update opp; 
         
         List<OpportunityLineItem> olis =  [SELECT Id, Product_Name__c, PB_Initial_Purchase_Price_Ex_GST__c, PB_Per_User_Purchase_Price_Ex_GST__c,
            Initial_Purchase_Price_Ex_GST__c, Per_User_Purchase_Price_Ex_GST__c, PricebookEntry.Product2.Product_Type__c,
            Total_List_Value__c, Discount_Percent__c, Discount_Value__c, Total_Value__c, AMV_Value__c, Services_Value__c,
            Software_Value__c, Total_List_Value_Inc_GST__c, Discount_Value_inc_GST__c, Total_Value_Inc_GST__c,
            AMV_Value_Inc_GST__c, Services_Value_Inc_GST__c, Software_Value_Inc_GST__c, Initial_Purchase__c, Number_of_Users__c,
            Product_Type__c, CurrencyIsoCode, Services_Discounted_Value__c, PricebookEntry.Initial_Purchase_Price_Ex_GST__c
            FROM OpportunityLineItem];
    // check if the product is added correctly on opportunitylineitem
    for (OpportunityLineItem oli : olis) {   
         if (oli.PricebookEntry.Product2.Product_Type__c == 'DIFMO') {
             System.assertEquals('Essentials Connected Ledger', oli.Product_Name__c);
}
}
     }
}