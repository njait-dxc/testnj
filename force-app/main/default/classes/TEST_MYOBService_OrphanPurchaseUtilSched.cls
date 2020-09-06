/**
 * Created by Ankit.Bhardwaj on 9/06/2020.
 */
@IsTest
public with sharing class TEST_MYOBService_OrphanPurchaseUtilSched {
       @IsTest static void runBatchJob(){
           Test.startTest();
           MYOBService_OrphanPurchaseUtilSchedular ops = new MYOBService_OrphanPurchaseUtilSchedular();
           String sch = '0  00 1 3 * ?';
           String jobId = System.schedule('Test', sch, ops);
           Test.stopTest();
           CronTrigger ct = [
                   SELECT Id, CronExpression, TimesTriggered, NextFireTime
                   FROM CronTrigger
                   WHERE Id = :jobId
           ];
           System.assertEquals(sch, ct.CronExpression);
           System.assertEquals(0, ct.TimesTriggered);
       }
}