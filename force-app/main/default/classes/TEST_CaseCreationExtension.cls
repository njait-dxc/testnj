/**
 * @author
 * @date
 * @description
 */

@IsTest
public class TEST_CaseCreationExtension
{
	@IsTest
	static void testCaseCreationExtension()
	{
		Account ac = new Account(Name = 'TestAccount');
		insert ac;
		Contact ct = new Contact (LastName = 'Ln1', FirstName = 'fn1', AccountId = ac.Id);
		insert ct;
		Case cs = new Case (AccountId = ac.Id, ContactId = ct.Id, Primary_Category__c = 'Billing & Finance', Categ__c = 'Cancellations', Serial_Number__c = '1212121', Cancellation_Reason__c = 'Nothing', Cancellation_Reason_Competitor__c = 'Closure of Business', Refund_Required__c = 'No', Description = 'Testing');
		Case cs3 = new Case (AccountId = ac.Id, Primary_Category__c = 'Billing & Finance', Categ__c = 'Cancellations', Serial_Number__c = '1212121', Cancellation_Reason__c = 'Unconsumed Bureau', Refund_Required__c = 'No');

		Blob bodyBlob = Blob.valueOf('Unit Testing Att');
		Attachment att = new Attachment(Name = 'Unit Testing Att', Body = bodyBlob, ParentId = cs.Id);

		Case csError1 = new Case (AccountId = ac.Id, ContactId = ct.Id, Primary_Category__c = 'Billing & Finance', Categ__c = 'Cancellations', Cancellation_Reason__c = 'Unconsumed Bureau', Refund_Required__c = 'No', Subject = '', Description = '');
		Case csError2 = new Case (AccountId = ac.Id, ContactId = ct.Id, Primary_Category__c = 'Administrative Request', Categ__c = 'General Service Request', Sub_Category__c = 'EA Demo File', Subject = null, Description = null);
		Case csError3 = new Case (AccountId = ac.Id, ContactId = ct.Id, Primary_Category__c = 'Billing & Finance', Categ__c = 'Cancellations', Serial_Number__c = '1212121', Cancellation_Reason__c = 'Moving to Competitor', Refund_Required__c = 'No', Cancellation_Reason_Competitor__c = null, Cancellation_Additional_Reason__c = null, Cancellation_Specific_Reason__c = null);
		Case csError4 = new Case (AccountId = ac.Id, ContactId = ct.Id, Primary_Category__c = 'Billing & Finance', Categ__c = 'Credit Note', Clear_Reason_For_the_Credit__c = null);
		Case csError5 = new Case (AccountId = ac.Id, ContactId = ct.Id, Primary_Category__c = 'Sales Processing', Categ__c = 'Practice Solution', Sub_Category__c = null);
		Case csError6 = new Case (AccountId = ac.Id, ContactId = ct.Id, Primary_Category__c = 'Support Escalation', Categ__c = 'Practice Solutions', Sub_Category__c = 'Client Accounting', Called_Support_Before__c = 'No');

		Case csErrorQuoteCreation = new Case (AccountId = ac.Id, ContactId = ct.Id, Primary_Category__c = 'Sales Processing', Categ__c = 'SME Solution', Sub_Category__c = 'Quote Creation', New_Account__c = 'Yes', SubmittedCompany__c = null);

		Case csErrorWholeSales = new Case (AccountId = ac.Id, ContactId = ct.Id, Primary_Category__c = 'Sales Processing', Categ__c = 'SME Solution', Sub_Category__c = 'Wholesale Order', ARL_Basic__c = null);

		Case csErrorBLEssentials = new Case (AccountId = ac.Id, ContactId = ct.Id, Primary_Category__c = 'Onboarding Request', Categ__c = 'BL - Essentials', Sub_Category__c = 'Migration Service', Concie__c = null);

		Case csCCOnboarding = new Case (AccountId = ac.Id, ContactId = ct.Id, Primary_Category__c = 'Partner Program', Categ__c = 'Certified Consultant On Boarding', Sub_Category__c = '', Partner_on_new_Partner_Program__c = null, Has_your_Partner_completed_prework__c = null, Dashboard_Set_Up_10_Files_Linked__c = null);

		Case csTotalValueRequired = new Case (AccountId = ac.Id, ContactId = ct.Id, Primary_Category__c = 'Billing & Finance', Categ__c = 'Cancellation', Sub_Category__c = '', Refund_Required__c = 'Yes', Total_Value__c = null);


		Test.startTest();
		PageReference pageRefError1 = Page.Case_Category_Product_New;
		Test.setCurrentPage(pageRefError1);
		ApexPages.StandardController scError1 = new ApexPages.StandardController(csError1);
		CaseCreationExtension ecError1 = new CaseCreationExtension(scError1);
		ecError1.validateSaveRedirect();
		ApexPages.Message[] pageMessagesError1 = ApexPages.getMessages();
		System.assertNotEquals(0, pageMessagesError1.size());
		ApexPages.getMessages().clear();
		System.debug('apex message pageRefError1:' + ApexPages.getMessages());

		PageReference pageRefError2 = Page.Case_Category_Product_New;
		Test.setCurrentPage(pageRefError2);
		ApexPages.StandardController scError2 = new ApexPages.StandardController(csError2);
		CaseCreationExtension ecError2 = new CaseCreationExtension(scError2);
		ecError2.validateSaveRedirect();
		ApexPages.Message[] pageMessagesError2 = ApexPages.getMessages();
		System.assertNotEquals(0, pageMessagesError2.size());
		ApexPages.getMessages().clear();
		System.debug('apex message pageRefError2:' + ApexPages.getMessages());

		PageReference pageRefError3 = Page.Case_Category_Product_New;
		Test.setCurrentPage(pageRefError3);
		ApexPages.StandardController scError3 = new ApexPages.StandardController(csError3);
		CaseCreationExtension ecError3 = new CaseCreationExtension(scError3);
		ecError3.validateSaveRedirect();
		ApexPages.Message[] pageMessagesError3 = ApexPages.getMessages();
		System.assertNotEquals(0, pageMessagesError3.size());

		PageReference pageRefError4 = Page.Case_Category_Product_New;
		Test.setCurrentPage(pageRefError4);
		ApexPages.StandardController scError4 = new ApexPages.StandardController(csError4);
		CaseCreationExtension ecError4 = new CaseCreationExtension(scError4);
		ecError4.validateSaveRedirect();
		ApexPages.Message[] pageMessagesError4 = ApexPages.getMessages();
		System.assertNotEquals(0, pageMessagesError4.size());

		PageReference pageRefError5 = Page.Case_Category_Product_New;
		Test.setCurrentPage(pageRefError5);
		ApexPages.StandardController scError5 = new ApexPages.StandardController(csError5);
		CaseCreationExtension ecError5 = new CaseCreationExtension(scError5);
		ecError5.validateSaveRedirect();
		ApexPages.Message[] pageMessagesError5 = ApexPages.getMessages();
		System.assertNotEquals(0, pageMessagesError5.size());

		PageReference pageRefError6 = Page.Case_Category_Product_New;
		Test.setCurrentPage(pageRefError6);
		ApexPages.StandardController scError6 = new ApexPages.StandardController(csError6);
		CaseCreationExtension ecError6 = new CaseCreationExtension(scError6);
		ecError6.validateSaveRedirect();
		ApexPages.Message[] pageMessagesError6 = ApexPages.getMessages();
		System.assertNotEquals(0, pageMessagesError6.size());


		PageReference pageRefErrorQuoteCreation = Page.Case_Category_Product_New;
		Test.setCurrentPage(pageRefErrorQuoteCreation);
		ApexPages.StandardController scErrorQuoteCreation = new ApexPages.StandardController(csErrorQuoteCreation);
		CaseCreationExtension ecErrorQuoteCreation = new CaseCreationExtension(scErrorQuoteCreation);
		ecErrorQuoteCreation.validateSaveRedirect();
		ApexPages.Message[] pageMessagesQuoteCreation = ApexPages.getMessages();
		System.assertNotEquals(0, pageMessagesQuoteCreation.size());

		PageReference pageRefErrorWholesales = Page.Case_Category_Product_New;
		Test.setCurrentPage(pageRefErrorWholesales);
		ApexPages.StandardController scErrorWholesale = new ApexPages.StandardController(csErrorWholeSales);
		CaseCreationExtension ecErrorWholesales = new CaseCreationExtension(scErrorWholesale);
		ecErrorWholesales.validateSaveRedirect();
		ApexPages.Message[] pageMessagesWholesales = ApexPages.getMessages();
		System.assertNotEquals(0, pageMessagesWholesales.size());

		PageReference pageRefErrorBLEssentials = Page.Case_Category_Product_New;
		Test.setCurrentPage(pageRefErrorBLEssentials);
		ApexPages.StandardController scErrorBLEssentials = new ApexPages.StandardController(csErrorBLEssentials);
		CaseCreationExtension ecErrorBLEssentials = new CaseCreationExtension(scErrorBLEssentials);
		ecErrorBLEssentials.validateSaveRedirect();
		ApexPages.Message[] pageMessagesErrorBLEssentials = ApexPages.getMessages();
		System.assertNotEquals(0, pageMessagesErrorBLEssentials.size());

		PageReference pageRefErrorCCOnboarding = Page.Case_Category_Product_New;
		Test.setCurrentPage(pageRefErrorCCOnboarding);
		ApexPages.StandardController scErrorCCOnboarding = new ApexPages.StandardController(csCCOnboarding);
		CaseCreationExtension ecErrorOnboarding = new CaseCreationExtension(scErrorCCOnboarding);
		ecErrorOnboarding.validateSaveRedirect();
		ApexPages.Message[] pageMessagesOnboarding = ApexPages.getMessages();
		System.assertNotEquals(0, pageMessagesOnboarding.size());

		PageReference pageRefErrorTotalValueRequired = Page.Case_Category_Product_New;
		Test.setCurrentPage(pageRefErrorTotalValueRequired);
		ApexPages.StandardController scErrorTotalValueRequired = new ApexPages.StandardController(csTotalValueRequired);
		CaseCreationExtension ecErrorTotalValueRequired = new CaseCreationExtension(scErrorTotalValueRequired);
		ecErrorTotalValueRequired.validateSaveRedirect();
		ApexPages.Message[] pageMessagesTotalValueRequired = ApexPages.getMessages();
		System.assertNotEquals(0, pageMessagesTotalValueRequired.size());


		PageReference pageRef1 = Page.Case_Category_Product_New;
		Test.setCurrentPage(pageRef1);
		ApexPages.StandardController sc = new ApexPages.StandardController(cs);
		CaseCreationExtension ec = new CaseCreationExtension(sc);
		Attachment attachment1 = new Attachment();
		attachment1.Body = Blob.valueOf('Testing');
		attachment1.Name = String.valueOf('test.txt');
		ec.newAttachment = attachment1;
		ec.validateSaveRedirect();
		//System.assertNotEquals(0, pageMessages1.size());

		PageReference pageRef11 = Page.Case_Category_Product_New;
		Test.setCurrentPage(pageRef11);
		ApexPages.StandardController sc11 = new ApexPages.StandardController(cs);
		CaseCreationExtension ec11 = new CaseCreationExtension(sc11);
		String nextPageSaveRedirect11 = ec11.validateSaveRedirect().getUrl();
		System.assertEquals('/' + cs.Id, nextPageSaveRedirect11);

		PageReference pageRef2 = Page.Case_Category_Product_New;
		Test.setCurrentPage(pageRef2);
		ApexPages.StandardController sc2 = new ApexPages.StandardController(cs);
		CaseCreationExtension ec2 = new CaseCreationExtension(sc2);
		String nextPageSaveRedirect2 = ec2.cancelRedirect().getUrl();
		System.assertEquals('/' + ct.Id, nextPageSaveRedirect2);

		PageReference pageRef3 = Page.Case_Category_Product_New;
		Test.setCurrentPage(pageRef3);
		ApexPages.StandardController sc3 = new ApexPages.StandardController(cs3);
		CaseCreationExtension ec3 = new CaseCreationExtension(sc3);
		String nextPageSaveRedirect3 = ec3.cancelRedirect().getUrl();
		System.assertEquals('/' + ac.Id, nextPageSaveRedirect3);
		Test.stopTest();
	}

