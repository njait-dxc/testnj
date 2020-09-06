/**
 * @Author : Ankit Bhardwaj
 * @Created Date : 30/06/2020
 * @Description : This class polls AWS queue and create oppotunity records
 */
public with sharing class MYOBService_OrderTrackingSvcPollingQue implements Queueable, Database.AllowsCallouts  {
  private String API_NAME = '';
  private List<MYOBService_UpdateOptyLinesProvStatus.OrderTrackingResponseWrapper> messages;
  private Map<String, MYOBService_OrderTrackingSvcResponse> mesgAlreadyRead;
  private Integer MAX_MESSAGE_READ = 0;
  private Integer Total_Message_Read;
  public MYOBService_OrderTrackingSvcPollingQue(String apiName) {
    this.Total_Message_Read = 0;
    this.mesgAlreadyRead = new Map<String, MYOBService_OrderTrackingSvcResponse>();
    this.messages = new List<MYOBService_UpdateOptyLinesProvStatus.OrderTrackingResponseWrapper>();
    for(Support_Setting__mdt ss : [SELECT Id, Value__c
                                   FROM Support_Setting__mdt
                                   WHERE DeveloperName = 'MYOB_DirectSales_Q_Throttle'
                                   LIMIT 1]) {
      this.MAX_MESSAGE_READ = Integer.valueOf(ss.Value__c);
      this.API_NAME = apiName;
    }
  }
  public MYOBService_OrderTrackingSvcPollingQue(Integer messagesRead, Integer maxMesg, List<MYOBService_UpdateOptyLinesProvStatus.OrderTrackingResponseWrapper> messages, Map<String, MYOBService_OrderTrackingSvcResponse> mesgAlreadyRead, String apiName) {
    this.Total_Message_Read = messagesRead;  
    this.messages = messages;
    this.mesgAlreadyRead = mesgAlreadyRead;
    this.MAX_MESSAGE_READ = maxMesg;
    this.API_NAME = apiName;
  }
  /**
   * @Author : Ankit Bhardwaj
   * @Created Date : 31/07/2020
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
      LogUtilityException.throwException('MYOBService_OrderTrackingSvcPollingQue','getAccessToken',ex, new List<String>{'error obtaining token from IDAM'});
    } 
    Map<String, MYOBService_OrderTrackingSvcResponse> mapMesgIdRespMap = new Map<String,MYOBService_OrderTrackingSvcResponse>();
    MYOBService_OrderTrackingSvcResponse tempResp;
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
          LogUtilityException.throwException('MYOBService_OrderTrackingSvcPollingQue','getMessageFromQueue',ex,new List<String>{'error processing message from queue'});
        } 
        this.Total_Message_Read++;
        if(tempResp != null && tempResp.data != null && !tempResp.data.isEmpty()) {
          for(MYOBService_OrderTrackingSvcResponse.PubSubResponseData dt : tempResp.data) {
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
          System.enqueueJob(new MYOBService_OrderTrackingSvcPollingQue(Total_Message_Read, MAX_MESSAGE_READ, messages, mesgAlreadyRead,API_NAME));
        } else if(!messages.isEmpty())  {
          Database.executeBatch(new MYOBService_UpdateProvStatusBatch(messages, API_NAME), 100);
        }
      }
    }
  }
  /**
   * @Author : Ankit Bhardwaj
   * @Created Date : 30/06/2020
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
   * @Author : Ankit Bhardwaj
   * @Created Date : 30/06/2020
   * @Description : This method is used to get message from the queue
   */
  private static MYOBService_OrderTrackingSvcResponse getMessageFromQueue(String accessToken, String endPoint) {
    MYOBService_OrderTrackingSvcResponse resp;
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
      resp = (MYOBService_OrderTrackingSvcResponse) JSON.deserialize(response.getBody(), MYOBService_OrderTrackingSvcResponse.class);
    }
    return resp;
  }

  /**
   * @Description : This method is used to process Message received from service
   * @Author : Ankit Bhardwaj
   * @CreatedDate : 30/06/2020
   */
   private static List<MYOBService_UpdateOptyLinesProvStatus.OrderTrackingResponseWrapper> processMessage(Map<String, MYOBService_OrderTrackingSvcResponse> messages) {
     List<MYOBService_UpdateOptyLinesProvStatus.OrderTrackingResponseWrapper> optyLinesResponses = new List<MYOBService_UpdateOptyLinesProvStatus.OrderTrackingResponseWrapper>();
     for(MYOBService_OrderTrackingSvcResponse resp : messages.values()) {
        for(MYOBService_OrderTrackingSvcResponse.PubSubResponseData dt : resp.data) {
            if(dt.message.id != null) {
              MYOBService_UpdateOptyLinesProvStatus.OrderTrackingResponseWrapper tmpSubsResp = new MYOBService_UpdateOptyLinesProvStatus.OrderTrackingResponseWrapper();
              tmpSubsResp.purchaseId = dt.message.id;
              tmpSubsResp.provisioningStatus = dt.message.status;
              tmpSubsResp.receiptId = dt.receiptId;
              optyLinesResponses.add(tmpSubsResp);
            }
        }
     }
     return optyLinesResponses;
   }
}