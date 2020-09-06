global class g_CustomCaseLookupController {
	public List<Case> case_results {get;set;} // search results
  
	public String searchString {get;set;} // search keyword, set either by invoking page or via URI
	public static String ixnId {get;set;} // interaction id
	public String caseNumber {get;set;} //set by invoking page
	public String subject {get;set;}    // set by invoking page
	public String createdDate {get;set;}
	public String inServiceCloudConsole {get;set;} // set in constructor
  
	public g_CustomCaseLookupController() {
		// get the current search string
		searchString = System.currentPageReference().getParameters().get('lksrch');
		ixnId = System.currentPageReference().getParameters().get('ixnId');
		inServiceCloudConsole = System.currentPageReference().getParameters().get('inServiceCloudConsole');
		System.debug('*** CustomCaseLookupController ixnId ' + ixnId);
		System.debug('*** CustomCaseLookupController search for ' + searchString);
		  
		if (searchString != '' && searchString != null) {
			runSearch();
		}
	}
	
	
	// performs the keyword search
	global PageReference search() {
		System.debug('*** search');
		runSearch();
		return null;
	}
    
  
	// prepare the query and issue the search command
	private void runSearch() {
		System.debug('*** runSearch');
		performSearch(searchString);         
	} 
  
  
	// run the search and save the records found. 
	private void performSearch(String searchString) {
		System.debug('*** performSearch for ' + searchString);
		
		case_results = new List<Case>();
		Integer listSize = 0;
		System.debug('*** caseNumber = ' + caseNumber);
		System.debug('*** subject = ' + subject);
		System.debug('*** createdDate = ' + createdDate);

		if (searchString != null && searchString != '') {
			List<Case> case_result = [SELECT Id, CaseNumber, Subject, Account.Name, Contact.Name, CreatedDate
					FROM Case WHERE CaseNumber = :searchString];
			case_results.addAll(case_result);

		}
		try {
			if (subject != null && subject != '') {
				String term = '%' + subject + '%';
				List<Case> case_results1 = [SELECT Id, CaseNumber, Subject, Account.Name, Contact.Name, CreatedDate
						FROM Case WHERE Subject LIKE :term];
				System.debug('*** case_results1 size = ' + case_results1.size());
				System.debug('*** case_results1 = ' + case_results1);
				case_results.addAll(case_results1);
			}
		}
		catch (QueryException e) {
			System.debug('*** ERROR = ' + e);
		}
	}
	
	
	// used by the visualforce page to send the link to the right dom element
	public String getFormTag() {
		return System.currentPageReference().getParameters().get('frm');
	}
	  
	// used by the visualforce page to send the link to the right dom element for the text box
	public String getTextBox() {
		return System.currentPageReference().getParameters().get('txt');
	}
}