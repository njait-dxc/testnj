public with sharing class TRIG_DocuSign_Recipient_Status_Handler extends TriggerHandler
{
	public override void beforeUpdate()
	{
		DocuSignRecipientStatus((List <dsfs__DocuSign_Recipient_Status__c >) Trigger.new);// ,(Map<Id,dsfs__DocuSign_Recipient_Status__c >) Trigger.oldMap);
	}

	public override void beforeInsert()
	{
		DocuSignRecipientStatus((List <dsfs__DocuSign_Recipient_Status__c >) Trigger.new);// ,(Map<Id,dsfs__DocuSign_Recipient_Status__c >) Trigger.oldMap);
	}

	public static void DocuSignRecipientStatus(List <dsfs__DocuSign_Recipient_Status__c > docusignRecipientStatuses)
	{
		List <Id> completedIds = new List <Id>();
		List <Id> declinedIds = new List <Id>();

		for (dsfs__DocuSign_Recipient_Status__c docusignRecipientStatus : docusignRecipientStatuses)
		{
			if (docusignRecipientStatus.dsfs__Recipient_Status__c == 'Completed')
			{
				completedIds.add(docusignRecipientStatus.dsfs__Parent_Status_Record__c);
			}
			else if (docusignRecipientStatus.dsfs__Recipient_Status__c == 'Declined')
			{
				declinedIds.add(docusignRecipientStatus.dsfs__Parent_Status_Record__c);
			}
		}

		// Process 'Completed' opportunities
		List <dsfs__DocuSign_Status__c> completedDocusignStatuses = [SELECT Id, dsfs__Opportunity__c FROM dsfs__DocuSign_Status__c WHERE Id IN :completedIds];
		Set <Id> completedOpportunityIds = new Set <Id>();

		for (dsfs__DocuSign_Status__c docusignStatus : completedDocusignStatuses)
		{
			completedOpportunityIds.add(docusignStatus.dsfs__Opportunity__c);
		}

		List <Opportunity> completedOpportunities = [SELECT Id, Name, AccountId, StageName, RecordType.Name FROM Opportunity WHERE Id IN :completedOpportunityIds];

		for (Opportunity opportunity : completedOpportunities)
		{
			opportunity.StageName = 'Closed Won';
			opportunity.Client_Sign_Status__c = 'Accepted';
            
			if(opportunity.RecordType.Name == 'Client Manager April.2017')
            {
                opportunity.StageName = 'Closed Won';
                opportunity.Client_Sign_Status__c = 'Accepted';
                
            }
			else if(opportunity.RecordType.Name == 'SME Solution Sales Processing')
            {
                opportunity.StageName = 'Released for Provisioning';
                opportunity.Client_Sign_Status__c = 'Accepted';               
            }              
		}

		update completedOpportunities;

		// Process 'Declined' opportunities
		List <dsfs__DocuSign_Status__c> declinedDocusignStatuses = [SELECT dsfs__Opportunity__c FROM dsfs__DocuSign_Status__c WHERE Id IN :declinedIds];
		Set <Id> declinedOpportunityIds = new Set <Id>();

		for (dsfs__DocuSign_Status__c docusignStatus : declinedDocusignStatuses)
		{
			declinedOpportunityIds.add(docusignStatus.dsfs__Opportunity__c);
		}

		List <Opportunity> declinedOpportunities = [SELECT Id, Name, AccountId, StageName FROM Opportunity WHERE Id IN :declinedOpportunityIds];

		for (Opportunity opportunity : declinedOpportunities)
		{
			opportunity.Client_Sign_Status__c = 'Declined';
		}

		update declinedOpportunities;
	}
}