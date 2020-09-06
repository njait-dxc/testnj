/**
 * @author
 * @date
 * @description AgentWork Trigger Handler
 */

public with sharing class TRIG_AgentWork_TriggerHandler extends TriggerHandler
{
	public override void afterUpdate()
	{
		UpdateCaseStatusAfterAssigned((List <AgentWork>) Trigger.new, (Map <Id, AgentWork>) Trigger.oldMap);
	}

	public static void updateCaseStatusAfterAssigned(List <AgentWork> agentWorks, Map <Id, AgentWork> agentWorkMap)
	{
		Set <Id> caseIds = new Set <Id>();

		for (AgentWork agentWork : agentWorks)
		{
			String workItemId = agentWork.WorkItemId;
			Datetime acceptDateTime = agentWork.AcceptDateTime;

			if (workItemId.left(3) == '500' && acceptDateTime != null && acceptDateTime != agentWorkMap.get(agentWork.Id).AcceptDateTime)
			{
				caseIds.add(agentWork.WorkItemId);
			}
		}
 
		// Update status of each case
		List <Case> cases = [SELECT Id, Status FROM Case WHERE Id IN :caseIds];

		for (Case caseRecord : cases)
		{
			caseRecord.Status = 'In Progress';
			caseRecord.In_Progress_DateTime__c = System.now();
		}

		try
		{
			/*List <Database.SaveResult> updateCaseStatusResults =*/ Database.update(cases, true);
		}
		catch(Exception e)
		{
			LogUtilityException.throwException('TRIG_AgentWork_TriggerHandler', 'UpdateCaseStatusAfterAssigned', e, cases);
		}
	}
}