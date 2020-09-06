@IsTest
private with sharing class TEST_TRIG_Account
{
	@TestSetup
	private static void setupTestData()
	{
		// Retrieve Client Manager Profile
		Profile clientManagerProfile = [SELECT Id FROM Profile WHERE Name = '~ Client Manager April.2017'];

		// Create Test User 1
		User testUser1 = new User();
		testUser1.ProfileId = clientManagerProfile.Id;
		testUser1.FirstName = 'Test';
		testUser1.LastName = 'User 1';
		testUser1.Username = 'testUser1@myob.com';
		testUser1.Email = 'testUser1@test.com';
		testUser1.FederationIdentifier = 'testUser1@myob.com';
		testUser1.Alias = 'tu1';
		testUser1.EmailEncodingKey = 'UTF-8';
		testUser1.LanguageLocaleKey = 'en_US';
		testUser1.LocaleSidKey = 'en_AU';
		testUser1.TimeZoneSidKey = 'Australia/Sydney';
		insert testUser1;

		// Create Test User 2
		User testUser2 = new User();
		testUser2.ProfileId = clientManagerProfile.Id;
		testUser2.FirstName = 'Test';
		testUser2.LastName = 'User 2';
		testUser2.Username = 'testUser2@myob.com';
		testUser2.Email = 'testUser2@myob.com';
		testUser2.FederationIdentifier = 'testUser2@myob.com';
		testUser2.Alias = 'tu2';
		testUser2.EmailEncodingKey = 'UTF-8';
		testUser2.LanguageLocaleKey = 'en_US';
		testUser2.LocaleSidKey = 'en_AU';
		testUser2.TimeZoneSidKey = 'Australia/Sydney';
		insert testUser2;
	}

	@IsTest
	private static void autoPopulateBillingAddress_Test1()
	{
		// Setup
		Account account = new Account();
		account.Name = 'Test Account 1';
		account.Client_Manager__c = 'testUser1@myob.com';
		account.Copy_Head_Office_Address_to_Billing__c = true;
		account.Head_Office_Coutnry__c = 'Australia';
		account.Head_Office_Street__c = 'Collins St';
		account.Head_Office_City__c = 'Melbourne';
		account.Head_Office_State__c = 'VIC';
		account.Head_Office_Zip_Postal_Code__c = '8003';

		//Execute
		insert account;

		//Verify
		List <Account> accounts =
		[
				SELECT Id, Head_Office_Coutnry__c, Billing_Country_new__c, Head_Office_Street__c, Billing_Street_new__c, Head_Office_City__c, Billing_City_new__c, Head_Office_State__c, Billing_State_new__c, Head_Office_Zip_Postal_Code__c, Billing_Zip_new__c
				FROM Account
				WHERE Id = :account.Id
		];

		System.assertEquals(1, accounts.size());
		account = accounts.get(0);
		System.assertEquals(account.Head_Office_Coutnry__c, account.Billing_Country_new__c);
		System.assertEquals(account.Head_Office_Street__c, account.Billing_Street_new__c);
		System.assertEquals(account.Head_Office_City__c, account.Billing_City_new__c);
		System.assertEquals(account.Head_Office_State__c, account.Billing_State_new__c);
		System.assertEquals(account.Head_Office_Zip_Postal_Code__c, account.Billing_Zip_new__c);
	}

	@IsTest
	private static void associateParent_Test1()
	{
		// Setup
		Account parentAccount = new Account();
		parentAccount.Name = 'Parent Account';
		parentAccount.Client_ID__c = '111111';

		Account childAccount1 = new Account();
		childAccount1.Name = 'Child Account 1';
		childAccount1.Client_ID__c = '222222';
		childAccount1.LP_Parent_Archie_Client_Id__c = '111111';

		Account childAccount2 = new Account();
		childAccount2.Name = 'Child Account 2';
		childAccount2.Client_ID__c = '333333';
		childAccount2.LP_Parent_Archie_Client_Id__c = '444444';

		// Execute
		Test.startTest();
		insert parentAccount;
		insert childAccount1;
		insert childAccount2;
		Test.stopTest();

		// Verify
		List <Account> accounts = [SELECT Id, ParentId, LP_Acc_Related_List__c FROM Account WHERE Name = 'Child Account 1'];
		System.assertEquals(1, accounts.size());
		childAccount1 = accounts.get(0);
		System.assertEquals(parentAccount.Id, childAccount1.ParentId);
		System.assertEquals(parentAccount.Id, childAccount1.LP_Acc_Related_List__c);

		accounts = [SELECT Id, ParentId, LP_Acc_Related_List__c FROM Account WHERE Name = 'Child Account 2'];
		System.assertEquals(1, accounts.size());
		childAccount2 = accounts.get(0);
		System.assertEquals(null, childAccount2.ParentId);
		System.assertEquals(null, childAccount2.LP_Acc_Related_List__c);
	}

	@IsTest
	private static void processAccount_BeforeInsert_Test1()
	{
		// Setup
		Account account = new Account();
		account.Name = 'Testing Account 1';
		account.Client_Manager__c = 'testUser1@myob.com';
		account.Legal_Entity__c = 'Test Value';

		// Execute
		Test.startTest();
		insert account;
		Test.stopTest();

		// Verify
		List <Account> accounts = [SELECT Id, Legal_Entity_Picklist__c, Client_Manager__c, Client_Manager_New__c, Sync_Status__c FROM Account WHERE Name = 'Testing Account 1' LIMIT 1];
		System.assertEquals(1, accounts.size());
		account = accounts.get(0);

		List <User> users = [SELECT Id FROM User WHERE FederationIdentifier = :account.Client_Manager__c LIMIT 1];
		System.assertEquals(1, users.size());
		User clientManager = users.get(0);

		System.assertEquals(clientManager.Id, account.Client_Manager_New__c);
		System.assertEquals('Test Value', account.Legal_Entity_Picklist__c);
		System.assertEquals('Pending', account.Sync_Status__c);
	}

	@IsTest
	private static void processAccount_AfterInsert_Test1()
	{
		// Setup
		Account account = new Account();
		account.Name = 'Test Account 1';
		account.Client_Manager__c = 'testUser1@myob.com';

		// Execute
		Test.startTest();
		insert account;
		Test.stopTest();

		// Verify Client Manager Account Team Member
		List <AccountTeamMember> accountTeamMembers = [SELECT Id, UserId FROM AccountTeamMember WHERE AccountId = :account.Id AND TeamMemberRole = 'Client Manager'];
		System.assertEquals(1, accountTeamMembers.size());
		AccountTeamMember accountTeamMember = accountTeamMembers.get(0);

		List <User> users = [SELECT Id FROM User WHERE FederationIdentifier = :account.Client_Manager__c LIMIT 1];
		System.assertEquals(1, users.size());
		User clientManager = users.get(0);

		System.assertEquals(clientManager.Id, accountTeamMember.UserId);

		// V// Verify Partner Manager Account Team Member
		accountTeamMembers = [SELECT Id, UserId FROM AccountTeamMember WHERE AccountId = :account.Id AND TeamMemberRole = 'Partner Manager'];
		users = [SELECT Id FROM User WHERE FederationIdentifier = :account.Client_Manager__c LIMIT 1];
		System.assertEquals(1, users.size());
		User partnerManager = users.get(0);

		System.assertEquals(partnerManager.Id, accountTeamMember.UserId);
	}

	@IsTest
	private static void processAccount_BeforeUpdate_Test1()
	{
		// Setup
		Account account = new Account();
		account.Name = 'Test Account 1';
		account.Client_Manager__c = 'testUser1@myob.com';
		account.Legal_Entity__c = 'Test Value';
		account.Legal_Entity__c = null;
		account.Total_Employees__c = 5;
		insert account;

		// Execute
		Test.startTest();
		account.IsPartner = true;
		account.Legal_Entity__c = 'Test Value 1';
		account.Total_Employees__c = 6;
		update account;

		account = [SELECT Id, IsPartner, IsCommunity__c, Legal_Entity_Picklist__c, Sync_Status__c FROM Account WHERE Name = 'Test Account 1'];
		System.assertEquals(true, account.IsCommunity__c);
		System.assertEquals('Test Value 1', account.Legal_Entity_Picklist__c);
		System.assertEquals('Pending', account.Sync_Status__c);

		account.IsPartner = false;
		account.Legal_Entity__c = null;
		update account;

		account = [SELECT Id, IsPartner, IsCommunity__c, Legal_Entity_Picklist__c FROM Account WHERE Name = 'Test Account 1'];
		System.assertEquals(false, account.IsCommunity__c);
		System.assertEquals(null, account.Legal_Entity_Picklist__c);

		Test.stopTest();
	}
}