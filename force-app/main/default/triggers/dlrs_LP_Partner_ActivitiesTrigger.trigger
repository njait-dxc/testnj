/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_LP_Partner_ActivitiesTrigger on LP_Partner_Activities__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(LP_Partner_Activities__c.SObjectType);
}