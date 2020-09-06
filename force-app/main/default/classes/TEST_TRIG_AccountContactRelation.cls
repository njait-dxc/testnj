@IsTest
private with sharing class TEST_TRIG_AccountContactRelation
{
	@TestSetup
	static void setupTestData()
	{
		List <Account> accounts = (List<Account>) TestDataFactory.createSObjectList(new Account(), 2, true);

		Contact contact = new Contact();
		contact.AccountId = accounts.get(0).Id;
		contact.Account_Contact_Rel_Siebel_Row_Id__c = '123456';
		TestDataFactory.createSObject(contact, true);
	}

	@IsTest
	private static void processAccountContactRelation_Test1()
	{
		Account account = [SELECT Id FROM Account WHERE Name = 'Test Account 2'];
		Contact contact = [SELECT Id FROM Contact LIMIT 1];

		AccountContactRelation accountContactRelation = new AccountContactRelation();
		accountContactRelation.AccountId = account.Id;
		accountContactRelation.ContactId = contact.Id;

		Test.startTest();

		Date today = System.today();

		insert accountContactRelation;

		accountContactRelation = [SELECT Id, Sync_Status__c, StartDate FROM AccountContactRelation WHERE Id = :accountContactRelation.Id][0];

		System.assertEquals('Pending', accountContactRelation.Sync_Status__c);
		System.assertEquals(today, accountContactRelation.StartDate);

		accountContactRelation.EndDate = Date.newInstance(2099, 2, 11);

		update accountContactRelation;

		Test.stopTest();

		System.assertEquals('Pending', accountContactRelation.Sync_Status__c);
	}

	@IsTest
	private static void processAccountContactRelation_Test2()
	{
		List <User> users = [SELECT Id FROM User WHERE Name = 'Integration User'];

		User integrationUser;

		if (users.isEmpty() == false)
		{
			integrationUser = users.get(0);
			System.runAs(integrationUser)
			{
				Account account = [SELECT Id FROM Account WHERE Name = 'Test Account 2'];
				Contact contact = [SELECT Id FROM Contact LIMIT 1];

				AccountContactRelation accountContactRelation = new AccountContactRelation();
				accountContactRelation.AccountId = account.Id;
				accountContactRelation.ContactId = contact.Id;

				Test.startTest();

				insert accountContactRelation;

				accountContactRelation = [SELECT Id, Sync_Status__c, Siebel_Row_Id__c, Account_Contact_Rel_Siebel_Row_Id__c FROM AccountContactRelation WHERE Id = :accountContactRelation.Id][0];

				System.assertEquals(null, accountContactRelation.Sync_Status__c);
				System.assertEquals(accountContactRelation.Siebel_Row_Id__c, accountContactRelation.Account_Contact_Rel_Siebel_Row_Id__c);

				Test.stopTest();
			}
		}
	}
}