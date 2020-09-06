/**
 * @author
 * @date
 * @description
 */

public inherited sharing class CMCreateECCaseExtension
{
	public Flow.Interview.Flow_Client_Manager_EC_Case_Process_New flowInterview { get; set; }
	public String recordId { get; set; }
	public CMCreateECCaseExtension(ApexPages.StandardController controller)
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
		if (flowInterview != null)
		{
			strTemp = String.valueOf(flowInterview.CaseId);
		}
		PageReference prRef = new PageReference('/' + strTemp);
		prRef.setRedirect(true);
		return prRef;
	}
}