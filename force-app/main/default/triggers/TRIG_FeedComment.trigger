trigger TRIG_FeedComment on FeedComment (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
	// Instantiate the object TriggerHandler
	TRIG_FeedComment_TriggerHandler triggerHandler = new TRIG_FeedComment_TriggerHandler();

	// Execute the TriggerHandler by calling the run method
	triggerHandler.run();
}