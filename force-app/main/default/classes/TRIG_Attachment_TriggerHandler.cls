public with sharing class TRIG_Attachment_TriggerHandler extends TriggerHandler
{
	public override void afterInsert()
	{
		handleCaseStatus((List<Attachment>) Trigger.new);
	}

	public static void handleCaseStatus(List <Attachment> attachments)
	{
		Set <Id> caseIds = new Set <Id>();

		for (Attachment attachment : attachments)
		{
			String attachmentId = attachment.ParentId;

			if (attachmentId.left(3) == '500')
			{
				caseIds.add(attachmentId);
			}
		}

		if (caseIds.isEmpty() == false)
		{
			List <Case> cases = [SELECT Id, Status FROM Case WHERE Id IN :caseIds AND Status = 'New' AND Primary_Category__c = 'Administrative Request' AND Categ__c = 'Technical Services Request' AND Sub_Category__c = 'IT Assessment'];

			for (Case caseObject : cases)
			{
				caseObject.Status = 'Response Received';
			}
			
			try
			{
				/*List <Database.SaveResult> updateCaseToHandleResults = */Database.update(cases, true);
			}
			catch(Exception e)
			{
				LogUtilityException.throwException('TRIG_Attachment_TriggerHandler', 'handleCaseStatus', e, cases);
			}  
		}
	}
}