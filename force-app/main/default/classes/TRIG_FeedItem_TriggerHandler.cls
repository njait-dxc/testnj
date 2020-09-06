public with sharing class TRIG_FeedItem_TriggerHandler extends TriggerHandler
{
	public override void beforeDelete()
	{
		DisableFeedItem((List <FeedItem>) Trigger.old);
	}

	public static void DisableFeedItem(List <FeedItem> feedItems)
	{
		if (allowDelete() == false)
		{
			for (FeedItem feedItem : feedItems)
			{
				String parentId = feedItem.ParentId;

				if ((parentId.startsWith('00Q') && feedItem.Type == 'TrackedChange') == false)
				{
					feedItem.addError('Your administrator has disabled feed post and comment deletions.');
				}
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