	@IsTest
	static void testValidateSaveRedirectWithCancelledClient()
	{
		Account testAccount = new Account(Name = 'TestAccount', Status__c = 'Cancelled Client');
		insert testAccount;
		Contact testContact = new Contact (LastName = 'Ln1', FirstName = 'fn1', AccountId = testAccount.Id);
		insert testContact;
		Case testCase = new Case (AccountId = testAccount.Id, ContactId = testContact.Id, Primary_Category__c = 'Billing & Finance', Categ__c = 'Cancellations', Serial_Number__c = '1212121', Cancellation_Reason__c = 'Nothing', Cancellation_Reason_Competitor__c = 'Closure of Business', Refund_Required__c = 'No', Description = 'Testing');
		PageReference pageRef = Page.Case_Category_Product_New;
		Test.setCurrentPage(pageRef);
		Test.startTest();
		ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);
		CaseCreationExtension extension = new CaseCreationExtension(stdController);
		extension.validateSaveRedirect();
		Test.stopTest();
		List<ApexPages.Message> pageMessages = ApexPages.getMessages();
		Boolean checkErrorMessage = false;
		for (ApexPages.Message msg : pageMessages)
		{
			if (msg.getDetail().contains('Cannot create new case for Cancelled Client'))
			{
				checkErrorMessage = true;
				break;
			}
		}
		System.assert(checkErrorMessage);
	}

	@IsTest
	static void testDashboardCleanUpCaseSubCategory()
	{
		Account testAccount = new Account(Name = 'TestAccount');
		insert testAccount;
		Contact testContact = new Contact (LastName = 'Ln1', FirstName = 'fn1', AccountId = testAccount.Id);
		insert testContact;
		Case testCase = new Case (AccountId = testAccount.Id, ContactId = testContact.Id, Primary_Category__c = 'Administrative Request',
				Categ__c = 'Technical Services Request', Serial_Number__c = '1212121', Sub_Category__c = 'Dashboard Cleanup or Provisioning',
				Description = 'Testing');
		PageReference pageRef = Page.Case_Category_Product_New;
		Test.setCurrentPage(pageRef);
		Test.startTest();
		ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);
		CaseCreationExtension extension = new CaseCreationExtension(stdController);
		extension.validateSaveRedirect();
		Test.stopTest();
		List<ApexPages.Message> pageMessages = ApexPages.getMessages();
		Boolean checkErrorMessage = false;
		for (ApexPages.Message msg : pageMessages)
		{
			if (msg.getDetail().contains('Field Email Address for Cleanup or Provisioning must be filled in if it is for Dashboard Cleanup or Provisioning.'))
			{
				checkErrorMessage = true;
				break;
			}
		}
		System.assert(checkErrorMessage);
	}

	@IsTest
	static void testOnlineFileRemovalCaseSubCategory()
	{
		Account testAccount = new Account(Name = 'TestAccount');
		insert testAccount;
		Contact testContact = new Contact (LastName = 'Ln1', FirstName = 'fn1', AccountId = testAccount.Id);
		insert testContact;
		Case testCase = new Case (AccountId = testAccount.Id, ContactId = testContact.Id, Primary_Category__c = 'Administrative Request',
				Categ__c = 'Live Services Admin', Serial_Number__c = '1212121', Sub_Category__c = 'Online File Removal',
				Description = 'Testing');
		PageReference pageRef = Page.Case_Category_Product_New;
		Test.setCurrentPage(pageRef);
		Test.startTest();
		ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);
		CaseCreationExtension extension = new CaseCreationExtension(stdController);
		extension.validateSaveRedirect();
		Test.stopTest();
		List<ApexPages.Message> pageMessages = ApexPages.getMessages();
		Boolean checkErrorMessage = false;
		for (ApexPages.Message msg : pageMessages)
		{
			if (msg.getDetail().contains('Field Serial Number must be filled in if it is for Online File Removal'))
			{
				checkErrorMessage = true;
				break;
			}
		}
		System.assert(checkErrorMessage);
	}

	@IsTest
	static void testPracticeMergerCaseSubCategory()
	{
		Account testAccount = new Account(Name = 'TestAccount');
		insert testAccount;
		Contact testContact = new Contact (LastName = 'Ln1', FirstName = 'fn1', AccountId = testAccount.Id);
		insert testContact;
		Case testCase = new Case (AccountId = testAccount.Id, ContactId = testContact.Id, Primary_Category__c = 'Administrative Request',
				Categ__c = 'Account Administration', Serial_Number__c = '1212121', Sub_Category__c = 'Practice Merger',
				Description = 'Testing');
		PageReference pageRef = Page.Case_Category_Product_New;
		Test.setCurrentPage(pageRef);
		Test.startTest();
		ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);
		CaseCreationExtension extension = new CaseCreationExtension(stdController);
		extension.validateSaveRedirect();
		Test.stopTest();
		List<ApexPages.Message> pageMessages = ApexPages.getMessages();
		Boolean checkErrorMessage = false;
		for (ApexPages.Message msg : pageMessages)
		{
			if (msg.getDetail().contains('Fields Most Appropriate Contact to Liaise With, Is the Merge Amicable, Are any technical or consulting services required to be scoped'))
			{
				checkErrorMessage = true;
				break;
			}
		}
		System.assert(checkErrorMessage);
	}

	@IsTest
	static void testPracticeSplitCaseSubCategory()
	{
		Account testAccount = new Account(Name = 'TestAccount');
		insert testAccount;
		Contact testContact = new Contact (LastName = 'Ln1', FirstName = 'fn1', AccountId = testAccount.Id);
		insert testContact;
		Case testCase = new Case (AccountId = testAccount.Id, ContactId = testContact.Id, Primary_Category__c = 'Administrative Request',
				Categ__c = 'Account Administration', Serial_Number__c = '1212121', Sub_Category__c = 'Practice Split',
				Description = 'Testing');
		PageReference pageRef = Page.Case_Category_Product_New;
		Test.setCurrentPage(pageRef);
		Test.startTest();
		ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);
		CaseCreationExtension extension = new CaseCreationExtension(stdController);
		extension.validateSaveRedirect();
		Test.stopTest();
		List<ApexPages.Message> pageMessages = ApexPages.getMessages();
		Boolean checkErrorMessage = false;
		for (ApexPages.Message msg : pageMessages)
		{
			if (msg.getDetail().contains('Fields Most Appropriate Contact to Liaise With, Is the Split Amicable, Are any technical or consulting services required to be scoped, Client IDs and Effective Date of Split must be filled in if it is for Practice Split'))
			{
				checkErrorMessage = true;
				break;
			}
		}
		System.assert(checkErrorMessage);
	}

	@IsTest
	static void testSalesPromotionCaseCategory()
	{
		Account testAccount = new Account(Name = 'TestAccount');
		insert testAccount;
		Contact testContact = new Contact (LastName = 'Ln1', FirstName = 'fn1', AccountId = testAccount.Id);
		insert testContact;
		Case testCase = new Case (AccountId = testAccount.Id, ContactId = testContact.Id, Primary_Category__c = 'Billing & Finance',
				Categ__c = 'Sales Promotion/Agreement Adjustment', Serial_Number__c = '1212121',
				Description = 'Testing');
		PageReference pageRef = Page.Case_Category_Product_New;
		Test.setCurrentPage(pageRef);
		Test.startTest();
		ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);
		CaseCreationExtension extension = new CaseCreationExtension(stdController);
		extension.validateSaveRedirect();
		Test.stopTest();
		List<ApexPages.Message> pageMessages = ApexPages.getMessages();
		Boolean checkErrorMessage = false;
		for (ApexPages.Message msg : pageMessages)
		{
			if (msg.getDetail().contains('Field Whats the Offer That should be Applied must be filled in for Sales Promotion/Agreement Adjustment'))
			{
				checkErrorMessage = true;
				break;
			}
		}
		System.assert(checkErrorMessage);
	}

}