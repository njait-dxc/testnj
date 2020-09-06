trigger TRIG_Task on Task (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
	// Instantiate the object TriggerHandler
	TRIG_Task_TriggerHandler triggerHandler = new TRIG_Task_TriggerHandler();

	// Execute the TriggerHandler by calling the run method
	triggerHandler.run();
}