/**
 * @Author : Nikhil Jaitly
 * @Created Date : 23/05/2020
 * @Description : This class polls AWS queue and create oppotunity records
 */
public with sharing class MYOBService_SubscriptionPollingQue implements Queueable, Database.AllowsCallouts  {
  private static final String API_NAME = 'PubSub Subscription Service';
  private static final String TYPE_FREE = 'free';
  private static final String TYPE_PAID = 'paid';
  private static final String STATUS_ACTIVE = 'active';
  private static final String STATUS_EXPIRED = 'expired';
  private List<MYOBService_PurchaseOpportunityUtility.SubscriptionResponse> messages;
  private Map<String, MYOBService_SubscriptionPollingResponse> mesgAlreadyRead;
  private Integer MAX_MESSAGE_READ = 0;
  private Integer Total_Message_Read;
  public MYOBService_SubscriptionPollingQue() {
    this.Total_Message_Read = 0;
    this.mesgAlreadyRead = new Map<String, MYOBService_SubscriptionPollingResponse>();
    this.messages = new List<MYOBService_PurchaseOpportunityUtility.SubscriptionResponse>();
    for(Support_Setting__mdt ss : [SELECT Id, Value__c
                                   FROM Support_Setting__mdt
                                   WHERE DeveloperName = 'MYOB_DirectSales_Q_Throttle'
                                   LIMIT 1]) {
      this.MAX_MESSAGE_READ = Integer.valueOf(ss.Value__c);                               
    }
  }
  public MYOBService_SubscriptionPollingQue(Integer messagesRead, Integer maxMesg, List<MYOBService_PurchaseOpportunityUtility.SubscriptionResponse> messages, Map<String, MYOBService_SubscriptionPollingResponse> mesgAlreadyRead) {
    this.Total_Message_Read = messagesRead;  
    this.messages = messages;
    this.mesgAlreadyRead = mesgAlreadyRead;
    this.MAX_MESSAGE_READ = maxMesg;
  }
  /**
   * @Author : Nikhil Jaitly
   * @Created Date : 23/05/2020
   * @Description : Excute method of the queueable 
   */
  public void execute(QueueableContext context) {
    MYOB_Service_API__mdt myobServiceAPI = MYOBService.getMYOBService(API_NAME);
    Integer totalCallouts = Limits.getLimitCallouts();
    //Step 1 : Get the access token
    String accessToken;
    try {
      accessToken = getAccessToken(myobServiceAPI.Resource_Id__c);
    } catch(CalloutException ex) {
      LogUtilityException.throwException('MYOBService_SubscriptionPollingQue','getAccessToken',ex, null);
    } 
    Map<String, MYOBService_SubscriptionPollingResponse> mapMesgIdRespMap = new Map<String,MYOBService_SubscriptionPollingResponse>();
    MYOBService_SubscriptionPollingResponse tempResp;
    Boolean endOfQueueReached = false;
    if(String.isNotBlank(accessToken)) {
      for(Decimal request = 0 ; request < totalCallouts - Limits.getCallouts(); request++) {
        //Maximum message read count reached, break the chain
        if(this.Total_Message_Read == MAX_MESSAGE_READ) {
          endOfQueueReached = true;
          break;
        } 
        //Step 2: Get the message using the token from the API
        try {
          tempResp = getMessageFromQueue(accessToken, myobServiceAPI.Endpoint__c);
        } catch(CalloutException ex) {
          LogUtilityException.throwException('MYOBService_SubscriptionPollingQue','getMessageFromQueue',ex,null);
        } 
        this.Total_Message_Read++;
        if(tempResp != null && tempResp.data != null && !tempResp.data.isEmpty()) {
          for(MYOBService_SubscriptionPollingResponse.Data dt : tempResp.data) {
            if(!mesgAlreadyRead.containsKey(dt.receiptId)) {
              mesgAlreadyRead.put(dt.receiptId, tempResp);
              mapMesgIdRespMap.put(dt.receiptId, tempResp);
            } else {
              endOfQueueReached = true;
              // If same mesg is received this means we have reached end of queue and now needs to process message and empty the queue
              break;
            }
          }
        } else {
          endOfQueueReached = true;
          break;
        }
      }
      //Step 3 : Process message
      if(!mapMesgIdRespMap.isEmpty()) { 
        messages.addAll(processMessage(mapMesgIdRespMap));
      }
      if(!Test.isRunningTest()) {
        //If there are more messages in the queue, re run this process
        if(!endOfQueueReached) {
          System.enqueueJob(new MYOBService_SubscriptionPollingQue(Total_Message_Read, MAX_MESSAGE_READ, messages, mesgAlreadyRead));
        } else if(!messages.isEmpty())  {
          System.debug('NJ-Messages '+messages);  
          Database.executeBatch(new MYOBService_SubscriptionUpdateBatch(messages, API_NAME), 100);
        }
      }
    }
  }
  /**
   * @Author : Nikhil Jaitly
   * @Created Date : 23/05/2020
   * @Description : This method is used to get access token
   */
  public static String getAccessToken(String resource) {
    String accessToken;
    MYOBService_AuthorisationAPI.AccessToken_Response accessTokenResponse = MYOBService_AuthorisationAPI.getAccessToken(resource);
    if(accessTokenResponse != null) {
      accessToken = accessTokenResponse.access_token;
    }
    return accessToken;
  }
  /**
   * @Author : Nikhil Jaitly
   * @Created Date : 23/05/2020
   * @Description : This method is used to get message from the queue
   */
  private static MYOBService_SubscriptionPollingResponse getMessageFromQueue(String accessToken, String endPoint) {
    MYOBService_SubscriptionPollingResponse resp;
    HttpRequest request = new HttpRequest();
    request.setMethod('GET');
    request.setTimeout(30000);
    request.setEndpoint(endPoint);
    Map <String, String> requestHeaders = new Map <String, String> { 'Content-Type' => 'application/json',
                                                                     'Authorization' => 'Bearer ' + accessToken
                                                                   };
    for (String key : requestHeaders.keySet()) {
      request.setHeader(key, requestHeaders.get(key));
    }
    HttpResponse response = APICallLogger.send(request, requestHeaders);
    if(response.getStatusCode() == 200) { 
      resp = (MYOBService_SubscriptionPollingResponse) JSON.deserialize(addKeywords(response.getBody()), MYOBService_SubscriptionPollingResponse.class);
    }
    return resp;
  }

  /**
   * @Description : This method is used to process Message received from service
   * @Author : Nikhil Jaitly
   * @CreatedDate : 23/05/2020
   */
   private static List<MYOBService_PurchaseOpportunityUtility.SubscriptionResponse> processMessage(Map<String, MYOBService_SubscriptionPollingResponse> messages) {
     List<MYOBService_PurchaseOpportunityUtility.SubscriptionResponse> subscriptionResponses = new List<MYOBService_PurchaseOpportunityUtility.SubscriptionResponse>();
     for(MYOBService_SubscriptionPollingResponse resp : messages.values()) {
        for(MYOBService_SubscriptionPollingResponse.Data dt : resp.data) {
          for(MYOBService_SubscriptionPollingResponse.Items itm : dt.message.items){
            if(itm.id != null) {
              MYOBService_PurchaseOpportunityUtility.SubscriptionResponse tmpSubsResp = new MYOBService_PurchaseOpportunityUtility.SubscriptionResponse();
              tmpSubsResp.receiptId = dt.receiptId;
              tmpSubsResp.accountId = itm.account != null && itm.account.id != null ? itm.account.id : null;
              tmpSubsResp.contactId = itm.account != null && itm.account.contact != null && itm.account.contact.id != null 
                                    ? itm.account.contact.id : null;
              tmpSubsResp.serialNumber = itm.serial_number;
              tmpSubsResp.endDate = itm.end_datetime != null ? itm.end_datetime : null;
              tmpSubsResp.productId = itm.product != null ? itm.product.id : null;
              tmpSubsResp.status = itm.status;
              tmpSubsResp.type = itm.type_Z;
              tmpSubsResp.id = itm.id+system.now().gettime();
              // Update subscriptions if Type is paid and status = active OR
              // Type is free and status expired
              if((tmpSubsResp.type == TYPE_PAID && tmpSubsResp.status == STATUS_ACTIVE) ||
                (tmpSubsResp.type == TYPE_FREE && tmpSubsResp.status == STATUS_EXPIRED)) {
                tmpSubsResp.isInsert = false;
              }
              // Create only free active subscription
              else if(tmpSubsResp.type == TYPE_FREE && tmpSubsResp.status == STATUS_ACTIVE) {
                tmpSubsResp.isInsert = true;
              }
              else{
                    //not supported scenario,set the boolean isInsert to null to delete the message from queue
                    tmpSubsResp.isInsert = null;
                }
              subscriptionResponses.add(tmpSubsResp);
            }
          }
        }
     }
     return subscriptionResponses;
   }
  /**
   * This method is used to add __Z keyword to type keyword in apex to properly de serialize
   * @Author : Nikhil Jaitly
   * @CreatedDate : 23/05/2020
   */
   private static String addKeywords(String source) {
     return source.replaceAll('type', 'type_Z');
   }
}