/*
    Date        : 19 Dec 2016
    Author      : SMS Management & Technology
    Description : Unit test factory for LP_RelateActivityPartnerBatch
*/
@IsTest
public with sharing class LP_RelateActivityToPartnerBatch_UT {
	@TestSetup
	static void setup() {
		// Create a partner
		Account objPartner = LP_UnitTestFactory.buildTestPartner();
		insert objPartner;

		// List of activities
		List<LP_Partner_Activities__c> lstActivities = new List<LP_Partner_Activities__c>();

		// Create an activity 1 for the partner
		LP_Partner_Activities__c objActivities1 = LP_UnitTestFactory.buildTestActivities();
		objActivities1.LP_Activity_GUID__c = 'GUID-ID-1011'; // GUID has to be unique
		objActivities1.LP_Partner_GUID__c = objPartner.LP_Partner_GUID__c;
		objActivities1.LP_Partner_Archie_ID__c = objPartner.Client_ID__c;
		lstActivities.add(objActivities1);

		// Create an activity 2 for the partner
		LP_Partner_Activities__c objActivities2 = LP_UnitTestFactory.buildTestActivities();
		objActivities2.LP_Activity_GUID__c = 'GUID-ID-1012'; // GUID has to be unique
		objActivities2.LP_Partner_GUID__c = objPartner.LP_Partner_GUID__c;
		objActivities2.LP_Partner_Archie_ID__c = objPartner.Client_ID__c;
		lstActivities.add(objActivities2);
		insert lstActivities;

		// Create custom setting that stores the email group
		LS_Email_Group__c objEmail = new LS_Email_Group__c();
		objEmail.Name = 'test_support_group@myob.com';
		insert objEmail;
	}

	// Test for list of activities to get associated
	// to thier partner
	public static testMethod void testRelateActivities() {
		// Setting the user - for manual trigger email
		User runningUser = LP_UnitTestFactory.createUser();
		insert runningUser;

		// Create error
		LP_ErrorLogHandler.log('ErrorMessage','ExceptionMessage','Element');
		List<LP_Error_Log__c> lstNewErr = [SELECT Id FROM LP_Error_Log__c];

		// Call the batch job
		System.runAs(runningUser) {
			List<Map<String, Object>> jobStatus = new List<Map<String, Object>>();
			LP_RelateActivityToPartnerBatch con = new LP_RelateActivityToPartnerBatch(jobStatus);
			/*Database.BatchableContext  bc;
			con.start(bc);
			con.lstError = lstNewErr;
			con.execute(bc, lstActivities);*/
			Test.startTest();
			Database.executeBatch(con);
			Test.stopTest();

			/*System.assertEquals(objActivities1.LP_Partner_Name__c != null, true);
			System.assertEquals(objActivities1.LP_Partner_Name__c == objPartner.Id, true);
			System.assertEquals(objActivities2.LP_Partner_Name__c != null, true);
			System.assertEquals(objActivities2.LP_Partner_Name__c == objPartner.Id, true);*/
		}
	}
}