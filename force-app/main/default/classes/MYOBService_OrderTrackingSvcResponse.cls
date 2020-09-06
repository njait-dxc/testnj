/**
 * @Author : Ankit Bhardwaj
 * @Created Date : 31/07/2020
 * @Description : Response of Order Tracking Service Polling
 */
public with sharing class MYOBService_OrderTrackingSvcResponse {
  //create wrapper for order tracking service message response
  public class PubSubResponseMessage
  {
    public String id {get;set;}
    public String status {get;set;}
    public String type {get;set;}
  }

  public class PubSubResponseData
  {
    public PubSubResponseMessage message {get;set;}
    public String receiptId {get;set;}
    public String messageId {get;set;}
  }
  public List<PubSubResponseData> data {get;set;}
}