@IsTest
private with sharing class TEST_TRIG_AgentWork
{
	@TestSetup
	private static void init()
	{
		Account accnt1 = TestDataFactory.createAccount('Alpha', 'Partner_Success_Accounts', '8131725111111', true);
		Database.insert(new Case(Origin = 'Web', AccountId = accnt1.Id));
	}

	@IsTest
	private static void updateCaseStatusAfterAssigned_Test1()
	{
		ServiceChannel serviceChannel = [SELECT Id FROM ServiceChannel LIMIT 1];
		Case caseRecord = [SELECT Id FROM Case LIMIT 1];

		AgentWork agentWork = new AgentWork(
				ServiceChannelId = serviceChannel.Id,
				UserId = UserInfo.getUserId(),
				WorkItemId = caseRecord.Id
		);

		Map <Id, AgentWork> triggerOldMap = new Map <Id, AgentWork>();
		triggerOldMap.put(agentWork.Id, agentWork);

		// This is a workaround for AcceptDateTime field being not writable
		String agentWorkJSON = JSON.serialize(agentWork);
		agentWorkJSON = agentWorkJSON.substringBeforeLast('}') + ',"AcceptDateTime":"2019-11-11T22:30:00.000Z"}';
		agentWork = (AgentWork) JSON.deserialize(agentWorkJSON, agentWork.class);

		List <AgentWork> triggerNew = new List <AgentWork>();
		triggerNew.add(agentWork);

		Test.startTest();
		TRIG_AgentWork_TriggerHandler.updateCaseStatusAfterAssigned(triggerNew, triggerOldMap);
		Test.stopTest();

		List <Case> cases = [SELECT Status FROM Case LIMIT 1];
		System.assertEquals(1, cases.size());
		caseRecord = cases.get(0);
		System.assertEquals('In Progress', caseRecord.Status);
	}

	@IsTest
	private static void updateCaseStatusAfterAssigned_Test2()
	{
		ServiceChannel serviceChannel = [SELECT Id FROM ServiceChannel LIMIT 1];
		Case caseRecord = [SELECT Id FROM Case LIMIT 1];

		AgentWork agentWork = new AgentWork(
				ServiceChannelId = serviceChannel.Id,
				UserId = UserInfo.getUserId(),
				WorkItemId = caseRecord.Id
		);

		Database.insert(agentWork, false);
		System.assertEquals(null, agentWork.Id);
	}
}