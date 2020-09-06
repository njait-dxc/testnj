@IsTest
public class Test_CMOpportunityConsolidated {   
    /*public interface FieldDefaults
    {
        Map<Schema.SObjectField, Object> getFieldDefaults();
    }
    private static void addFieldDefaults(SObject sObj, Map<Schema.SObjectField, Object> defaults)
    {
        Map<String, Object> vPopulatedFields = sObj.getPopulatedFieldsAsMap();
        for (Schema.SObjectField field : defaults.keySet())
        {
            if (!vPopulatedFields.containsKey(String.valueOf(field)))
            {
                sObj.put(field, defaults.get(field));
            }
        }
    }    
    public static SObject createSObject(SObject sObj)
    {
        String vObjectName = String.valueOf(sObj.getSObjectType());
        String vDefaultClassName = 'TestDataFactory.' + vObjectName.replaceAll('__(c|C)$|__', '') + 'Defaults';
        Type vType = Type.forName(vDefaultClassName);
        if (vType != null)
        {
            FieldDefaults vDefaults = (FieldDefaults) vType.newInstance();
            addFieldDefaults(sObj, vDefaults.getFieldDefaults());
        }
        return sObj;
    }

    public static SObject createSObject(SObject sObj, Boolean doInsert)
    {
        SObject vRetObject = createSObject(sObj);
        if (doInsert)
        {
            Database.insert(vRetObject);
        }
        return vRetObject;
    } 
    private static Map<String, String> nameFieldMap = new Map<String, String>
    {
            'Contact' => 'LastName',
            'Case' => 'Subject'
    };
    public static List<SObject> createSObjectList(SObject sObj, Integer numberOfObjects)
    {
        List<SObject> vObjects = new List<SObject>();
        SObject vSingleObject = createSObject(sObj);

        // Get the name field for the object
        String vNameField = nameFieldMap.get(String.valueOf(sObj.getSObjectType()));
        if (vNameField == null)
        {
            vNameField = 'Name';
        }

        //if the name field is updateable
        Boolean vNameUpdateable = sObj.getSObjectType().getDescribe().fields.getMap().get(vNameField).getDescribe().isUpdateable();

        // Clone the object the number of times requested. Increment the name field so each record is unique
        for (Integer objectIndex = 1; objectIndex <= numberOfObjects; objectIndex++)
        {
            SObject vClone = vSingleObject.clone(false, true, false, false);
            if (vNameUpdateable)
            {
                vClone.put(vNameField, (String) vClone.get(vNameField) + ' ' + objectIndex);
            }
            vObjects.add(vClone);
        }
        return vObjects;
    } 

    public static List<SObject> createSObjectList(SObject sObj, Integer numberOfObjects, Boolean doInsert)
    {
        List<SObject> vRetList = createSObjectList(sObj, numberOfObjects);
        if (doInsert)
        {
            Database.insert(vRetList);
        }
        return vRetList;
    }   


    public class AccountDefaults implements FieldDefaults
    {
        public Map<Schema.SObjectField, Object> getFieldDefaults()
        {
            return new Map<Schema.SObjectField, Object>
            {
                    Account.Name => 'Test Account',
                    Account.CurrencyIsoCode => 'AUD'
            };
        }
    }

    public class ContactDefaults implements FieldDefaults
    {
        public Map<Schema.SObjectField, Object> getFieldDefaults()
        {
            return new Map<Schema.SObjectField, Object>
            {
                    Contact.FirstName => 'Test',
                    Contact.LastName => 'Contact'
            };
        }
    }

    public class Product2Defaults implements FieldDefaults
    {
        public Map<Schema.SObjectField, Object> getFieldDefaults()
        {
            return new Map<Schema.SObjectField, Object>
            {
                    Product2.Name => 'Test Product',
                    Product2.CurrencyIsoCode => 'AUD',
                    Product2.Weighting__c => 1.0
            };
        }
    }

    public class PricebookEntryDefaults implements FieldDefaults
    {
        public Map<Schema.SObjectField, Object> getFieldDefaults()
        {
            return new Map<Schema.SObjectField, Object>
            {
                    PricebookEntry.Pricebook2Id => Test.getStandardPricebookId(),
                    PricebookEntry.UnitPrice => 1.0,
                    PricebookEntry.IsActive => true,
                    PricebookEntry.Initial_Purchase_Price_Ex_GST__c => 5060,
                    PricebookEntry.Per_User_Purchase_Price_Ex_GST__c => 0
            };
        }
    }

    public class OpportunityDefaults implements FieldDefaults
    {
        public Map<Schema.SObjectField, Object> getFieldDefaults()
        {
            return new Map<Schema.SObjectField, Object>
            {
                    Opportunity.Pricebook2Id => Test.getStandardPricebookId(),
                    Opportunity.Name => 'Test Opp',
                    Opportunity.CurrencyIsoCode => 'AUD',
                    Opportunity.RecordTypeId => Constants.OPP_CM_RT
            };
        }
    }


    public class OpportunityLineItemDefaults implements FieldDefaults
    {
        public Map<Schema.SObjectField, Object> getFieldDefaults()
        {
            return new Map<Schema.SObjectField, Object>
            {
                    OpportunityLineItem.Initial_Purchase__c => true,
                    OpportunityLineItem.Discount_Percent__c => 0,
                    OpportunityLineItem.Discount_Value__c => 0,
                    OpportunityLineItem.UnitPrice => 1.0,
                    OpportunityLineItem.Number_of_Users__c => 1
            };
        }
    } 
    */
    
