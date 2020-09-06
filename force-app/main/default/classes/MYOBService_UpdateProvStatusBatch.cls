/**
 * @Author : Nikhil Jaitly
 * @Created Date : 30/05/2020
 * @Description : This batch class inserts messages read from AWS
 */
global with sharing class MYOBService_UpdateProvStatusBatch implements Database.Batchable<Object>, Database.Stateful, Database.AllowsCallouts {
  private List<Object> messages;
  private List<String> dmlSuccess;
  private String API_NAME;
  global MYOBService_UpdateProvStatusBatch(List<Object> mesg, String apiName) {
    this.messages = mesg;
    this.API_NAME = apiName;
    this.dmlSuccess = new List<String>();
  }
  global Iterable<Object> start(Database.BatchableContext bc) {
    return messages;
  }
  global void execute(Database.BatchableContext bc, List<Object> scope) {
    List<MYOBService_UpdateOptyLinesProvStatus.OrderTrackingResponseWrapper> resps = (List<MYOBService_UpdateOptyLinesProvStatus.OrderTrackingResponseWrapper>)scope;
    Boolean updationSuccess = true;
    System.debug('NJ-subRes '+resps);
    try {
        updationSuccess = MYOBService_UpdateOptyLinesProvStatus.updateOptyLines(resps);

      }

     catch(Exception ex) {
      LogUtilityException.logException('MYOBService_UpdateProvStatusBatch','execute',ex ,resps, false);
    }
    if(updationSuccess) {
      for(MYOBService_UpdateOptyLinesProvStatus.OrderTrackingResponseWrapper res : resps) {
        dmlSuccess.add(res.receiptId);
      }
    }
  }
  
	global void finish(Database.BatchableContext bc) {
      if(!Test.isRunningTest()) {
        System.enqueueJob(new MYOBService_SubscriptionRemoveQue(dmlSuccess, API_NAME));
      }
  }
}