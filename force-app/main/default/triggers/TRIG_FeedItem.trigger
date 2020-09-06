trigger TRIG_FeedItem on FeedItem (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
	// Instantiate the object TriggerHandler
	TRIG_FeedItem_TriggerHandler triggerHandler = new TRIG_FeedItem_TriggerHandler();

	// Execute the TriggerHandler by calling the run method
	triggerHandler.run();
}