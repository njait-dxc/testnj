global class g_CustomLookupController {
	public List<Contact> contact_results {get;set;} // search results
	public List<Contact> contact_results1{get;set;} // search results for FirstName
	public List<Contact> contact_results2{get;set;} // search results for LastName
	public List<Contact> contact_results3{get;set;} // search results for Email

	public List<Account> account_results {get;set;} // search results
	public List<Lead> lead_results {get;set;} // search results

	public String searchString {get;set;} // search keyword, set either by invoking page or via URI
	public String firstName {get;set;} // set by invoking page
	public String lastName {get;set;} // set by invoking page
	public String email {get;set;} // set by invoking page
	
	public static String ixnId {get;set;} // interaction id, set via URI
	public String inServiceCloudConsole {get;set;} // set in constructor
	
	public g_CustomLookupController() {
		// get the current search string
		searchString = System.currentPageReference().getParameters().get('lksrch');
		ixnId = System.currentPageReference().getParameters().get('ixnId');
		inServiceCloudConsole = System.currentPageReference().getParameters().get('inServiceCloudConsole');
		System.debug('*** CustomLookupController ixnId ' + ixnId);
		System.debug('*** CustomLookupController inServiceCloudConsole '+inServiceCloudConsole);
		System.debug('*** CustomLookupController search for '+searchString);
		
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
		/*
		String soql = 'select id, name from contact';
		if (searchString != '' && searchString != null) {
			//soql = soql +  ' where name LIKE \'%' + searchString +'%\'';
			soql = soql +  ' where phone LIKE \'%' + searchString +'%\'';      
		}
		soql = soql + ' limit 25';
		System.debug(soql);
		return database.query(soql);
		*/
		List<List<SObject>> objs = null;
		contact_results = new List<Contact>();
		contact_results1 = null;
		contact_results2 = null;
		contact_results3 = null;
		Integer listSize = 0;
		
		System.debug('*** firstName = ' + firstName);
		System.debug('*** lastName = ' + lastName);
		System.debug('*** email = ' + email);

		if (searchString != null && searchString != '') {
			objs = [FIND :searchString IN PHONE FIELDS RETURNING Contact(Account.Name, Id,
					Name, FirstName, LastName, 
					MailingStreet, 
					EMail, 
					Phone, MobilePhone, HomePhone, AssistantPhone, OtherPhone)];
			listSize = objs.size();
			System.debug('*** contact listSize = ' + listSize);
			List<Contact> contacts = null;
			if (!objs.isEmpty()) {
				contact_results.addAll((List<Contact>) objs[0]);
			}
		} 
		System.debug('*** contact_results= ' + contact_results);
		
		try {
			if (firstName != null && firstName != '') {
				String term = '%' + firstName + '%';
				List<Contact> contact_results1 = [SELECT  Account.Name, Id,
						Name, FirstName, LastName, 
						MailingStreet, 
						Email,
						Phone, MobilePhone, HomePhone, AssistantPhone, OtherPhone 
						FROM Contact WHERE FirstName LIKE :term];
				System.debug('*** contact listSize1 = ' + contact_results1.size());
				System.debug('*** contact_results1 = ' + contact_results1);
				contact_results.addAll(contact_results1);
			}

			if (lastName != null && lastName != '') {
				String term = '%' + lastName + '%';
				List<Contact> contact_results2 = [SELECT Account.Name, Id,
						Name, FirstName, LastName, 
						MailingStreet, 
						Email,
						Phone, MobilePhone, HomePhone, AssistantPhone, OtherPhone 
						FROM Contact WHERE LastName LIKE :term];
				System.debug('*** contact listSize2 = ' + contact_results2.size());
				System.debug('*** contact_results2 = ' + contact_results2);
				contact_results.addAll(contact_results2);
			} 
			
			if (email != null && email != '') {
				String term = '%' + email + '%';
				List<Contact> contact_results3 = [SELECT Account.Name, Id,
						Name, FirstName, LastName, 
						MailingStreet, 
						Email,
						Phone, MobilePhone, HomePhone, AssistantPhone, OtherPhone 
						FROM Contact WHERE Email LIKE :term];
				System.debug('*** contact listSize3 = ' + contact_results3.size());
				System.debug('*** contact_results3 = ' + contact_results3);
				contact_results.addAll(contact_results3);
			}         
			System.debug('*** TOTAL contact_results= ' + contact_results);

			/*
			// Use default sorting
			if (contact_results.size() != 0) {
				Set<Contact> myset = new Set<Contact>();
				List<Contact> myresult = new List<Contact>();
				//this removes the duplicates since list is not allowed dups
				myset.addAll(contact_results);
				myresult.addAll(myset);
				contact_results = myresult;
				contact_results.sort();
			}
			*/

			// Use custom sorting
			if (contact_results.size() != 0) {
				Set<Contact> myset = new Set<Contact>();
				List<g_ContactWrapper> myresult = new List<g_ContactWrapper>();
				//this removes the duplicates since list is not allowed dups
				myset.addAll(contact_results);
				for (Contact c : myset) {
					myresult.add(new g_ContactWrapper(c));
				}
				myresult.sort();

				contact_results.clear();
				for (g_ContactWrapper g_c : myresult) {
					contact_results.add(g_c.getContact());
				}
			}
		}
		catch (QueryException e) {
			System.debug('*** ERROR = ' + e);
		}
		
		if (searchString != null && searchString != '') {
			objs = [FIND :searchString IN PHONE FIELDS RETURNING Account(Id, Name, Phone)];

			listSize = objs.size();
			System.debug('*** account listSize = ' + listSize);
			List<Account> accounts = null;
			if (!objs.isEmpty()) {
				account_results = ((List<Account>)objs[0]);
			}
		}
		System.debug('*** contact_results = ' + contact_results);
    
		if (searchString != null && searchString != '') { 
			//Error "field not recognized" when using Address in query   
			objs = [FIND :searchString IN PHONE FIELDS RETURNING Lead(Id, ConvertedAccountId, 
					Name, Street, FirstName, LastName, Email, Phone, MobilePhone)];
			listSize = objs.size();
			System.debug('*** lead listSize = ' + listSize);
			List<Lead> leads = null;
			if (!objs.isEmpty()) {
				lead_results = ((List<Lead>)objs[0]);
			}
		}
		System.debug('*** lead_results = ' + lead_results);
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