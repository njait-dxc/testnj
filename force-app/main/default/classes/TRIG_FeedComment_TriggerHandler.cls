public with sharing class TRIG_FeedComment_TriggerHandler extends TriggerHandler
{
	public override void beforeDelete()
	{
		DisableFeedComment((List <FeedComment>) Trigger.old);
	}

	public static void DisableFeedComment(List <FeedComment> feedComments)
	{
		if (allowDelete() == false)
		{
			for (FeedComment feedComment : feedComments)
			{
				feedComment.addError('Your administrator has disabled feed post and comment deletions.');
			}
		}
	}

	public static Boolean allowDelete()
	{
		Chatter_Delete_Settings__c chatterDeleteSettings = Chatter_Delete_Settings__c.getInstance();
		//Checking the setting Name as a non-null chatterDeleteSettings object is always returned even if there are no settings
		//Checking the Id doesn't work as getInstance() doesn't return Id for settings inherited from hierarchy
		if (chatterDeleteSettings.Name == null)
		{
			String profileId = UserInfo.getProfileId();
			Boolean modifyAllData = [SELECT Id, PermissionsModifyAllData FROM Profile WHERE Id = :profileId].PermissionsModifyAllData;
			return modifyAllData;
		}
		else
		{
			return chatterDeleteSettings.Allow_Feed_Post_and_Comment_deletes__c;
		}
	}
}