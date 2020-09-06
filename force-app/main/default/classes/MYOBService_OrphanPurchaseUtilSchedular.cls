/**
 * Created by Ankit.Bhardwaj on 9/06/2020.
 */

global with sharing class MYOBService_OrphanPurchaseUtilSchedular implements Schedulable {

    //schedular class for orphan purchases
    global void execute(SchedulableContext sc) {
        MYOBService_ProcessOrphanPurchaseUtility purchaseUtility = new MYOBService_ProcessOrphanPurchaseUtility();
        Database.executeBatch(purchaseUtility);
    }

}