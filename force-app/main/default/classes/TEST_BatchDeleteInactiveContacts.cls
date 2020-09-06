@IsTest
private class TEST_BatchDeleteInactiveContacts
{
	@TestSetup
	static void setupData()
	{
		Account vAcc = (Account)TestDataFactory.createSObject(new Account(), true);
		List<Contact> vContacts = (List<Contact>) TestDataFactory.createSObjectList(new Contact(AccountId = vAcc.Id, Active_Contact__c = false), 10, false);
		vContacts.add((Contact)TestDataFactory.createSObject(new Contact(FirstName = 'PGF', LastName = 'PGL', AccountId = vAcc.Id, Active_Contact__c = false, RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('PayGlobal Contacts').getRecordTypeId()), false));
		Database.insert(vContacts);
	}

	@IsTest
	static void testSchedule()
	{
		Test.startTest();
		BatchDeleteInactiveContactsSchedule vBDIC1 = new BatchDeleteInactiveContactsSchedule();
		String sch = '0  00 1 3 * ?';
		System.schedule('Test', sch, vBDIC1);
		Test.stopTest();
		List <Contact> vPGContactlList = [SELECT Id FROM Contact WHERE Active_Contact__c = FALSE AND FirstName = 'PGF' AND LastName = 'PGL'];
		System.assert(!vPGContactlList.isEmpty());
	}
}