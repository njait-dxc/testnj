/**
 * @author
 * @date
 * @description
 */

public inherited sharing class CMConsultingQuestionExtension
{
	ApexPages.StandardController stdCtrl;
	Opportunity_Product_Question__c question;
	Opportunity optyObject;
	public String optyCurr { get; set; }

	public CMConsultingQuestionExtension(ApexPages.StandardController controller)
	{
		if (!Test.isRunningTest())
		{
			controller.addFields(new List<String>
			{
					'Opportunity__c'
			});
		}
		this.stdCtrl = controller;
		question = (Opportunity_Product_Question__c) stdCtrl.getRecord();
		optyObject = [SELECT CurrencyIsoCode FROM Opportunity WHERE Id = :question.Opportunity__c];
		optyCurr = optyObject.CurrencyIsoCode;
	}

	/**
	 * @description
	 * @return
	 */
	public PageReference saveAndRedirect()
	{
		stdCtrl.save();
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