@IsTest
public class CMConsultingQuestionExtensionTest
{
	@IsTest
	static void testExtension()
	{
		Account ac = new Account(Name = 'TestAccount');
		insert ac;

		Id vCMOptyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Client Manager April.2017').getRecordTypeId();

		Opportunity op = new Opportunity (AccountId = ac.Id, Name = 'TestOpty', StageName = 'Open', CloseDate = Date.newInstance(2018, 10, 10), CurrencyIsoCode = 'AUD', RecordTypeId = vCMOptyRecordTypeId);
		insert op;
		Opportunity_Product_Question__c osq = new Opportunity_Product_Question__c(Opportunity__c = op.Id);
		//insert osq;

		Test.startTest();
		PageReference pageRef1 = Page.CMOpportunityProductQuestion;
		Test.setCurrentPage(pageRef1);
		ApexPages.StandardController sc = new ApexPages.StandardController(osq);
		CMConsultingQuestionExtension ec = new CMConsultingQuestionExtension(sc);

		String nextPageSaveRedirect1 = ec.saveAndRedirect().getUrl();
		System.assertEquals('/' + op.Id, nextPageSaveRedirect1);

		PageReference pageRef2 = Page.CMOpportunityProductQuestion;
		Test.setCurrentPage(pageRef2);
		ApexPages.StandardController sc2 = new ApexPages.StandardController(osq);
		CMConsultingQuestionExtension ec2 = new CMConsultingQuestionExtension(sc2);

		String nextPageSaveRedirect2 = ec2.cancelAndRedirect().getUrl();
		System.assertEquals('/' + op.Id, nextPageSaveRedirect2);
		Test.stopTest();
	}
}