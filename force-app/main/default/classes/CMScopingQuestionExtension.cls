/**
 * @author
 * @date
 * @description
 */

public inherited sharing class CMScopingQuestionExtension
{
	ApexPages.StandardController stdCtrl;
	Opportunity_Scoping_Question__c question;

	public CMScopingQuestionExtension(ApexPages.StandardController controller)
	{
		if (!Test.isRunningTest())
		{
			controller.addFields(new List<String>
			{
					'Opportunity__c'
			});
		}
		this.stdCtrl = controller;
		question = (Opportunity_Scoping_Question__c) stdCtrl.getRecord();
	}

	/**
	 * @description
	 * @return
	 */
	public PageReference saveAndRedirect()
	{
		if (null == stdCtrl.save())
		{
			return null;
		}
		/*try{
			stdCtrl.save();
		}
		catch(system.Exception e){
			ApexPages.Message msg = new apexPages.Message(Apexpages.Severity.ERROR, e.getdmlMessage(0));
			   ApexPages.addMessage(msg);
			return null;
		}*/
		System.debug('opty id:' + question.Opportunity__c);
		PageReference pr = new PageReference('/' + question.Opportunity__c);
		pr.setRedirect(true);
		return pr;
	}

	/**
	 * @description
	 * @return
	 */
	public PageReference cancelAndRedirect()
	{
		stdCtrl.cancel();
		System.debug('opty id:' + question.Opportunity__c);
		PageReference pr = new PageReference('/' + question.Opportunity__c);
		pr.setRedirect(true);
		return pr;
	}
}