/**
 * @Author : Nikhil Jaitly
 * @Created Date : 02/06/2020
 * @Description : Test class for MYOBService_SubscriptionUpdateBatch
 */
@isTest
public with sharing class MYOBService_SubscriptionUpdateBatchTest {
  @TestSetup
  static void createData(){
    Account testAccount = new Account(Name = 'Testing123', Client_ID__c = '1234');
        insert testAccount;
        Contact c = new Contact(FirstName = 'FN', LastName = 'LN', AccountId = testAccount.Id);
        insert c;
        String stdPbId = Test.getStandardPricebookId();
    Pricebook2 prb2 = new Pricebook2(Name = 'SME Purchase Pricebook', Description = 'SME Purchase Pricebook', IsActive = true);
    insert prb2;
  }
  @isTest
  static void test_MYOBService_SubscriptionUpdateBatch() {
    String response = '{\"data\":[{\"message\":{\"items\":[{\"serial_number\":\"612382603311\",\"type\":\"paid\",\"status\":\"active\",\"start_datetime\":\"2020-05-27T06:55:49Z\",\"updated_at\":\"2020-05-27T06:55:58+00:00\",\"id\":\"628c72ce-deca-468d-95c7-3e91be926622\",\"name\":\"Ryan LLC\",\"product\":{\"id\":\"56\",\"code\":\"SMEPCL\",\"product_line\":\"MYOB Essentials (New)\",\"name\":\"Connected Ledger\",\"display_name\":\"MYOB Essentials (New) Connected Ledger\"},\"account\":{\"id\":\"9174000\",\"contact\":{\"id\":\"1-NDYJSQ0\",\"identity_id\":\"cf4af747-ae77-43c2-aa95-62f8934390f2\"}},\"billing_account\":{\"id\":\"9174000\",\"contact\":{\"id\":\"1-NDYJSQ0\",\"identity_id\":\"cf4af747-ae77-43c2-aa95-62f8934390f2\"}},\"payment_profile\":{\"id\":\"1-NDYJSQC\",\"account_type\":\"SME\",\"client_id\":\"9174000\"},\"features\":[{\"name\":\"Banking\"},{\"name\":\"Online-Payments\"}]}]},\"receiptId\":\"AQEBKyoqJKCvZvuibKtGIK2vuE3pAHSNyLTLi9uoMUrtlcAbG3%2FOTF9C%2FRZ9mdhMahymjDjJPRdOuRUDcIOe7Ze0mg2O1uEhuSYJtT%2FjduZSIH1ll24Vjt6vTZOV30%2FiN%2B5nLQ8dYLInhtrPdMsi602y2TNSDkXxTZPi8st%2FjGq3JgB4CZi%2FXKICijUb2UwJrR5SxQH2oEZxHLpL8b1jxA4%2BzRVWq0nz3tKSOofKrRdjVzej6zi%2BK0Wse3Cy1TTPDDVRIKxY9hRJezSJfKttFUCFOuIa4OymkmuIg6ZBw7UswZ1OPa%2FWIxG7UVxhFu1yNNm5VpSdY96mn28wrGlTeLI7z%2FORr6zEJxlZCOU1oZmjctvB%2BogeCUrxc%2FhGHasucVbU%2Fd6ip6LF22UvuCEkOEiEITr10nfJ42egwYRjHhD5gQzvy4cxpoSCh54xxF3bJUa0bnUR55F1gyxURaiu0Oc1dQ%3D%3D\",\"messageId\":\"bc18d643-ce6a-4044-8c04-b070f1771cbb\"}]}';
    String tknRes = '{\"access_token\":\"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6IlVPR0tNNHltTFVPWkhTalh5VlcwTlVjemxLUSIsInR0eSI6ImFjY2Vzc190b2tlbiJ9.eyJpc3MiOiJodHRwczovL3NpdC5sb2dpbi5teW9iLmNvbS8iLCJzdWIiOiJzYWxlc2ZvcmNlLWVudGVycHJpc2UtY3JtIiwiYXVkIjoiMjU5NjRmMTAtYWMyYy00NDI1LWJjNjYtZDc2Y2FmZjIzODk5IiwiZXhwIjoxNTkwNTY0OTEyLCJuYmYiOjE1OTA1NjMxMTIsImlhdCI6MTU5MDU2MzExMiwianRpIjoiYzRiMmE1ZTQtMGQwZS00NjAwLTgzMTYtY2RhOGJiNTRiMjNkIiwiY2xpZW50X2lkIjoic2FsZXNmb3JjZS1lbnRlcnByaXNlLWNybSIsInNjcCI6InNlcnZpY2UuYWNjZXNzIHNlcnZpY2UuY3JlYXRlIn0.UubCYw4wE8uQAD03qstkBiilc-e6m5jAd4GWZgambqR9FMiBNlyJS80wf9BsaNKEKW54msD56zEQeQC87wkd4FEqlMdXTWaE-Ne0tYotYYIX4I7hIeJj4G-UV-jxebnlnn35_-rSKWjSrjtRWmTaBqkSpjPpuINKtCXuINxeQL5Y3wKHv8n9FzJvbwS5nE94oSpM0NZyLWJ9Hsz_dQgvHJ-Cf8OrqxLvvYASJqsJtfQzOCUIjdfLvMwsm7Y5zyaPDBhj8RXEeoQKTYJ15mnVjCOXot8j4xZP2XVuSneOokBWsOcB4RtqUCtaSvHuW2aBD81xCx7XkVGqh5OzL3bp4g\",\"token_type\":\"Bearer\",\"expires_in\":1800,\"expires_on\":1590564912,\"issued_at\":1590563112,\"resource\":\"25964f10-ac2c-4425-bc66-d76caff23899\",\"scope\":\"service.access service.create\"}';
     Test.setMock(HttpCalloutMock.class, new MYOBService_SubscriptionPollingQueMock(tknRes, response));
    MYOBService_PurchaseOpportunityUtility.SubscriptionResponse tmpSubsResp = new MYOBService_PurchaseOpportunityUtility.SubscriptionResponse();
    tmpSubsResp.receiptId = 'Test';
    tmpSubsResp.accountId = '1234';
    tmpSubsResp.contactId ='Test';
    tmpSubsResp.serialNumber = null;
    tmpSubsResp.endDate = String.valueOf(Datetime.now());
    tmpSubsResp.productId = 'test';
    tmpSubsResp.status = 'active';
    tmpSubsResp.type = 'free';
    tmpSubsResp.id = 'Test' + System.now().gettime();
    tmpSubsResp.isInsert = true;
    Test.startTest();
    try {
      Database.executeBatch(new MYOBService_SubscriptionUpdateBatch(new List<MYOBService_PurchaseOpportunityUtility.SubscriptionResponse> {tmpSubsResp}, 'PubSub Subscription Service'));
    } catch(Exception ex) {

    }
    Test.stopTest();
  }
}