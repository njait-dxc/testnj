/**
 * @author
 * @date
 * @description
 */

@IsTest
public class DocuSignStatusTriggerTest
{
	@TestSetup
	static void init()
	{
		// create account
		Account account = new Account(Name = 'Acc1', Type = 'Customer', Industry = 'Automotive');
		insert account;
		Id vCMOptyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Client Manager April.2017').getRecordTypeId();
		// create opportunity
		Opportunity opp = new Opportunity(AccountId = account.Id, Name = 'Opp1', StageName = 'Prospect', CloseDate = Date.newInstance(2047, 10, 10), CurrencyIsoCode = 'AUD', RecordTypeId = vCMOptyRecordTypeId, Onsite_Consulting__c = 'No');
		insert opp;
		insert new dsfs__DocuSign_Status__c(dsfs__Opportunity__c = opp.Id, dsfs__Envelope_Status__c = 'Sent');
	}

	@IsTest
	static void testAccepted()
	{
		Opportunity vOpp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
		dsfs__DocuSign_Status__c vDSS = [SELECT dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c WHERE dsfs__Opportunity__c = :vOpp.Id];
		vOpp.StageName='Proposal Recommended';
		update vOpp;
		Test.startTest();
		vDSS.dsfs__Envelope_Status__c = 'Completed';
		update vDSS;
		Test.stopTest();

		vOpp = [SELECT StageName, Client_Sign_Status__c FROM Opportunity WHERE Id = :vOpp.Id];
		System.assertEquals('Closed Won', vOpp.StageName);
		System.assertEquals('Accepted', vOpp.Client_Sign_Status__c);
	}

	static testMethod void testDeclined()
	{
		Opportunity vOpp = [SELECT Id FROM Opportunity LIMIT 1];
		dsfs__DocuSign_Status__c vDSS = [SELECT dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c WHERE dsfs__Opportunity__c = :vOpp.Id];

		Test.startTest();
		vDSS.dsfs__Envelope_Status__c = 'Declined';
		update vDSS;
		Test.stopTest();

		vOpp = [SELECT StageName, Client_Sign_Status__c FROM Opportunity WHERE Id = :vOpp.Id];
		System.assertEquals('Declined', vOpp.Client_Sign_Status__c);
	}
}