trigger TRIG_Contact on Contact (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
	// Instantiate the object TriggerHandler
	TRIG_Contact_TriggerHandler triggerHandler = new TRIG_Contact_TriggerHandler();

	// Execute the TriggerHandler by calling the run method
	triggerHandler.run();
}