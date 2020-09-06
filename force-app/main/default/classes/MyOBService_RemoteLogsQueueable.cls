/**
 * @Author : Nikhil Jaitly
 * @Created Date : 29/06/2020
 * @Description : This class insert remote logs
 */
public with sharing class MyOBService_RemoteLogsQueueable implements Queueable, Database.AllowsCallouts {
  public List<String> logs;
  public MyOBService_RemoteLogsQueueable(List<String> logs) {
    this.logs = logs;
  }
  /**
   * @Author : Nikhil Jaitly
   * @Created Date : 29/06/2020
   * @Description : Execute method of the queueable 
   */
  public void execute(QueueableContext context) {
    MyOBService_LogUtility.pushLogs(logs);
  }
}