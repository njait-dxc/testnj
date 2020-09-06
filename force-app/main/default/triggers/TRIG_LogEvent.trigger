trigger TRIG_LogEvent on LogEvent__e ( after insert) {
    
    // Instantiate the object TriggerHandler
	TRIG_LogEvent_TriggerHandler triggerHandler = new TRIG_LogEvent_TriggerHandler();

	// Execute the TriggerHandler by calling the run method
	triggerHandler.run();
}