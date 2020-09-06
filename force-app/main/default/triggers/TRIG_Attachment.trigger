trigger TRIG_Attachment on Attachment (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
	// Instantiate the object TriggerHandler
	TRIG_Attachment_TriggerHandler triggerHandler = new TRIG_Attachment_TriggerHandler();

	// Execute the TriggerHandler by calling the run method
	triggerHandler.run();
}