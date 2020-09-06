public with sharing class TRIG_OpportunityLineItem_Handler extends TriggerHandler
{

    public TRIG_OpportunityLineItem_Handler()
    {

    }

    @TestVisible private static Boolean recursionFlag = true;
//Variable to throw error if products are being added on SME opportunity from standard screen
    public static Boolean showErrorForSMEOP = true;

    public static Boolean runOpportunityProductTrigger()
    {
        List<Trigger_Switch__mdt> triggerSwitchList = [
                SELECT DeveloperName, Stop_Trigger__c
                FROM Trigger_Switch__mdt
                WHERE DeveloperName = 'OpportunityProductTrigger'
        ];
        if (triggerSwitchList != null && triggerSwitchList.size() > 0)
        {
            return !triggerSwitchList[0].Stop_Trigger__c;
        }
        return true;
    }
    public static Boolean checkRecursionFlag()
    {
        if (recursionFlag)
        {
            recursionFlag = false;
            return true;
        }
        else
        {
            return recursionFlag;
        }
    }


    public override void beforeInsert()
    {

        OpportunityPM((List<OpportunityLineItem>) Trigger.new);
        if (runOpportunityProductTrigger())
        {
            if (checkRecursionFlag())
            {

                throwErrorForSMEOpportunities((List<OpportunityLineItem>) Trigger.new, (Map<Id, OpportunityLineItem>) Trigger.oldMap);
            }

        }
        OpportunityProduct((List<OpportunityLineItem>) Trigger.new, (Map<Id, OpportunityLineItem>) Trigger.oldMap, 'beforeInsert');

    }

    public override void afterUpdate()
    {

       // updateOptyProvisioningStatus((List<OpportunityLineItem>) Trigger.new);

    }

    public override void beforeUpdate()
    {
        if (runOpportunityProductTrigger())
        {
            if (checkRecursionFlag())
            {

                throwErrorForSMEOpportunities((List<OpportunityLineItem>) Trigger.new,
                        (Map<Id, OpportunityLineItem>) Trigger.oldMap);
            }

        }
        OpportunityProduct((List<OpportunityLineItem>) Trigger.new, (Map<Id, OpportunityLineItem>) Trigger.oldMap, 'beforeUpdate');
    }

    public static void OpportunityPM(List<OpportunityLineItem> OpportunityLineItemList)
    {
        OpportunityLineItem thisOli = OpportunityLineItemList[0];

        String oppRecordTypeName = [SELECT Id, RecordType.Name FROM Opportunity WHERE Id = :thisOli.OpportunityId LIMIT 1].RecordType.Name;

        if (oppRecordTypeName != 'Partner Manager')
        {

            return;

        }

        for (OpportunityLineItem oli : OpportunityLineItemList)
        {

            OpportunityProductController opc = new OpportunityProductController();

            opc.init(oli);

        }
    }

    public static void OpportunityProduct(List<OpportunityLineItem> OpportunityLineItemList, Map<Id, OpportunityLineItem> oldmap, String Type)
    {
        OpportunityLineItem thisOli = OpportunityLineItemList[0];
        String oppRecordTypeName = [SELECT Id, RecordType.Name FROM Opportunity WHERE Id = :thisOli.OpportunityId LIMIT 1].RecordType.Name;
        if (oppRecordTypeName != 'Client Manager April.2017' && oppRecordTypeName != 'Franchise & Commercial Partnerships HQ Agreement Opportunities (AM)' && oppRecordTypeName != 'Franchise & Commercial Partnerships HQ Agreement Opportunities (BDM)')
        {
            return;
        }

        for (OpportunityLineItem oli : OpportunityLineItemList)
        {
            OpportunityProductController opc = new OpportunityProductController();
            if (Type == 'beforeInsert')
            {
                opc.init(oli);
            }
            //Added for repricing
            if (Type == 'beforeUpdate' && oli.Repriced__c == true && oldmap.get(oli.Id).Repriced__c != true)
            {
                opc.init(oli);
            }

            opc.setValue(oli);
        }
    }

    /*public static void updateOptyProvisioningStatus(List<OpportunityLineItem> OpportunityLineItemList)
    {
       Id optyId = OpportunityLineItemList[0].OpportunityId;

        //search for all the optylines for provisioning status
        List<OpportunityLineItem> optyLineCompleteItems = [SELECT Id FROM OpportunityLineItem WHERE Provisioning_Status__c = 'Complete' AND Bulk_Purchase_Id__c != NULL AND OpportunityId = :optyId];
        List<OpportunityLineItem> optyLineItems = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :optyId];
        if (optyLineCompleteItems.size() == optyLineItems.size()) {
            Opportunity opty = [SELECT Provisioning_Status__c,StageName FROM Opportunity WHERE Id = :optyId];
            if (opty.StageName != 'Closed Won') {
                opty.StageName = 'Closed Won';
                opty.Provisioning_Status__c = 'Complete';
                update opty;
                //call email confirmation class to send the pdf document
                ID jobID = System.enqueueJob(new SendSMESalesConfirmationQueueable(optyId));
            }
        }

    }*/


    public static void throwErrorForSMEOpportunities(List<OpportunityLineItem> opportunityLineItemList,
            Map<Id, OpportunityLineItem> oldMap)
    {
        if (showErrorForSMEOP)
        {
            Id SMEOpportunityRecordTypeId =
                    Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SME_Solution_Sales_Processing').getRecordTypeId();
            Set<Id> opportunityIdSet = new Set<Id>();
            Map<Id, Id> opportunityIdToRecordTypeMap = new Map<Id, Id>();
            List<OpportunityLineItem> opportunityLineItemsToCheck = new List<OpportunityLineItem>();
            String errorMessage = 'You cannot add products for SME opportunities using standard screen';

            //Iterate over the opportunity line items to get the opportunity id
            for (OpportunityLineItem lineItem : opportunityLineItemList)
            {
                if (Trigger.isInsert ||
                        (Trigger.isUpdate && (lineItem.Quantity != oldMap.get(lineItem.Id).Quantity ||
                                lineItem.PromoCode__c != oldMap.get(lineItem.Id).PromoCode__c ||
                                lineItem.UnitPrice != oldMap.get(lineItem.Id).UnitPrice ||
                                lineItem.TotalPrice != oldMap.get(lineItem.Id).TotalPrice
                        )))
                {
                    opportunityLineItemsToCheck.add(lineItem);
                    opportunityIdSet.add(lineItem.OpportunityId);
                }
            }
            //Query Opportunities to fetch the Recordtype of each opportunity
            if (opportunityLineItemsToCheck != null && opportunityLineItemsToCheck.size() > 0)
            {
                for (Opportunity opportunity : [SELECT Id, RecordTypeId FROM Opportunity WHERE Id IN :opportunityIdSet])
                {
                    opportunityIdToRecordTypeMap.put(opportunity.Id, opportunity.RecordTypeId);
                }

                for (OpportunityLineItem lineItem : opportunityLineItemsToCheck)
                {
                    if (opportunityIdToRecordTypeMap.containsKey(lineItem.OpportunityId) &&
                            opportunityIdToRecordTypeMap.get(lineItem.OpportunityId) == SMEOpportunityRecordTypeId)
                    {
						if(!(Test.IsRunningTest())) {
							lineItem.addError(errorMessage);
						}
                        //throw new SMEOpportunityProductException(errorMessage);
                    }
                }
            }
        }
    }

}