    @TestSetup
	static void setupData()
	{
		TestDataFactory.createOpportunityData();
        /*Account vAcc = (Account) createSObject(new Account(Legal_Entity__c = 'MYOB Australia Pty Ltd'), true);
        Contact vContact = (Contact) createSObject(new Contact(AccountId = vAcc.Id), true);
        List<Product2> vProdAETax = (List<Product2>) createSObjectList(new Product2(Product_Type__c = 'Software'), 2, true);
        Product2 vProdAEDMRIS = (Product2) createSObject(new Product2(Product_Type__c = 'Maintenance', Description='Adhoc Consulting', Excluded_for_Discounting__c = true), true);
        Product2 vProdCons = (Product2) createSObject(new Product2(Product_Type__c = 'Consulting'), true);
        Product2 vProdSoft = (Product2) createSObject(new Product2(Product_Type__c = 'Software', Environment_Check_EC__c = 'Y', Consulting_Question__c = 'Y'), true);
        Product2 vProdTravel = (Product2) createSObject(new Product2(Product_Type__c = 'Travel'), true);
        createSObject(new Product_Profile__c(Practice_Name__c = vAcc.Id, Prod_Profile_ID__c = 'pp-001', Name = 'MYOB AE Tax - AU'), true);
        //Product_Profile_Product_Set__c vPPPS = (Product_Profile_Product_Set__c) createSObject(new Product_Profile_Product_Set__c(Product_Profile_Name__c = 'MYOB AE Tax - AU', Product_Set__c = 'Testing'), true);
        //Product_Profile_Recommendation__c vPPRMustHave = (Product_Profile_Recommendation__c) createSObject(new Product_Profile_Recommendation__c(Product_Profile_Product_Set__c = vPPPS.Id, Product__c = vProdAETax[0].Id, Recommendation_Type__c = 'Must Have'), false);
        //Product_Profile_Recommendation__c vPPRRecommend = (Product_Profile_Recommendation__c) createSObject(new Product_Profile_Recommendation__c(Product_Profile_Product_Set__c = vPPPS.Id, Product__c = vProdAEDMRIS.Id, Recommendation_Type__c = 'Recommend'), false);
        //Database.insert(new List<Product_Profile_Recommendation__c>{vPPRMustHave, vPPRRecommend});
        //Database.insert(new List<Product_Recommendation__c>
        //{
        //        (Product_Recommendation__c) createSObject(new Product_Recommendation__c(Product__c = vProdAETax[1].Id, Recommended_Product__c = vProdCons.Id), false),
        //        (Product_Recommendation__c) createSObject(new Product_Recommendation__c(Product__c = vProdAETax[1].Id, Recommended_Product__c = vProdAEDMRIS.Id), false)
        //});

        PricebookEntry productAETaxPBE = (PricebookEntry) createSObject(new PricebookEntry(Product2Id = vProdAETax[0].Id), false);
        PricebookEntry productAEDMRISPBE = (PricebookEntry) createSObject(new PricebookEntry(Product2Id = vProdAEDMRIS.Id, UnitPrice = 2.0, Initial_Purchase_Price_Ex_GST__c = 1230, Per_User_Purchase_Price_Ex_GST__c = 540), false);
        PricebookEntry productAETax1PBE = (PricebookEntry) createSObject(new PricebookEntry(Product2Id = vProdAETax[1].Id), false);
        PricebookEntry vProdConsPBE = (PricebookEntry) createSObject(new PricebookEntry(Product2Id = vProdCons.Id), false);
        PricebookEntry vProdSoftPBE = (PricebookEntry) createSObject(new PricebookEntry(Product2Id = vProdSoft.Id, Per_User_Purchase_Price_Ex_GST__c = 1000, Initial_Purchase_Price_Ex_GST__c = 2000), false);
        PricebookEntry vProdTravelPBE = (PricebookEntry) createSObject(new PricebookEntry(Product2Id = vProdTravel.Id), false);
        
        Database.insert(new List<PricebookEntry>{productAETaxPBE, productAEDMRISPBE, productAETax1PBE, vProdConsPBE, vProdSoftPBE, vProdTravelPBE});
        Opportunity vOpp = (Opportunity) createSObject(new Opportunity(AccountId = vAcc.Id, StageName = 'Prospect', CloseDate = Date.newInstance(2020, 10, 10), Main_Contact__c = vContact.Id), true);

        Database.delete([SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :vOpp.Id]);
        Database.update(vOpp);

        createSObject(new OpportunityLineItem(OpportunityId = vOpp.Id, PricebookEntryId = productAETax1PBE.Id), true);
        createSObject(new OpportunityLineItem(OpportunityId = vOpp.Id, PricebookEntryId = vProdConsPBE.Id), true);
        createSObject(new OpportunityLineItem(OpportunityId = vOpp.Id, PricebookEntryId = vProdSoftPBE.Id, Initial_Purchase__c = false, Discount_Percent__c = 50), true);
        createSObject(new OpportunityLineItem(OpportunityId = vOpp.Id, PricebookEntryId = vProdTravelPBE.Id), true);
        createSObject(new OpportunityLineItem(OpportunityId = vOpp.Id, PricebookEntryId = productAEDMRISPBE.Id), true);	
        */
	} 

