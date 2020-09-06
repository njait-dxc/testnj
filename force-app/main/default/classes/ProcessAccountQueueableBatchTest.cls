@IsTest
public class ProcessAccountQueueableBatchTest
{
	@TestSetup
	static void setupTestData()
	{
		Profile p = [SELECT Id FROM Profile WHERE Name = '~ Client Manager April.2017'];
		User u = new User(Alias = 'UL', Email = 'u@test.com',
				EmailEncodingKey = 'UTF-8', LastName = 'UL', LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US', ProfileId = p.Id,
				TimeZoneSidKey = 'America/Los_Angeles', Username = 'testingmyob@myob.com', FederationIdentifier = 'testingmyob@myob.com');
		insert u;

		User u2 = new User(Alias = 'UL2', Email = 'u2@test.com',
				EmailEncodingKey = 'UTF-8', LastName = 'UL2', LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US', ProfileId = p.Id,
				TimeZoneSidKey = 'America/Los_Angeles', Username = 'testingmyob2@myob.com', FederationIdentifier = 'testingmyob2@myob.com');
		insert u2;
	}

	@IsTest
	static void testAccountTrigger2()
	{
		Test.startTest();
		Account ac = new Account(Name = 'Testing Account 111111112', Client_Manager__c = 'testingmyob@myob.com');
		insert ac;
		Account ac1 = [SELECT Id, Client_Manager_New__c FROM Account WHERE Name = 'Testing Account 111111112' LIMIT 1][0];

		Account ta = [SELECT Id, Client_Manager_New__c FROM Account WHERE Name = 'Testing Account 111111112' LIMIT 1][0];
		User tu = [SELECT Id FROM User WHERE FederationIdentifier = 'testingmyob2@myob.com' LIMIT 1][0];
		ta.Client_Manager__c = 'testingmyob2@myob.com';

		update ta;
		// String jsonString1 = json.serialize(ta);
		// String jsonString2 = json.serialize(ac1);
		// System.enqueueJob(new ProcessUpdatedAccountInFutureClass(jsonString1,jsonString2));

		Test.stopTest();
		List <AccountTeamMember> atmList3 = [SELECT Id, UserId FROM AccountTeamMember WHERE AccountId = :ta.Id AND TeamMemberRole = 'Client Manager'];
		System.assertEquals(tu.Id, atmList3[0].UserId);
	}

	@IsTest
	static void testAccountTrigger5()
	{
		Test.startTest();
		Account ac = new Account(Name = 'Testing Account 111111112', Client_Manager__c = 'testingmyob@myob.com');
		insert ac;

		Account ta = [SELECT Id, Client_Manager_New__c FROM Account WHERE Name = 'Testing Account 111111112' LIMIT 1][0];
		ta.IsPartner = true;
		update ta;
		Test.stopTest();

		ta = [SELECT Id, Client_Manager_New__c, IsCommunity__c FROM Account WHERE Name = 'Testing Account 111111112' LIMIT 1][0];
		System.assertEquals(true, ta.IsCommunity__c);

	}
}