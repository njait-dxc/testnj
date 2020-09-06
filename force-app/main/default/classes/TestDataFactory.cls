/**
 * @author
 * @date
 * @description Test Data Factory
 */

public without sharing class TestDataFactory
{

    /************ Defaults ************/

    /**
     * @description Use this interface to set up values to be defaulted for all objects
     */
    public interface FieldDefaults
    {
        Map<Schema.SObjectField, Object> getFieldDefaults();
    }


    /**
    * @description Default values for Account
    */
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

    /**
    * @description Default values for Contact
    */
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

    /**
    * @description Default values for Product2
    */
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

    /**
    * @description Default values for PricebookEntry
    */
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

    /**
    * @description Default values for Opportunity
    */
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

    /**
    * @description Default values for OpportunityLineItem
    */
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

    /**
    * @description Default values for Product_Profile__c
    */
    public class Product_ProfileDefaults implements FieldDefaults
    {
        public Map<Schema.SObjectField, Object> getFieldDefaults()
        {
            return new Map<Schema.SObjectField, Object>
            {
                    Product_Profile__c.Name => 'PP'
            };
        }
    }

    /**
    * @description Default values for User
    */
    public class UserDefaults implements FieldDefaults
    {
        public Map<Schema.SObjectField, Object> getFieldDefaults()
        {
            return new Map<Schema.SObjectField, Object>
            {
                    User.EmailEncodingKey => 'UTF-8',
                    User.LanguageLocaleKey => 'en_US',
                    User.LocaleSidKey => 'en_US',
                    User.TimeZoneSidKey => 'America/Los_Angeles',
                    User.FirstName => 'TestFirst',
                    User.LastName => 'TestLast'
            };
        }
    }

    /**
    * @description Default values for Case
    */
    public class CaseDefaults implements FieldDefaults
    {
        public Map<Schema.SObjectField, Object> getFieldDefaults()
        {
            return new Map<Schema.SObjectField, Object>
            {
                    Case.Subject => 'TestSubject',
                    Case.Description => 'Test Description',
                    Case.IsEscalated => false
            };
        }
    }

    /**
    * @description Default values for Lead
    */
    public class LeadDefaults implements FieldDefaults
    {
        public Map<Schema.SObjectField, Object> getFieldDefaults()
        {
            return new Map<Schema.SObjectField, Object>
            {
                    Lead.LastName => 'TestLastName',
                    Lead.Company => 'Test Company'
            };
        }
    }

    /************ Supporting methods ************/

    /**
     * @description Assign default values if field value isn't specified
     * @param sObj
     * @param defaults
     */
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

    /**
     * @description Map for unique Name fields (needed to create lists of objects)
     */
    private static Map<String, String> nameFieldMap = new Map<String, String>
    {
            'Contact' => 'LastName',
            'Case' => 'Subject'
    };


    /************ SObject generators ************/

    /**
     * @description Generate an SObject with respective field defaults (if any)
     * @param sObj
     * @return
     */
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

    /**
     * @description Generate an SObject with insert option
     * @param sObj
     * @param doInsert
     * @return
     */
    public static SObject createSObject(SObject sObj, Boolean doInsert)
    {
        SObject vRetObject = createSObject(sObj);
        if (doInsert)
        {
            Database.insert(vRetObject);
        }
        return vRetObject;
    }

    /**
     * @description Generate a List of SObjects
     * @param sObj
     * @param numberOfObjects
     * @return
     */
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

    /**
     * @description Generate a list of SObjects with insert option
     * @param sObj
     * @param numberOfObjects
     * @param doInsert
     * @return
     */
    public static List<SObject> createSObjectList(SObject sObj, Integer numberOfObjects, Boolean doInsert)
    {
        List<SObject> vRetList = createSObjectList(sObj, numberOfObjects);
        if (doInsert)
        {
            Database.insert(vRetList);
        }
        return vRetList;
    }


    public static Account createAccount(String name, String recordTypeName, String archieClientId, Boolean doInsert)
    {
        Account account = new Account();
        Id accountRecordTypeId =
                Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        account.Name = name;
        account.RecordTypeId = accountRecordTypeId;
        account.Archie_Client_ID__c = archieClientId;
        account.Client_ID__c = archieClientId;
        account.CurrencyIsoCode = 'AUD';
        if (doInsert)
        {
            insert account;
        }
        return account;
    }

    public static Contact createContact(String recordTypeName, Id accountId, Boolean doInsert)
    {
        Contact contact = new Contact();
        Id contactRecordTypeId =
                Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        contact.FirstName = 'Joe';
        contact.LastName = 'Bloggs';
        contact.RecordTypeId = contactRecordTypeId;
        contact.AccountId = accountId;
        contact.CurrencyIsoCode = 'AUD';
        if (doInsert)
        {
            insert contact;
        }
        return contact;
    }

    public static Pricebook2 createPriceBook(String name, Boolean isActive, Boolean doInsert)
    {
        Pricebook2 pricebook = new Pricebook2();
        pricebook.Name = name;
        pricebook.IsActive = isActive;
        if (doInsert)
        {
            insert pricebook;
        }
        return pricebook;
    }

    public static Product2 createProduct(String productName, Integer archieId, Double weighting, Boolean doInsert)
    {
        Product2 product = new Product2();
        product.Name = productName;
        product.Weighting__c = weighting;
        product.ProductCatalogueID__c = Double.valueOf(archieId);
        product.CurrencyIsoCode = 'AUD';
        if (doInsert)
        {
            insert product;
        }
        return product;
    }

    public static List<PricebookEntry> createPricebookEntry(List<Product2> productList, Id pricebookId, String currencyCode,
            Boolean doInsert)
    {
        List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
        for (Product2 product : productList)
        {
            PricebookEntry pbe = new PricebookEntry();
            pbe.CurrencyIsoCode = currencyCode;
            pbe.IsActive = true;
            pbe.UnitPrice = 200;
            pbe.Pricebook2Id = pricebookId;
            pbe.Product2Id = product.Id;
            pricebookEntryList.add(pbe);
        }
        if (doInsert)
        {
            insert pricebookEntryList;
        }
        return pricebookEntryList;
    }

    public static Opportunity createOpportunity(String name, String recordTypeName, String stage, Id pricebookId,
            String type, Date closeDate, Id accountId, Id contactId, Boolean doInsert)
    {
        Id oppRecordTypeId =
                Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        Opportunity opportunity = new Opportunity();
        opportunity.Name = name;
        opportunity.StageName = stage;
        opportunity.RecordTypeId = oppRecordTypeId;
        opportunity.Pricebook2Id = pricebookId;
        opportunity.Type = type;
        opportunity.CloseDate = closeDate;
        opportunity.AccountId = accountId;
        opportunity.Main_Contact__c = contactId;
        opportunity.CurrencyIsoCode = 'AUD';
        if (doInsert)
        {
            insert opportunity;
        }
        return opportunity;
    }

    public static List<OpportunityLineItem> createOpportunityLineItem(Id opportunityId, List<PricebookEntry> pbeList,
            Boolean doInsert)
    {
        List<OpportunityLineItem> lineItemList = new List<OpportunityLineItem>();
        for (PricebookEntry pbe : pbeList)
        {
            OpportunityLineItem lineItem = new OpportunityLineItem();
            lineItem.OpportunityId = opportunityId;
            lineItem.PricebookEntryId = pbe.Id;
            lineItem.Quantity = 1;
            lineItem.UnitPrice = 10;
            lineItem.PromoCode__c = '50PRCTOFF';
            lineItem.Number_of_Users__c = 1;
            lineItemList.add(lineItem);
        }
        if (doInsert)
        {
            insert lineItemList;
        }
        return lineItemList;
    }

    public static API_Call_Log__c createAPICallLog(String methodName, Boolean doInsert)
    {
        API_Call_Log__c apiCallLog = new API_Call_Log__c();
        apiCallLog.Request_Method__c = methodName;
        if (doInsert)
        {
            insert apiCallLog;
        }
        return apiCallLog;
    }

    /**
     * @description Creates full suite of Opportunity-related objects
     */
    public static void createOpportunityData()
    {
        Account vAcc = (Account) createSObject(new Account(Legal_Entity__c = 'MYOB Australia Pty Ltd'), true);
        Contact vContact = (Contact) createSObject(new Contact(AccountId = vAcc.Id), true);
        List<Product2> vProdAETax = (List<Product2>) createSObjectList(new Product2(Product_Type__c = 'Software'), 2, true);
        Product2 vProdAEDMRIS = (Product2) createSObject(new Product2(Product_Type__c = 'Maintenance', Description='Adhoc Consulting', Excluded_for_Discounting__c = true), true);
        Product2 vProdCons = (Product2) createSObject(new Product2(Product_Type__c = 'Consulting'), true);
        Product2 vProdSoft = (Product2) createSObject(new Product2(Product_Type__c = 'Software', Environment_Check_EC__c = 'Y', Consulting_Question__c = 'Y'), true);
        Product2 vProdTravel = (Product2) createSObject(new Product2(Product_Type__c = 'Travel'), true);
        createSObject(new Product_Profile__c(Practice_Name__c = vAcc.Id, Prod_Profile_ID__c = 'pp-001', Name = 'MYOB AE Tax - AU'), true);
        Product_Profile_Product_Set__c vPPPS = (Product_Profile_Product_Set__c) createSObject(new Product_Profile_Product_Set__c(Product_Profile_Name__c = 'MYOB AE Tax - AU', Product_Set__c = 'Testing'), true);
        Product_Profile_Recommendation__c vPPRMustHave = (Product_Profile_Recommendation__c) createSObject(new Product_Profile_Recommendation__c(Product_Profile_Product_Set__c = vPPPS.Id, Product__c = vProdAETax[0].Id, Recommendation_Type__c = 'Must Have'), false);
        Product_Profile_Recommendation__c vPPRRecommend = (Product_Profile_Recommendation__c) createSObject(new Product_Profile_Recommendation__c(Product_Profile_Product_Set__c = vPPPS.Id, Product__c = vProdAEDMRIS.Id, Recommendation_Type__c = 'Recommend'), false);
        Database.insert(new List<Product_Profile_Recommendation__c>{vPPRMustHave, vPPRRecommend});
        Database.insert(new List<Product_Recommendation__c>
        {
                (Product_Recommendation__c) createSObject(new Product_Recommendation__c(Product__c = vProdAETax[1].Id, Recommended_Product__c = vProdCons.Id), false),
                (Product_Recommendation__c) createSObject(new Product_Recommendation__c(Product__c = vProdAETax[1].Id, Recommended_Product__c = vProdAEDMRIS.Id), false)
        });

        PricebookEntry productAETaxPBE = (PricebookEntry) createSObject(new PricebookEntry(Product2Id = vProdAETax[0].Id), false);
        PricebookEntry productAEDMRISPBE = (PricebookEntry) createSObject(new PricebookEntry(Product2Id = vProdAEDMRIS.Id, UnitPrice = 2.0, Initial_Purchase_Price_Ex_GST__c = 1230, Per_User_Purchase_Price_Ex_GST__c = 540), false);
        PricebookEntry productAETax1PBE = (PricebookEntry) createSObject(new PricebookEntry(Product2Id = vProdAETax[1].Id), false);
        PricebookEntry vProdConsPBE = (PricebookEntry) createSObject(new PricebookEntry(Product2Id = vProdCons.Id), false);
        PricebookEntry vProdSoftPBE = (PricebookEntry) createSObject(new PricebookEntry(Product2Id = vProdSoft.Id, Per_User_Purchase_Price_Ex_GST__c = 1000, Initial_Purchase_Price_Ex_GST__c = 2000), false);
        PricebookEntry vProdTravelPBE = (PricebookEntry) createSObject(new PricebookEntry(Product2Id = vProdTravel.Id), false);
        
        Database.insert(new List<PricebookEntry>{productAETaxPBE, productAEDMRISPBE, productAETax1PBE, vProdConsPBE, vProdSoftPBE, vProdTravelPBE});
        Opportunity vOpp = (Opportunity) createSObject(new Opportunity(Name= 'Practice Opp 1',AccountId = vAcc.Id, StageName = 'Prospect', CloseDate = Date.newInstance(2020, 10, 10), Main_Contact__c = vContact.Id), true);

        /* Workaround for PB/workflows changing Pricebook after insert */
        Database.delete([SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :vOpp.Id]);
        Database.update(vOpp);

        createSObject(new OpportunityLineItem(OpportunityId = vOpp.Id, PricebookEntryId = productAETax1PBE.Id), true);
        createSObject(new OpportunityLineItem(OpportunityId = vOpp.Id, PricebookEntryId = vProdConsPBE.Id), true);
        createSObject(new OpportunityLineItem(OpportunityId = vOpp.Id, PricebookEntryId = vProdSoftPBE.Id, Initial_Purchase__c = false, Discount_Percent__c = 50), true);
        createSObject(new OpportunityLineItem(OpportunityId = vOpp.Id, PricebookEntryId = vProdTravelPBE.Id), true);
        createSObject(new OpportunityLineItem(OpportunityId = vOpp.Id, PricebookEntryId = productAEDMRISPBE.Id), true);
        Case vECCase1 = (Case) TestDataFactory.createSObject(new Case(Subject= 'Client System Environment Check Request', Opportunity__c = vOpp.Id,AccountId=vAcc.Id, ContactId=vContact.id, Primary_Category__c ='Administrative Request', Categ__c = 'Technical Services Request',Sub_Category__c = 'IT Assessment', Status = 'Open' ), true);
        Case vECCase2 = (Case) TestDataFactory.createSObject(new Case(Subject= 'Client System Environment Check Request', Opportunity__c = vOpp.Id,AccountId=vAcc.Id, ContactId=vContact.id, Primary_Category__c ='Administrative Request', Categ__c = 'Technical Services Request',Sub_Category__c = 'IT Assessment', Status = 'Closed' ), true);
        
    }
    
    /**
     * @Author : Nikhil Jaitly
     * @Created Date : 27/06/2020
     * @Description : Get Exception Log
     */
    public static Exception_Log__c getExceptionLog(String description, String excepDet, 
                                                   String excepTyp, String clsName, String methodName) {
      return new Exception_Log__c(Exception_Description__c = description,
                                  Exception_Details__c = excepDet,
                                  Exception_Type__c = excepTyp,
                                  Class_Name__c = clsName,
                                  Method_Name__c = methodName
                                  );
    }
}