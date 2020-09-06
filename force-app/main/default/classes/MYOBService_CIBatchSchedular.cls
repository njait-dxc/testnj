/**
 * Created by Ankit.Bhardwaj on 23/06/2020.
 */

public with sharing class MYOBService_CIBatchSchedular implements Schedulable {

    //schedular class for orphan purchases
    public void execute(SchedulableContext sc) {
        MYOBService_CustomerInsightMasterBatch ciMasterBatch = new MYOBService_CustomerInsightMasterBatch();
        Database.executeBatch(ciMasterBatch);
    }

}