/**
 * @Author : Nikhil Jaitly
 * @Created Date : 28/06/2020
 * @Description : Log utility class for MyOb, send logs to the external logging
 */
public with sharing class MyOBService_LogUtility {
  private static final String LOG_API_NAME = 'LOG_API';
  private static final String LOG_CENTRAL_QUEUE_NAME = 'Log_Central_Queue';
  private static final String LOG_CENTRAL_KEY_SETTING_NAME = 'Log_Central_Key';
  private static final String LOG_EVENT_SUFFIX = '/v2/event';
  @InvocableMethod(label='Insert Remote Logs')
  public static void insertRemoteLogs(List<String> logs) {
    if(!logs.isEmpty()) {
      System.enqueueJob(new MyOBService_RemoteLogsQueueable(logs));
    }
  }
  /**
  * @Author : Nikhil Jaitly
  * @Created Date : 28/06/2020
  * @Description : This method is used to push logs to the LOG API
  */
  public static Boolean pushLogs(List<String> logs) {
    Boolean isSuccess = true;
    if(!logs.isEmpty()) {
      MYOB_Service_API__mdt myobServiceAPI = MYOBService.getMYOBService(LOG_API_NAME);
      Support_Setting__mdt logKey = UtilityClass_MYOB.getSupportSetting(LOG_CENTRAL_KEY_SETTING_NAME);
      Support_Setting__mdt queue = UtilityClass_MYOB.getSupportSetting(LOG_CENTRAL_QUEUE_NAME);
      LogsRequest lr = new LogsRequest();
      lr.queue = queue.Value__c;
      String serializeBody;
      for(String log : logs) {
        if(String.isNotBlank(log)) {            
          lr.messages.add(new Message(log, (DateTime.now().getTime() / 1000L)));
        }
        
      }
      System.debug('Log Message:'+lr);  
      HttpRequest request = new HttpRequest();
      request.setMethod('POST');
      request.setTimeout(120000);
      request.setEndpoint(myobServiceAPI.Endpoint__c + LOG_EVENT_SUFFIX);
      request.setBody(JSON.serialize(lr));
      Map <String, String> requestHeaders = new Map <String, String> { 'Content-Type' => 'application/json',
                                                                       'X-API-Key' => logKey.Value__c
                                                                     };
      for (String key : requestHeaders.keySet()) {
        request.setHeader(key, requestHeaders.get(key));
      }
      try {
        System.debug('requestHeaders'+requestHeaders);
         System.debug('requestHeaders'+request);
        HttpResponse response = APICallLogger.send(request, requestHeaders);
        System.debug('SumoLogsResponse'+response);
        Integer logResponseCode = response.getStatusCode();
        if(logResponseCode == 200 || logResponseCode == 202) {
          isSuccess = true;
        } else {
          isSuccess = false;
        }
      } catch(Exception ex) {
        isSuccess = false;
      }
    }
    return isSuccess;
  }

  public class LogsRequest {
    public String queue;
    public List<Message> messages;
    public LogsRequest() {
      messages = new List<Message>();
    }
  }
  public class Message {
    public String msg;
    public Long ts;
    public Message(String msg, Long ts) {
      this.msg = msg;
      this.ts = ts;
    }
  }
}