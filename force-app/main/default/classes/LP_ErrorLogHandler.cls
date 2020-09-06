/*
    Date            : 27-10-2016
    Author          : SMS Management & Technology
    Description     : Loggin errors associated to the project on Error Log object
*/
public class LP_ErrorLogHandler {
    
    public static void log(String Message, String ExceptionMsg, String Element) {
        
        LP_Error_Log__c objErrLog = new LP_Error_Log__c();
        objErrLog.LP_Error_Message__c = Message;
        objErrLog.LP_Exception__c = ExceptionMsg;
        objErrLog.LP_Element__c = Element;
        
        Database.insert(objErrLog, false);
    }
    
    public static void log(String Message, String ExceptionMsg, String Element, String GUID, String SalesforceID, String CorrelationID) {
        
        LP_Error_Log__c objErrLog = new LP_Error_Log__c();
        objErrLog.LP_Error_Message__c = Message;
        objErrLog.LP_Exception__c = ExceptionMsg;
        objErrLog.LP_Element__c = Element;
        objErrLog.LP_GUID__c = GUID;
        objErrLog.LP_Salesforce_ID__c = SalesforceID;
        objErrLog.LP_Correlation_ID__c = CorrelationID;
        
        Database.insert(objErrLog, false);
    }
    
    public static LP_Error_Log__c buildLog(String Message, String ExceptionMsg, String Element, String GUID, String SalesforceID, String CorrelationID) {
        
        LP_Error_Log__c objErrLog = new LP_Error_Log__c();
        objErrLog.LP_Error_Message__c = Message;
        objErrLog.LP_Exception__c = ExceptionMsg;
        objErrLog.LP_Element__c = Element;
        objErrLog.LP_GUID__c = GUID;
        objErrLog.LP_Salesforce_ID__c = SalesforceID;
        objErrLog.LP_Correlation_ID__c = CorrelationID;
        
        return objErrLog;
    }
}