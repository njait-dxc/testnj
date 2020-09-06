/**
 * @author
 * @date
 * @description
 */

public with sharing class TRIG_DocuSign_Status_TriggerHandler extends TriggerHandler
{
	public override void afterInsert()
	{
		DocuSignStatus((List <dsfs__DocuSign_Status__c>) Trigger.new);
	}

	public override void afterUpdate()
	{
		DocuSignStatus((List <dsfs__DocuSign_Status__c>) Trigger.new);
	}

	public static void DocuSignStatus(List<dsfs__DocuSign_Status__c> docuSignList)
	{
		Set <Id> completedOpportunityIds = new Set <Id>();
		Set <Id> declinedOpportunityIds = new Set <Id>();
		List<Opportunity> vOppsToUpdate = new List<Opportunity>();

		for (dsfs__DocuSign_Status__c dsrs : docuSignList)
		{
			if (dsrs.dsfs__Envelope_Status__c == 'Completed')
			{
				completedOpportunityIds.add(dsrs.dsfs__Opportunity__c);
			}
			else if (dsrs.dsfs__Envelope_Status__c == 'Declined')
			{
				declinedOpportunityIds.add(dsrs.dsfs__Opportunity__c);
			}
		}

		// Process 'Completed' opportunities
		//List <Opportunity> completedOpportunities = [SELECT Id, Name, AccountId, StageName FROM Opportunity WHERE Id IN :completedOpportunityIds];

		for (Opportunity opportunity : [SELECT Id, Name, AccountId, StageName, RecordType.Name FROM Opportunity WHERE Id IN :completedOpportunityIds])
		{
			if(opportunity.RecordType.Name == 'Client Manager April.2017')
            {
                opportunity.StageName = 'Closed Won';
                opportunity.Client_Sign_Status__c = 'Accepted';
                vOppsToUpdate.add(opportunity);                
            }
			else if(opportunity.RecordType.Name == 'SME Solution Sales Processing')
            {
                opportunity.StageName = 'Released for Provisioning';
                opportunity.Client_Sign_Status__c = 'Accepted';
                vOppsToUpdate.add(opportunity);                
            }            
		}

		//update completedOpportunities;

		// Process 'Declined' opportunities
		//List <Opportunity> declinedOpportunities = [SELECT Id, Name, AccountId, StageName FROM Opportunity WHERE Id IN :declinedOpportunityIds];

		for (Opportunity opportunity : [SELECT Id, Name, AccountId, StageName FROM Opportunity WHERE Id IN :declinedOpportunityIds])
		{
			opportunity.Client_Sign_Status__c = 'Declined';
			vOppsToUpdate.add(opportunity);
		}

		//update declinedOpportunities;
		if (!vOppsToUpdate.isEmpty())
		{
			Database.update(vOppsToUpdate);
		}
	}
}