trigger TRIG_AccountContactRelation on AccountContactRelation (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
	// Instantiate the object TriggerHandler
	TRIG_AccountContactRelation_Handler triggerHandler = new TRIG_AccountContactRelation_Handler();

	// Execute the TriggerHandler by calling the run method
	triggerHandler.run();
}