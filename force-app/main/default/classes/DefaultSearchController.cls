public with sharing class DefaultSearchController {
    public List<Contact> contact_results { get; set; }
    public List<Account> account_results { get; set; }
    public List<Lead> lead_results { get; set; }
    
	public String phoneNumber { get; set; }
	public String name { get; set; }
	public String email { get; set; }
	public String ixnId { get; set; }
	
	public DefaultSearchController() {
		phoneNumber = System.currentPageReference().getParameters().get('phoneNumber');
		name = System.currentPageReference().getParameters().get('name');
		email = System.currentPageReference().getParameters().get('email');
		ixnId = System.currentPageReference().getParameters().get('id');
		System.debug('ixnId=' + ixnId + ', phoneNumber=' + phoneNumber);
		
		if ((phoneNumber != '' && phoneNumber != null) ||
				(name != '' && name != null) ||
				(email != '' && email != null)) {
			performSearch();  
		}
	}
   
	public void performSearch() {
		System.debug('performSearch for ' + phoneNumber + ', ' + name +  ', ' + email);
		List<List<SObject>> objs = null;
		contact_results = new List<Contact>();
		
		if (phoneNumber != null && phoneNumber != '') {
			objs = [FIND :phoneNumber IN PHONE FIELDS RETURNING Contact(Account.Name, Id,
					Name,
					MailingStreet,
					EMail, Phone)];
			if (!objs.isEmpty()) {
				contact_results.addAll((List<Contact>) objs[0]);
			}
		} 
			
		if (name != null && name != '') {
			String term = '*' + name + '*';
			objs = [FIND :term IN NAME FIELDS RETURNING Contact(Account.Name, Id,
					Name,
					MailingStreet,
					EMail, Phone)];
					
			if (!objs.isEmpty()) {
				contact_results.addAll((List<Contact>) objs[0]);
			}
		}

		if (email != null && email != '') {
			String term = '*' + email + '*';
			objs = [FIND :term IN EMAIL FIELDS RETURNING Contact(Account.Name, Id,
					Name,
					MailingStreet, 
					EMail, Phone)];
					
			if (!objs.isEmpty()) {
				contact_results.addAll((List<Contact>) objs[0]);
			}
		}
		
		System.debug('*** TOTAL contact_results= ' + contact_results);
		
		account_results = new List<Account>();
		if (phoneNumber != null && phoneNumber != '') {
			objs = [FIND :phoneNumber IN PHONE FIELDS RETURNING Account(Id,
					Name,
					Phone)];
			if (!objs.isEmpty()) {
				account_results.addAll((List<Account>) objs[0]);
			}
		}
		
		System.debug('*** TOTAL account_results= ' + account_results);
		
		lead_results = new List<Lead>();
		if (phoneNumber != null && phoneNumber != '') {
			objs = [FIND :phoneNumber IN PHONE FIELDS RETURNING Lead(Id,
					Name,
					Address,
					Email, Phone)];
			if (!objs.isEmpty()) {
				lead_results.addAll((List<Lead>) objs[0]);
			}
		}  
		
		System.debug('*** TOTAL lead_results= ' + lead_results);
	}
}