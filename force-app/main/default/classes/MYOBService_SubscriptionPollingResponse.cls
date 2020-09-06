/**
 * @Author : Nikhil Jaitly
 * @Created Date : 23/05/2020
 * @Description : Response of subscription polling
 */
public with sharing class MYOBService_SubscriptionPollingResponse {
  public class Account {
    public String id {get;set;} 
    public Contact contact {get;set;} 
  }

  public class Message {
    public List<Items> items {get;set;} 
  }

  public class Product {
    public String id {get;set;} 
    public String code {get;set;} 
    public String product_line {get;set;} 
    public String name {get;set;} 
    public String display_name {get;set;} 
  }

  public class Features {
    public String name {get;set;} 
  }

  public class Items {
    public String serial_number {get;set;} 
    public String type_Z {get;set;} // in json: type
    public String status {get;set;} 
    public String start_datetime {get;set;} 
    public String end_datetime {get;set;} 
    public String updated_at {get;set;} 
    public String id {get;set;} 
    public String name {get;set;} 
    public Product product {get;set;} 
    public Account account {get;set;} 
    public Account billing_account {get;set;} 
    public List<Features> features {get;set;} 
  }
  public class Data {
    public Message message {get;set;} 
    public String receiptId {get;set;} 
    public String messageId {get;set;} 
  }
  public List<Data> data {get;set;} 
  public class Contact {
    public String id {get;set;} 
    public String identity_id {get;set;} 
  }
}