/**
 * @Author : Nikhil Jaitly
 * @Created Date : 27/06/2020
 * @Description : Test class for BatchDeleteExceptionLogsTest
 */
@isTest
public with sharing class BatchDeleteExceptionLogsTest {
  @testSetup
  static void createData(){
    List<Exception_Log__c> logs = new List<Exception_Log__c>();
    Exception_Log__c log1, log2;
    String descrp = 'Update failed. First exception on row 0 with id 0060p000007lOm2AAE; first error: CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, TRIG_Account: execution of AfterUpdate caused by: System.AsyncException: Future method cannot be called from a future or batch method: TRIG_Account_TriggerHandler.processAccount_AfterUpdate(Set<Id>, String, String) Class.TRIG_Account_TriggerHandler.afterUpdate: line 33, column 1 Class.TriggerHandler.run: line 53, column 1 Trigger.TRIG_Account: line 7, column 1: []';
    logs.add(log1 = TestDataFactory.getExceptionLog(descrp, 'Class.MYOBService_PurchaseOpportunityUtility.updateExistingOpportunities', 'System.DmlException', 'MYOBService_PurchaseOpportunityUtility', 'updateExistingOpportunities'));
    logs.add(log2 = TestDataFactory.getExceptionLog(descrp, 'Class.MYOBService_PurchaseOpportunityUtility.updateExistingOpportunities', 'System.DmlException', 'MYOBService_PurchaseOpportunityUtility', 'updateExistingOpportunities'));
    insert logs;
    Test.setCreatedDate(log1.Id, Date.today().addDays(-31));
    Test.setCreatedDate(log2.Id, Date.today().addDays(-31));

  }
  @isTest
  static void test_BatchDeleteExceptionLogs() {
    Test.startTest();
      Database.executeBatch(new BatchDeleteExceptionLogs());
    Test.stopTest();
    List<Exception_Log__c> logs = [SELECT Id
                                   FROM Exception_Log__c];
    System.assert(logs.isEmpty());
  }
  @isTest
  static void test_BatchDeleteExceptionLogsSchedule() {
    Test.startTest();
      BatchDeleteExceptionLogsSchedule vBDIC1 = new BatchDeleteExceptionLogsSchedule();
      String sch = '0  00 1 3 * ?';
      System.schedule('Test', sch, vBDIC1);
    Test.stopTest();
    List<Exception_Log__c> logs = [SELECT Id
                                   FROM Exception_Log__c];
    System.assert(!logs.isEmpty());
  }
}