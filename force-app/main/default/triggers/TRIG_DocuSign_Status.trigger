trigger TRIG_DocuSign_Status on dsfs__DocuSign_Status__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
    // Call the DLRS triggerHandler
    dlrs.RollupService.triggerHandler(dsfs__DocuSign_Status__c.SObjectType);

    // Instantiate the object TriggerHandler
    TRIG_DocuSign_Status_TriggerHandler triggerHandler = new TRIG_DocuSign_Status_TriggerHandler();

    // Execute the TriggerHandler by calling the run method
    triggerHandler.run();

}