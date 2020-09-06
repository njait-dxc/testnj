/**
 * Created by Ankit.Bhardwaj on 19/06/2020.
 */

public with sharing class MYOBService_CustomerInsightMasterBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    public Database.QueryLocator start(Database.BatchableContext bc){
        String Query = 'SELECT Id,Name,Account__c,Client_Id__c,Practice_AMV__c,SME_AMV__c,Total_Practice_Value__c FROM Customer_Insights__c where Account__c = null and Latest_Record__c = true order by Name desc';
        return Database.getQueryLocator(Query);

    }
    public void execute(Database.BatchableContext bc, List<Customer_Insights__c> scope){
        System.debug(scope.size());
        Set<String> clientIds = new Set<String>();
        List<Id> oldAssoIds = new List<Id>();
        Map<String,Id> alreadyprocessedCIds = new Map<String, Id>();
        List<String> toDeleteClientIds = new List<String>();
        Map<String, Id> scopeDuplicateMap = new Map<String, Id>();
        Map<String,Id> mapAccIds = new Map<String, Id>();
        for(Customer_Insights__c ci : scope)
        {
            clientIds.add(ci.Client_Id__c);
        }

        //check if this scope batch is duplicated
        alreadyprocessedCIds = checkIfAlreadyProcessed(clientIds);

        //get older associations of the scope
        oldAssoIds = findOldAssociations(clientIds);

        //get accIdsMap for the relevant client Ids
        mapAccIds = getAccountIds(clientIds);

        //now set the AccountIds on the customer insight record to create the relationship
        for(Customer_Insights__c ciRec : scope)
        {
            if(!(alreadyprocessedCIds.containsKey(ciRec.Client_Id__c)) && !(scopeDuplicateMap.containsKey(ciRec.Client_Id__c))) {
                if (mapAccIds.containsKey(ciRec.Client_Id__c)) {
                    //add in the processing map to filter out duplicates in same scope
                    scopeDuplicateMap.put(ciRec.Client_Id__c,ciRec.Id);
                    ciRec.Account__c = mapAccIds.get(ciRec.Client_Id__c);
                } else {
                    toDeleteClientIds.add(ciRec.Id);
                }
            }
            else {
                toDeleteClientIds.add(ciRec.Id);
            }
        }

        try
        {
            System.debug(toDeleteClientIds);
            Database.update(scope,true);

            //now delete the records in the object from scope
            if(toDeleteClientIds.size() > 0)
            {
                Database.delete(toDeleteClientIds,true);
            }

            //now delete the older associations
            if(oldAssoIds.size() > 0)
            {
                Database.delete(oldAssoIds,true);
            }

        }
        catch (Exception e)
        {
            LogUtilityException.throwException('MYOBService_BatchAssignTPVToAccount','execute',e,scope);
        }


    }
    public void finish(Database.BatchableContext bc)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // Below code will fetch the job Id
        AsyncApexJob a = [SELECT a.TotalJobItems, a.Status, a.NumberOfErrors,
                a.JobType, a.JobItemsProcessed, a.ExtendedStatus, a.CreatedById,
                a.CompletedDate FROM AsyncApexJob a WHERE Id = :bc.getJobId()];
        // get the job Id
        System.debug('$$$ Jobid is'+bc.getJobId());

        // below code will send an email to User about the status
        String[] toaddress = new String[] {'SFSupportEnquiries@myob.com'};
        mail.setToAddresses(toaddress);
        mail.setReplyTo('SFSupportEnquiries@myob.com');
        mail.setSenderDisplayName('Apex Batch Processing Customer Insights');
        mail.setSubject('Batch Processing '+a.Status);
        mail.setPlainTextBody('The Batch Apex job processed '+a.TotalJobItems+' batches with '+a.NumberOfErrors+' failures.'+' Job Item processed are '+a.JobItemsProcessed);
        Messaging.sendEmail(new Messaging.SingleEmailMessage [] {mail});
        //call the update batch to mark latest record flag to false
        Database.executeBatch(new MYOBService_CustomerInsightUpdateBatch(), 2000);

    }

    public Map<String,Id> getAccountIds(Set<String> clientIds)
    {
        Map<String,Id> accIdsMap = new Map<String, Id>();
        List<Account> acc = [SELECT Client_ID__c,Id from Account where Client_ID__c in :clientIds];

        if(acc.size() > 0) {
            for (Account a : acc) {
                accIdsMap.put(a.Client_ID__c, a.Id);
            }
        }
        return accIdsMap;
    }

    public Map<String,Id> checkIfAlreadyProcessed(Set<String> clientIds)
    {
        Map<String, Id> duplicateCIdsMap = new Map<String, Id>();
        List<Customer_Insights__c> duplicateCIRows = [select Client_Id__c,Id from Customer_Insights__c where Client_Id__c in :clientIds and Latest_Record__c = true and Account__c != null];

        if(duplicateCIRows.size() > 0)
        {
            for(Customer_Insights__c c : duplicateCIRows) {
                duplicateCIdsMap.put(c.Client_Id__c,c.Id);
            }
        }
        return duplicateCIdsMap;
    }

    public List<Id> findOldAssociations(Set<String> clientIds)
    {
        List<Id> existingIds = new List<Id>();
        List<Customer_Insights__c> existingAssociations = [select Client_Id__c,Id from Customer_Insights__c where Client_Id__c in :clientIds and Latest_Record__c = false and Account__c != null];

        if(existingAssociations.size() > 0)
        {
            for(Customer_Insights__c c : existingAssociations) {
                existingIds.add(c.Id);
            }
        }
        return existingIds;
    }

}