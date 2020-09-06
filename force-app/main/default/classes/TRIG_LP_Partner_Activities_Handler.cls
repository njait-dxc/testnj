public with sharing class TRIG_LP_Partner_Activities_Handler extends TriggerHandler
{
	public override void beforeInsert()
	{
		partnerActivityInsert((List <LP_Partner_Activities__c>) Trigger.new);
	}

	public override void beforeUpdate()
	{
		partnerActivityUpdate((List <LP_Partner_Activities__c>) Trigger.new, (Map <Id, LP_Partner_Activities__c>) Trigger.oldMap);
	}

	public static void partnerActivityInsert(List <LP_Partner_Activities__c> partnerActivities)
	{
		Set <String> partnerArchieIds = new Set <String>();
		Map <String, String> accountMap = new Map <String, String>();

		// Get a list of all the external Id's for the partners.
		for (LP_Partner_Activities__c partnerActivity : partnerActivities)
		{
			partnerArchieIds.add(partnerActivity.LP_Partner_Archie_ID__c);
		}

		// Map the external Id's to their Salesforce Id's
		for (Account account : [SELECT Id,Client_ID__c FROM Account WHERE Client_ID__c IN :partnerArchieIds])
		{
			accountMap.put(account.Client_ID__c, account.Id);
		}

		try
		{
			for (LP_Partner_Activities__c partnerActivity : partnerActivities)
			{
				if (partnerActivity.LP_Partner_Archie_ID__c != null)
				{
					if (accountMap.containsKey(partnerActivity.LP_Partner_Archie_ID__c))
					{
						partnerActivity.LP_Partner_Name__c = Id.valueOf(accountMap.get(partnerActivity.LP_Partner_Archie_ID__c));
					}
				}
			}
		}
		catch (Exception e)
		{
			LP_ErrorLogHandler.log('Activity partner association failure during insertion', String.valueOf(e), 'LP_PartnerActivitiesTriggerHandler');
		}
	}

	// When an existing activity is updated
	public static void partnerActivityUpdate(List <LP_Partner_Activities__c> partnerActivities, Map <Id, LP_Partner_Activities__c> oldMap)
	{
		Set <String> partnerArchieIds = new Set <String>();
		Map <String, String> accountMap = new Map <String, String>();

		// Get a list of all the external Id's for the partners
		for (LP_Partner_Activities__c partnerActivity : partnerActivities)
		{
			partnerArchieIds.add(partnerActivity.LP_Partner_Archie_ID__c);
		}

		// Map the external Id's to their Salesforce Id's
		for (Account account : [SELECT Id, Client_ID__c FROM Account WHERE Client_ID__c IN :partnerArchieIds])
		{
			accountMap.put(account.Client_ID__c, account.Id);
		}

		try
		{
			for (LP_Partner_Activities__c partnerActivity : partnerActivities)
			{
				if (partnerActivity.LP_Partner_Archie_ID__c != oldMap.get(partnerActivity.Id).LP_Partner_Archie_ID__c)
				{
					if (partnerActivity.LP_Partner_Archie_ID__c != null && partnerActivity.LP_Statement_Only__c == false)
					{
						if (accountMap.containsKey(partnerActivity.LP_Partner_Archie_ID__c))
						{
							partnerActivity.LP_Partner_Name__c = Id.valueOf(accountMap.get(partnerActivity.LP_Partner_Archie_ID__c));
						}
						else
						{
							partnerActivity.LP_Partner_Name__c = null;
						}
					}
					else
					{
						partnerActivity.LP_Partner_Name__c = null;
					}
				}
			}
		}
		catch (Exception exceptionObject)
		{
			LP_ErrorLogHandler.log('Activity partner association failure during updation', String.valueOf(exceptionObject), 'LP_PartnerActivitiesTriggerHandler');
		}
	}
}