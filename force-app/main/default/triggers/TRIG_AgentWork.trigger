trigger TRIG_AgentWork on AgentWork (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
	// Instantiate the object TriggerHandler
	TRIG_AgentWork_TriggerHandler triggerHandler = new TRIG_AgentWork_TriggerHandler();

	// Execute the TriggerHandler by calling the run method
	triggerHandler.run();
}