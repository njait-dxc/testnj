@IsTest
public class EnrollmentTrigger_Test
{
	@TestSetup static void dataSetUp()
	{

		//Creating learndot Account
		/* learndot__Learndot_Account__c ldAccountRecord = new learndot__Learndot_Account__c();
		 ldAccountRecord.learndot__ID__c = '12321';
		 ldAccountRecord.Name = 'Test LdAccount';
		 insert ldAccountRecord;
		 //Creating SF Contact
		 Contact conObj = new Contact();
		 conObj.LastName = 'testSF Contact';
		 conObj.Email = 'Test@email.com';
		 insert conObj;
		 //Creating Learndot Contact
		 learndot__Learndot_Contact__c ldContactRecord = new learndot__Learndot_Contact__c();
		 ldContactRecord.learndot__ID__c = '1231234';
		 ldContactRecord.learndot__External_ID__c = conObj.Id;
		 ldContactRecord.learndot__Salesforce_Contact__c = conObj.Id;
		 ldContactRecord.Name = 'Test LdContact';
		 insert ldContactRecord;
		 //Creating Learndot Catalog Items
		 learndot__Learndot_Product__c ldCatalog = new learndot__Learndot_Product__c();
		 ldCatalog.Name = 'Certified Consultant Recertification (AU)';
		 ldCatalog.learndot__type__c = 'Course';
		 ldCatalog.learndot__ID__c = '559';
		 insert ldCatalog;
		 //Creating Re-Certification custom setting details
		 ReCertification_Course_Details__c customSetting = new ReCertification_Course_Details__c();
		 customSetting.Name = '559';
		 customSetting.Course_Id__c = 'Certified Consultant Recertification (AU)';
		 insert customSetting;
		 //Creating test course
		 learndot__Learndot_Product__c testCourse = new learndot__Learndot_Product__c();
		 testCourse.Name = 'test modules';
		 testCourse.learndot__type__c = 'Course';
		 testCourse.learndot__ID__c = 'course_pathway-509';
		 testCourse.learndot__Custom_Field_2__c = '10';
		 testCourse.learndot__Custom_Field_1__c = '10';
		 insert testCourse;
		 learndot__Learndot_Enrollments__c enrollment = new learndot__Learndot_Enrollments__c();
		 enrollment.Name = 'Certified Consultant Recertification (AU)';
		 enrollment.learndot__Learndot_Contact__c = ldContactRecord.Id;
		 enrollment.learndot__Learndot_Account__c = ldAccountRecord.Id;
		 enrollment.learndot__Learndot_Catalog_Item__c = ldCatalog.Id;
		 insert enrollment;
		 learndot__Learndot_Enrollments__c enrollment2 = new learndot__Learndot_Enrollments__c();
		 enrollment2.Name = 'Certified Consultant Recertification (AU)';
		 enrollment2.learndot__Learndot_Contact__c = ldContactRecord.Id;
		 enrollment2.learndot__Learndot_Account__c = ldAccountRecord.Id;
		 enrollment2.learndot__Learndot_Catalog_Item__c = ldCatalog.Id;
		 enrollment2.Is_Score_Updated__c = true;
		 enrollment2.learndot__status__c = 'CANCELLED';
		 insert enrollment2; */


	}
	public static testMethod void enrollmentInsert()
	{
		//learndot__Learndot_Account__c ldAccount = [select id from learndot__Learndot_Account__c limit 1];
		// learndot__Learndot_Contact__c ldContact = [select id from learndot__Learndot_Contact__c limit 1];
		//learndot__Learndot_Product__c ldCourse = [select id from learndot__Learndot_Product__c where Name = :'test modules' limit 1];
		// learndot__Learndot_Enrollments__c enrollment = new learndot__Learndot_Enrollments__c();
		// enrollment.Name = 'Test Enrollment';
		// enrollment.learndot__Learndot_Contact__c = ldContact.Id;
		//enrollment.learndot__Learndot_Account__c = ldAccount.Id;
		// enrollment.learndot__Learndot_Catalog_Item__c = ldCourse.Id;
		// enrollment.learndot__status__c = 'COMPLETED';
		// insert enrollment;
	}
	public static testMethod void enrollmentUpdate()
	{
		// learndot__Learndot_Account__c ldAccount = [select id from learndot__Learndot_Account__c limit 1];
		//learndot__Learndot_Contact__c ldContact = [select id from learndot__Learndot_Contact__c limit 1];
		//learndot__Learndot_Product__c ldCourse = [select id from learndot__Learndot_Product__c where Name = :'test modules' limit 1];
		//learndot__Learndot_Enrollments__c enrollment = new learndot__Learndot_Enrollments__c();
		//enrollment.Name = 'Test Enrollment';
		// enrollment.learndot__Learndot_Contact__c = ldContact.Id;
		//enrollment.learndot__Learndot_Account__c = ldAccount.Id;
		//enrollment.learndot__Learndot_Catalog_Item__c = ldCourse.Id;
		// insert enrollment;
		// enrollment.learndot__status__c = 'COMPLETED';
		// Update enrollment;
	}


}