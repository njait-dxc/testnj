/**
 * Created by Ankit.Bhardwaj on 2/07/2020.
 */

@isTest
public with sharing class TEST_MYOB_Service_ARLSubsPollingQue {
    @TestSetup
    static void createData(){
        Account testAccount = new Account(Name = 'Testing123');
        insert testAccount;
        Contact c = new Contact(FirstName = 'FN', LastName = 'LN', AccountId = testAccount.Id);
        insert c;
        String stdPbId = Test.getStandardPricebookId();
        Pricebook2 prb2 = new Pricebook2(Name = 'SME Purchase Pricebook', Description = 'SME Purchase Pricebook', IsActive = true);
        insert prb2;

    }
    @isTest
    static void test_MYOBService_SubscriptionPollingQue() {
        String response = '{\"data\":[{\"message\":{\"serial_number\":\"612382603311\",\"type\":\"paid\",\"status\":\"active\",\"product\": \"MYOB Test Drive AccountRight Live Standard - Optimus - AU\",\"product_id\": \"1\",\"contact_id\": \"1-N06XVYA\",\"client_id\": \"9174616\"},\"receiptId\":\"AQEBKyoqJKCvZvuibKtGIK2vuE3pAHSNyLTLi9uoMUrtlcAbG3%2FOTF9C%2FRZ9mdhMahymjDjJPRdOuRUDcIOe7Ze0mg2O1uEhuSYJtT%2FjduZSIH1ll24Vjt6vTZOV30%2FiN%2B5nLQ8dYLInhtrPdMsi602y2TNSDkXxTZPi8st%2FjGq3JgB4CZi%2FXKICijUb2UwJrR5SxQH2oEZxHLpL8b1jxA4%2BzRVWq0nz3tKSOofKrRdjVzej6zi%2BK0Wse3Cy1TTPDDVRIKxY9hRJezSJfKttFUCFOuIa4OymkmuIg6ZBw7UswZ1OPa%2FWIxG7UVxhFu1yNNm5VpSdY96mn28wrGlTeLI7z%2FORr6zEJxlZCOU1oZmjctvB%2BogeCUrxc%2FhGHasucVbU%2Fd6ip6LF22UvuCEkOEiEITr10nfJ42egwYRjHhD5gQzvy4cxpoSCh54xxF3bJUa0bnUR55F1gyxURaiu0Oc1dQ%3D%3D\",\"messageId\":\"bc18d643-ce6a-4044-8c04-b070f1771cbb\"}]}';
        String tknRes = '{\"access_token\":\"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6IlVPR0tNNHltTFVPWkhTalh5VlcwTlVjemxLUSIsInR0eSI6ImFjY2Vzc190b2tlbiJ9.eyJpc3MiOiJodHRwczovL3NpdC5sb2dpbi5teW9iLmNvbS8iLCJzdWIiOiJzYWxlc2ZvcmNlLWVudGVycHJpc2UtY3JtIiwiYXVkIjoiMjU5NjRmMTAtYWMyYy00NDI1LWJjNjYtZDc2Y2FmZjIzODk5IiwiZXhwIjoxNTkwNTY0OTEyLCJuYmYiOjE1OTA1NjMxMTIsImlhdCI6MTU5MDU2MzExMiwianRpIjoiYzRiMmE1ZTQtMGQwZS00NjAwLTgzMTYtY2RhOGJiNTRiMjNkIiwiY2xpZW50X2lkIjoic2FsZXNmb3JjZS1lbnRlcnByaXNlLWNybSIsInNjcCI6InNlcnZpY2UuYWNjZXNzIHNlcnZpY2UuY3JlYXRlIn0.UubCYw4wE8uQAD03qstkBiilc-e6m5jAd4GWZgambqR9FMiBNlyJS80wf9BsaNKEKW54msD56zEQeQC87wkd4FEqlMdXTWaE-Ne0tYotYYIX4I7hIeJj4G-UV-jxebnlnn35_-rSKWjSrjtRWmTaBqkSpjPpuINKtCXuINxeQL5Y3wKHv8n9FzJvbwS5nE94oSpM0NZyLWJ9Hsz_dQgvHJ-Cf8OrqxLvvYASJqsJtfQzOCUIjdfLvMwsm7Y5zyaPDBhj8RXEeoQKTYJ15mnVjCOXot8j4xZP2XVuSneOokBWsOcB4RtqUCtaSvHuW2aBD81xCx7XkVGqh5OzL3bp4g\",\"token_type\":\"Bearer\",\"expires_in\":1800,\"expires_on\":1590564912,\"issued_at\":1590563112,\"resource\":\"25964f10-ac2c-4425-bc66-d76caff23899\",\"scope\":\"service.access service.create\"}';
        Test.setMock(HttpCalloutMock.class, new MYOBService_SubscriptionPollingQueMock(tknRes, response));
        Test.startTest();
        System.enqueueJob(new MYOBService_ARLSubsPollingQue());
        Test.stopTest();
    }
    @isTest
    static void test_MYOBService_SubscriptionPollingSche() {
        String response = '{\"data\":[{\"message\":{\"serial_number\":\"612382603311\",\"type\":\"paid\",\"status\":\"active\",\"product\": \"MYOB Test Drive AccountRight Live Standard - Optimus - AU\",\"product_id\": \"1\",\"contact_id\": \"1-N06XVYA\",\"client_id\": \"9174616\"},\"receiptId\":\"AQEBKyoqJKCvZvuibKtGIK2vuE3pAHSNyLTLi9uoMUrtlcAbG3%2FOTF9C%2FRZ9mdhMahymjDjJPRdOuRUDcIOe7Ze0mg2O1uEhuSYJtT%2FjduZSIH1ll24Vjt6vTZOV30%2FiN%2B5nLQ8dYLInhtrPdMsi602y2TNSDkXxTZPi8st%2FjGq3JgB4CZi%2FXKICijUb2UwJrR5SxQH2oEZxHLpL8b1jxA4%2BzRVWq0nz3tKSOofKrRdjVzej6zi%2BK0Wse3Cy1TTPDDVRIKxY9hRJezSJfKttFUCFOuIa4OymkmuIg6ZBw7UswZ1OPa%2FWIxG7UVxhFu1yNNm5VpSdY96mn28wrGlTeLI7z%2FORr6zEJxlZCOU1oZmjctvB%2BogeCUrxc%2FhGHasucVbU%2Fd6ip6LF22UvuCEkOEiEITr10nfJ42egwYRjHhD5gQzvy4cxpoSCh54xxF3bJUa0bnUR55F1gyxURaiu0Oc1dQ%3D%3D\",\"messageId\":\"bc18d643-ce6a-4044-8c04-b070f1771cbb\"}]}';
        String tknRes = '{\"access_token\":\"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6IlVPR0tNNHltTFVPWkhTalh5VlcwTlVjemxLUSIsInR0eSI6ImFjY2Vzc190b2tlbiJ9.eyJpc3MiOiJodHRwczovL3NpdC5sb2dpbi5teW9iLmNvbS8iLCJzdWIiOiJzYWxlc2ZvcmNlLWVudGVycHJpc2UtY3JtIiwiYXVkIjoiMjU5NjRmMTAtYWMyYy00NDI1LWJjNjYtZDc2Y2FmZjIzODk5IiwiZXhwIjoxNTkwNTY0OTEyLCJuYmYiOjE1OTA1NjMxMTIsImlhdCI6MTU5MDU2MzExMiwianRpIjoiYzRiMmE1ZTQtMGQwZS00NjAwLTgzMTYtY2RhOGJiNTRiMjNkIiwiY2xpZW50X2lkIjoic2FsZXNmb3JjZS1lbnRlcnByaXNlLWNybSIsInNjcCI6InNlcnZpY2UuYWNjZXNzIHNlcnZpY2UuY3JlYXRlIn0.UubCYw4wE8uQAD03qstkBiilc-e6m5jAd4GWZgambqR9FMiBNlyJS80wf9BsaNKEKW54msD56zEQeQC87wkd4FEqlMdXTWaE-Ne0tYotYYIX4I7hIeJj4G-UV-jxebnlnn35_-rSKWjSrjtRWmTaBqkSpjPpuINKtCXuINxeQL5Y3wKHv8n9FzJvbwS5nE94oSpM0NZyLWJ9Hsz_dQgvHJ-Cf8OrqxLvvYASJqsJtfQzOCUIjdfLvMwsm7Y5zyaPDBhj8RXEeoQKTYJ15mnVjCOXot8j4xZP2XVuSneOokBWsOcB4RtqUCtaSvHuW2aBD81xCx7XkVGqh5OzL3bp4g\",\"token_type\":\"Bearer\",\"expires_in\":1800,\"expires_on\":1590564912,\"issued_at\":1590563112,\"resource\":\"25964f10-ac2c-4425-bc66-d76caff23899\",\"scope\":\"service.access service.create\"}';
        Test.setMock(HttpCalloutMock.class, new MYOBService_SubscriptionPollingQueMock(tknRes, response));
        Test.startTest();
        String jobId = System.schedule('testScheduleJob','0 0 0 3 9 ? 2022',new MYOBService_ARLSubsPollingSchedular());
        Test.stopTest();
    }

}