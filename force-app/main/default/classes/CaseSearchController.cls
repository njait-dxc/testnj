/**
 * @author
 * @date
 * @description
 */

public with sharing class CaseSearchController
{
	public List<Case> case_results { get; set; }
	public String caseNumber { get; set; }
	public String subject { get; set; }
	public String ixnId { get; set; }

	public CaseSearchController()
	{
		caseNumber = System.currentPageReference().getParameters().get('caseNumber');
		subject = System.currentPageReference().getParameters().get('subject');
		ixnId = System.currentPageReference().getParameters().get('id');
		System.debug('ixnId=' + ixnId + ', caseNumber=' + caseNumber);

		if ((caseNumber != '' && caseNumber != null) ||
				(subject != '' && subject != null))
		{
			performSearch();
		}
	}

	/**
	 * @description
	 */
	public void performSearch()
	{
		System.debug('performSearch for ' + caseNumber + ', ' + subject);
		List<List<Case>> objs = null;
		case_results = new List<Case>();

		if (caseNumber != null && caseNumber != '')
		{
			String term = '*' + caseNumber + '*';
			objs = [
					FIND :term
					IN NAME FIELDS
							RETURNING Case(Id,
							Contact.Id, CaseNumber, Subject, Account.Name, Contact.Name, CreatedDate)
			];

			if (!objs.isEmpty())
			{
				case_results.addAll(objs[0]);
			}
		}

		if (subject != null && subject != '')
		{
			String term = '*' + subject + '*';
			objs = [
					FIND :term
					IN NAME FIELDS
							RETURNING Case(Id,
							Contact.Id, CaseNumber, Subject, Account.Name, Contact.Name, CreatedDate)
			];

			if (!objs.isEmpty())
			{
				case_results.addAll((List<Case>) objs[0]);
			}
		}

		System.debug('*** TOTAL case_results= ' + case_results);
	}
}