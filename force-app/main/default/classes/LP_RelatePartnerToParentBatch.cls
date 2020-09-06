/*
	Date		: 24 Nov 2016
	Author		: SMS Management & Technology
	Description : Batch job for associating partner with thier respective
				  parent partners if in any case the parent arrived after the 
				  child arrived from the loyalty service
*/
global inherited sharing class LP_RelatePartnerToParentBatch implements Database.Batchable<SObject>, Database.Stateful{
	
	// Definition
	global Boolean hasError;
	global Set<String> setParents;
	global Map<String,String> mapParents;
	global List<LP_Error_Log__c> lstError;
	global List<Map<String, Object>> jobStatus;

	// Constructor
	global LP_RelatePartnerToParentBatch() {
		hasError = false;
		mapParents = new Map<String,String>();
		setParents = new Set<String>();
    	lstError = new List<LP_Error_Log__c>();
    	jobStatus = new List<Map<String, Object>>();
	}
	
	// Start 
	global Database.QueryLocator start(Database.BatchableContext bc) {	
		String Query = 'SELECT Id, LP_Parent_Archie_Client_Id__c, ParentId FROM Account WHERE ParentId = NULL AND LP_Parent_Archie_Client_Id__c != NULL';
		return Database.getQueryLocator(Query);
	}
	
	// Execute
	global void execute(Database.BatchableContext bc, List<Account> scope) {
		
		// Create a set of partner archie 
		for(Account  pA : scope) {
			setParents.add(pA.LP_Parent_Archie_Client_Id__c);
		}
		
		// Create a map of partners
		for(Account aC : [SELECT Id, Client_ID__c FROM Account WHERE Client_ID__c IN: setParents]) {
			mapParents.put(aC.Client_ID__c, aC.Id);
		}
		
		// Map the partner archie id to the related salesforce account id
		for(Account aC : scope) {	
			if(aC.LP_Parent_Archie_Client_Id__c != null) {
				if(mapParents.containsKey(aC.LP_Parent_Archie_Client_Id__c)) {
					aC.ParentId = mapParents.get(aC.LP_Parent_Archie_Client_Id__c);
				}
			}
		}
		
		// Update the record
		List<Database.SaveResult> saveResultActivity = Database.update(scope,false);

		LogUtilityException.logSaveResults('LP_RelatePartnerToParentBatch','execute',scope,saveResultActivity);

		for(Database.SaveResult sr : saveResultActivity) {
			if(!sr.isSuccess()) {
				hasError = true;
				for(Database.Error err : sr.getErrors()) {
					lstError.add(LP_ErrorLogHandler.buildLog('Failure to update partner - parent partner association successfully',err.getMessage(),'LP_RelateActivityToPartnerBatch', '', sr.getId(), String.valueOf(bc.getJobId())));
				}	
			}
		}
		
		// Logging the errors
        if(lstError.size() > 0) {
        	try{
        		List<Database.SaveResult> saveResultErr = Database.insert(lstError, false);
				LogUtilityException.logSaveResults('LP_RelatePartnerToParentBatch','execute',lstError,saveResultErr);
        	} catch(Exception e) {
        		System.debug('+++++++++++ Error logging failed : ' + e);		
			LogUtilityException.throwException('LP_RelatePartnerToParentBatch', 'execute', e, lstError);
		}  
        	lstError.clear();
        }
	}
		
	// Finish
    global void finish(Database.BatchableContext bc) {
    	Map<String, Object> jobResponse = new Map<String, Object>();
    	jobResponse.put('id', bc.getJobId());
    	jobResponse.put('name', 'Relate Partner & Parent');
    	jobResponse.put('hasError', hasError);
    	 
    	this.jobStatus.add(jobResponse);
    	
    	Database.executeBatch(new LP_RelateActivityToPartnerBatch(this.jobStatus), 2000);
	}
}