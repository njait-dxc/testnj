/**
 * Created by Ankit.Bhardwaj on 31/07/2020.
 */

public with sharing class MYOBService_UpdateOptyLinesProvStatus {

    public static Boolean updateOptyLines(List<OrderTrackingResponseWrapper> responseWrapper)
    {
        Boolean processedSuccessfully = true;
        Set<String> purchaseIdSet = new Set<String>();
        Map<String,String> optyMap = new Map<String, String>();
        Set<Id> optyIds = new Set<Id>();

        try {
            if (responseWrapper.size() > 0) {
                for (OrderTrackingResponseWrapper res : responseWrapper) {
                    purchaseIdSet.add(res.purchaseId);
                    optyMap.put(res.purchaseId, res.provisioningStatus);
                }

                List<OpportunityLineItem> optyLines = [
                        SELECT Id,Provisioning_Status__c,Bulk_Purchase_Id__c,OpportunityId
                        from OpportunityLineItem
                        where Bulk_Purchase_Id__c in :purchaseIdSet AND Provisioning_Status__c = 'In Progress'
                ];

                if (optyLines.size() > 0) {
                    for (OpportunityLineItem oli : optyLines) {
                        oli.Provisioning_Status__c = statusMapper(optyMap.get(oli.Bulk_Purchase_Id__c));
                        optyIds.add(oli.OpportunityId);
                    }

                    Database.update(optyLines,true);

                    //now find all the opportunities that would require email sent out
                    List<Id> emailsToProcesIds = new List<Id>();
                    List<Opportunity> opty = [SELECT Id,Provisioning_Status__c,StageName,RecordTypeId FROM Opportunity
                    WHERE Id in :optyIds and StageName != 'Closed Won' and NonProvisioned_Line_Count__c = 0];
                    if (opty.size() > 0 ) {
                        for (Opportunity op : opty) {
                            op.StageName = 'Closed Won';
                            op.Provisioning_Status__c = 'Complete';
                            if(op.RecordTypeId ==  Constants.OPP_SME_RT) {
                                System.debug(op.RecordTypeId);
                                System.debug(Constants.OPP_SME_RT);
                                emailsToProcesIds.add(op.Id);
                            }
                        }
                        Database.update(opty,true);

                        //call email confirmation class to send the pdf document
                        if(emailsToProcesIds.size() > 0 ) {
                            System.debug('Reached Here');
                            ID jobID = System.enqueueJob(new SendSMESalesConfirmationQueueable(emailsToProcesIds));
                        }
                    }
                }
            }
        }
        catch (Exception e)
        {
            processedSuccessfully = false;
            LogUtilityException.throwException('MYOBService_UpdateOptyLinesProvStatus','updateOptyLines',e,responseWrapper);
        }
        return processedSuccessfully;
    }

    public class OrderTrackingResponseWrapper
    {
        public String provisioningStatus;
        public String purchaseId;
        public String receiptId;
    }

    public static String statusMapper(String provisioningStatus)
    {
        if (provisioningStatus == 'PURCHASE_COMPLETE')
        {
            provisioningStatus = 'Complete';
        }
        else
        {
            provisioningStatus = 'Error';

        }
        System.debug(provisioningStatus);
        return provisioningStatus;
    }

}