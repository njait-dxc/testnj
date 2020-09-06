/**
 * @author
 * @date
 * @description
 */

@IsTest
public class DeleteInactiveContactsTest
{

	public static testMethod void testSchedule()
	{
		Account ac = new Account(Name = 'Testing Account');
		insert ac;
		List <Contact> contactList = new List<Contact>();
		for (Integer i = 0; i < 10; i++)
		{
			contactList.add(new Contact(FirstName = 'fn' + i, LastName = 'ln' + i, AccountId = ac.Id, Active_Contact__c = false));
		}

		//Case case1 = new Case (AccountId=ac.id, ContactId=contactList[0].id, Primary_Category__c = 'Billing & Finance', Categ__c = 'Cancellations', Serial_Number__c = '1212121', Cancellation_Reason__c ='Unconsumed Bureau', Refund_Required__c = 'No');
		//insert case1;

		if (!contactList.isEmpty())
		{
			insert contactList;
		}

		Test.startTest();
		DeleteInactiveContacts vDIC1 = new DeleteInactiveContacts();
		String sch = '0  00 1 3 * ?';
		System.schedule('Test', sch, vDIC1);
		Test.stopTest();
		List <Contact> resultList = [SELECT Id FROM Contact WHERE Active_Contact__c = FALSE];
		System.assert(resultList.isEmpty());
	}
}