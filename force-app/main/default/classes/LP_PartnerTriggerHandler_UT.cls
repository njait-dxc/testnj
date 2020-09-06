/*
    Date            : 27-10-2016
    Author          : SMS Management & Technology
    Description     : Unit test class for LP_PartnerActivitiesTriggerHandler
*/
@IsTest
public with sharing class LP_PartnerTriggerHandler_UT
{

	// Test partner insertion when the parent is already present
	public static testMethod void testPartnerInsertion()
	{
		// List of partners
		List<Account> lstPartner = new List<Account>();

		// Create partner 1
		Account objPartner1 = LP_UnitTestFactory.buildTestPartner();
		objPartner1.Client_ID__c = 'ARCH-ID-1001';
		objPartner1.LP_Partner_GUID__c = 'GUID-ID-1001';
		lstPartner.add(objPartner1);

		// Create partner 2
		Account objPartner2 = LP_UnitTestFactory.buildTestPartner();
		objPartner2.Client_ID__c = 'ARCH-ID-1002';
		objPartner2.LP_Partner_GUID__c = 'GUID-ID-1002';
		objPartner1.LP_Parent_Archie_Client_Id__c = 'ARCH-ID-1001';
		lstPartner.add(objPartner2);

		insert lstPartner;
		TRIG_Account_TriggerHandler.associateParent(lstPartner, 'beforeInsert');

		List<Account> lstAcc = [SELECT Id FROM Account];
		System.assertEquals(lstAcc.size(), 2, true);
	}

	// Test insertion of partners when the parent partner is not yet
	// created in Salesforce
	public static testMethod void testParentNotFound()
	{
		List<Account> lstPartner = new List<Account>();
		// Create Partner 1
		Account objPartner1 = LP_UnitTestFactory.buildTestPartner();
		objPartner1.Client_ID__c = 'ARCH-ID-1001';
		objPartner1.LP_Partner_GUID__c = 'GUID-ID-1001';
		lstPartner.add(objPartner1);

		// Create Partner 2
		Account objPartner2 = LP_UnitTestFactory.buildTestPartner();
		objPartner2.Client_ID__c = 'ARCH-ID-1002';
		objPartner2.LP_Partner_GUID__c = 'GUID-ID-1002';
		objPartner2.LP_Parent_Archie_Client_Id__c = 'ARCH-ID-1003';
		lstPartner.add(objPartner2);

		insert lstPartner;
		TRIG_Account_TriggerHandler.associateParent(lstPartner, 'beforeInsert');

		List<Account> lstAcc = [SELECT Id FROM Account];
		System.assertEquals(lstAcc.size(), 2, true);
	}

	// Test for when the parent partner is updated
	public static testMethod void testParentUpdation()
	{
		List<Account> lstPartner = new List<Account>();
		// Create Partner
		Account objPartner1 = LP_UnitTestFactory.buildTestPartner();
		objPartner1.Client_ID__c = 'ARCH-ID-1001';
		insert objPartner1;

		// Update Partner
		objPartner1.LP_Parent_Archie_Client_Id__c = '';
		update objPartner1;
	}

	// Testing if the partner delta flag is updated - this flag helps
	// determine which partners need to be sent to the service post the
	// point calculation
	public static testMethod void testPartnerDeltas()
	{
		List<Account> lstPartner = new List<Account>();
		// Create Partner 1
		Account objPartner1 = LP_UnitTestFactory.buildTestPartner();
		objPartner1.Client_ID__c = 'ARCH-ID-1001';
		objPartner1.LP_Partner_GUID__c = 'GUID-ID-1001';
		lstPartner.add(objPartner1);

		// Create Partner 2
		Account objPartner2 = LP_UnitTestFactory.buildTestPartner();
		objPartner2.Client_ID__c = 'ARCH-ID-1002';
		objPartner2.LP_Partner_GUID__c = 'GUID-ID-1002';
		objPartner2.LP_Parent_Archie_Client_Id__c = 'ARCH-ID-1003';
		lstPartner.add(objPartner2);

		insert lstPartner;

		// Update Partner
		try
		{
			objPartner1.LP_Parent_Archie_Client_Id__c = 'ARCH-ID-1002';
			objPartner1.LP_Points__c = 10;
			update objPartner1;

			System.assertEquals(objPartner1.Parent != null, false);
		} catch (Exception e)
		{

		}
	}

	// Test for partner update - updating with a new parent
	public static testMethod void testParentUpdate()
	{
		// Create Partner
		Account objPartner1 = LP_UnitTestFactory.buildTestPartner();
		insert objPartner1;

		// Update the partner
		try
		{
			objPartner1.LP_Parent_Archie_Client_Id__c = 'werviwer';
			update objPartner1;

			System.assertEquals(objPartner1.Parent == null, true);
		} catch (Exception e)
		{

		}
	}
}