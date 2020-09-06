/**
 * @author - Nikhil Jaitly
 * @date   - 25/06/2020
 * @description - this batch class will delete all the exception logs from the object Exception_Log__c older than 30 days.
 */

public without sharing class BatchDeleteExceptionLogs implements Database.Batchable<SObject>{

    /**
     * @param bc
     * @return
     * @description
     */
    public Database.QueryLocator start (Database.BatchableContext bc) {

        return Database.getQueryLocator('Select Id FROM Exception_Log__c WHERE CreatedDate < Last_N_days:30');
    }

    /**
     * @description
     * @param bc
     * @param scope
     */

    public void execute (Database.BatchableContext bc, List<SObject> scope) {
        
        if(!scope.isEmpty()){
            
            List<Database.DeleteResult> dbResultList = new List<Database.DeleteResult>();

            dbResultList = Database.delete(scope, false);

            LogUtilityException.logSaveResults('BatchDeleteExceptionLogs','execute',scope,dbResultList);

            for(Database.DeleteResult dr : dbResultList)
            {
                if(!dr.isSuccess())
                {
                    for(Database.Error err : dr.getErrors()) {
                        System.debug('The following error has occurred.');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    }
                }

            }
            //Database.emptyRecycleBin(scope);
        }
    }

    /**
     * @description
     * @param bc
     */
    public void finish(Database.BatchableContext bc){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // Below code will fetch the job Id
        AsyncApexJob a = [SELECT a.TotalJobItems, a.Status, a.NumberOfErrors,
                a.JobType, a.JobItemsProcessed, a.ExtendedStatus, a.CreatedById,
                a.CompletedDate FROM AsyncApexJob a WHERE Id = :bc.getJobId()];
        // get the job Id
        System.debug('$$$ Jobid is'+bc.getJobId());

        // below code will send an email to User about the status
        String[] toaddress = new String[] {'admin.salesforceclientpartnetr@myob.com'};
        mail.setToAddresses(toaddress);
        mail.setReplyTo('nikhil.jaitly@myob.com');
        mail.setSenderDisplayName('Apex Batch Deleting Exception Logs older than 30 days');
        mail.setSubject('Batch Processing '+a.Status);
        mail.setPlainTextBody('The Batch Apex job processed '+a.TotalJobItems+' batches with '+a.NumberOfErrors+' failures'+' Job Item processed are'+a.JobItemsProcessed);
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }
}