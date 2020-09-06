@IsTest
private class TEST_TRIG_Question
{
	@IsTest
	private static void validateQuestionEscalation()
	{
		List <Community> communities = [SELECT Id FROM Community LIMIT 1];

		if (communities.isEmpty() == true)
		{
			return;
		}

		String communityId = communities.get(0).Id;
		Question question = new Question();
		question.Title = 'Question Title';
		question.Body = 'Question Body';
		question.CommunityId = communityId;

		insert(question);

		question.Priority = 'high';

		update(question);

		Case caseRecord = [SELECT Origin, CommunityId, Subject, Description FROM Case WHERE QuestionId = :question.Id];

		System.assertEquals('Question Title', caseRecord.Subject);
		System.assertEquals('Question Body', caseRecord.Description);
		System.assertEquals('Chatter Answers', caseRecord.Origin);
		System.assertEquals(communityId, caseRecord.CommunityId);
	}
}