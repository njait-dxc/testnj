@IsTest
private class TEST_TRIG_Task
{
	@IsTest
	static void testEventTrigger1()
	{
		Profile clientManagerProfile = [SELECT Id FROM Profile WHERE Name = '~ Client Manager April.2017'];
		User clientManagerUser = new User();
		clientManagerUser.Alias = 'UL';
		clientManagerUser.Email = 'u@test.com';
		clientManagerUser.EmailEncodingKey = 'UTF-8';
		clientManagerUser.LastName = 'UL';
		clientManagerUser.LanguageLocaleKey = 'en_US';
		clientManagerUser.LocaleSidKey = 'en_US';
		clientManagerUser.ProfileId = clientManagerProfile.Id;
		clientManagerUser.TimeZoneSidKey = 'America/Los_Angeles';
		clientManagerUser.Username = 'testingmyob@myob.com';
		clientManagerUser.FederationIdentifier = 'testingmyob@myob.com';
		insert clientManagerUser;

		Test.startTest();

		System.runAs(clientManagerUser)
		{
            Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('SME Solution Sales Processing Tasks').getRecordTypeId();
			//Task task = new Task(Subject = 'Test', Status = 'Not Started',RecordTypeId = '01228000000Tj25AAC');
			Task task = new Task(Subject = 'Test', Status = 'Not Started',RecordTypeId = recordTypeId);
			insert task;
			Task taskResult = [SELECT Id, Sync_Status__c FROM Task WHERE Id = :task.Id];

			System.assertEquals('Pending', taskResult.Sync_Status__c);

			task.Description = 'test';
			task.Type = 'Call';
			task.Sync_Status__c = 'Updated';
			update task;
			task.Subject = 'test';
			update task;
			task.Status = 'In Progress';
			update task;
			taskResult = [SELECT Id, Sync_Status__c FROM Task WHERE Id = :task.Id];

			System.assertEquals('Pending', taskResult.Sync_Status__c);
		}
		Test.stopTest();
	}

	@IsTest static void checkBanklinkLogicOnTask()
	{
			Case ca = new Case(Subject = 'Test Controller Acct Case');
			ca.Primary_Category__c = 'Onboarding Request';
			ca.Categ__c = 'BL - Essentials';
			ca.Sub_Category__c = 'Migration Services';
			insert ca;
			Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Bank Link Cancellation').getRecordTypeId();
			//Task task = new Task(Subject = 'Test', Status = 'Not Started', WhatId = ca.Id, RecordTypeId = '0121m00000022HfAAI');
			Task task = new Task(Subject = 'Test', Status = 'Not Started', WhatId = ca.Id, RecordTypeId = recordTypeId);
			insert task;


			task.Status = 'Completed';
			task.Cancel_Banklink_Account__c = 'Yes';
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new MYOBServicesMockResponse());
			update task;
			Test.stopTest();
		//Task taskResult = [SELECT Id, Sync_Status__c FROM Task WHERE Id = :task.Id];
	}
}