trigger TRIG_CaseComment on CaseComment (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
	// Instantiate the object TriggerHandler
	TRIG_CaseComment_TriggerHandler triggerHandler = new TRIG_CaseComment_TriggerHandler();

	// Execute the TriggerHandler by calling the run method
	triggerHandler.run();
}