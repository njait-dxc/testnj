/**
 * @Author : Nikhil Jaitly
 * @Created Date : 29/06/2020
 * @Description : Test class for MyOBService_RemoteLogsQueueable
 */
@isTest
public with sharing class TEST_MyOBService_RemoteLogsQueueableTest {
  @isTest
  static void test_MyOBService_RemoteLogsQueueableTeste() {
    Test.setMock(HttpCalloutMock.class, new MYOBService_RemoteLogsMock());
    List<Exception_Log__c> logs = new List<Exception_Log__c>();
    Test.startTest();
      for(Integer i = 0 ; i < 20 ; i++) {
        logs.add(TestDataFactory.getExceptionLog('Test Description', 'Test Detail', 'Error', 'TEST_MyOBService_RemoteLogsQueueableTest', 'test_MyOBService_RemoteLogsQueueableTeste'));
      }
      insert logs; 
    Test.stopTest();
    List<Exception_Log__c> elogs = [SELECT Id
                                    FROM Exception_Log__c];
    System.assert(elogs.size() == 20);
  }
  @isTest
  static void test_insertRemoteLogs() {
    Test.setMock(HttpCalloutMock.class, new MYOBService_RemoteLogsMock());
    List<Exception_Log__c> logs = new List<Exception_Log__c>();
    List<String> exLogs = new List<String>();
    Test.startTest();
      for(Integer i = 0 ; i < 20 ; i++) {
        logs.add(TestDataFactory.getExceptionLog('Test Description', 'Test Detail', 'Error', 'TEST_MyOBService_RemoteLogsQueueableTest', 'test_MyOBService_RemoteLogsQueueableTeste'));
      }
      insert logs; 
      for(Exception_Log__c el : [SELECT Id, Exception_Description__c
                                 FROM Exception_Log__c]) {
        exLogs.add(el.Exception_Description__c);
      }
      MyOBService_LogUtility.insertRemoteLogs(exLogs);
    Test.stopTest();
    System.assert(exLogs.size() == 20);
  }
}