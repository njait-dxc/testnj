/*
	Date		: 24 Nov 2016
	Author		: SMS Management & Technology
	Description : Batch job for associating activities with thier respective
				  partners if in any case the partners arrived after the activities
				  from the loyalty service 
*/
global class LP_RelateActivityToPartnerBatch implements Database.Batchable<SObject>, Database.Stateful{
	
	// Definitions
	global Boolean hasError;
	global Set<String> setPartners;
	global Map<String,String> mapPartners;
	global List<LP_Error_Log__c> lstError;
	global List<Map<String, Object>> jobStatus;

	// Constructor
	global LP_RelateActivityToPartnerBatch(List<Map<String, Object>> jobStatus) {
		this.jobStatus = jobStatus;
		hasError = false;
		mapPartners = new Map<String,String>();
		setPartners = new Set<String>();
    	lstError = new List<LP_Error_Log__c>();
	}
	
	// Start 
	global Database.QueryLocator start(Database.BatchableContext bc) {	
		String Query = 'SELECT Id, LP_Partner_Archie_ID__c, LP_Partner_Name__c, LP_Statement_Only__c, LP_Points_Expiry_Date__c FROM LP_Partner_Activities__c WHERE LP_Partner_Name__c = NULL';
		return Database.getQueryLocator(Query);
	}
	
	// Execute
	global void execute(Database.BatchableContext bc, List<LP_Partner_Activities__c> scope) {
		
		// Create a set of partner archie 
		for(LP_Partner_Activities__c  pA : scope) {
			setPartners.add(pA.LP_Partner_Archie_ID__c);
		}
		
		// Create a map of activities
		for(Account aC : [SELECT Id, Client_ID__c FROM Account WHERE Client_ID__c IN: setPartners]) {
			mapPartners.put(aC.Client_ID__c, aC.Id);
		}
		
		// Map the partner archie id to the related salesforce account id
		for(LP_Partner_Activities__c pA : scope) {	
			if((pA.LP_Partner_Archie_ID__c != null && pA.LP_Statement_Only__c == false) ||
			   (pA.LP_Partner_Archie_ID__c != null && pA.LP_Statement_Only__c == true && pA.LP_Points_Expiry_Date__c < System.today())) {
                   System.debug('pA.LP_Partner_Name__c = '+pA.LP_Partner_Name__c);
				if(mapPartners.containsKey(pA.LP_Partner_Archie_ID__c) && pA.LP_Partner_Name__c ==null ) {
                    try{
                        pA.LP_Partner_Name__c = mapPartners.get(pA.LP_Partner_Archie_ID__c);
                    }catch(Exception e){
                        System.debug(e.getMessage());
                        /*if(e.getMessage().containsIgnoreCase('System.SObjectException: Field is not writeable:')){
                            LP_Partner_Activities__c newChild = pA.clone(false, false);
                            newChild.LP_Partner_Name__c= mapPartners.get(pA.LP_Partner_Archie_ID__c); // insert the new parent here
                            insert newChild;
                            List<Id> idsToPurge = new List<Id>();
                            idsToPurge.add(pA.Id); 
                            delete pA;
                            Database.emptyRecycleBin(idsToPurge);
                        }*/                       
                    }
				}
			}
		}
		
		// Update the record
		List<Database.SaveResult> saveResultActivity = Database.update(scope, false);
		for(Database.SaveResult sr : saveResultActivity) {
			if(!sr.isSuccess()) {
				hasError = true;
				for(Database.Error err : sr.getErrors()) {
					lstError.add(LP_ErrorLogHandler.buildLog('Failure to update activity partner association successfully',err.getMessage(),'LP_RelateActivityToPartnerBatch', '', sr.getId(), String.valueOf(bc.getJobId())));
				}	
			}
		}
		
        // Logging the errors
        if(lstError.size() > 0) {
        	try{
        		List<Database.SaveResult> saveResultErr = Database.insert(lstError, false);
        	} catch(Exception e) {
        		System.debug('+++++++++++ Error logging failed : ' + e);
        	}
        	lstError.clear();
        }
	}
		
	// Finish
    global void finish(Database.BatchableContext bc) {
    	Map<String, Object> jobResponse = new Map<String, Object>();
    	jobResponse.put('id', bc.getJobId());
    	jobResponse.put('name', 'Relate Activity & Partner');
    	jobResponse.put('hasError', hasError);
    	 
    	this.jobStatus.add(jobResponse);
    	
    	LP_BatchUtil.sendEmail(this.jobStatus);    	
	}
}