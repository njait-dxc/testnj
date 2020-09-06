@IsTest

private class g_CustomLookupController_Test {
	
	static testMethod void searcha_Test() {
		g_CustomLookupController lookup = new g_CustomLookupController();
		Contact con1 = new Contact(FirstName = 'John', LastName = 'Doer', Phone = '4444', MobilePhone = '3333');
		insert con1;
		Contact con2 = new Contact(FirstName = 'Pat', LastName = 'Doer', Phone = '1111');
		insert con2;
		Contact con3 = new Contact(FirstName = 'Patty', LastName = 'Ty', Phone = '2222');
		insert con3;
		Contact con4 = new Contact(FirstName = 'Jane', LastName = 'Doer', Email = 'test@gmail.com');
		insert con4;
		lookup.searchString = '4444';
		lookup.firstName = 'Pat';
		lookup.lastName = 'Ty';
		lookup.email = 'test@gmail.com';
		PageReference pr = lookup.search();
		
		System.debug('*** results = ' + lookup.contact_results);
		//System.assert(lookup.contact_results.isEmpty());
		System.assert(lookup.contact_results.size() != 0);
	}  
}