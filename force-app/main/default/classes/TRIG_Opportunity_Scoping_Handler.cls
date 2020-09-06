public with sharing class TRIG_Opportunity_Scoping_Handler extends TriggerHandler
{
	public override void afterInsert()
	{
		opportunityScopingQuestionInsert((List <Opportunity_Scoping_Question__c>) Trigger.new);
	}
	public override void beforeDelete()
	{
		opportunityScopingQuestionDelete((List <Opportunity_Scoping_Question__c>) Trigger.old);
	}

	public static void opportunityScopingQuestionInsert(List <Opportunity_Scoping_Question__c> opportunityScopingQuestions)
	{
		List <Id> opportunityIds = new List <Id>();

		for (Opportunity_Scoping_Question__c opportunityScopingQuestion : opportunityScopingQuestions)
		{
			opportunityIds.add(opportunityScopingQuestion.Opportunity__c);
		}

		List<Opportunity> opportunities = [SELECT Id, Scoping_Required__c FROM Opportunity WHERE Id IN :opportunityIds];

		for (Opportunity opportunity : opportunities)
		{
			opportunity.Scoping_Required__c = true;
		}

		// Update Opportunities
		try
		{
			List <Database.SaveResult> saveResults = Database.update(opportunities, true);
		}
		catch (Exception e)
		{
			LogUtilityException.throwException('TRIG_Opportunity_Scoping_Handler', 'OpportunityScopingQuestionInsert', e, opportunities);
		}
	}

	public static void opportunityScopingQuestionDelete(List<Opportunity_Scoping_Question__c> opportunityScopingQuestions)
	{
		List <Id> opportunityIds = new List<Id>();

		for (Opportunity_Scoping_Question__c opportunityScopingQuestion : opportunityScopingQuestions)
		{
			opportunityIds.add(opportunityScopingQuestion.Opportunity__c);
		}

		List <AggregateResult> aggregateResults = [
				SELECT Opportunity__c, COUNT(Id)
				FROM Opportunity_Scoping_Question__c
				WHERE Opportunity__c IN :opportunityIds
				GROUP BY Opportunity__c
		];

		List <Opportunity> opportunitiesToUpdate = new List <Opportunity>();

		for (AggregateResult aggregateResult : aggregateResults)
		{
			Integer count = (Integer) aggregateResult.get('expr0');

			if (count <= 1)
			{
				String opportunityId = (String) aggregateResult.get('Opportunity__c');
				Opportunity opportunity = new Opportunity(Id = opportunityId);
				opportunity.Scoping_Required__c = false;
				opportunitiesToUpdate.add(opportunity);
			}
		}

		// Update Opportunities
		try
		{
			List<Database.SaveResult> saveResults = Database.update(opportunitiesToUpdate, true);
		}
		catch (Exception exceptionObject)
		{
			LogUtilityException.throwException('TRIG_Opportunity_Scoping_Handler', 'OpportunityScopingQuestiondelete', exceptionObject, opportunitiesToUpdate);
		}
	}
}