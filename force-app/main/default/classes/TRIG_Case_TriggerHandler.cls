/**
 * @author
 * @date
 * @description Case Trigger Handler
 */

public with sharing class TRIG_Case_TriggerHandler extends TriggerHandler
{
    
    private static final String CASEEVENT = 'Case';

    PublishEvents__mdt pbEventCase = UtilityClass_MYOB.getPublishEventsSetting(CASEEVENT);

    public TRIG_Case_TriggerHandler()
    {

    }
    public override void afterInsert()
    {
        CaseAssignment((List<Case>) Trigger.new);
        if(pbEventCase.CreateEvents__c){
        publishCasePlatformEvent( (List< Case >) Trigger.new, null );
        }    
    }
    public override void beforeInsert()
    {
        restrictEmail2Case((List<Case>) Trigger.new);
        //if executed by a community guest user, switch the record owner
     /*   if (Site.getSiteId() != null && UserInfo.getUserType()=='Guest')
        {
          for (Case c: (List<Case>) Trigger.new)
          {
              c.OwnerId = Site.getAdminId();
          }
        }*/
    }

    public override void afterUpdate()
    {
        CaseAssignmentForInlineEditing((List<Case>) Trigger.new, (Map<Id, Case>) Trigger.oldMap);
        //publishCasePlatformEvent( (List< Case >) Trigger.old, (Map<Id, Case>) Trigger.oldMap );
    }

    public override void afterDelete(){
        if(pbEventCase.CreateEvents__c){
        publishCasePlatformEvent( (List< Case >) Trigger.old, null );
        }
    }

    public override void afterUndelete(){
        if(pbEventCase.CreateEvents__c){
        publishCasePlatformEvent( (List< Case >) Trigger.new, null );
        }    
    }

    public static void CaseAssignmentForInlineEditing(List<Case> newCaseList, Map<Id, Case> oldMap)
    {
        List<Case> caseList = new List<Case>();
        for (Case caseObj : newCaseList)
        {
            System.debug('start trigger iteraion');
            if (caseObj.IsEscalated == true && caseObj.IsEscalated != oldMap.get(caseObj.Id).IsEscalated)
            {
                caseList.add(new Case(Id = caseObj.Id));
            }
            else if (caseObj.Status != 'Closed' && caseObj.Approval_Status__c == 'Approved' && caseObj.Refund_Required__c == 'Yes' && oldMap.get(caseObj.Id).Approval_Status__c != 'Approved')
            {
                System.debug('Cancellation Case for assignment: ' + caseObj.Id);
                caseList.add(new Case(Id = caseObj.Id));
            }
            else if (caseObj.Status != 'Closed' && caseObj.Approval_Status__c == 'Approved' && (caseObj.Categ__c == 'Credit Note' || caseObj.Categ__c == 'License Reduction' || caseObj.Primary_Category__c == 'Commission') && oldMap.get(caseObj.Id).Approval_Status__c != 'Approved')
            {
                System.debug('Credit Note/License Reduction/Commission Case for assignment: ' + caseObj.Id);
                caseList.add(new Case(Id = caseObj.Id));
            }
            else if (caseObj.Status == 'Response Received' && caseObj.Categ__c == 'Account Administration' && oldMap.get(caseObj.Id).Status != 'Response Received')
            {
                System.debug('Entity Tranfer Response Received: ' + caseObj.Id);
                caseList.add(new Case(Id = caseObj.Id));
            }
        }

        if (caseList.size() != 0)
        {
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            try
            {
                List<Database.SaveResult> caseUpdateResults = Database.update(caseList, dmo);
            } catch (Exception e)
            {
                LogUtilityException.throwException('TRIG_Case_TriggerHandler', 'CaseAssignmentForInlineEditing', e, caseList);
            }

            System.debug('Assigment Finished');


        }

    }


    public static void CaseAssignment(List<Case> newCaseList)
    {
        List<Case> caseList = new List<Case>();
        system.debug('Assigning case');
        for (Case caseObj : newCaseList)
        {
            if (caseObj.Status != 'Closed')
            {
                caseList.add(new Case(Id = caseObj.Id));
            }
        }

        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        try
        {
            Database.update(caseList, dmo);
        } catch (Exception e)
        {
            LogUtilityException.throwException('TRIG_Case_TriggerHandler', 'CaseAssignment', e, caseList);
        }

    }

    private static Set<String> getE2CSupportSetting(String supportSettinngName)
    {
        Support_Setting__mdt supportSetting = [SELECT Value__c FROM Support_Setting__mdt WHERE DeveloperName = :supportSettinngName];
        Set<String> settingValues = new Set<String>();
        settingValues.addAll(supportSetting.Value__c.split(','));
        return settingValues;
    }

    @TestVisible
    private static Set<String> getRestrictedDomainsSwitch
    {
        get
        {
            if(getRestrictedDomainsSwitch == null)
            {
                getRestrictedDomainsSwitch = getE2CSupportSetting('Restricted_E2C_Domains_Switch');
            }
            return getRestrictedDomainsSwitch;
        }
        set;
    }

    public static void restrictEmail2Case(List<Case> listCases)
    {
        Set<String> restrictedE2CDomainsSwitch = getRestrictedDomainsSwitch;
        System.debug('Switch:' + restrictedE2CDomainsSwitch);

        if (restrictedE2CDomainsSwitch.contains('On'))
        {
            Set<String> restrictedE2CDomains = getE2CSupportSetting('Restricted_E2C_Domains');
            System.debug('restricted domains:' + restrictedE2CDomains);

            for (Case newCase : listCases)
            {
                if (newCase.SuppliedEmail != null && newCase.SuppliedEmail.contains('@'))
                {
                    List<String> emailParts = newCase.SuppliedEmail.split('@');
                    if (restrictedE2CDomains.contains(emailParts[1]))
                    {
                        System.debug('restricted email domain identified as' + emailParts[1]);
                        newCase.addError('Creation of cases with these domains are not allowed');
                    }
                }
            }
        }
    }

    /*************************************************************************************************************
    * @Description        : Function to publish Case platform event on insert, update, delete, undelete          *
    * @Author             : Nikhil Jaitly                                                                        *
    * @Last Modified By   : Nikhil Jaitly                                                                        *
    * @Last Modified On   : 15/08/2020                                                                           *
    * @Params             : newList,  oldMap                                                                     * 
    * @Return             : Void                                                                                 * 
    *************************************************************************************************************/
    public static void publishCasePlatformEvent( List< Case > newList, Map< Id,Case > oldMap ){

        List< Case_Event__e > lstCaseEvent = new List< Case_Event__e >();

        for( Case cs : newList ){
            if( oldMap == null || ( cs.CaseNumber != oldMap.get( cs.Id ).CaseNumber || cs.RecordTypeId != oldMap.get( cs.Id ).RecordTypeId || 
                                    cs.OwnerId != oldMap.get( cs.Id ).OwnerId || cs.AccountId != oldMap.get( cs.Id ).AccountId ||
                                    cs.ContactId != oldMap.get( cs.Id ).ContactId || cs.Origin != oldMap.get( cs.Id ).Origin ||
                                    cs.Status != oldMap.get( cs.Id ).Status || cs.Sub_Status__c != oldMap.get( cs.Id ).Sub_Status__c ||
                                    cs.Subject != oldMap.get( cs.Id ).Subject || cs.ClosedDate != oldMap.get( cs.Id ).ClosedDate ||
                                    cs.Primary_Category__c != oldMap.get( cs.Id ).Primary_Category__c || cs.Categ__c != oldMap.get( cs.Id ).Categ__c || 
                                    cs.Sub_Category__c != oldMap.get( cs.Id ).Sub_Category__c || cs.Product_Type__c != oldMap.get( cs.Id ).Product_Type__c || 
                                    cs.PSSSubProduct__c != oldMap.get( cs.Id ).PSSSubProduct__c || cs.Nature_of_Client_enquiry__c != oldMap.get( cs.Id ).Nature_of_Client_enquiry__c || 
                                    cs.Priority_of_the_Issue2__c != oldMap.get( cs.Id ).Priority_of_the_Issue2__c )){
              
                Map< String,String > mapCaseFieldApiNameToValue = new Map< String,String >();     
                                        
                mapCaseFieldApiNameToValue.put( 'Id', cs.Id );
                mapCaseFieldApiNameToValue.put( 'Origin', cs.Origin );
                mapCaseFieldApiNameToValue.put( 'Status', cs.Status );
                mapCaseFieldApiNameToValue.put( 'OwnerId', cs.OwnerId );
                mapCaseFieldApiNameToValue.put( 'Subject', cs.Subject );
                mapCaseFieldApiNameToValue.put( 'Categ__c', cs.Categ__c );
                mapCaseFieldApiNameToValue.put( 'CaseNumber', cs.CaseNumber );
                mapCaseFieldApiNameToValue.put( 'AccountId', cs.AccountId );
                mapCaseFieldApiNameToValue.put( 'ContactId', cs.ContactId ); 
                mapCaseFieldApiNameToValue.put( 'ClosedDate', String.valueOf(cs.ClosedDate ));                         
                mapCaseFieldApiNameToValue.put( 'CreatedDate', String.valueOf(cs.CreatedDate ));                         
                mapCaseFieldApiNameToValue.put( 'RecordTypeId', cs.RecordTypeId );                        
                mapCaseFieldApiNameToValue.put( 'Sub_Status__c', cs.Sub_Status__c );                         
                mapCaseFieldApiNameToValue.put( 'Sub_Category__c', cs.Sub_Category__c );                        
                mapCaseFieldApiNameToValue.put( 'Product_Type__c', cs.Product_Type__c );                        
                mapCaseFieldApiNameToValue.put( 'PSSSubProduct__c', cs.PSSSubProduct__c );  
                mapCaseFieldApiNameToValue.put( 'Primary_Category__c', cs.Primary_Category__c );                        
                mapCaseFieldApiNameToValue.put( 'Nature_of_Client_enquiry__c', cs.Nature_of_Client_enquiry__c );                         
                mapCaseFieldApiNameToValue.put( 'Priority_of_the_Issue2__c', String.valueOf(cs.Priority_of_the_Issue2__c ));                        
                                        
                System.debug( ' Case Json >>>'+  JSON.serialize( mapCaseFieldApiNameToValue ) );                

                // Create and publish the event
                Case_Event__e caseEvent = new Case_Event__e();
                caseEvent.Case__c = JSON.serialize( mapCaseFieldApiNameToValue );                        
                                        
               
               /* // Create and publish the event
                Case_Event__e caseEvent = new Case_Event__e();
                
                caseEvent.Case_ID__c               = cs.Id;
                caseEvent.CaseOrigin__c            = cs.Origin;
                caseEvent.CaseStatus__c            = cs.Status;
                caseEvent.CaseOwnerId__c           = cs.OwnerId;
                caseEvent.CaseSubject__c           = cs.Subject;
                caseEvent.Case_Categ__c            = cs.Categ__c;
                caseEvent.CaseNumber__c            = cs.CaseNumber;
                caseEvent.CaseAccountId__c         = cs.AccountId;
                caseEvent.CaseContactId__c         = cs.ContactId;
                caseEvent.CaseClosedDate__c        = cs.ClosedDate;
                caseEvent.CaseCreatedDate__c       = cs.CreatedDate;
                caseEvent.CaseRecordTypeId__c      = cs.RecordTypeId;   
                caseEvent.Case_Sub_Status__c       = cs.Sub_Status__c;
                caseEvent.Case_Sub_Category__c     = cs.Sub_Category__c;
                caseEvent.Case_Product_Type__c     = cs.Product_Type__c;
                caseEvent.Case_PSSSubProduct__c    = cs.PSSSubProduct__c;
                caseEvent.Case_Primary_Category__c = cs.Primary_Category__c; 
                
                
                caseEvent.Case_Nature_of_Client_enquiry__c = cs.Nature_of_Client_enquiry__c;
                caseEvent.case_Priority_of_the_Issue2__c = String.valueOf( cs.Priority_of_the_Issue2__c );*/

                if( Trigger.isInsert ){
                    caseEvent.Change_Type__c = 'Create';
                }else if( Trigger.isUpdate ){
                    caseEvent.Change_Type__c = 'Update';
                }else if( Trigger.isDelete ){
                    caseEvent.Change_Type__c = 'Delete';
                }else{
                    caseEvent.Change_Type__c = 'Undelete';
                }
                
                lstCaseEvent.add( caseEvent );
            }
        }

        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish( lstCaseEvent );
    }
}