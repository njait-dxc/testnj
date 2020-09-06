/**
 * @description Batch class to delete the API Call Log Records which are older than 15 days.
 */
public class PurgeAPICallLogBatch implements Database.Batchable<SObject>, Schedulable
{

    //Schedulable method to execute the batch
    public void execute(SchedulableContext sc)
    {
        Id batchprocessid = Database.executeBatch(this);
    }

    //Query locator to query the records that are older than 15 days
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator('SELECT ID FROM API_Call_Log__c WHERE CREATEDDATE < LAST_N_DAYS:15');
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope)
    {
        //Delete the data
        Database.delete(scope);
        //Hard delete
        Database.emptyRecycleBin(scope);
    }

    public void finish(Database.BatchableContext BC)
    {
    }
}