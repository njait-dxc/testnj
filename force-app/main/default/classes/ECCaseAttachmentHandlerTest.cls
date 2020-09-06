@IsTest
public class ECCaseAttachmentHandlerTest
{
	@IsTest
	static void test()
	{
		Account ac = new Account(Name = 'TestAccount', Legal_Entity__c = 'MYOB Australia Pty Ltd');
		insert ac;
		Contact ct = new Contact(FirstName = 'FN', LastName = 'LN', AccountId = ac.Id);
		insert ct;
		Case cs1 = new Case (AccountId = ac.Id, ContactId = ct.Id, Primary_Category__c = 'Administrative Request', Categ__c = 'Technical Services Request', Sub_Category__c = 'IT Assessment', Status = 'New', Description = 'Testing');
		Case cs2 = new Case (AccountId = ac.Id, ContactId = ct.Id, Primary_Category__c = 'Administrative Request', Categ__c = 'Technical Services Request', Sub_Category__c = 'IT Assessment', Status = 'New', Description = 'Testing');
		insert cs1;
		insert cs2;

		Attachment attach1 = new Attachment();
		attach1.Name = 'Unit Test Attachment1';
		Blob bodyBlob1 = Blob.valueOf('Unit Test Attachment Body1');
		attach1.Body = bodyBlob1;
		attach1.ParentId = cs1.Id;
		insert attach1;
		/*
	 Attachment attach2=new Attachment();
	 attach2.Name='Unit Test Attachment2';
	 Blob bodyBlob2=Blob.valueOf('Unit Test Attachment Body2');
	 attach2.body=bodyBlob2;
	 attach2.parentId=cs2.id;
	 insert attach2;
	 */
		Case ct1 = [SELECT Status FROM Case WHERE Id = :cs1.Id];
		Case ct2 = [SELECT Status FROM Case WHERE Id = :cs2.Id];

		System.assertEquals('In Queue', ct1.Status);
		System.assertEquals('New', ct2.Status);
	}
}