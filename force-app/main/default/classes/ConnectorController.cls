global class ConnectorController {

	/**
	 * The main search request to find a contact/account/whatever etc
	 **/
	@RemoteAction global static Object findContact(String searchId, String searchValue, Map<String, String> userData) {
		System.debug('findContact: searchId - ' + searchId +', searchValue - ' + searchValue);

		try {
			String query = 'SELECT Id, Name, AccountId FROM Contact WHERE ' + searchId  + ' = \'' + searchValue + '\'';
			System.debug('query = ' + query);
			List<Contact> contacts = Database.query(query);

			if (!contacts.isEmpty()) {
				Integer numContacts = contacts.size();
				System.debug('contacts found=' + numContacts);

				if (numContacts > 1) {
					Contact c = contacts[0];
					c.Id = null; // indicator for multiple contacts
					return c;
				}
				else if (numContacts == 1) {
					return contacts[0];
				}
			}
		}
		catch (QueryException e) {
			System.debug('QueryException ' + e);
			LogUtilityException.logException('ConnectorController', 'findContact', e, null, false);
		}

		try {
			// throw in an account search if we've found nothing while we're here
			String query = 'SELECT Id, Name FROM Account WHERE ' + searchId  + ' = \'' + searchValue + '\'';
			List<Account> accounts = Database.query(query);

			if (!accounts.isEmpty()) {
				Integer numAccounts = accounts.size();
				System.debug('accounts found=' + numAccounts);

				if (numAccounts > 1) {
					Account c = accounts[0];
					c.Id = null; // indicator for multiple accounts
					return c;
				}
				else if (numAccounts == 1) {
					return accounts[0];
				}
			}
		}
		catch (QueryException e) {
			System.debug('QueryException ' + e);
			LogUtilityException.logException('ConnectorController', 'findContact', e, null, false);
		}

		try {
			// and lead as well
			String query = 'SELECT Id, Name FROM Lead WHERE ' + searchId  + ' = \'' + searchValue + '\'';
			List<Lead> leads = Database.query(query);

			if (!leads.isEmpty()) {
				Integer numLeads = leads.size();
				System.debug('leads found=' + numLeads);

				if (numLeads > 1) {
					Lead c = leads[0];
					c.Id = null; // indicator for multiple leads
					return c;
				}
				else if (numLeads == 1) {
					return leads[0];
				}
			}
		}
		catch (QueryException e) {
			System.debug('QueryException ' + e);
			LogUtilityException.logException('ConnectorController', 'findContact', e, null, false);
		}

		return null;
	}

	/**
	 * Comes from the search contact/case screens
	 **/
	@RemoteAction global static Object getContact(String contactId, String field) {
		System.debug('getContact: contactId - ' + contactId);
		if (field != null) {
			field = ', ' + field;
		}
		else {
			field = '';
		}

		try {
			String query = 'SELECT Id, Name, AccountId' + field + ' FROM Contact WHERE Id= :contactId';
			System.debug('query = ' + query);
			List<Contact> contacts = Database.query(query);
			if (!contacts.isEmpty()) {
				return contacts[0];
			}
		}
		catch (QueryException e) {
			System.debug('QueryException ' + e);
			LogUtilityException.logException('ConnectorController', 'getContact', e, null, false);
		}

		try {
			String query = 'SELECT Id, Name' + field + ' FROM Account WHERE Id= :contactId';
			System.debug('query = ' + query);
			List<Account> accounts = Database.query(query);
			if (!accounts.isEmpty()) {
				return accounts[0];
			}
		}
		catch (QueryException e) {
			System.debug('QueryException ' + e);
			LogUtilityException.logException('ConnectorController', 'getContact', e, null, false);
		}

		try {
			String query = 'SELECT Id, Name' + field + ' FROM Lead WHERE Id= :contactId';
			System.debug('query = ' + query);
			List<Lead> leads = Database.query(query);
			if (!leads.isEmpty()) {
				return leads[0];
			}
		}
		catch (QueryException e) {
			System.debug('QueryException ' + e);
			LogUtilityException.logException('ConnectorController', 'getContact', e, null, false);
		}

		return null;
	}

	/**
	 * Used by click to dial on a task to work out the contact id
	 **/
	@RemoteAction global static Task getContactByTask(String taskId) {
		System.debug('getContactByTask: taskId - ' + taskId);

		Task task = [SELECT WhoId, WhatId FROM Task WHERE Id= :taskId];
		System.debug('contact id = '  + task.WhoId);

		// see if this task has an associated case
		List<Case> cases = [SELECT CaseNumber FROM Case WHERE Id= :task.WhatId];

		if (!cases.isEmpty()) {
			// return the case number in the call object field
			task.CallObject = cases[0].CaseNumber;
		}

		return task;
	}

	@RemoteAction global static Task createTask(String ixnId,
			String contactId,
			String whatId,
			String subject,
			Map<String, String> userData,
			Map<String, String> taskMap) {
		System.debug('createTask: ' + contactId);

		// check to see if this is an account and not a contact
		String accountPrefix = Schema.SObjectType.Account.getKeyPrefix();
		if (contactId != null) {
			String prefix = contactId.substring(0, 3);
			if (prefix == accountPrefix) {
				// see if the 'what' needs to be an account
				String casePrefix = Schema.SObjectType.Case.getKeyPrefix();
				if (whatId == null || whatId.substring(0, 3) != casePrefix) {
					whatId = contactId;
				}

				contactId = null;
			}
		}

		Task task = new Task (
				Status = 'In Progress',
				Subject = subject,
				WhoId = contactId,
				WhatId = whatId,
				CallObject = ixnId,
				TaskSubtype = 'Call',
				Type= 'Call',
				ActivityDate = Date.today()
		);

		if (taskMap != null) {
			for (String sfdcField : taskMap.keySet()) {
				String val = taskMap.get(sfdcField);
				System.debug(sfdcField + ':' + val);
				try {
					task.put(sfdcField, val);
				}
				catch (Exception te){
					System.debug('is integer?');
					task.put(sfdcField, Integer.valueOf(val));
				}
			}
		}

		//insert task;
		try
		{
			Database.SaveResult insertTaskResult = Database.insert(task, true);
		}
		catch(Exception e){
			LogUtilityException.throwException('ConnectorController', 'createTask', e, new List<Task>{task});
		}

		return task;
	}

	/**
	 * Called if a task is created first -> contact found -> task updated
	 */
	@RemoteAction global static Task updateTaskDetails(Id taskId,
			String contactId,
			String whatId) {
		System.debug('updateTaskDetails: ' + contactId);

		Task[] tasks = null;
		Task task = null;

		if (taskId != null) {
			tasks = [SELECT Id, Description FROM Task WHERE Id= :taskId];
		}

		if (tasks == null || tasks.size() == 0) { // created yet?
			System.debug('updateTaskDetails: task does not exist');
			return null;
		}
		else {
			task = tasks[0];
		}

		// check to see if this is an account and not a contact
		String accountPrefix = Schema.SObjectType.Account.getKeyPrefix();
		if (contactId != null) {
			String prefix = contactId.substring(0, 3);
			if (prefix == accountPrefix) {
				// see if the 'what' needs to be an account
				String casePrefix = Schema.SObjectType.Case.getKeyPrefix();
				if (whatId == null || whatId.substring(0, 3) != casePrefix) {
					whatId = contactId;
				}

				contactId = null;
			}
		}

		task.put('WhoId', contactId);
		task.put('WhatId', whatId);
		//update task;


		try
		{
			Database.SaveResult updateTaskResult = Database.update(task, true);
		}
		catch(Exception e){
			LogUtilityException.throwException('ConnectorController', 'updateTaskDetails', e,new List<Task>{task});
		}
		System.debug('Task id = '  + task.Id);

		return task;
	}

	/**
	 * Called when ixn attached data changes and task can update dynamically
	 */
	@RemoteAction global static Task updateTask(Id taskId,
			Map<String, String> userData,
			Map<String, String> taskMap) {
		System.debug('updateTask: ' + taskId);
		Task[] tasks = null;
		Task task = null;

		if (taskId != null) {
			tasks = [SELECT Id, Description FROM Task WHERE Id= :taskId];
		}

		if (tasks == null || tasks.size() == 0) { // created yet?
			System.debug('updateTask: task does not exist');
			return null;
		}
		else {
			task = tasks[0];
		}

		for (String sfdcField : taskMap.keySet()) {
			String val = taskMap.get(sfdcField);
			System.debug(sfdcField + ':' + val);
			try {
				task.put(sfdcField, val);
			}
			catch (Exception te){
				System.debug('is integer?');
				task.put(sfdcField, Integer.valueOf(val));
			}
		}

		//update task;
		try
		{
			Database.SaveResult updateTaskResult = Database.update(task, true);
		}
		catch(Exception e){
			LogUtilityException.throwException('ConnectorController', 'updateTask', e,new List<Task>{task});
		}
		return task;
	}

	@RemoteAction global static Task closeTask(String ixnId,
			String contactId,
			Id taskId,
			Id whatId,
			String subject,
			String comments,
			Map<String, String> userData,
			String dispositionKVP,
			Map<String, String> taskMap,
			Integer callDuration) {
		System.debug('closeTask: ' + taskId);
		Task[] tasks = null;
		Task task = null;

		if (taskId != null) {
			tasks = [SELECT Id, Description FROM Task WHERE Id= :taskId];
		}

		if (tasks == null || tasks.size() == 0) { // created yet?
			task = createTask(ixnId, contactId, whatId, subject, userData, taskMap); // task id is actually the contact id
			if (task == null) {
				System.debug('closeTask: task not created');
				return null;
			}
		}
		else {
			task = tasks[0];
		}

		String disposition = '';
		if (userData != null && userData.containsKey(dispositionKVP)) {
			disposition = userData.get(dispositionKVP);
		}

		task.CallDisposition = disposition;
		task.CallDurationInSeconds = callDuration;
		task.Status = 'Completed';
		task.Subject = subject;

		if (comments != '') {
			if (task.Description == null) {
				task.Description = '';
			}

			task.Description += '\n' + comments;
		}

		for (String sfdcField : taskMap.keySet()) {
			String val = taskMap.get(sfdcField);
			System.debug(sfdcField + ':' + val);
			try {
				task.put(sfdcField, val);
			}
			catch (Exception te){
				System.debug('is integer?');
				task.put(sfdcField, Integer.valueOf(val));
			}
		}

		//update task;


		try
		{
			Database.SaveResult updateTaskResult = Database.update(task, true);
		}
		catch(Exception e){
			LogUtilityException.throwException('ConnectorController', 'closeTask',e,new List<Task>{task});
		}

		return task;
	}

	@RemoteAction global static Case findCase(String caseNumber) {
		System.debug('findCase: ' + caseNumber);
		List<Case> cases = [SELECT CaseNumber, ContactId FROM Case WHERE CaseNumber= :caseNumber];

		if (!cases.isEmpty()) {
			return cases[0];
		}

		return null;
	}

	@RemoteAction global static Case createCase(String contactId, String accountId, String mediaType, String subject, Map<String, String> userData, Map<String, String> caseMap) {
		System.debug('createCase: ' + subject);

		// check to see if this is an account and not a contact
		String accountPrefix = Schema.SObjectType.Account.getKeyPrefix();
		if (contactId != null) {
			String prefix = contactId.substring(0, 3);
			if (prefix == accountPrefix) {
				accountId = contactId;
				contactId = null;
			}
		}

		Case c = new Case (
				ContactId = contactId,
				AccountId = accountId,
				Subject = subject,
				Priority = 'Medium',
				Origin = mediaType
		);

		if (caseMap != null) {
			for (String sfdcField : caseMap.keySet()) {
				System.debug(sfdcField + ':' + caseMap.get(sfdcField));
				c.put(sfdcField, caseMap.get(sfdcField));
			}
		}

		try {
			//insert c;

			Database.SaveResult insertCaseResult = Database.insert(c, false);
			LogUtilityException.logSaveResults('ConnectorController', 'CreateCase',new List<Case> {c}, new List<Database.SaveResult>{insertCaseResult});

			c = [SELECT Id, CaseNumber FROM Case WHERE Id=:c.Id];
		}
		catch (QueryException e) {
			System.debug('QueryException ' + e);
			LogUtilityException.logException('ConnectorController', 'CreateCase', e, null, false);
			return null;

		}

		System.debug('Case id = '  + c.Id);
		return c;
	}

	//The method below is for the support of activating Mark Done and Call Result from Salesforce to Genesys WDE
	@AuraEnabled
	public static SObject getRecord(Id recordId, String fieldsToShow) {
		String objectName = recordId.getSobjectType().getDescribe().getName();
		String soql = 'Select ' + fieldsToShow + '  from ' + objectName + ' where Id = :recordId';
		return Database.query(soql);
	}
}