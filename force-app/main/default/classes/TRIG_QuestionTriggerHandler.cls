public with sharing class TRIG_QuestionTriggerHandler extends TriggerHandler
{
	public override void afterUpdate()
	{
		insertCases();
	}
	
	private void insertCases()
	{
		List <Case> casesToInsert = new List <Case>();
		Map <Id, Question> oldMap = (Map <Id, Question>) Trigger.oldMap;
		Set <Id> questionIds = new Set <Id>();

		//Re-query to get fields from relationships
		for (Question question : (List <Question>) Trigger.new)
		{
			questionIds.add(question.Id);
		}

		for (Question question : [SELECT Id, Title, Body, Priority, CommunityId, CreatedById, CreatedBy.AccountId, CreatedBy.ContactId, (SELECT Id FROM Cases) FROM Question WHERE Id IN :questionIds])
		{
			if (question.Priority == 'high' && (question.Cases == null || question.Cases.isEmpty() == true) && oldMap.get(question.Id).Priority != 'high')
			{
				Case caseRecord = new Case();
				caseRecord.AccountId = question.CreatedBy.AccountId;
				caseRecord.ContactId = question.CreatedBy.ContactId;
				caseRecord.Origin = 'Chatter Answers';
				caseRecord.OwnerId = question.CreatedById;
				caseRecord.QuestionId = question.Id;
				caseRecord.CommunityId = question.CommunityId;
				caseRecord.Subject = question.Title;
				caseRecord.Description = question.Body;
				casesToInsert.add(caseRecord);
			}
		}

		if (!casesToInsert.isEmpty())
		{
			List <Database.SaveResult> saveResults = Database.insert(casesToInsert, false);
			LogUtilityException.logSaveResults('TRIG_QuestionTriggerHandler', 'afterUpdate', casesToInsert, saveResults);
			
			List <Messaging.SingleEmailMessage> singleEmailMessages = new List <Messaging.SingleEmailMessage>();
			String siteName = Site.getName();
			List <String> adminEmails = new List <String> { Site.getAdminEmail() };
			
			//Save results are in the same order as the initial cases list - it's the only way to relate the two
			for (Integer index = 0; index < saveResults.size(); index++)
			{
				Database.SaveResult saveResult = saveResults[index];
				
				if (saveResult.isSuccess() == false)
				{
					String errList = '';
					for (Database.Error err : saveResult.getErrors())
					{
						errList = errList + '   ' + err.getMessage();
					}
					String subjectText = 'Case Escalation exception in site ' + siteName;
					String bodyText = 'Case Escalation on Question having ID: ' + casesToInsert[index].QuestionId + ' has failed with the following message: ' + saveResult.getErrors()[0].getMessage() +
							'\n\nStacktrace: ' + errList;

					Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
					mail.setReplyTo('no-reply@salesforce.com');
					mail.setSenderDisplayName('Salesforce Chatter Answers User');

					// The default sender is the portal user causing this trigger to run, to change this, set an organization-wide address for
					// the portal user profile, and set the ID in the following line.
					// mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
					mail.setToAddresses(adminEmails);
					mail.setSubject(subjectText);
					mail.setPlainTextBody(bodyText);
					singleEmailMessages.add(mail);
				}
			}

			if (!singleEmailMessages.isEmpty())
			{
				Messaging.sendEmail(singleEmailMessages);
			}
		}
	}
}