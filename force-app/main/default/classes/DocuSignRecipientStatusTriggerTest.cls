/**
 * @author
 * @date
 * @description
 */

@IsTest
public class DocuSignRecipientStatusTriggerTest
{
	@TestSetup
	static void init()
	{
		// create account
		Account account = new Account(Name = 'Acc1', Type = 'Customer', Industry = 'Automotive');
		insert account;
		Id vCMOptyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Client Manager April.2017').getRecordTypeId();
		// create opportunities
		Opportunity opp = new Opportunity(AccountId = account.Id, Name = 'Opp1', StageName = 'Open', CloseDate = Date.newInstance(2017, 10, 10), CurrencyIsoCode = 'AUD', RecordTypeId = vCMOptyRecordTypeId);
		insert opp;
		insert new dsfs__DocuSign_Status__c(dsfs__Opportunity__c = opp.Id);
	}

	@IsTest
	static void testCompleted()
	{
		Opportunity vOpp1 = [SELECT Id FROM Opportunity LIMIT 1];
		dsfs__DocuSign_Status__c vDSS = [SELECT Id FROM dsfs__DocuSign_Status__c WHERE dsfs__Opportunity__c = :vOpp1.Id];

		Test.startTest();
		// create DocuSign Recipient Status
		dsfs__DocuSign_Recipient_Status__c dsrs = new dsfs__DocuSign_Recipient_Status__c(dsfs__Parent_Status_Record__c = vDSS.Id, dsfs__DocuSign_Recipient_Id__c = '1234567890', dsfs__Recipient_Status__c = 'Completed');
		insert dsrs;
		Test.stopTest();

		vOpp1 = [SELECT StageName, Client_Sign_Status__c FROM Opportunity WHERE Id = :vOpp1.Id];
		System.assertEquals('Closed Won', vOpp1.StageName);
	}

	static testMethod void testDeclined()
	{
		Opportunity vOpp1 = [SELECT Id FROM Opportunity LIMIT 1];
		dsfs__DocuSign_Status__c vDSS = [SELECT Id FROM dsfs__DocuSign_Status__c WHERE dsfs__Opportunity__c = :vOpp1.Id];

		Test.startTest();
		// create DocuSign Recipient Status
		dsfs__DocuSign_Recipient_Status__c dsrs = new dsfs__DocuSign_Recipient_Status__c(dsfs__Parent_Status_Record__c = vDSS.Id, dsfs__DocuSign_Recipient_Id__c = '1234567890', dsfs__Recipient_Status__c = 'Declined');
		insert dsrs;
		Test.stopTest();
	}


}