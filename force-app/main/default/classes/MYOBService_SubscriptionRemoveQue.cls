/**
 * @Author : Nikhil Jaitly
 * @Created Date : 29/05/2020
 * @Description : This class removed messages from AWS queue
*/
public with sharing class MYOBService_SubscriptionRemoveQue implements Queueable, Database.AllowsCallouts {
  //private static final String API_NAME = 'PubSub Subscription Service';
  public List<String> queueMessages;
  public String API_NAME;
  public MYOBService_SubscriptionRemoveQue(List<String> messages, String apiName) {
    this.queueMessages = messages;
    this.API_NAME = apiName;
  }
  /**
   * @Author : Nikhil Jaitly
   * @Created Date : 29/05/2020
   * @Description : Excute method of the queueable 
   */
  public void execute(QueueableContext context) {
    MYOB_Service_API__mdt myobServiceAPI = MYOBService.getMYOBService(API_NAME);
    //Step 1 : Get the access token
    String accessToken = MYOBService_SubscriptionPollingQue.getAccessToken(myobServiceAPI.Resource_Id__c);
    Integer allowedCallouts = Limits.getLimitCallouts() -  Limits.getCallouts();
    for(Integer request = 0 ; request < allowedCallouts; request++) {
      if(!queueMessages.isEmpty()) {
        try {
          removeMessageFromQueue(queueMessages.get(0), myobServiceAPI.Endpoint__c, accessToken);
          queueMessages.remove(0);
        } catch(Exception ex) {
          LogUtilityException.throwException('MYOBService_SubscriptionRemoveQue','removeMessageFromQueue',ex,null);
        }
      } else {
        // all messages removed
        break;
      }
    }
    // If more messages left to remove
    if(!queueMessages.isEmpty()) {
        System.enqueueJob(new MYOBService_SubscriptionRemoveQue(queueMessages,API_NAME));
    }
  }
  /**
   * @Description : This method is used to remove message from Queue
   * @Author : Nikhil Jaitly
   * @CreatedDate : 25/05/2020
   */
  public static void removeMessageFromQueue(String receiptId, String endPoint, String accessToken) {
    HttpRequest httpRequest = new HttpRequest();
    httpRequest.setEndpoint(endPoint + '?receiptId=' + receiptId);
    httpRequest.setMethod('DELETE');
    Map <String, String> requestHeaders = new Map <String, String>();
    requestHeaders.put('Content-Type', 'application/json');
    requestHeaders.put('Authorization', 'Bearer ' + accessToken);
    for (String key : requestHeaders.keySet()) {
      httpRequest.setHeader(key, requestHeaders.get(key));
    }
    HttpResponse httpResponse = APICallLogger.send(httpRequest, requestHeaders);
  }
}