/**
 * @author alexvolkov
 * @date 7/1/20
 * @description 
 */
public with sharing class OpportunityService
{
    public static String optyRecordTypeId;
    public static void processOrderItems (Set<Id> pOppIds)
    {
        List<MYOBService_PurchasingAPI.PurchaseRequest> vPRList = new List<MYOBService_PurchasingAPI.PurchaseRequest>();
        for (Opportunity o: [SELECT Account.Name, Account.Client_Id__c, Main_Contact__r.Email, Main_Contact__r.FirstName, Main_Contact__r.LastName, Main_Contact__r.Phone, CurrencyIsoCode,
                            Main_Contact__r.Contact_Siebel_Row_Id__c, Payment_Profile_Id__c,Record_Type_Name__c,Subscription_Serial_Number__c,RecordTypeId,
                            Main_Contact__r.STS_GUID__c,
                            (SELECT Quantity, Product2.ProductCatalogueID__c, Promo_Id__c, Product2.Name FROM OpportunityLineItems WHERE Quantity > 0)
                            FROM Opportunity WHERE Id IN :pOppIds])
        {
            MYOBService_PurchasingAPI.PurchaseRequest vPR = new MYOBService_PurchasingAPI.PurchaseRequest();
            optyRecordTypeId = o.RecordTypeId;
            vPR.data = new MYOBService_PurchasingAPI.PurchaseRequestData();
            vPR.parentId = o.Id;
            vPR.data.attributes = new MYOBService_PurchasingAPI.PurchaseRequestDataAttributes();
            if(optyRecordTypeId == Constants.OPP_SME_RT) {
                vPR.data.attributes.sourceInitiative = 'SALESFORCEBULK';
            }
            else{
                vPR.data.attributes.sourceInitiative = 'SALESFORCE';
            }
            vPR.data.attributes.account = new MYOBService_PurchasingAPI.PurchaseAccount();
            //vPR.data.attributes.account.name = o.Account.Name;
            switch on o.CurrencyIsoCode
            {
                when 'AUD'
                {
                    vPR.data.attributes.account.legalEntity = 'MYOB Australia Pty Ltd';
                }
                when 'NZD'
                {
                    vPR.data.attributes.account.legalEntity = 'MYOB NZ Limited';
                }
            }
            vPR.data.attributes.account.contact = new MYOBService_PurchasingAPI.PurchaseContact();
            vPR.data.attributes.account.contact.id = o.Main_Contact__r.Contact_Siebel_Row_Id__c;
            vPR.data.attributes.account.contact.identityId = o.Main_Contact__r.STS_GUID__c;
            //vPR.data.attributes.account.contact.emailId = o.Main_Contact__r.Email; Commented by AB on 03/02/2020 as per the integration contract
            //vPR.data.attributes.account.contact.firstName = o.Main_Contact__r.FirstName; Commented by AB on 03/02/2020 as per the integration contract
            //vPR.data.attributes.account.contact.lastName = o.Main_Contact__r.LastName; Commented by AB on 03/02/2020 as per the integration contract
            //vPR.data.attributes.account.contact.phoneNumber = o.Main_Contact__r.Phone; Commented by AB on 03/02/2020 as per the integration contract
            vPR.data.attributes.billingAccount = new MYOBService_PurchasingAPI.PurchaseBillingAccount();
            //vPR.data.attributes.billingAccount.id = null;
            vPR.data.attributes.billingAccount.id = o.Account.Client_Id__c; //change made by NJ on 23012020
            vPR.data.attributes.billingAccount.billingContact = new MYOBService_PurchasingAPI.PurchaseContact();
            vPR.data.attributes.billingAccount.billingContact.id = o.Main_Contact__r.Contact_Siebel_Row_Id__c;
            vPR.data.attributes.billingAccount.paymentProfile = new MYOBService_PurchasingAPI.PaymentProfile();
            vPR.data.attributes.billingAccount.paymentProfile.id = o.Payment_Profile_Id__c;
            vPR.data.attributes.referringAccount = new MYOBService_PurchasingAPI.PurchaseReferringAccount();
            //vPR.data.attributes.referringAccount.id = null;
            vPR.data.attributes.referringAccount.id = o.Account.Client_Id__c; //change made by NJ on 23012020
            vPR.data.attributes.referringAccount.referringContact = new MYOBService_PurchasingAPI.PurchaseContact();
            vPR.data.attributes.referringAccount.referringContact.id = o.Main_Contact__r.Contact_Siebel_Row_Id__c;
            vPR.data.attributes.products = new List<MYOBService_PurchasingAPI.PurchaseProduct>();
            for (OpportunityLineItem oli: o.OpportunityLineItems)
            {
                MYOBService_PurchasingAPI.PurchaseProduct vPRProduct = new MYOBService_PurchasingAPI.PurchaseProduct();
                vPRProduct.lineItemId = oli.Id;
                vPRProduct.quantity = (Integer)oli.Quantity;
                vPRProduct.productId = (Integer)oli.Product2.ProductCatalogueID__c;
                vPRProduct.dealId = oli.Promo_Id__c;
                vPRProduct.name = oli.Product2.Name;
                vPRProduct.serialNumber = o.Subscription_Serial_Number__c;
                vPR.data.attributes.products.add(vPRProduct);
            }
            System.debug('vPR'+vPR);
            vPRList.add(vPR);
        }
        if (!vPRList.isEmpty())
        {

            if(optyRecordTypeId == Constants.OPP_SME_RT) {
                MYOBService_PurchasingAPI.postPurchases(vPRList, MYOBService_PurchasingAPI.BULKIFICATION_LEVEL.LINE_ITEM);
            }
            else {
                MYOBService_PurchasingAPI.postPurchases(vPRList, MYOBService_PurchasingAPI.BULKIFICATION_LEVEL.ORDER_ITEM);
            }
        }
    }
}