trigger TRIG_OpportunityLineItem on OpportunityLineItem (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
	// Instantiate the object TriggerHandler
	TRIG_OpportunityLineItem_Handler triggerHandler = new TRIG_OpportunityLineItem_Handler();

	// Execute the TriggerHandler by calling the run method
	triggerHandler.run();
}