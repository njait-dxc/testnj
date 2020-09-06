trigger TRIG_Account on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
	// Instantiate the object TriggerHandler
	TRIG_Account_TriggerHandler triggerHandler = new TRIG_Account_TriggerHandler();

	// Execute the TriggerHandler by calling the run method
	triggerHandler.run();

}