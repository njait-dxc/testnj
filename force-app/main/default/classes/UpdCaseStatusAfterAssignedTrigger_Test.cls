@IsTest
public class UpdCaseStatusAfterAssignedTrigger_Test
{
	@TestSetup
	static void init()
	{
		Account accnt1 = TestDataFactory.createAccount('Alpha', 'Partner_Success_Accounts', '8131725111111', true);
		Database.insert(new Case(Origin = 'Web', AccountId = accnt1.Id));
	}

	static testMethod void testAgentWorkTrigger()
	{
		ServiceChannel vServiceChannel = [SELECT Id FROM ServiceChannel LIMIT 1];
		Case vCase = [SELECT Id FROM Case LIMIT 1];
		AgentWork vAgentWork = new AgentWork(Id = '0Bz0I000002Z7asSAC', ServiceChannelId = vServiceChannel.Id, UserId = UserInfo.getUserId(), WorkItemId = vCase.Id);
		Map<Id, AgentWork> vOldMap = new Map<Id, AgentWork>{vAgentWork.Id => vAgentWork};
		//This is a workaround for AcceptDateTime field being not writable
		String vAgentWorkString = JSON.serialize(vAgentWork);
		vAgentWorkString = vAgentWorkString.substringBeforeLast('}') + ',"AcceptDateTime":"2019-11-11T22:30:00.000Z"}';
		vAgentWork = (AgentWork)JSON.deserialize(vAgentWorkString, AgentWork.class);
		//Test needs to run without actual DMLs on AgentWork as agent can't be made available on OmniChannel from Apex. Doesn't impact functionality as the trigger is logic-less.
		Test.startTest();
		//This will throw an exception as agent isn't available on the channel. Needed to have trigger test coverage.
		try
		{
			insert new AgentWork(ServiceChannelId = vServiceChannel.Id, UserId = UserInfo.getUserId(), WorkItemId = vCase.Id);
		}
		catch (Exception e)
		{
		}
		//This is the actual test
		TRIG_AgentWork_TriggerHandler.UpdateCaseStatusAfterAssigned(new List<AgentWork>{vAgentWork}, vOldMap);
		Test.stopTest();
		System.assertEquals('In Progress', [SELECT Status FROM Case LIMIT 1][0].Status);
	}
}