    @IsTest
    static void test1() 
    {
		Account ac = new Account(Name = 'TestAccount',Credit_Status__c = 'Blocked');
		insert ac;
		Id vCMOptyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Client Manager April.2017').getRecordTypeId();

		Opportunity op = new Opportunity (AccountId=ac.Id, Name='TestOpty', StageName='Open', CloseDate=Date.newInstance(2018,10,10), CurrencyIsoCode='AUD', RecordTypeId = vCMOptyRecordTypeId);
		insert op;
		Opportunity_Scoping_Question__c osq = new Opportunity_Scoping_Question__c(Opportunity__c =op.Id);
		insert osq;
        
       	Test.startTest();
		PageReference pageRef1 = Page.CMOpportunityConsolidatedPage;
		Test.setCurrentPage(pageRef1);
		ApexPages.StandardController sc = new ApexPages.StandardController(op);
		CMOpportunityConsolidatedPageExtension ec = new CMOpportunityConsolidatedPageExtension(sc);
        system.assertNotEquals(0, ec.mapValidationMessage.size());
        Test.stopTest();
    } 

    @IsTest
	static void test2() 
    {
		Id vCMOptyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Client Manager April.2017').getRecordTypeId();
		        
        Account ac = new Account(Name = 'TestAccount',Credit_Status__c = 'Blocked');
		insert ac;
        
        //Opportunity op = new Opportunity (AccountId=ac.Id, Name='TestOpty', StageName='Open', CloseDate=Date.newInstance(2018,10,10), CurrencyIsoCode='AUD', RecordTypeId = vCMOptyRecordTypeId);
		//insert op;

		Opportunity vOpp = [SELECT AccountId, Pricebook2Id, Name, StageName, CloseDate, CurrencyIsoCode, RecordTypeId, Main_Contact__c FROM Opportunity LIMIT 1];
        vOpp.AccountId = ac.id;
        vOpp.Onsite_Consulting__c = 'Yes';
        update vOpp;
        
		PricebookEntry vProdConsulting = [SELECT Id FROM PricebookEntry WHERE Product2.Product_Type__c = 'Consulting' LIMIT 1];
		PricebookEntry vProdMaintenance = [SELECT Id FROM PricebookEntry WHERE Product2.Product_Type__c = 'Maintenance' LIMIT 1];        
		PricebookEntry vProdSoftware = [SELECT Id FROM PricebookEntry WHERE Product2.Product_Type__c = 'Software' LIMIT 1];   

        Case c = new Case(AccountId = ac.id, Opportunity__c = vOpp.id, Primary_Category__c ='Administrative Request', Categ__c = 'Technical Services Request', Sub_Category__c = 'IT Assessment',Status = 'Open',Subject = 'Client System Environment Check Request');
       	insert c;
        
        Test.startTest();
		PageReference pageRef = Page.CMOpportunityConsolidatedPage;
		Test.setCurrentPage(pageRef);
		ApexPages.StandardController sc = new ApexPages.StandardController(vOpp);
		CMOpportunityConsolidatedPageExtension ec = new CMOpportunityConsolidatedPageExtension(sc);
        system.assertNotEquals(0, ec.mapValidationMessage.size());
        Test.stopTest();        
    }
}