/**
 * Created by Ankit.Bhardwaj on 21/06/2020.
 */

public with sharing class MYOBService_CustomerInsightUpdateBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    public Database.QueryLocator start(Database.BatchableContext bc){
        String Query = 'SELECT Id,Name,Account__c,Client_Id__c,Practice_AMV__c,SME_AMV__c,Total_Practice_Value__c FROM Customer_Insights__c where Account__c != null and Latest_Record__c = true order by Name desc';
        return Database.getQueryLocator(Query);
    }
    public void execute(Database.BatchableContext bc, List<Customer_Insights__c> scope){
       for(Customer_Insights__c ciRec : scope)
       {
           ciRec.Latest_Record__c = false;
       }
        try
        {
            Database.update(scope,true);
        }
        catch (Exception e)
        {
            LogUtilityException.throwException('MYOBService_CustomerInsightUpdateBatch','execute',e,scope);
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
        mail.setSenderDisplayName('Apex Batch Updating Customer Insights Latest Records');
        mail.setSubject('Batch Processing '+a.Status);
        mail.setPlainTextBody('The Batch Apex job processed '+a.TotalJobItems+' batches with '+a.NumberOfErrors+' failures.'+' Job Item processed are '+a.JobItemsProcessed);
        Messaging.sendEmail(new Messaging.SingleEmailMessage [] {mail});
        //call the update batch to mark latest record flag to false
    }
}