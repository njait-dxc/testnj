/**
 * Created by Ankit.Bhardwaj on 21/05/2020.
 */

public with sharing class MYOBService_PurchaseOpportunityUtility {
    public static Boolean processedSuccessfully = true;
    public static Boolean createPurchaseOpportunities(List<SubscriptionResponse> newSubsWrapper)
    {
        List<Opportunity> opty = new List<Opportunity>();
        List<OpportunityLineItem> optyLine = new List<OpportunityLineItem>();
        try {

            System.debug(newSubsWrapper);

            Set<Integer> productIds = new Set<Integer>();
            Map<Integer,Id> priceBookEntryIds = new Map<Integer, Id>();
            Map<String,Id> accountContactRelationMap = new Map<String, Id>();
            List<String> clientIds = new List<String>();
            List<String> contactIds = new List<String>();
            Map<String,String> duplicateOrphansMsgMap = new Map<String, String>();
            Map<String,String> duplicateTrialOpsMsgMap = new Map<String, String>();
            Set<String> serialNumbers = new Set<String>();
            List<Orphan_Purchases__c> orphanPurchases = new List<Orphan_Purchases__c>();
            

            //get PriceBookId
            Id priceBookId = getPriceBookId();

            //get RecordTypeId
            Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SME Purchase Opportunity').getRecordTypeId();


            //create the lists for account ids, contact ids and product ids from the input wrapper
            for(SubscriptionResponse res: newSubsWrapper)
            {
                if(res.accountId != null && res.contactId != null && res.serialNumber != null && res.productId != null)
                {
                    productIds.add(Integer.valueOf(res.productId));
                    clientIds.add(res.accountId);
                    contactIds.add(res.contactId);
                    serialNumbers.add(res.serialNumber);
                }
            }

            //prepare list of existing serial numbers to avoid creating duplicate trial opportunities
            List<Opportunity> existingOpportunities = [SELECT Id,Subscription_Serial_Number__c from Opportunity where Subscription_Serial_Number__c in :serialNumbers and StageName = 'Trial'];

            if(existingOpportunities.size() > 0)
            {
                for (Opportunity o :existingOpportunities)
                {
                    duplicateTrialOpsMsgMap.put(o.Subscription_Serial_Number__c,o.Id);
                }
            }


            //get the map of pricebook entry ids
            priceBookEntryIds = getPriceBookEntryIds(productIds,priceBookId);

            //get the map of account contact relationship
            accountContactRelationMap = checkAccConExists(clientIds,contactIds);
            
            System.debug('clientIds'+clientIds);
			System.debug('contactIds'+contactIds);
            System.debug('accountrelation map'+ accountContactRelationMap);
            System.debug('productIds'+productIds);


            for(SubscriptionResponse res: newSubsWrapper)
            {

                if(res.serialNumber != null && res.accountId != null && res.contactId != null && res.productId != null & res.endDate != null) {
                    //check if Account exists in the map, else create an orphan
                    Id pbId = priceBookEntryIds.get(Integer.valueOf(res.productId));
                    if (!(duplicateTrialOpsMsgMap.containsKey(res.serialNumber)) && pbId != null) {
                        if (accountContactRelationMap.containsKey(res.accountId)) {
                            System.debug('accountId=' + res.accountId);
                            System.debug('pbId=' + pbId);
                            duplicateTrialOpsMsgMap.put(res.serialNumber, res.id);
                            OpportunityLineItem oli = new OpportunityLineItem();
                            String extId = String.valueOf(Datetime.now().getTime());
                            extId = extId + res.serialNumber + res.accountId;
                            System.debug(extId);
                            Opportunity optyRef = new Opportunity(Opty_External_Id__c = extId);
                            oli.Opportunity = optyRef;
                            oli.PricebookEntryId = priceBookEntryIds.get(Integer.valueOf(res.productId));
                            oli.TotalPrice = 0;
                            oli.Quantity = 1;
                            optyLine.add(oli);

                            Opportunity opp = new Opportunity();
                            opp.Name = 'New Purchase-' + res.serialNumber;
                            opp.RecordTypeId = recordTypeId;
                            opp.Opty_External_Id__c = extId;
                            Account acc = new Account(Client_ID__c = res.accountId);
                            //Contact con = new Contact(Contact_Siebel_Row_Id__c = res.contactId);
                            opp.Account = acc;
                            opp.Main_Contact__c = accountContactRelationMap.get(res.accountId);
                            opp.StageName = 'Trial';
                            opp.Subscription_Serial_Number__c = res.serialNumber;
                            opp.Probability = 50;
                            if (res.serialNumber.startsWith('61')) {
                                opp.CurrencyIsoCode = 'AUD';
                            } else {
                                opp.CurrencyIsoCode = 'NZD';
                            }
                            opp.mti_pb__PriceBook_To_Use__c = 'SME Purchase Pricebook';
                            String endDate = res.endDate;
                            Datetime dt = Datetime.valueOfGmt(endDate.replace('T', ' '));
                            String dtString = dt.format('dd/MM/yyyy');
                            System.debug(dtString);
                            opp.CloseDate = Date.parse(dtString);
                            opp.Pricebook2Id = priceBookId;
                            opty.add(opp);
                        } else {
                            if (!duplicateOrphansMsgMap.containsKey(res.serialNumber)) {
                                //add the serial number and account
                                duplicateOrphansMsgMap.put(res.serialNumber, res.id);
                                Orphan_Purchases__c op = new Orphan_Purchases__c();
                                op.Serial_Number__c = res.serialNumber;
                                op.Account_Id__c = res.accountId;
                                op.Contact_Id__c = res.contactId;
                                op.End_Date__c = res.endDate;
                                op.Product_Id__c = res.productId;
                                op.Status__c = res.status;
                                op.Type__c = res.type;
                                op.Item_Id__c = res.id;

                                orphanPurchases.add(op);
                            }
                        }
                    }
                    else {
                        continue;
                    }
                }
                else
                {
                    continue;
                }

            }

                Database.insert(opty,true);
                Database.insert(optyLine,true);
                if(orphanPurchases.size() > 0)
                {
                    Schema.SObjectField itemId = Orphan_Purchases__c.Fields.Serial_Number__c;
                    Database.upsert(orphanPurchases,itemId,true);

                }

        }
        catch (Exception e) {
            processedSuccessfully = false;
            LogUtilityException.throwException('MYOBService_PurchaseOpportunityUtility','createPurchaseOpportunities',e,opty);
        }
        return processedSuccessfully;
    }

    //this method gets the response list of messages which are of type - free/paid and status - active/expired
    public static Boolean updateExistingOpportunities(List<SubscriptionResponse> updateSubsWrapper)
    {

        try
        {
            System.debug('reached in updateExistingOpportunities method');
            List<String> activeSerialNumbers = new List<String>();
            Set<Integer> activeProductIds = new Set<Integer>();
            Map<Integer,Id> activePriceBookEntryIds = new Map<Integer, Id>();
            Map<String,String> activeSerialNumberWithProductIds = new Map<String, String>();
            List<String> expiredSerialNumbers = new List<String>();


            //get PriceBookId
            Id priceBookId = getPriceBookId();

            //build the lists and map for productid , serial numbers for processing the requests
            for(SubscriptionResponse sub: updateSubsWrapper)
            {
                if(sub.status == 'active' && sub.type == 'paid') {
                    activeSerialNumbers.add(sub.serialNumber);
                    activeProductIds.add(Integer.valueOf(sub.productId));
                    activeSerialNumberWithProductIds.put(sub.serialNumber, sub.productId);
                }
                else
                {
                    expiredSerialNumbers.add(sub.serialNumber);
                }
            }

            //get the map of pricebook entry ids
            activePriceBookEntryIds = getPriceBookEntryIds(activeProductIds,priceBookId);

            //populate the existing opty Ids and Line Items Ids list for processing
            List<Opportunity> activeOpps = [SELECT Id,StageName from Opportunity where Subscription_Serial_Number__c in :activeSerialNumbers and StageName = 'Trial'];
            List<Opportunity> expiredOpps = [SELECT Id,StageName from Opportunity where Subscription_Serial_Number__c in :expiredSerialNumbers and StageName = 'Trial'];
            List<Id> optyIdsForProductSwap = new List<Id>();
            List<Id> optyLinesToDelete = new List<Id>();
            List<OpportunityLineItem> newLinesToCreate = new List<OpportunityLineItem>();
            List<OpportunityLineItem> activeOppLines = [SELECT Id,Product2.ProductCatalogueID__c,Opportunity.Subscription_Serial_Number__c from OpportunityLineItem where Opportunity.Subscription_Serial_Number__c in :activeSerialNumbers];

            if(activeOpps.size() > 0)
            {
                for (Opportunity o: activeOpps)
                {
                    o.StageName = 'Closed Won';

                }
                for(OpportunityLineItem oli: activeOppLines)
                {
                    if(Integer.valueOf(oli.Product2.ProductCatalogueID__c) != Integer.valueOf(activeSerialNumberWithProductIds.get(oli.Opportunity.Subscription_Serial_Number__c)))
                    {
                        optyIdsForProductSwap.add(oli.OpportunityId);
                        optyLinesToDelete.add(oli.Id);
                    }
                }
                if(optyIdsForProductSwap.size() > 0)
                {
                    List<Opportunity> optyToUpdateProducts = [SELECT Id,Subscription_Serial_Number__c from Opportunity where Id in:optyIdsForProductSwap and StageName = 'Trial'];
                    for(Opportunity o: optyToUpdateProducts)
                    {
                        OpportunityLineItem oli = new OpportunityLineItem();
                        oli.OpportunityId = o.Id;
                        oli.PricebookEntryId = activePriceBookEntryIds.get(Integer.valueOf(Integer.valueOf(activeSerialNumberWithProductIds.get(o.Subscription_Serial_Number__c))));
                        oli.TotalPrice = 0;
                        oli.Quantity = 1;
                        newLinesToCreate.add(oli);
                    }

                }
                Database.delete(optyLinesToDelete,true);
                Database.update(activeOpps,true);
                Database.insert(newLinesToCreate,true);
            }
            if(expiredOpps.size() > 0)
            {
                for(Opportunity o: expiredOpps)
                {
                    o.StageName = 'Closed Lost';
                }
                Database.update(expiredOpps,true);
            }
        }
        catch (Exception e)
        {
            processedSuccessfully = false;
            LogUtilityException.throwException('MYOBService_PurchaseOpportunityUtility','updateExistingOpportunities',e,updateSubsWrapper);
        }
        return processedSuccessfully;
    }

    //helper methods start here
    public static Map<Integer,Id> getPriceBookEntryIds(Set<Integer> productIds, Id priceBookId)
    {
        Map<Integer,Id> pbEntries = new Map<Integer, Id>();
        List<PricebookEntry> pb = [select Id,Product2.CurrencyIsoCode,Product2.ProductCatalogueID__c from PricebookEntry where Pricebook2Id = :priceBookId and Product2.ProductCatalogueID__c = :productIds];
        if(pb.size() > 0)
        {
            for(PricebookEntry p: pb)
            {
                pbEntries.put(Integer.valueOf(p.Product2.ProductCatalogueID__c),p.Id);
            }
        }
        return pbEntries;
    }
    public static Id getPriceBookId()
    {
        Pricebook2 priceBook = [select Id from Pricebook2 where Name = 'SME Purchase Pricebook'];
        return priceBook.Id;
    }

    public static Map<String,Id> checkAccConExists(List<String> clientIds, List<String> contactIds)
    {
        Map<String,Id> relationMap = new Map<String,Id>();
        List<AccountContactRelation> accountContactRelations = [SELECT AccountId,ContactId,Account.Client_ID__c from AccountContactRelation where Account.Client_ID__c in : clientIds and Siebel_Contact_Row_Id__c in :contactIds];
        if(accountContactRelations.size() > 0)
        {
            for (AccountContactRelation rel: accountContactRelations)
            {
              relationMap.put(rel.Account.Client_ID__c,rel.ContactId);
            }
        }
        return relationMap;
    }

    public class SubscriptionResponse
    {
        public String serialNumber;
        public String accountId;
        public String contactId;
        public String productId;
        public string endDate;
        public string status;
        public string type;
        public string id;
        // Added by Nikhil on 01/06/2020 , required in queueable
        public Boolean isInsert;
        public String receiptId;
    }

}