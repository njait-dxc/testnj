/**
 * Created by Ankit.Bhardwaj on 29/05/2020.
 */

global class MYOBService_ProcessOrphanPurchaseUtility implements Database.Batchable<sobject>, Database.AllowsCallouts, Database.Stateful
{
    global Database.QueryLocator start(Database.BatchableContext bc)
    {

        String Query = 'SELECT Id,Serial_Number__c,Account_Id__c,Contact_Id__c,End_Date__c,Product_Id__c,Status__c,Type__c,Item_Id__c FROM Orphan_Purchases__c';
        return Database.getQueryLocator(Query);
    }

    global void execute(Database.BatchableContext bc, List<Orphan_Purchases__c> scope)
    {
        List<MYOBService_PurchaseOpportunityUtility.SubscriptionResponse> orphanRequests = new List<MYOBService_PurchaseOpportunityUtility.SubscriptionResponse>();
        Set<String> serialNumbersFromScope = new Set<String>();
        Set<String> serialNumbersToDelete = new Set<String>();


        for (Orphan_Purchases__c op: scope)
        {
            MYOBService_PurchaseOpportunityUtility.SubscriptionResponse sr = new MYOBService_PurchaseOpportunityUtility.SubscriptionResponse();
            sr.serialNumber = op.Serial_Number__c;
            sr.id = op.Item_Id__c;
            sr.accountId = op.Account_Id__c;
            sr.contactId = op.Contact_Id__c;
            sr.endDate = op.End_Date__c;
            sr.productId = op.Product_Id__c;
            sr.type = op.Type__c;
            sr.status = op.Status__c;
            orphanRequests.add(sr);
            //maintain the set of serialnumbers being sent so that they can be deleted later
            serialNumbersFromScope.add(op.Serial_Number__c);
        }

        //call the trial purchase opportunities method to process the orphans
        try {
            Boolean success = true;
            success = MYOBService_PurchaseOpportunityUtility.createPurchaseOpportunities(orphanRequests);
            System.debug(success);
            if(success)
            {
                //find the ones that are created and delete the records from table
                List<Opportunity> oppsCreated = [SELECT Subscription_Serial_Number__c from Opportunity where Subscription_Serial_Number__c in :serialNumbersFromScope];

                if(oppsCreated.size() > 0)
                {
                    for (Opportunity opps : oppsCreated)
                    {
                        String serialNumber = opps.Subscription_Serial_Number__c;
                        serialNumbersToDelete.add(serialNumber);
                    }

                    //get the lists of records to delete
                    List<Orphan_Purchases__c> orphanPurchasesToDelete = [SELECT Id from Orphan_Purchases__c where Serial_Number__c in :serialNumbersToDelete];

                    if(orphanPurchasesToDelete.size() > 0)
                    {
                        Database.delete(orphanPurchasesToDelete, true);
                    }
                    System.debug(orphanPurchasesToDelete);
                    System.debug(oppsCreated);
                }

            }


        }
        catch (Exception e)
        {
            LogUtilityException.throwException('MYOBService_ProcessOrphanPurchaseUtility','execute',e,orphanRequests);
        }

    }

    global void finish(Database.BatchableContext bc)
    {

    }
}