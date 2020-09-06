trigger TRIG_DocuSign_Recipient_Status on dsfs__DocuSign_Recipient_Status__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
    // Instantiate the object TriggerHandler
    TRIG_DocuSign_Recipient_Status_Handler triggerHandler = new TRIG_DocuSign_Recipient_Status_Handler();

    // Execute the TriggerHandler by calling the run method
    triggerHandler.run();
}