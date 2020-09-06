@IsTest
public class CloneWithProductExtensionTest
{
	static testMethod void testFinishPage()
	{
		Account testAccount = new Account(Name = 'Testing123');
		insert testAccount;
		Contact c = new Contact(FirstName = 'FN', LastName = 'LN', AccountId = testAccount.Id);
		insert c;

		String stdPbId = Test.getStandardPricebookId();
		Id vCMOptyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Client Manager April.2017').getRecordTypeId();

		Opportunity opp = new Opportunity(AccountId = testAccount.Id, Pricebook2Id = stdPbId, Name = 'TestOpp', StageName = 'Prospect',
				CloseDate = Date.newInstance(2070, 10, 10), CurrencyIsoCode = 'AUD', RecordTypeId = vCMOptyRecordTypeId);
		insert opp;

		ApexPages.StandardController std = new ApexPages.StandardController(opp);
		CloneWithProductExtension controllerExt = new CloneWithProductExtension(std);
		PageReference pageRef = Page.CloneWithProducts;
		Test.setCurrentPage(pageRef);

		if (controllerExt.flowInterview != null)
		{
			if (UserInfo.getUiThemeDisplayed() == 'Theme4d' || UserInfo.getUiThemeDisplayed() == 'Theme4t' || UserInfo.getUiThemeDisplayed() == 'Theme4u')
			{
				//prRef = new PageReference('/' + strTemp);
				System.assertEquals(controllerExt.getFinishLocation().getUrl(), '/lightning/r/Opportunity/' + opp.Id + '/view');
			}
			else
			{
				//prRef = new PageReference('/lightning/r/Opportunity/' + strTemp + '/view');
				System.assertEquals(controllerExt.getFinishLocation().getUrl(), '/' + opp.Id);
			}
		}
		else
		{
			System.assertEquals(controllerExt.getFinishLocation().getUrl(), '/home/home.jsp');
		}

	}
}