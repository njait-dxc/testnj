/*
    Date            : 27-10-2016
    Author          : SMS Management & Technology
    Description     : UT class for LP_ErrorLogHandler
*/
@IsTest
public with sharing class LP_ErrorLogHandler_UT {
    
    // Creating an error log successfully
    public static testMethod void testErrorLog() {
        LP_ErrorLogHandler.log('ErrorMessage','ExceptionMessage','Element');        
        List<LP_Error_Log__c> lstErr = [SELECT Id FROM LP_Error_Log__c];
        System.assertEquals(lstErr.size(), 1, true);
    }
    
    // Creating an error log that contains details about the job
    public static testMethod void testListErrorLogging() {
        LP_ErrorLogHandler.log('ErrorMessage', 'ExceptionMessage','Element','GUID001','SaleforceID1001','CorrelationID1001');
        List<LP_Error_Log__c> lstErr = [SELECT Id FROM LP_Error_Log__c];
        System.assertEquals(lstErr.size(), 1, true);
    }
    
    // Building a list of error log
    public static testMethod void testBuildErrorLog() {
        LP_Error_Log__c objErrLog = new LP_Error_Log__c();  
        objErrLog = LP_ErrorLogHandler.buildLog('ErrorMessage', 'ExceptionMessage','Element','GUID001','SaleforceID1001','CorrelationID1001');
        insert objErrLog;
        List<LP_Error_Log__c> lstErr = [SELECT Id FROM LP_Error_Log__c];
        System.assertEquals(lstErr.size(), 1, true);
    }
}