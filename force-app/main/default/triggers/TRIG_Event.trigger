trigger TRIG_Event on Event (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
	// Instantiate the object TriggerHandler
	TRIG_Event_TriggerHandler triggerHandler = new TRIG_Event_TriggerHandler();

	// Execute the TriggerHandler by calling the run method
	triggerHandler.run();
}