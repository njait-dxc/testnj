trigger TRIG_LP_Partner_Activities on LP_Partner_Activities__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
	// Instantiate the object TriggerHandler
	TRIG_LP_Partner_Activities_Handler triggerHandler = new TRIG_LP_Partner_Activities_Handler();

	// Execute the TriggerHandler by calling the run method
	triggerHandler.run();
}