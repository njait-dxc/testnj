/**
 * @author
 * @date
 * @description Event Trigger Handler
 */

public with sharing class TRIG_Event_TriggerHandler extends TriggerHandler
{
	public override void beforeInsert()
	{
		processEvent((List <Event>) Trigger.new, (Map<Id, Event>) Trigger.oldMap, 'BeforeNew');
	}
	public override void beforeUpdate()
	{
		processEvent((List <Event>) Trigger.new, (Map<Id, Event>) Trigger.oldMap, 'BeforeUpdate');
	}

	public static void processEvent(List<Event> events, Map<Id, Event> oldMap, String triggerContext)
	{
		List <User> users = [SELECT Id FROM User WHERE Name = 'Integration User'];

		User integrationUser;

		if (users.isEmpty() == false)
		{
			integrationUser = users.get(0);
		}

		for (Event event : events)
		{
			if (integrationUser == null || System.UserInfo.getUserId() != integrationUser.Id)
			{
				if (triggerContext == 'BeforeNew')
				{
					event.Sync_Status__c = 'Pending';
				}
				else if (triggerContext == 'BeforeUpdate' && event.CreatedById != integrationUser.Id)
				{
					Event eventOld = oldMap.get(event.Id);

					if (event.Type != eventOld.Type
							|| event.Subject != eventOld.Subject
							|| event.What != eventOld.What
							|| event.Who != eventOld.Who
							|| event.Owner != eventOld.Owner
							|| event.StartDateTime != eventOld.StartDateTime
							|| event.Description != eventOld.Description
						)
					{
						event.Sync_Status__c = 'Pending';
					}
				}
			}
		}
	}
}