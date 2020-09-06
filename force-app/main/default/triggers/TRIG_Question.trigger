trigger TRIG_Question on Question (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
	// Instantiate the object TriggerHandler
	TRIG_QuestionTriggerHandler handler = new TRIG_QuestionTriggerHandler();

	// Execute the TriggerHandler by calling the run method
	handler.run();
}