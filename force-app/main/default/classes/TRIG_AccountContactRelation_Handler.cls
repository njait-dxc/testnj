/**
 * @author
 * @date
 * @description AccountContactRelation Trigger Handler
 */

public with sharing class TRIG_AccountContactRelation_Handler extends TriggerHandler
{
	public override void beforeInsert()
	{
		processAccountContactRelation((List <AccountContactRelation>) Trigger.new, 'BeforeNew');
	}

	public override void beforeUpdate()
	{
		processAccountContactRelation((List <AccountContactRelation>) Trigger.new, 'BeforeUpdate');
	}

	public static void processAccountContactRelation(List <AccountContactRelation> accountContactRelations, String triggerContext)
	{
		List <User> users = [SELECT Id FROM User WHERE Name = 'Integration User'];

		User integrationUser;

		if (users.isEmpty() == false)
		{
			integrationUser = users.get(0);
		}

		for (AccountContactRelation accountContactRelation : accountContactRelations)
		{
			if ((integrationUser == null) || (System.UserInfo.getUserId() != integrationUser.Id))
			{
				accountContactRelation.Sync_Status__c = 'Pending';

				if (triggerContext == 'BeforeNew')
				{
					accountContactRelation.StartDate = System.today();
				}
			}
			else
			{
				if (triggerContext == 'BeforeNew' && accountContactRelation.Siebel_Row_Id__c == null && accountContactRelation.Account_Contact_Rel_Siebel_Row_Id__c != null)
				{
					accountContactRelation.Siebel_Row_Id__c = accountContactRelation.Account_Contact_Rel_Siebel_Row_Id__c;
				}
			}
		}
	}
}