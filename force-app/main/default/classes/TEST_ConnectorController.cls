/**
 * @description
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@IsTest
private class TEST_ConnectorController
{
	@TestSetup
	static void setupData()
	{
		TestDataFactory.createSObject(new Contact(Phone = '1234'), true);
		TestDataFactory.createSObject(new Account(Phone = '2345'), true);
		TestDataFactory.createSObject(new Case(Subject = 'abc'), true);
	}

	static testMethod void findContactTest()
	{
		Test.startTest();
		Contact c = (Contact) ConnectorController.findContact('Phone', '1234', null);
		System.assert(c != null);

		c = (Contact) ConnectorController.getContact(c.Id, null);
		System.assert(c != null);

		/* multiple contacts */
		Contact contact2 = new Contact(FirstName = 'Foo', LastName = 'Bar', Phone = '1234');
		insert contact2;
		c = (Contact) ConnectorController.findContact('Phone', '1234', null);
		System.assert(c.Id == null);

		/* search unsuccessful */
		c = (Contact) ConnectorController.findContact('Phone', 'abcd', null);
		Test.stopTest();
		System.assert(c == null);
	}

	static testMethod void findAccountTest()
	{
		Test.startTest();
		Account c = (Account) ConnectorController.findContact('Phone', '2345', null);
		System.assert(c != null);

		c = (Account) ConnectorController.getContact(c.Id, null);
		System.assert(c != null);

		/* multiple accounts */
		Account account2 = new Account(Name = 'Foo2', Phone = '2345');
		insert account2;
		c = (Account) ConnectorController.findContact('Phone', '2345', null);
		Test.stopTest();
		System.assert(c.Id == null);
	}

	static testMethod void findLeadTest()
	{
		Lead lead = new Lead(Company = 'Lead Company', FirstName = 'firstname', LastName = 'lastname', Phone = '3456');
		insert lead;
		Test.startTest();
		Lead c = (Lead) ConnectorController.findContact('Phone', '3456', null);
		System.assert(c != null);

		c = (Lead) ConnectorController.getContact(c.Id, null);
		System.assert(c != null);

		Lead lead2 = new Lead(Company = 'Lead Company', FirstName = 'firstname2', LastName = 'lastname2', Phone = '3456');
		insert lead2;
		c = (Lead) ConnectorController.findContact('Phone', '3456', null);
		Test.stopTest();
		System.assert(c.Id == null);
	}

	static testMethod void findCase()
	{
		Case myCase = [SELECT CaseNumber FROM Case WHERE Subject = 'abc'];

		Test.startTest();
		Case c = ConnectorController.findCase(myCase.CaseNumber);
		Test.stopTest();

		System.assert(c != null);
	}

	static testMethod void createTask1()
	{
		Map<String, String> taskMap = new Map<String, String>{'CallDurationInSeconds' => '1'};

		Contact c = (Contact) ConnectorController.findContact('Phone', '1234', null);

		Task task = ConnectorController.closeTask(c.Id, c.Id, null, c.AccountId, 'a subject', 'a comment', null, null, taskMap, 10);
		System.assert(task != null);

		task = ConnectorController.getContactByTask(task.Id);
		System.assert(task != null);

		SObject record = ConnectorController.getRecord(task.Id, 'CallObject');
		System.assert(record != null);
	}

	static testMethod void createTask2()
	{
		Map<String, String> taskMap = new Map<String, String>{'CallDurationInSeconds' => '1'};
		Account account = [SELECT Id FROM Account LIMIT 1];

		Test.startTest();
		Contact c = (Contact) ConnectorController.findContact('Phone', '1234', null);

		Task task = ConnectorController.createTask(c.Id, c.Id, null, c.AccountId, null, taskMap);
		System.assert(task != null);

		Task task2 = ConnectorController.createTask(c.Id, account.Id, null, c.AccountId, null, taskMap);
		System.assert(task2 != null);

		task = ConnectorController.updateTask(task.Id, null, taskMap);

		task = ConnectorController.updateTaskDetails(task.Id, account.Id, null);
		Test.stopTest();

		System.assert(task != null);
	}

	static testMethod void createCase()
	{
		Map<String, String> caseMap = new Map<String, String>();
		Contact contact = [SELECT Id, AccountId FROM Contact LIMIT 1];

		Test.startTest();
		Case c = ConnectorController.createCase(contact.Id, contact.AccountId, 'interaction', 'a subject', null, caseMap);
		Test.stopTest();

		System.assert(c != null);

	}
}