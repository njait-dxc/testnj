@IsTest
public class CMCreateECCaseExtensionTest {
	static testMethod void testFinishPage() {
		Account testAccount = new Account(Name = 'Testing123');
		insert testAccount;
		ApexPages.StandardController std = new ApexPages.StandardController(testAccount);
		CMCreateECCaseExtension controllerExt = new CMCreateECCaseExtension(std);
		PageReference pageRef = Page.CMCreateECCase;
		Test.setCurrentPage(pageRef);
		System.assertEquals(controllerExt.getFinishLocation().getUrl(), '/home/home.jsp');
	}
}