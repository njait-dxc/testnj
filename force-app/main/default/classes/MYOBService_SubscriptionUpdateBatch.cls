/**
 * @Author : Nikhil Jaitly
 * @Created Date : 30/05/2020
 * @Description : This batch class inserts messages read from AWS
 */
global with sharing class MYOBService_SubscriptionUpdateBatch implements Database.Batchable<Object>, Database.Stateful, Database.AllowsCallouts {
  private List<Object> messages;
  private List<String> dmlSuccess;
  private String API_NAME;
  global MYOBService_SubscriptionUpdateBatch(List<Object> mesg, String apiName) {
    this.messages = mesg;
    this.API_NAME = apiName;
    this.dmlSuccess = new List<String>();
  }
  global Iterable<Object> start(Database.BatchableContext bc) {
    return messages;
  }
  global void execute(Database.BatchableContext bc, List<Object> scope) {
    List<MYOBService_PurchaseOpportunityUtility.SubscriptionResponse> resps = (List<MYOBService_PurchaseOpportunityUtility.SubscriptionResponse>)scope;
    List<MYOBService_PurchaseOpportunityUtility.SubscriptionResponse> createOpp = new List<MYOBService_PurchaseOpportunityUtility.SubscriptionResponse>();
    List<MYOBService_PurchaseOpportunityUtility.SubscriptionResponse> updateOpp = new List<MYOBService_PurchaseOpportunityUtility.SubscriptionResponse>();
    Boolean creationSuccess = true, updationSuccess = true;
    System.debug('NJ-subRes '+resps);  
      System.debug(resps.size());
    for(MYOBService_PurchaseOpportunityUtility.SubscriptionResponse subsRes : resps) {
        System.debug(subsRes);
        System.debug(subsRes.type);
        System.debug(subsRes.status);
        if(subsRes.isInsert == null)
        {
            //no need to process but still need to delete the message
            dmlSuccess.add(subsRes.receiptId);
            continue;
        }
      else if(subsRes.isInsert) {
        createOpp.add(subsRes);
      } else {
        updateOpp.add(subsRes);
      }
    }
    try {
      if(!createOpp.isEmpty()) {
        creationSuccess = MYOBService_PurchaseOpportunityUtility.createPurchaseOpportunities(createOpp);
      }
      if(!updateOpp.isEmpty()) {
        updationSuccess = MYOBService_PurchaseOpportunityUtility.updateExistingOpportunities(updateOpp);
      }
    } catch(Exception ex) {
      LogUtilityException.logException('MYOBService_SubscriptionUpdateBatch','execute',ex ,new List<Object> { createOpp, updateOpp}, false);
    }
    if(creationSuccess) {
      for(MYOBService_PurchaseOpportunityUtility.SubscriptionResponse res : createOpp) {
        dmlSuccess.add(res.receiptId);
      }
    }
    if(updationSuccess) {
      for(MYOBService_PurchaseOpportunityUtility.SubscriptionResponse res : updateOpp) {
        dmlSuccess.add(res.receiptId);
      }
    }
  }
  
	global void finish(Database.BatchableContext bc) {
    System.enqueueJob(new MYOBService_SubscriptionRemoveQue(dmlSuccess, API_NAME));
  }
}