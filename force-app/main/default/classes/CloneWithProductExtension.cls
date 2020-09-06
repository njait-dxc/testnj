/**
 * @author
 * @date
 * @description
 */

public inherited sharing class CloneWithProductExtension
{
	public Flow.Interview.Flow_Clone_Opportunity_With_Products flowInterview { get; set; }
	public String recordId { get; set; }
	public CloneWithProductExtension(ApexPages.StandardController controller)
	{
		recordId = controller.getRecord().Id;
	}

	/**
	 * @description
	 * @return
	 */
	public PageReference getFinishLocation()
	{
		String strTemp = 'home/home.jsp';
		if (flowInterview != null) strTemp = String.valueOf(flowInterview.newOppId);
		//system.debug('New opp id:' + flowInterview.newOppId);
		PageReference prRef = null;
		if (UserInfo.getUiThemeDisplayed() == 'Theme4d' || UserInfo.getUiThemeDisplayed() == 'Theme4t' || UserInfo.getUiThemeDisplayed() == 'Theme4u')
		{
			prRef = new PageReference('/lightning/r/Opportunity/' + strTemp + '/view');
		}
		else
		{
			prRef = new PageReference('/' + strTemp);
		}

		prRef.setRedirect(true);
		return prRef;
	}
}