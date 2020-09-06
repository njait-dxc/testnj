/**
 * Created by Ankit.Bhardwaj on 22/06/2020.
 */

@IsTest
public with sharing class TEST_MYOBService_CustomerInsightMaster {

    @TestSetup
    static void setupData()
    {
        Account vAcc = (Account)TestDataFactory.createSObject(new Account(Client_Id__c = '12345' , Name = 'Test Account') , true);
        Customer_Insights__c ciList = (Customer_Insights__c)TestDataFactory.createSObject(new Customer_Insights__c(Client_Id__c = '12345', Practice_AMV__c = 55, SME_AMV__c = 55, Total_Practice_Value__c = 110 ), true);
        Customer_Insights__c ciList1 = (Customer_Insights__c)TestDataFactory.createSObject(new Customer_Insights__c(Client_Id__c = '12345', Practice_AMV__c = 55, SME_AMV__c = 55, Total_Practice_Value__c = 110 ), true);
        Customer_Insights__c ciList2 = (Customer_Insights__c)TestDataFactory.createSObject(new Customer_Insights__c(Client_Id__c = '12345', Practice_AMV__c = 55, SME_AMV__c = 55, Total_Practice_Value__c = 110, Latest_Record__c = false, Account__c = vAcc.Id), true);
        Customer_Insights__c ciList3 = (Customer_Insights__c)TestDataFactory.createSObject(new Customer_Insights__c(Client_Id__c = '6789', Practice_AMV__c = 55, SME_AMV__c = 55, Total_Practice_Value__c = 110 ), true);

    }

    @IsTest
    static void testCIMasterJob()
    {
        Test.startTest();
        MYOBService_CustomerInsightMasterBatch bupp = new MYOBService_CustomerInsightMasterBatch();
        Database.executeBatch(bupp);
        Test.stopTest();
        Customer_Insights__c ci = [select Account__c, Latest_Record__c from Customer_Insights__c where Client_Id__c = '12345'];
        List<Customer_Insights__c> ciOrphan = [select Account__c, Latest_Record__c from Customer_Insights__c where Client_Id__c = '6789'];
        Account acc = [select Id from Account];
        System.assertEquals(ci.Account__c,acc.Id);
        System.assertEquals(ci.Latest_Record__c,false);
        System.assertEquals(0,ciOrphan.size());
    }

}