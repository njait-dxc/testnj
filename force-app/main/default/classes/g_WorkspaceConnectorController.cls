global class g_WorkspaceConnectorController {


	@RemoteAction
	global static Case findCaseFromNumber(String num)
	{
		System.debug('[WSC] findCaseFromNumber using  ' + num);
		try {
			List<Case> cases = [SELECT CaseNumber FROM Case WHERE CaseNumber= :num];
			if(!cases.isEmpty()) {
				// return the first case found (should only be one)
				for (Case c : cases) {
					return c;
				}
			}
		} catch(QueryException e){
			return null;
		}
		return null;
	}



	@RemoteAction
	global static Object findObjectFromANI(String ANI)
	{
		System.debug('*** findObjectFromANIfor '+ANI);
		Integer listSize = 0;
		//List<SObject> objList;
		SObject obj_found = null;
		try{

			List<List<SObject>> aobjects = [FIND :ANI IN PHONE FIELDS RETURNING Account];
			if (!aobjects.isEmpty()){
				List<Account> accounts = ((List<Account>)aobjects[0]);
				listSize = accounts.size();
				System.debug('*** accounts listSize = ' + listSize);
				if(listSize > 1){
					return 'multiple found';
				}
				if(listSize != 0){
					for (List<SObject> objList : aobjects)
					{
						for (SObject aobj : objList)
						{
							obj_found = aobj;
							System.debug('*** findObjectFromANI account = ' + obj_found.Id);
						}
					}
				}
			}


			List<List<SObject>> cobjects = [FIND :ANI IN PHONE FIELDS RETURNING Contact];
			if (!cobjects.isEmpty()){
				List<Contact> contacts= ((List<Contact>)cobjects[0]);
				listSize = contacts.size();
				System.debug('*** contacts listSize = ' + listSize);
				if(listSize > 1){
					return 'multiple found';
				}
				if(listSize == 1 && obj_found != null){
					return 'multiple found';
				}
				if(listSize != 0){
					for (List<SObject> objList : cobjects)
					{
						for (SObject cobj : objList)
						{
							obj_found = cobj;
							System.debug('*** findObjectFromANI contact = ' + obj_found.Id);
						}
					}
				}
			}


			List<List<SObject>> lobjects = [FIND :ANI IN PHONE FIELDS RETURNING Lead];
			if (!lobjects.isEmpty()){
				List<Lead> leads= ((List<Lead>)lobjects[0]);
				listSize = leads.size();
				System.debug('*** leads listSize = ' + listSize);
				if(listSize > 1){
					return 'multiple found';
				}
				if(listSize == 1 && obj_found != null){
					return 'multiple found';
				}
				if(listSize != 0){
					for (List<SObject> objList : lobjects)
					{
						for (SObject lobj : objList)
						{
							obj_found = lobj;
							System.debug('*** findObjectFromANI lead= ' + obj_found.Id);
						}
					}
				}
			}

			if (obj_found != null)
			{
				return obj_found;
			}
			return 'not found';

		}
		catch(QueryException e){
			return 'not found';
		}
	}


	@RemoteAction
	global static Object findContactFromANI(String ANI)
	{
		System.debug('*** findContactFromANI '+ANI);
		try{
			List<List<SObject>> cobjects = [FIND :ANI IN PHONE FIELDS RETURNING Contact];
			Integer listSize = cobjects.size();
			System.debug('*** listSize = ' + listSize);
			if(listSize > 1){
				return 'multiple found'; //not expected
			}
			if (!cobjects.isEmpty()){
				List<Contact> contacts = ((List<Contact>)cobjects[0]);
				listSize = contacts.size();
				System.debug('*** contacts listSize = ' + listSize);
				if(listSize > 1){
					return 'multiple found';
				}
				if(listSize == 0){
					return 'not found';
				}
				for (List<SObject> objList : cobjects)
				{
					for (SObject cobj : objList)
					{
						System.debug('*** findContactFromANI contact = ' + cobj.Id);
						return cobj;
					}
				}
			}
			return null;

		}
		catch(QueryException e){
			return null;
		}
	}

	@RemoteAction
	global static Object findContactFromEmailAddress(String address)
	{
		System.debug('*** findObjectFromEmailAddress' + address);
		try {
			List<Contact> objects = [SELECT Name FROM Contact WHERE Email= :address ];
			Integer listSize = objects.size();
			if(listSize == 1){
				//if (!objects.isEmpty()) {
				for (Contact obj : objects) {
					System.debug('*** findContactFromEmailAddress contact = '+ obj.Name);
					return obj;
				}
			}
			return null;
		}
		catch(QueryException e){
			return null;
		}
	}

	@RemoteAction
	global static Object findContactFromChatAddress(String theName)
	{
		System.debug('*** findObjectFromChatAddress' + theName);
		try {
			List<Contact> objects = [SELECT Name FROM Contact WHERE Name= :theName];
			Integer listSize = objects.size();
			if(listSize == 1){
				//if (!objects.isEmpty()) {
				for (Contact obj : objects) {
					System.debug('*** findObjectFromChatAddresscontact = '+ obj.Name);
					return obj;
				}
			}
			return null;
		}
		catch(QueryException e){
			return null;
		}
	}


	@RemoteAction
	global static Object findContactFromWorkItemAddress(String theName)
	{
		System.debug('*** findContactFromWorkItemAddress' + theName);
		try {
			List<Contact> objects = [SELECT Name FROM Contact WHERE Name= :theName];
			Integer listSize = objects.size();
			if(listSize == 1){
				//if (!objects.isEmpty()) {
				for (Contact obj : objects) {
					System.debug('*** findContactFromWorkItemAddress = '+ obj.Name);
					return obj;
				}
			}
			return null;
		}
		catch(QueryException e){
			return null;
		}
	}


	@RemoteAction
	global static Object findContactFromOpenMediaAddress(String theName)
	{
		System.debug('*** findContactFromOpenMediaAddress' + theName);
		try {
			List<Contact> objects = [SELECT Name FROM Contact WHERE Name= :theName];
			Integer listSize = objects.size();
			if(listSize == 1){
				//if (!objects.isEmpty()) {
				for (Contact obj : objects) {
					System.debug('*** findContactFromOpenMediaAddress = '+ obj.Name);
					return obj;
				}
			}
			return null;
		}
		catch(QueryException e){
			return null;
		}
	}


	@RemoteAction global static String createActivity(Map<String,String> activityMap){
		System.debug('*** createActivity' );
		String result = 'not found';

		String accountPrefix = Schema.SObjectType.Account.getKeyPrefix();
		String contactPrefix = Schema.SObjectType.Contact.getKeyPrefix();
		String leadPrefix = Schema.SObjectType.Lead.getKeyPrefix();
		String casePrefix = Schema.SObjectType.Case.getKeyPrefix();

		System.debug('*** duration = ' + activityMap.get('Call Duration'));
		String callType = activityMap.get('IXN Type');
		String mediaType = activityMap.get('Media Type');
		String d = activityMap.get('DATE');
		System.debug('*** d   '+ d);
		if (d == '0001-01-01 00:00:00')
		{
			d = '';
		}
		String subject = callType + ' ' + mediaType + ' ' + d;
		String objectToUse = '';
		String duration = activityMap.get('Call Duration');
		Integer durationInSecs = Integer.valueOf(duration);

		Datetime startDate=null;
		try{
			startDate = (activityMap.get('StartDate')=='' && activityMap.get('StartDate')==null) ? null : Datetime.valueOf(activityMap.get('StartDate'));
		}catch(Exception e) {
			System.debug(e);
		}
		System.debug('*** start date = ' + startDate);

		Datetime endDate=null;
		try{
			endDate = (activityMap.get('EndDate')=='' && activityMap.get('EndDate')==null) ? null : Datetime.valueOf(activityMap.get('EndDate'));
		}catch(Exception e) {
			System.debug(e);
		}

		System.debug('*** end date = ' + endDate);

		if(activityMap.get('sfdc Object Id')!= ''){
			System.debug('*** createActivity sfdc Object Id = ' + activityMap.get('sfdc Object Id'));
			objectToUse = activityMap.get('sfdc Object Id');
		}
		else {
			//do a search
			String field_value = activityMap.get('fieldValue');
			String field_name = activityMap.get('fieldName');
			Object searchObj = g_WorkspaceConnectorController.findObject(field_name,field_value);
			if(searchObj != null){
				SObject sobj = (SObject) searchObj;
				objectToUse = sobj.Id;
			}
		}
		System.debug('*** createActivity for object ' + objectToUse);

		String prefix = '';
		if (objectToUse != '')
		{
			prefix = objectToUse.substring(0, 3);
		}
		System.debug('*** prefix = '+prefix);


		Task t = new Task (
				Type = 'Call',
				Status = 'Completed',
				Subject = subject,
				CallDurationInSeconds = durationInSecs,
				//PJB Start__c = startDate,  //If we want to use the start of the interaction
				//PJB End__c = endDate,  //If we want to use the end of the interaction
				Description = activityMap.get('Comments'),
				CallDisposition = activityMap.get('Disposition'),
				CallObject = activityMap.get('GenesysId')
		);

		if(prefix == accountPrefix || prefix == casePrefix){
			System.debug('*** create task for account or case');
			t.put('WhatId',objectToUse);
		}
		else{
			t.put('WhoId',objectToUse);
		}

		if(prefix == contactPrefix)
		{
			Contact contact= [SELECT AccountId, Id FROM Contact WHERE Id= :objectToUse];
			System.debug('*** create task for contact');
			t.put('WhatId',contact.AccountId);
		}

		String mySFDCfield = '';
		String mySFDCvalue = '';
		if (activityMap.get('SFDC1field') != '' && (activityMap.get('SFDC1field') != null) && activityMap.get('SFDC1value') != '' && activityMap.get('SFDC1value') != null)
		{
			mySFDCfield = activityMap.get('SFDC1field');
			mySFDCvalue = activityMap.get('SFDC1value');
			System.debug('*** mySFDCfield1 ' + mySFDCfield + ' -- ' + mySFDCvalue);
			t.put(mySFDCfield,mySFDCvalue);
		}
		if (activityMap.get('SFDC2field') != '' && (activityMap.get('SFDC2field') != null) && activityMap.get('SFDC2value') != '' && activityMap.get('SFDC2value') != null)
		{
			mySFDCfield = activityMap.get('SFDC2field');
			mySFDCvalue = activityMap.get('SFDC2value');
			System.debug('*** mySFDCfield2 ' + mySFDCfield + ' -- ' + mySFDCvalue);
			t.put(mySFDCfield,mySFDCvalue);
		}
		if (activityMap.get('SFDC3field') != '' && (activityMap.get('SFDC3field') != null) && activityMap.get('SFDC3value') != '' && activityMap.get('SFDC3value') != null)
		{
			mySFDCfield = activityMap.get('SFDC3field');
			mySFDCvalue = activityMap.get('SFDC3value');
			System.debug('*** mySFDCfield3 ' + mySFDCfield + ' -- ' + mySFDCvalue);
			t.put(mySFDCfield,mySFDCvalue);
		}
		if (activityMap.get('SFDC4field') != '' && (activityMap.get('SFDC4field') != null) && activityMap.get('SFDC4value') != '' && activityMap.get('SFDC4value') != null)
		{
			mySFDCfield = activityMap.get('SFDC4field');
			mySFDCvalue = activityMap.get('SFDC4value');
			System.debug('*** mySFDCfield4 ' + mySFDCfield + ' -- ' + mySFDCvalue);
			t.put(mySFDCfield,mySFDCvalue);
		}
		if (activityMap.get('SFDC5field') != '' && (activityMap.get('SFDC5field') != null) && activityMap.get('SFDC5value') != '' && activityMap.get('SFDC5value') != null)
		{
			mySFDCfield = activityMap.get('SFDC5field');
			mySFDCvalue = activityMap.get('SFDC5value');
			System.debug('*** mySFDCfield5 ' + mySFDCfield + ' -- ' + mySFDCvalue);
			t.put(mySFDCfield,mySFDCvalue);
		}

		try{
			insert t;
		}
		catch(QueryException e){
			return result;
		}
		System.debug('*** Task id = '  +t.Id);
		result = t.Id;
		return result;
	}
/*
    @RemoteAction global static String createActivity(Map<String,String> activityMap){
        system.debug('*** createActivity' );
        String result = 'not found';
                        
        String accountPrefix = Schema.SObjectType.Account.getKeyPrefix();
        String contactPrefix = Schema.SObjectType.Contact.getKeyPrefix();
        String leadPrefix = Schema.SObjectType.Lead.getKeyPrefix(); 
        String casePrefix = Schema.SObjectType.Case.getKeyPrefix(); 
        
        String ANI = activityMap.get('ANI');
        String lookupSource = activityMap.get('LOOKUP');
        system.debug('*** createActivity for '+lookupSource + ' - ANI = '+ANI);
        system.debug('*** duration = ' + activityMap.get('Call Duration'));
        String callType = activityMap.get('IXN Type');
        String mediaType = activityMap.get('Media Type');
        String d = activityMap.get('DATE');
        system.debug('*** d   '+ d);
        if(d == '0001-01-01 00:00:00')
        	d = '';
        String subject = callType + ' ' + mediaType + ' ' + d; 
        String objectToUse = '';
        String duration = activityMap.get('Call Duration');
        Integer durationInSecs = Integer.valueOf(duration);
                
        DateTime startDate=null;
        try{
        	startDate = (activityMap.get('StartDate')=='' && activityMap.get('StartDate')==null) ? null : dateTime.valueOf(activityMap.get('StartDate'));
        }catch(Exception e) {
        	system.debug(e); 
        }
        system.debug('*** start date = ' + startDate);

        DateTime endDate=null;
        try{
        	endDate = (activityMap.get('EndDate')=='' && activityMap.get('EndDate')==null) ? null : dateTime.valueOf(activityMap.get('EndDate'));
        }catch(Exception e) {
        	system.debug(e); 
        }
        
        system.debug('*** end date = ' + endDate);
        
        if(activityMap.get('sfdc Object Id')!= ''){
                system.debug('*** createActivity sfdc Object Id = ' + activityMap.get('sfdc Object Id'));
                objectToUse = activityMap.get('sfdc Object Id');
        }

        if(objectToUse == ''){
           object objectFromLookup;

            if(callType == 'Email')
            {
                objectFromLookup = findContactFromEmailAddress(lookupSource);
            }
            else if(callType == 'Chat')
            {
                objectFromLookup = findContactFromChatAddress(lookupSource);
            }
            else if(callType == 'InteractionWorkItem')
            {    
                objectFromLookup = findContactFromWorkItemAddress(lookupSource);
            }
            else if(callType == 'OpenMedia')
            {
                objectFromLookup = findContactFromOpenMediaAddress(lookupSource);
            }
            else
            {
                //objectFromLookup = findContactFromANI(lookupSource);
                objectFromLookup = findObjectFromANI(lookupSource);
            }


          if(objectFromLookup != null && objectFromLookup != 'not found' && objectFromLookup != 'multiple found'){
          	        sObject s = (Sobject) objectFromLookup;
                	String objectId = s.Id;
                	String objectIdPrefix = String.valueOf(objectId).substring(0,3);
                	if(contactPrefix == objectIdPrefix){
	                    Contact c = (Contact)objectFromLookup;
	                    if(c != null){
	                        system.debug('*** createActivity c Id = ' + c.Id);
	                        objectToUse = c.Id;
	                    }
                	}
                	if(accountPrefix == objectIdPrefix){
	                    Account a = (Account)objectFromLookup;
	                    if(a != null){
	                        system.debug('*** createActivity a Id = ' + a.Id);
	                        objectToUse = a.Id;
	                    }
                	}   
                	if(leadPrefix == objectIdPrefix){
	                    Lead l = (Lead)objectFromLookup;
	                    if(l != null){
	                        system.debug('*** createActivity l Id = ' + l.Id);
	                        objectToUse = l.Id;
	                    }
                	}                    
          }

        }
        
        system.debug('*** createActivity for object ' + objectToUse);      
        
        String prefix = '';
        if(objectToUse != '')
            prefix = objectToUse.substring(0, 3);
        system.debug('*** prefix = '+prefix);
          

        Task t = new Task (
          Type = 'Call',
          Status = 'Completed',
          Subject = subject,
          CallDurationInSeconds = durationInSecs,            
          //Interaction_Type__c = callType,
          //PJB Start__c = startDate,  //If we want to use the start of the interaction
          //PJB End__c = endDate,  //If we want to use the end of the interaction
          Description = activityMap.get('Comments'),
          CallDisposition = activityMap.get('Disposition'),
          CallObject = activityMap.get('GenesysId')
        );          
        
        if(prefix == accountPrefix || prefix == casePrefix){
          system.debug('*** create task for account or case');
          t.put('WhatId',objectToUse);
        }
        else{
          t.put('WhoId',objectToUse);
        }
              
        if(prefix == contactPrefix)
        {
          Contact contact= [SELECT AccountId, Id FROM Contact WHERE Id= :objectToUse];
          system.debug('*** create task for contact');
          t.put('WhatId',contact.AccountId); 
        }
                           
        String mySFDCfield = '';
        String mySFDCvalue = '';
        if (activityMap.get('SFDC1field') != '' && (activityMap.get('SFDC1field') != null) && activityMap.get('SFDC1value') != '' && activityMap.get('SFDC1value') != null)
        {
            mySFDCfield = activityMap.get('SFDC1field');
            mySFDCvalue = activityMap.get('SFDC1value');
            system.debug('*** mySFDCfield1 ' + mySFDCfield + ' -- ' + mySFDCvalue);
            t.put(mySFDCfield,mySFDCvalue);
        }
        if (activityMap.get('SFDC2field') != '' && (activityMap.get('SFDC2field') != null) && activityMap.get('SFDC2value') != '' && activityMap.get('SFDC2value') != null)
        {
            mySFDCfield = activityMap.get('SFDC2field');
            mySFDCvalue = activityMap.get('SFDC2value');
            system.debug('*** mySFDCfield2 ' + mySFDCfield + ' -- ' + mySFDCvalue);
            t.put(mySFDCfield,mySFDCvalue);
        }
        if (activityMap.get('SFDC3field') != '' && (activityMap.get('SFDC3field') != null) && activityMap.get('SFDC3value') != '' && activityMap.get('SFDC3value') != null)
        {
            mySFDCfield = activityMap.get('SFDC3field');
            mySFDCvalue = activityMap.get('SFDC3value');
            system.debug('*** mySFDCfield3 ' + mySFDCfield + ' -- ' + mySFDCvalue);
            t.put(mySFDCfield,mySFDCvalue);
        }
        if (activityMap.get('SFDC4field') != '' && (activityMap.get('SFDC4field') != null) && activityMap.get('SFDC4value') != '' && activityMap.get('SFDC4value') != null)
        {
            mySFDCfield = activityMap.get('SFDC4field');
            mySFDCvalue = activityMap.get('SFDC4value');
            system.debug('*** mySFDCfield4 ' + mySFDCfield + ' -- ' + mySFDCvalue);
            t.put(mySFDCfield,mySFDCvalue);
        }
        if (activityMap.get('SFDC5field') != '' && (activityMap.get('SFDC5field') != null) && activityMap.get('SFDC5value') != '' && activityMap.get('SFDC5value') != null)
        {
            mySFDCfield = activityMap.get('SFDC5field');
            mySFDCvalue = activityMap.get('SFDC5value');
            system.debug('*** mySFDCfield5 ' + mySFDCfield + ' -- ' + mySFDCvalue);
            t.put(mySFDCfield,mySFDCvalue);
        }            
            
        try{                        
                insert t;
        }
        catch(QueryException e){
                 return 'not found'; 
        }
        system.debug('*** Task id = '  +t.Id);
        result = t.Id;
        return result;
     }
*/


	@RemoteAction
	global static String createCase(Map<String,String> caseMap)
	{
		System.debug('*** createCase');
		String result = 'case not created';
		String ixnType = caseMap.get('IXN Type');
		String mediaType = caseMap.get('Media Type');
		String subject = ixnType + ' ' + mediaType + ' ' + caseMap.get('DATE');

		Case c = new Case (
				Subject = subject,
				Priority = 'Medium',
				Origin = ixnType
		);


		try{
			insert c;
		}
		catch(QueryException e){
			return result;
		}
		System.debug('*** Case id = '  +c.Id);
		result = c.Id;
		return result;
	}

	@RemoteAction
	global static String addAttachment(String objectId, String descriptionText, String nameText, String mimeType, Blob attachmentBody, String attachmentId)
	{
		System.debug('*** addAttachment to '+objectId);
		try{

			if(attachmentBody != null) {
				Attachment att = getAttachment(attachmentId);

				String newBody = '';
				if(att.Body != null) {
					newBody = EncodingUtil.base64Encode(att.Body);
				}

				String newAttachmentBody = EncodingUtil.base64Encode(attachmentBody);

				newBody += newAttachmentBody;

				att.Body = EncodingUtil.base64Decode(newBody);
				//att.Body = Blob.valueOf(newBody);

				if(attachmentId == null) {
					System.debug('*** First time through');
					att.Name = nameText;
					att.ParentId = objectId;
				}
				upsert att;
				return att.Id;
			} else {
				return 'error';
			}
		}
		catch(QueryException e){
			System.debug('*** addAttachment error ' + e);
			return 'error';
		}
	}

	private static Attachment getAttachment(String attId) {
		List<Attachment> attachments = [SELECT Id, Body
		FROM Attachment
		WHERE Id =: attId];
		if(attachments.isEmpty()) {
			Attachment a = new Attachment();
			return a;
		} else {
			return attachments[0];
		}
	}


	@RemoteAction
	global static Object findObject(String searchFieldName, String searchFieldValue){
		System.debug('*** findObject: searchFieldName - ' + searchFieldName +', searchFieldValue - ' + searchFieldValue);
		Object result = null;
		if (searchFieldName == '' || searchFieldValue == '')
		{
			return result;
		}
		String query;
		try{

			query = 'SELECT Id, Name, Phone FROM Account WHERE ' + searchFieldName  + ' = \'' + searchFieldValue + '\'';
			System.debug('*** Account query = ' + query);
			List<Account> accounts = Database.query(query);
			if (!accounts.isEmpty()){
				Integer listSize = accounts.size();
				if(listSize > 1){
					return result;
				}
				for (Account a : accounts){
					System.debug('***  Id = ' + a.Id);
					System.debug('***  Name = '+ a.Name);
					System.debug('*** Phone = '+ a.Phone);
					result = a;
				}
			}
		}
		catch(QueryException e){
			System.debug('*** QueryException ' + e);
		}
		//check contact
		try{
			query = 'SELECT Id, Name, Phone FROM Contact WHERE ' + searchFieldName  + ' = \'' + searchFieldValue + '\'';
			System.debug('*** Contact query = ' + query);
			List<Contact> contacts = Database.query(query);
			if (!contacts.isEmpty()){
				Integer listSize = contacts.size();
				if(listSize > 1){
					return result;
				}
				for (Contact c: contacts ){
					System.debug('***  Id = ' + c.Id);
					System.debug('***  Name = '+ c.Name);
					System.debug('*** Phone = '+ c.Phone);
					if(result == null){
						result = c;
					}
					else{
						//multiple found so return null
						return null;
					}
				}
			}
		}
		catch(QueryException e){
			System.debug('*** QueryException ' + e);
		}

		//check lead
		try{
			query = 'SELECT Id, Name, Phone FROM Lead WHERE ' + searchFieldName  + ' = \'' + searchFieldValue + '\'';
			System.debug('*** Contact query = ' + query);
			List<Lead> leads = Database.query(query);
			if (!leads.isEmpty()){
				Integer listSize = leads.size();
				if(listSize > 1){
					return result;
				}
				for (Lead l: leads ){
					System.debug('***  Id = ' + l.Id);
					System.debug('***  Name = '+ l.Name);
					System.debug('*** Phone = '+ l.Phone);
					if(result == null){
						result = l;
					}
					else{
						//multiple found so return null
						return null;
					}
				}
			}
		}
		catch(QueryException e){
			System.debug('*** QueryException ' + e);
		}

		return result;
	}

/*
   @RemoteAction
    global static String findAccount(String searchFieldName, String searchFieldValue){
        system.debug('*** findAccount: searchFieldName - ' + searchFieldName +', searchFieldValue - ' + searchFieldValue);
        try{

           String query = 'SELECT Id, Name, Phone FROM Account WHERE ' + searchFieldName  + ' = \'' + searchFieldValue + '\'';
           system.debug('*** findAccount: query = ' + query);            
           List<Account> accounts = Database.query(query);
           //List<Account> accounts = [SELECT Id, Name, Phone FROM Account WHERE Phone = :searchFieldValue]; 
            if (!accounts.isEmpty()){
                Integer listSize = accounts.size();
                if(listSize > 1){
                    return 'multiple found';
                }
                for (Account a : accounts){
                    system.debug('***  Id = ' + a.Id);
                    system.debug('***  Name = '+ a.Name);
                    system.debug('*** Phone = '+ a.Phone);
                    //return json string id  and full name
                    return '{"id":"' + a.Id + '","name":"' + a.Name + '"}';
                }
            }
        }
        catch(QueryException e){
                return 'QueryException ' + e; 
        }
        //check contact
        String query = 'SELECT Id, Name, Phone FROM Contact WHERE ' + searchFieldName  + ' = \'' + searchFieldValue + '\'';
        system.debug('*** findAccount - contact: query = ' + query);            
        List<Contact> contacts = Database.query(query);
        if (!contacts.isEmpty()){
                Integer listSize = contacts.size();
                if(listSize > 1){
                    return 'multiple found';
                }
                for (Contact c: contacts ){
                    system.debug('***  Id = ' + c.Id);
                    system.debug('***  Name = '+ c.Name);
                    system.debug('*** Phone = '+ c.Phone);
                    //return json string id  and full name
                    return '{"id":"' + c.Id + '","name":"' + c.Name + '"}';
                }
            }
        
        return 'not found';
    }    
*/

	@RemoteAction
	global static String testConnection()
	{
		return 'Active';
	}


}