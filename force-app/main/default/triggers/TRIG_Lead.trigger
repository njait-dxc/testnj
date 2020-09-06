trigger TRIG_Lead on Lead (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
	// Instantiate the object TriggerHandler
	TRIG_Lead_TriggerHandler triggerHandler = new TRIG_Lead_TriggerHandler();

	// Execute the TriggerHandler by calling the run method
	triggerHandler.run();
}