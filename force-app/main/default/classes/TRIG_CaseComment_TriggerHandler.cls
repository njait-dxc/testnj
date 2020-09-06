public with sharing class TRIG_CaseComment_TriggerHandler extends TriggerHandler
{
	public override void beforeInsert()
	{
		PreventNewCaseComment((List <CaseComment>) Trigger.new);
	}

	public static void PreventNewCaseComment(List <CaseComment> caseComments)
	{
		for (CaseComment caseComment : caseComments)
		{
			caseComment.addError('Because we are retiring Case Comment, please use Chatter to leave new comment. Thank you!');
		}
	}
}