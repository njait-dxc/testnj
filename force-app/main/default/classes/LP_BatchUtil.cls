/*
    Date            : 27-10-2016
    Author          : SMS Management & Technology
    Description     : Batch class utility
*/
public class LP_BatchUtil {
    
    // Get IDAM token
    public static String getToken(Id jobId, String element) {
        
        // Get the resource needed to be defined in the request body
        LP_Resource__c resource = LP_Resource__c.getOrgDefaults();

        HttpRequest request = new HttpRequest();    
        request.setMethod('POST');
        request.setEndpoint('callout:MYOB_Oauth');
       // request.setHeader('Content-Length', '0');
        request.setBody('grant_type=client_credentials&resource='+resource.Name);

          Map <String, String> requestHeaders = new Map <String, String>();
        requestHeaders.put('Content-Length', '0');

        for (String key : requestHeaders.keySet())
        {
            request.setHeader(key, requestHeaders.get(key));
        }

        try {
            Http http = new Http();
            HttpResponse response = APICallLogger.send(request,requestHeaders);
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            return String.valueOf(jsonResponse.get('access_token'));        
        } catch(Exception e) {
            LP_ErrorLogHandler.log('Failure to retrieve access token', String.valueOf(e), element, '', '', String.valueOf(jobId));
            return null;
        }
    }
    
    // Post to endpoint    
    public static Integer postData(String requestType, String endPoint, String accessToken, String jsonData) {
        
    /*    HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        if(requestType == 'PATCH') { 
            request.setHeader('X-HTTP-Method-Override','PATCH'); 
        }
        request.setEndpoint(endPoint);
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type','application/json');
        request.setBody(jsonData);  

        Http http = new Http();
        HttpResponse response = http.send(request);
        
        return response.getStatusCode(); */

        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('POST');
        if(requestType == 'PATCH') {
            httpRequest.setHeader('X-HTTP-Method-Override','PATCH');
        }
        httpRequest.setEndpoint(endPoint);
        httpRequest.setHeader('Authorization', 'Bearer ' + accessToken);
       // httpRequest.setHeader('Content-Type','application/json');
        httpRequest.setBody(jsonData);

         Map <String, String> requestHeaders = new Map <String, String>();
        requestHeaders.put('Content-Type','application/json');

        for (String key : requestHeaders.keySet())
        {
            httpRequest.setHeader(key, requestHeaders.get(key));
        }

        //Http http = new Http();
      //  HttpResponse httpResponse = APICallLogger.send(httpRequest, null);
      HttpResponse httpResponse = APICallLogger.send(httpRequest,requestHeaders);

        // Insert API Call Logs
        APICallLogger.insertLogs();

        return httpResponse.getStatusCode();

    }  
    
    // Send email on job completion
    public static void sendEmail(String subject,Id jobID, Boolean hasError) {
        // Get apex job details
        AsyncApexJob theJob = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, ExtendedStatus 
                                                                                                                FROM AsyncApexJob 
                                                                                                                WHERE Id = :jobID];     
        // Get the email address from custom setting 
        LS_Email_Group__c emailgrp = LS_Email_Group__c.getOrgDefaults();

        // Email with error status to be sent out on completion of the job
        String jobStatus = 'no errors.';
        if(hasError) {
            jobStatus = 'errors.';
        } 
        
        // Create url to access the Salesforce erorr log object                                                                                                         
        String baseUrl = System.Url.getSalesforceBaseUrl().toExternalForm();
        Schema.DescribeSObjectResult objErrorLog = LP_Error_Log__c.SObjectType.getDescribe();
        String objErrorURL = baseUrl + '/' +objErrorLog.getKeyPrefix();

        // Create and send the email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setUseSignature(false);
        mail.setToAddresses(new String[] {emailgrp.Name,UserInfo.getUserEmail()}); // Email group from custom setting + user who manually triggers
        mail.setSubject(subject + theJob.Status);
        mail.setHtmlBody('<p>Hi <br/><br/>The batch Apex job processed ' + theJob.TotalJobItems + ' batches with '+ jobStatus +
                         '<br/><br/>Correlation ID : ' + jobID +
                         '<br/><br/><a href="'+ objErrorURL +'">'+ objErrorURL +'</a><br/><br/>MYOB<br/><br/></p>');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    }
    
    // Combined email for all jobs
    public static void sendEmail(List<Map<String, Object>> jobStatus) {
        String message = '';
        for(Map<String, Object> lstJobs : jobStatus) {
            message +='<tr>' +
                        '<td> ' + lstJobs.get('name') + ' </td>'+
                        '<td> ' + lstJobs.get('id') + ' </td>'+
                        '<td> ' + lstJobs.get('hasError') + ' </td>'+
                    '</tr>' ;
        }
        
        // Get the email address from custom setting 
        LS_Email_Group__c emailgrp = LS_Email_Group__c.getOrgDefaults();
        
        // Create url to access the Salesforce erorr log object                                                                                                         
        String baseUrl = System.Url.getSalesforceBaseUrl().toExternalForm();
        Schema.DescribeSObjectResult objErrorLog = LP_Error_Log__c.SObjectType.getDescribe();
        String objErrorURL = baseUrl + '/' +objErrorLog.getKeyPrefix();

        // Create and send the email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setUseSignature(false);
        mail.setToAddresses(new String[] {emailgrp.Name,UserInfo.getUserEmail()}); // Email group from custom setting + user who manually triggers
        mail.setSubject('Partner Central Job Status');
        mail.setHtmlBody('<p>Hi<br/><br/>The batch jobs have completed. Here are the details :<br/><table><tr><th>Job</th><th>Correlation Id</th><th>Has Error</th>' + message
                            + '</table><br/>Find error logs at : <a href="'+ objErrorURL +'">'+ objErrorURL +'</a><br/><br/>MYOB<br/><br/></p>');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    }
}