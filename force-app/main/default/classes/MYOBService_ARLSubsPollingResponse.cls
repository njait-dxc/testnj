/**
 * @Author : Nikhil Jaitly
 * @Created Date : 23/05/2020
 * @Description : Response of subscription polling
 */
public with sharing class MYOBService_ARLSubsPollingResponse {
  public class Message {
    public String serial_number {get;set;}
    public String status {get;set;}
    public String end_datetime {get;set;}
    public String product_id {get;set;}
    public String client_id {get;set;}
    public String product {get;set;}
    public String contact_id {get;set;}
  }

  public class Data {
    public Message message {get;set;} 
    public String receiptId {get;set;} 
    public String messageId {get;set;} 
  }
  public List<Data> data {get;set;} 

}