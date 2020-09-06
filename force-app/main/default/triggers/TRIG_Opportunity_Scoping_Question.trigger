trigger TRIG_Opportunity_Scoping_Question on Opportunity_Scoping_Question__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
	// Instantiate the object TriggerHandler
	TRIG_Opportunity_Scoping_Handler triggerHandler = new TRIG_Opportunity_Scoping_Handler();

	// Execute the TriggerHandler by calling the run method
	triggerHandler.run();
}