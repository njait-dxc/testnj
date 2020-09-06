/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_LP_Partner_ActivitiesTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_LP_Partner_ActivitiesTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new LP_Partner_Activities__c());
    }
}