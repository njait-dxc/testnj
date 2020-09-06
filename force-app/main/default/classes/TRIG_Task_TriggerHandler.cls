/**
 * @author
 * @date
 * @description Task Trigger Handler
 */

public with sharing class TRIG_Task_TriggerHandler extends TriggerHandler
{
	public override void beforeInsert()
	{
		processTask((List <Task>) Trigger.new, (Map <Id, Task>) Trigger.oldMap, 'BeforeNew');
	}

	public override void beforeUpdate()
	{
		processTask((List <Task>) Trigger.new, (Map <Id, Task>) Trigger.oldMap, 'BeforeUpdate');
	}

	public override void afterUpdate()
	{
		cancelBanklinkAccounts((List <Task>) Trigger.new, (Map <Id, Task>) Trigger.oldMap, 'AfterUpdate');
	}

	public static void cancelBanklinkAccounts(List <Task> tasks, Map< Id, Task> oldMap, String triggerContext)
	{
		Map<Id, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Task.getRecordTypeInfosById();
		for(Task task: tasks)
		{
			if(task.WhatId != NULL && task.RecordTypeId != NULL) {
				String recordType = rtMap.get(task.RecordTypeId).getName();
				String whatId = String.valueOf(task.WhatId);
				Boolean isCase = whatId.startsWithIgnoreCase('500');
				if (isCase && recordType == 'Bank Link Cancellation' && task.Cancel_Banklink_Account__c == 'Yes') {
					Id relatedId = task.WhatId;
					Case cs = [Select Id,CaseNumber,Primary_Category__c,Categ__c,Sub_Category__c,RecordType.Name from Case where Id = :relatedId];

					if (cs.Id != null && task.Status == 'Completed' && cs.Primary_Category__c == 'Onboarding Request' && cs.Sub_Category__c == 'Migration Services' && cs.Categ__c == 'BL - Essentials' && cs.RecordType.Name == 'SME Product') {
						MYOBService_BLAccountCancellation.callBanklinkCancellator(cs.CaseNumber);
					}
				}
			}
		}
	}
	public static void processTask(List <Task> tasks, Map< Id, Task> oldMap, String triggerContext)
	{
		List <User> users = [SELECT Id FROM User WHERE Name = 'Integration User'];

		User integrationUser;

		if (users.isEmpty() == false)
		{
			integrationUser = users.get(0);
		}

		for (Task task : tasks)
		{
			if (integrationUser == null || System.UserInfo.getUserId() != integrationUser.Id)
			{
				if (triggerContext == 'BeforeNew')
				{
					task.Sync_Status__c = 'Pending';
				}
				else if (triggerContext == 'BeforeUpdate' && task.CreatedById != integrationUser.Id)
				{
					if (task.Type != oldMap.get(task.Id).Type
						|| task.Subject != oldMap.get(task.Id).Subject
						|| task.What != oldMap.get(task.Id).What
						|| task.Who != oldMap.get(task.Id).Who
						|| task.Owner != oldMap.get(task.Id).Owner
						|| task.Status != oldMap.get(task.Id).Status
						|| task.Description != oldMap.get(task.Id).Description
					)
					{
						task.Sync_Status__c = 'Pending';
					}
				}
			}
		}
	}
}