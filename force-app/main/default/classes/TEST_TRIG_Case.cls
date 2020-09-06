/**
 * @author alexvolkov
 * @date 25/11/19
 * @description Case Trigger Test class
 */
@IsTest
private with sharing class TEST_TRIG_Case
{
	@TestSetup
	static void setupData()
	{
		Account vAcc = (Account)TestDataFactory.createSObject(new Account(), true);
		Contact vContact = (Contact)TestDataFactory.createSObject(new Contact(AccountId = vAcc.Id), true);
		List<Case> vCases = (List<Case>)TestDataFactory.createSObjectList(new Case(AccountId = vAcc.Id, ContactId = vContact.Id), 4, false);
		vCases[1].Refund_Required__c = 'Yes';
		vCases[1].Approval_Status__c = 'Awaiting TM approval';
		vCases[2].Categ__c = 'Credit Note';
		vCases[2].Approval_Status__c = 'Awaiting TM approval';
		vCases[3].Categ__c = 'Account Administration';
		Database.insert(vCases);
	}

	static testMethod void testCaseAssignmentInsert()
	{
		Account vAcc = [SELECT Id FROM Account LIMIT 1];
		Contact vContact = [SELECT Id FROM Contact LIMIT 1];

		Case vCase = new Case (AccountId=vAcc.Id, ContactId=vContact.Id,
				Primary_Category__c = 'Administrative Request',
				Categ__c = 'General Service Request', Serial_Number__c = '1212121',
				Description = 'Testing', Status='New');

		Test.startTest();
		Database.insert(vCase);
		Test.stopTest();
		Case vCaseToVerify = [SELECT OwnerId FROM Case WHERE Id = :vCase.Id];
		System.assertNotEquals(UserInfo.getUserId(), vCaseToVerify.OwnerId, 'Case was not assigned');
	}

	static testMethod void testCaseAssignmentUpdate()
	{
		List<Case> vCases = [SELECT IsEscalated, Categ__c, Approval_Status__c, Status FROM Case LIMIT 4];
		for (Case c: vCases)
		{
			if (c.Approval_Status__c == 'Awaiting TM approval')
			{
				c.Approval_Status__c = 'Approved';
			}
			else if (c.Categ__c == 'Account Administration')
			{
				c.Status = 'Response Received';
			}
			else
			{
				c.IsEscalated = true;
			}
		}
		Test.startTest();
		Database.update(vCases);
		Test.stopTest();
		System.assertNotEquals(null, [SELECT OwnerId FROM Case LIMIT 1].OwnerId);
	}

	static testMethod void testE2CRestrictedDomain()
	{
		Account vAcc = [SELECT Id FROM Account LIMIT 1];
		Support_Setting__mdt vSupportSetting = [SELECT Value__c FROM Support_Setting__mdt WHERE DeveloperName = 'Restricted_E2C_Domains'];
		if (vSupportSetting.Value__c != null && vSupportSetting.Value__c != '')
		{
			String vSettingValue = vSupportSetting.Value__c.split(',')[0];
			TRIG_Case_TriggerHandler.getRestrictedDomainsSwitch = new Set<String>{'On'};

			Test.startTest();
			Database.SaveResult vSR = Database.insert(new Case(AccountId = vAcc.Id, SuppliedEmail = 'testing@' + vSettingValue), false);
			Test.stopTest();

			System.assertEquals(false, vSR.isSuccess(), 'Case was created for a restricted domain');
		}
	}

	static testMethod void testE2CAllowedDomain()
	{
		Account vAcc = [SELECT Id FROM Account LIMIT 1];
		TRIG_Case_TriggerHandler.getRestrictedDomainsSwitch  = new Set<String>{'On'};

		Test.startTest();
		Database.SaveResult vSR = Database.insert(new Case(AccountId = vAcc.Id, SuppliedEmail = 'testing@invalidalloweddomain.com.au'), false);
		Test.stopTest();

		System.assert(vSR.isSuccess(), 'Case was not created for an allowed domain');
	}
    
    static testMethod void testPublishCasePlatformEvent_Insert()
	{
		Account vAcc = [SELECT Id FROM Account LIMIT 1];
		Contact vContact = [SELECT Id FROM Contact LIMIT 1];

		Case vCase = new Case ( AccountId=vAcc.Id, ContactId=vContact.Id,
								Primary_Category__c = 'Administrative Request',
								Categ__c = 'General Service Request', Serial_Number__c = '1212121',
								Description = 'Testing', Status='New');

		Test.startTest();
		Database.insert(vCase);
		Test.stopTest();
		
	}

	static testMethod void testPublishCasePlatformEvent_Delete()
	{
		Account vAcc = [SELECT Id FROM Account LIMIT 1];
		Contact vContact = [SELECT Id FROM Contact LIMIT 1];

		Case vCase = new Case ( AccountId=vAcc.Id, ContactId=vContact.Id,
								Primary_Category__c = 'Administrative Request',
								Categ__c = 'General Service Request', Serial_Number__c = '1212121',
								Description = 'Testing', Status='New');

		
		Database.insert(vCase);

		Test.startTest();
		delete vCase;
		Test.stopTest();
		
	}

	static testMethod void testPublishCasePlatformEvent_Undelete()
	{
		Account vAcc = [SELECT Id FROM Account LIMIT 1];
		Contact vContact = [SELECT Id FROM Contact LIMIT 1];

		Case vCase = new Case ( AccountId=vAcc.Id, ContactId=vContact.Id,
								Primary_Category__c = 'Administrative Request',
								Categ__c = 'General Service Request', Serial_Number__c = '1212121',
								Description = 'Testing', Status='New');

		
		Database.insert(vCase);
		delete vCase;
		Test.startTest();
		undelete vCase;
		Test.stopTest();
	}

}