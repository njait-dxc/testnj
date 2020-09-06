public with sharing class TRIG_Contact_TriggerHandler extends TriggerHandler
{
	public override void beforeUpdate()
	{
		processContact((List <Contact>) Trigger.new, (Map <Id, Contact>) Trigger.oldMap, 'BeforeUpdate');
	}
	public override void beforeInsert()
	{
		processContact((List <Contact>) Trigger.new, (Map <Id, Contact>) Trigger.oldMap, 'BeforeNew');
	}

	public static void processContact(List <Contact> contacts, Map <Id, Contact> oldMap, String triggerContext)
	{
		List <User> users = [SELECT Id FROM User WHERE Name = 'Integration User'];

		User integrationUser;

		if (users.isEmpty() == false)
		{
			integrationUser = users.get(0);
		}

		for (Contact contact : contacts)
		{
			if (integrationUser == null || System.UserInfo.getUserId() != integrationUser.Id)
			{
				if (triggerContext == 'BeforeNew')
				{
					contact.Sync_Status__c = 'Pending';
				}
				else if (triggerContext == 'BeforeUpdate')
				{
					Contact contactOld = oldMap.get(contact.Id);

					if (contact.Phone != contactOld.Phone ||
						contact.MobilePhone != contactOld.MobilePhone ||
						contact.DoNotCall != contactOld.DoNotCall ||
						contact.HasOptedOutOfEmail != contactOld.HasOptedOutOfEmail ||
						contact.Do_Not_Mail__c != contactOld.Do_Not_Mail__c ||
						contact.Do_Not_SMS__c != contactOld.Do_Not_SMS__c ||
						contact.HasOptedOutOfFax != contactOld.HasOptedOutOfFax ||
						contact.Do_Not_Survey__c != contactOld.Do_Not_Survey__c ||
						contact.Special_Offers__c != contactOld.Special_Offers__c ||
						contact.Send_Promotions__c != contactOld.Send_Promotions__c ||
						contact.Tips_and_Tricks__c != contactOld.Tips_and_Tricks__c ||
						contact.Training_Events__c != contactOld.Training_Events__c ||
						contact.Opt_out_my_MYOB_Invoice__c != contactOld.Opt_out_my_MYOB_Invoice__c ||
						contact.Opt_in_to_MYOB_Research__c != contactOld.Opt_in_to_MYOB_Research__c ||
						contact.Reason_for_Leaving__c != contactOld.Reason_for_Leaving__c ||
						contact.Salutation != contactOld.Salutation ||
						contact.FirstName != contactOld.FirstName ||
						contact.LastName != contactOld.LastName)
					{
						contact.Sync_Status__c = 'Pending';
					}
				}
			}
		}
	}
}