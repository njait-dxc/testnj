/**
 * Test Suite for testing Chatter Disable Delete app
 * 
 * Author: Marcus Ericsson - mericsson@salesforce.com
 */
@IsTest
private class DisableChatterDeletesTestSuite
{

	static void deleteAllCustomSettings()
	{
		Chatter_Delete_Settings__c[] settings = [SELECT Id FROM Chatter_Delete_Settings__c];
		delete(settings);
	}

	static Id insertDummyContact()
	{
		// lets do User instead because some orgs don't have Feeds enabled on Contacts.
		Profile prof = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User u = new User(Alias = 'standt', Email = 'testFeedItemDeleteDummy@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = prof.Id, TimeZoneSidKey = 'America/Los_Angeles', Username = 'testFeedItemDeleteDummy@testorg.com');
		Database.SaveResult sr = Database.insert(u);
		System.assert(sr.isSuccess());
		return sr.getId();
	}

	static testMethod void testFeedItemDeleteSysAdmin()
	{
		deleteAllCustomSettings();

		Profile prof = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User u = new User(Alias = 'standt', Email = 'testFeedItemDelete@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = prof.Id, TimeZoneSidKey = 'America/Los_Angeles', Username = 'testFeedItemDelete@testorg.com');
		//insert a dummy contact we can post on
		Id cid = insertDummyContact();

		System.runAs(u)
		{


			// test single item delete
			FeedItem p = new FeedItem();
			p.ParentId = cid;
			p.Body = 'force.com labs is great!';
			insert(p);
			delete(p);
		}
	}

	static testMethod void testFeedItemDeleteSysAdminFrench()
	{
		deleteAllCustomSettings();

		Profile prof = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User u = new User(Alias = 'standt', Email = 'testFeedItemDelete@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'fr', LocaleSidKey = 'en_US', ProfileId = prof.Id, TimeZoneSidKey = 'America/Los_Angeles', Username = 'testFeedItemDelete@testorg.com');

		System.runAs(u)
		{
			// test single item delete
			FeedItem p = new FeedItem();
			p.ParentId = u.Id;
			p.Body = 'force.com labs is great!';
			insert(p);
			delete(p);
		}
	}

	static testMethod void testFeedCommentDeleteSysAdmin()
	{
		deleteAllCustomSettings();

		Profile prof = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User u = new User(Alias = 'standt', Email = 'testFeedItemDelete@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = prof.Id, TimeZoneSidKey = 'America/Los_Angeles', Username = 'testFeedItemDelete@testorg.com');

		System.runAs(u)
		{
			Id cid = insertDummyContact();

			// test single item delete
			FeedItem p = new FeedItem();
			p.ParentId = cid;
			p.Body = 'force.com labs is great!';

			Database.SaveResult sr = Database.insert(p);
			System.assert(sr.isSuccess());
			Id pId = sr.getId();

			FeedComment c = new FeedComment();
			c.FeedItemId = pId;
			c.CommentBody = 'this is a comment';
			insert(c);

			delete(c);
		}
	}

	static testMethod void testFeedItemDelete()
	{
		deleteAllCustomSettings();

		Profile prof = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
		User u = new User(Alias = 'standt', Email = 'testFeedItemDelete@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = prof.Id, TimeZoneSidKey = 'America/Los_Angeles', Username = 'testFeedItemDelete@testorg.com');
		//insert a dummy contact we can post on
		Id cid = insertDummyContact();

		System.runAs(u)
		{
			// The following code runs as user 'u'


			// test single item delete
			FeedItem p = new FeedItem();
			p.ParentId = cid;
			p.Body = 'force.com labs is great!';
			insert(p);
			try
			{
				delete(p);
				System.assert(false);
			} catch (System.DmlException e)
			{
				System.assert(e.getMessage().contains('disabled'));
			}


			// now test bulk delete
			FeedItem[] ps = new FeedItem[150];
			for (Integer i = 0; i < 150; i++)
			{
				ps[i] = new FeedItem();
				ps[i].ParentId = cid;
				ps[i].Body = 'force.com labs is great!';
			}
			insert(ps);
			try
			{
				delete(ps);
				System.assert(false);
			} catch (System.DmlException e)
			{
				System.assert(e.getMessage().contains('disabled'));
			}
		}
	}

	static testMethod void testFeedItemDeleteFrench()
	{
		deleteAllCustomSettings();

		Profile prof = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
		User u = new User(Alias = 'standt', Email = 'testFeedItemDelete@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'fr', LocaleSidKey = 'en_US', ProfileId = prof.Id, TimeZoneSidKey = 'America/Los_Angeles', Username = 'testFeedItemDelete@testorg.com');


		System.runAs(u)
		{
			// test single item delete
			FeedItem p = new FeedItem();
			p.ParentId = u.Id;
			p.Body = 'force.com labs is great!';
			insert(p);
			try
			{
				delete(p);
				System.assert(false);
			} catch (System.DmlException e)
			{
				System.assert(e.getMessage().contains('disabled'));
			}
		}
	}

	static testMethod void testFeedCommentDelete()
	{
		deleteAllCustomSettings();
		Profile prof = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
		User u = new User(Alias = 'standt', Email = 'testFeedCommentDelete@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = prof.Id, TimeZoneSidKey = 'America/Los_Angeles', Username = 'testFeedCommentDelete@testorg.com');
		Id cid = insertDummyContact();

		System.runAs(u)
		{
			// The following code runs as user 'u'
			//insert a dummy contact we can post on
			// Id cid = insertDummyContact();

			// test single item delete
			FeedItem p = new FeedItem();
			p.ParentId = cid;
			p.Body = 'force.com labs is great!';

			Database.SaveResult sr = Database.insert(p);
			System.assert(sr.isSuccess());
			Id pId = sr.getId();

			FeedComment c = new FeedComment();
			c.FeedItemId = pId;
			c.CommentBody = 'this is a comment';
			insert(c);

			try
			{
				delete(c);
				System.assert(false);
			} catch (System.DmlException e)
			{
				System.assert(e.getMessage().contains('disabled'));
			}


			// now test bulk delete
			FeedComment[] cs = new FeedComment[150];
			for (Integer i = 0; i < 150; i++)
			{
				cs[i] = new FeedComment();
				cs[i].FeedItemId = pId;
				cs[i].CommentBody = 'force.com labs is great!';
			}
			insert(cs);
			try
			{
				delete(cs);
				System.assert(false);
			} catch (System.DmlException e)
			{
				System.assert(e.getMessage().contains('disabled'));
			}
		}
	}

	static testMethod void testFeedItemDeleteCustomSetting()
	{
		deleteAllCustomSettings();

		Profile prof = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
		User u = new User(Alias = 'standt', Email = 'testFeedItemDelete@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = prof.Id, TimeZoneSidKey = 'America/Los_Angeles', Username = 'testFeedItemDelete@testorg.com');
		Chatter_Delete_Settings__c settings = new Chatter_Delete_Settings__c();
		settings.Allow_Feed_Post_and_Comment_deletes__c = true;
		settings.SetupOwnerId = prof.Id;
		upsert(settings);
		//insert a dummy contact we can post on
		Id cid = insertDummyContact();
		try
		{
			System.runAs(u)
			{
				// The following code runs as user 'u'


				// test single item delete
				FeedItem p = new FeedItem();
				p.ParentId = cid;
				p.Body = 'force.com labs is great!';
				insert(p);
				delete(p);

				// now test bulk delete
				FeedItem[] ps = new FeedItem[150];
				for (Integer i = 0; i < 150; i++)
				{
					ps[i] = new FeedItem();
					ps[i].ParentId = cid;
					ps[i].Body = 'force.com labs is great!';
				}
				insert(ps);
				delete(ps);
			}
		} finally
		{
			settings.Allow_Feed_Post_and_Comment_deletes__c = false;
			update(settings);
		}
	}

	static testMethod void testFeedCommentDeleteCustomSetting()
	{
		deleteAllCustomSettings();

		Profile prof = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
		User u = new User(Alias = 'standt', Email = 'testFeedCommentDelete@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = prof.Id, TimeZoneSidKey = 'America/Los_Angeles', Username = 'testFeedCommentDelete@testorg.com');
		Chatter_Delete_Settings__c settings = new Chatter_Delete_Settings__c();
		settings.Allow_Feed_Post_and_Comment_deletes__c = true;
		settings.SetupOwnerId = prof.Id;
		upsert(settings);
		//insert a dummy contact we can post on
		Id cid = insertDummyContact();
		try
		{


			System.runAs(u)
			{
				// The following code runs as user 'u'


				// test single item delete
				FeedItem p = new FeedItem();
				p.ParentId = cid;
				p.Body = 'force.com labs is great!';

				Database.SaveResult sr = Database.insert(p);
				System.assert(sr.isSuccess());
				Id pId = sr.getId();

				FeedComment c = new FeedComment();
				c.FeedItemId = pId;
				c.CommentBody = 'this is a comment';
				insert(c);


				delete(c);

				// now test bulk delete
				FeedComment[] cs = new FeedComment[150];
				for (Integer i = 0; i < 150; i++)
				{
					cs[i] = new FeedComment();
					cs[i].FeedItemId = pId;
					cs[i].CommentBody = 'force.com labs is great!';
				}
				insert(cs);
				delete(cs);
			}
		} finally
		{
			settings.Allow_Feed_Post_and_Comment_deletes__c = false;
			update(settings);
		}

	}

}