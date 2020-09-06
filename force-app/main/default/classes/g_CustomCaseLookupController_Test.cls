@IsTest

private class g_CustomCaseLookupController_Test {
	static testMethod void searcha_Test() {
		//Create Account test data
		g_CustomCaseLookupController lookup = new g_CustomCaseLookupController();
		Account newACC = new Account(Name = 'testAccount', Phone = '5555'); 
		insert newACC;
		Account acc = [SELECT Id, Name, Phone FROM Account WHERE Phone = '5555']; 
		//Create Contact test data
		Contact newCon = new Contact(FirstName = 'John', LastName = 'Doer', Phone = '4444', MobilePhone = '3333', Email = 'john.doer@somewhere.com');
		newCon.AccountId = acc.Id;  //account id 
		insert newCon; 
		Contact con = [SELECT Id FROM Contact WHERE Phone = '4444'];  
		//Create Case test data
		Case test_case = new Case(Subject = 'test_subject1', AccountId = acc.Id, ContactId = con.Id);
		insert test_case;
		test_case = new Case(Subject = 'test_subject2', AccountId = acc.Id, ContactId = con.Id);
		insert test_case;
		
		Case myCase1 = [SELECT Id, CaseNumber FROM Case WHERE Subject = 'test_subject1'];
		Case myCase2 = [SELECT Id FROM Case WHERE Subject = 'test_subject2'];
				
		lookup.searchString = myCase1.CaseNumber ;
		lookup.subject = test_case.Subject;
		
		PageReference pr = lookup.search();
		
		System.debug('*** results = ' + lookup.case_results.size());
		System.assert(lookup.case_results.size() != 0);
	}  
}