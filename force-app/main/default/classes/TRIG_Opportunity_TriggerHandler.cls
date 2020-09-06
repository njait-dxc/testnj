public with sharing class TRIG_Opportunity_TriggerHandler extends TriggerHandler
{
	private static Boolean PURCHASING_CALLOUT_EXECUTED = false;
	private static final String OPPORTUNITY = 'Opportunity';

    PublishEvents__mdt pbEventOpp = UtilityClass_MYOB.getPublishEventsSetting(OPPORTUNITY);
        
	public override void beforeUpdate()
	{
		requireRejectionComment((List <Opportunity>) Trigger.new, (Map <Id, Opportunity>) Trigger.oldMap);
        runPracticeOpportunityValidation((List <Opportunity>) Trigger.new, (Map <Id, Opportunity>) Trigger.oldMap);
	}
    
    public override void afterInsert(){
        System.debug('Entered this method for event creation on after insert');
        if(pbEventOpp.CreateEvents__c){
		publishOpportunityPlatformEvent( (List< Opportunity >) Trigger.new, null );
        }    
	}

	public override void afterDelete(){
        System.debug('Entered this method for event creation on after delete');
        if(pbEventOpp.CreateEvents__c){
		publishOpportunityPlatformEvent( (List< Opportunity >) Trigger.old, null );
        }    
	}

	public override void afterUndelete(){
        System.debug('Entered this method for event creation on after undelete');
        if(pbEventOpp.CreateEvents__c){
		publishOpportunityPlatformEvent( (List< Opportunity >) Trigger.new, null );
        }    
	}

	public static void requireRejectionComment(List <Opportunity> opportunities, Map <Id, Opportunity> oldMap)
	{
		Map <Id, Opportunity> rejectedOpportunities = new Map <Id, Opportunity>();
		Set<Id> vPurchasingReplaySet = new Set<Id>();

		for (Opportunity opportunity : opportunities)
		{
			Opportunity opportunityOld = oldMap.get(opportunity.Id);

			if (opportunityOld.Approval_Status__c != 'Rejected' && opportunity.Approval_Status__c == 'Rejected')
			{
				rejectedOpportunities.put(opportunity.Id, opportunity);
			}

			if (!opportunityOld.Retry_Purchasing__c && opportunity.Retry_Purchasing__c)
			{
				vPurchasingReplaySet.add(opportunity.Id);
				opportunity.Retry_Purchasing__c = false;
			}
		}

		if (rejectedOpportunities.isEmpty() == false)
		{
			List <Id> processInstanceIds = new List <Id>();

			for (Opportunity opportunity :
			[
					SELECT
					(
							SELECT Id
							FROM ProcessInstances
							ORDER BY CreatedDate DESC
							LIMIT 1
					)
					FROM Opportunity
					WHERE Id IN :rejectedOpportunities.keySet()
			]
			)
			{
				processInstanceIds.add(opportunity.ProcessInstances.get(0).Id);
			}

			// Now that we have the most recent process instances, we can check the most recent process steps for comments.
			for (ProcessInstance processInstance :
			[
					SELECT TargetObjectId,
					(
							SELECT Id, StepStatus, Comments
							FROM Steps
							ORDER BY CreatedDate DESC
							LIMIT 1
					)
					FROM ProcessInstance
					WHERE Id IN :processInstanceIds
					ORDER BY CreatedDate DESC
			])
			{
				String comments = processInstance.Steps.get(0).Comments;
				if ((comments == null || comments.trim().length() == 0))
				{
					rejectedOpportunities.get(processInstance.TargetObjectId).addError('Operation Cancelled: Please provide a rejection reason!');
				}
			}
		}

		if (!vPurchasingReplaySet.isEmpty())
		{
			runPurchaseQueueable(vPurchasingReplaySet);
		}
	}

	public override void afterUpdate()
	{
		if (!PURCHASING_CALLOUT_EXECUTED)
		{
			Map<Id, Opportunity> oldMap = (Map <Id, Opportunity>) Trigger.oldMap;
			Set<Id> vPurchasingSet = new Set<Id>();

			for (Opportunity opp : (List<Opportunity>) Trigger.new)
			{
				List<SME_Solution_Sales_Processing_Metadata__mdt> smeMetadata = [SELECT DeveloperName, MasterLabel
				FROM SME_Solution_Sales_Processing_Metadata__mdt
				WHERE Functionality__c = 'PurchasingAPI' AND oppRecordType__c = :opp.Record_Type_Name__c AND oppType__c = :opp.Type];
				if (opp.StageName == Constants.OPP_FOR_PROVISIONING && opp.StageName != oldMap.get(opp.Id).StageName && smeMetadata.size() > 0)
				{
					vPurchasingSet.add(opp.Id);
				}
			}

			if (!vPurchasingSet.isEmpty())
			{
				runPurchaseQueueable(vPurchasingSet);
				PURCHASING_CALLOUT_EXECUTED = true;
			}
		}
        System.debug('Entered this method for event creation on after update');
		//publishOpportunityPlatformEvent( (List< Opportunity >) Trigger.new, (Map <Id, Opportunity>) Trigger.oldMap );
	}

	/**
	 * @description Run Purchasing queueable
	 * @param pOpps
	 */
	private static void runPurchaseQueueable(Set<Id> pOpps)
	{
		if(pOpps != null && !pOpps.isEmpty())
		{
			System.enqueueJob(new GenericQueueable(pOpps, Constants.API_MODE.PRODUCT_PURCHASING));
		}
	}
    
    private static void runPracticeOpportunityValidation(List <Opportunity> opportunities, Map <Id, Opportunity> oldMap)
    {
		Map <Id, Opportunity> mapClosedWonOpportunities = new Map <Id, Opportunity>();
        Map <Id, Opportunity> mapRequiredECOpportunities = new Map <Id, Opportunity>();
        Map <Id, Case> mapNonClosedECCase = new Map <Id, Case>();
        Map <Id, Case> mapClosedECCase = new Map <Id, Case>();
        Id practiceOptyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Client Manager April.2017').getRecordTypeId();
        
        for (Opportunity opp : opportunities)
		{	
            Opportunity opportunityOld = oldMap.get(opp.Id);
			if (opportunityOld.StageName != 'Closed Won' && opp.StageName == 'Closed Won' && opp.RecordTypeId == practiceOptyRecordTypeId)
			{
                mapClosedWonOpportunities.put(opp.Id, opp);
            }
        } 
        
        if(mapClosedWonOpportunities.IsEmpty() == false)
        {
            
            for(OpportunityLineItem oli : [SELECT Id,OpportunityId From OpportunityLineItem WHERE OpportunityId IN: mapClosedWonOpportunities.KeySet() AND EC_Required__c = true])
            {
                mapRequiredECOpportunities.put(oli.OpportunityId, mapClosedWonOpportunities.get(oli.OpportunityId));
            }
        }
        
        if(mapRequiredECOpportunities.IsEmpty() == false)
        {
            /*for(Case c : [SELECT Opportunity__c FROM Case WHERE Opportunity__c IN:mapRequiredECOpportunities.KeySet() AND Primary_Category__c ='Administrative Request' AND Categ__c = 'Technical Services Request' AND Sub_Category__c = 'IT Assessment' AND Status != 'Closed' AND Subject = 'Client System Environment Check Request'])
            {
                mapNonClosedECCase.Put(c.Opportunity__c, c);
            }*/

            for(Case c : [SELECT Opportunity__c FROM Case WHERE Opportunity__c IN:mapRequiredECOpportunities.KeySet() AND Primary_Category__c ='Administrative Request' AND Categ__c = 'Technical Services Request' AND Sub_Category__c = 'IT Assessment' AND Status = 'Closed' AND Subject = 'Client System Environment Check Request'])
            {
                mapClosedECCase.Put(c.Opportunity__c, c);
            }            
        }
        
        for(Opportunity opp : mapRequiredECOpportunities.values())
        {
			if(!mapClosedECCase.containsKey(opp.Id))
            {
                mapRequiredECOpportunities.get(opp.Id).addError('Opportunity requires closed Environment Check case. Please submit EC case and get it closed prior to closing won the opportunity.');
            }
        }
	}   
	
	/*************************************************************************************************************
    * @Description        : Function to publish opportunity platform event on insert, update, delete, undelete   *
    * @Author             : Nikhil Jaitly                                                                  		 *
    * @Last Modified By   : Nikhil Jaitly                                                                  		 *
    * @Last Modified On   : 15/08/2020                                                                     		 *
    * @Params             : newList,  oldMap                                                              		 * 
    * @Return             : Void                                                                          		 * 
    *************************************************************************************************************/
	public static void publishOpportunityPlatformEvent( List< Opportunity > newList, Map< Id,Opportunity > oldMap ){

		List< Opportunity_Event__e > lstOpptyEvent = new List< Opportunity_Event__e >();

		for( Opportunity opp : newList ){
			if( oldMap == null || ( opp.CloseDate != oldMap.get( opp.Id ).CloseDate || opp.Amount != oldMap.get( opp.Id ).Amount || 
									opp.Main_Contact__c != oldMap.get( opp.Id ).Main_Contact__c || opp.OwnerId != oldMap.get( opp.Id ).OwnerId || 
									opp.AccountId != oldMap.get( opp.Id ).AccountId || opp.StageName != oldMap.get( opp.Id ).StageName || 
									opp.Type != oldMap.get( opp.Id ).Type || opp.RecordTypeId != oldMap.get( opp.Id ).RecordTypeId || 
									opp.Subscription_Serial_Number__c != oldMap.get( opp.Id ).Subscription_Serial_Number__c ) ){
			
				Map< String,String > mapOpptyFieldApiNameToValue = new Map< String,String >();
				
				mapOpptyFieldApiNameToValue.put( 'Id', opp.Id );
				mapOpptyFieldApiNameToValue.put( 'Type', opp.Type );
				mapOpptyFieldApiNameToValue.put( 'Amount', String.valueOf(opp.Amount) );
				mapOpptyFieldApiNameToValue.put( 'OwnerId', opp.OwnerId );
				mapOpptyFieldApiNameToValue.put( 'AccountId', opp.AccountId );
				mapOpptyFieldApiNameToValue.put( 'StageName', opp.StageName );
				mapOpptyFieldApiNameToValue.put( 'CloseDate', String.valueOf(opp.CloseDate) );
				mapOpptyFieldApiNameToValue.put( 'CreatedDate', String.valueOf(opp.CreatedDate) );
				mapOpptyFieldApiNameToValue.put( 'Main_Contact__c', opp.Main_Contact__c );
				mapOpptyFieldApiNameToValue.put( 'RecordTypeId', opp.RecordTypeId );
				mapOpptyFieldApiNameToValue.put( 'LastModifiedDate', String.valueOf(opp.LastModifiedDate) );
				mapOpptyFieldApiNameToValue.put( 'Subscription_Serial_Number__c', opp.Subscription_Serial_Number__c );
				mapOpptyFieldApiNameToValue.put( 'Name', opp.Name );
				mapOpptyFieldApiNameToValue.put( 'Software_Value__c', String.valueOf(opp.Software_Value__c ));
				mapOpptyFieldApiNameToValue.put( 'AMV_Value__c', String.valueOf(opp.AMV_Value__c ));
				mapOpptyFieldApiNameToValue.put( 'Services_Value__c', String.valueOf(opp.Services_Value__c ));
				mapOpptyFieldApiNameToValue.put( 'Total_Weighted_Units__c', String.valueOf(opp.Total_Weighted_Units__c ));
				mapOpptyFieldApiNameToValue.put( 'Number_of_software_user__c', String.valueOf(opp.Number_of_software_user__c ));
				mapOpptyFieldApiNameToValue.put( 'Software_Discounted_Value__c', String.valueOf(opp.Software_Discounted_Value__c ));
				mapOpptyFieldApiNameToValue.put( 'AMV_Discounted_Value__c', String.valueOf(opp.AMV_Discounted_Value__c ));
				mapOpptyFieldApiNameToValue.put( 'Services_Discounted_Value__c', String.valueOf(opp.Services_Discounted_Value__c ));
				mapOpptyFieldApiNameToValue.put( 'Discount_Reason_for_Consulting__c', opp.Discount_Reason_for_Consulting__c );
				mapOpptyFieldApiNameToValue.put( 'Discount_Reasons_for_Software__c', opp.Discount_Reasons_for_Software__c );
				mapOpptyFieldApiNameToValue.put( 'Lost_Reason__c', opp.Lost_Reason__c );
				mapOpptyFieldApiNameToValue.put( 'Pricebook2Id', opp.Pricebook2Id );
				
				System.debug( ' Opportunity Json >>>'+  JSON.serialize( mapOpptyFieldApiNameToValue ) );				

				// Create and publish the event
				Opportunity_Event__e oppEvent = new Opportunity_Event__e();
				oppEvent.Opportunity__c = JSON.serialize( mapOpptyFieldApiNameToValue );
				
				if( Trigger.isInsert ){
					oppEvent.Change_Type__c = 'Create';
				}else if( Trigger.isUpdate ){
					oppEvent.Change_Type__c = 'Update';
				}else if( Trigger.isDelete ){
					oppEvent.Change_Type__c = 'Delete';
				}else{
					oppEvent.Change_Type__c = 'Undelete';
				}
				
				lstOpptyEvent.add( oppEvent );
			}
		}
		System.debug('Entered this method for event creation'+lstOpptyEvent);
		// Call method to publish events
		List<Database.SaveResult> results = EventBus.publish( lstOpptyEvent );
        
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' + err.getStatusCode() +' - ' + err.getMessage());
                }
            }
        }           
	}
}