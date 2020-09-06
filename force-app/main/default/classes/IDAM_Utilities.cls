public class IDAM_Utilities {
    
  /*  // Get IDAM token
    public static String getToken(String resource) {
      
    //HttpRequest request = new HttpRequest();

    HttpRequest httpRequest = new HttpRequest();
    httpRequest.setMethod('POST');
    httpRequest.setEndpoint('callout:IDAM_OAuth');
    httpRequest.setHeader('Content-Length', '0');
    httpRequest.setBody('grant_type=client_credentials&resource='+resource);

    try {
      /*Http http = new Http();
      HttpResponse response = http.send(request);

      HttpResponse httpResponse = http.send(request);
      Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
      return String.valueOf(jsonResponse.get('access_token'));    
    } catch(exception e) {
       return null;
    }
  }  */


    // Get IDAM token
    public static String getToken(String resource) {

        //HttpRequest request = new HttpRequest();

        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('POST');
        httpRequest.setEndpoint('callout:IDAM_OAuth');
        httpRequest.setBody('grant_type=client_credentials&resource='+resource);
         
        // Set HTTP Request Headers
        Map <String, String> requestHeaders = new Map <String, String>();
        requestHeaders.put('Content-Length', '0');

        for (String key : requestHeaders.keySet())
        {
            httpRequest.setHeader(key, requestHeaders.get(key));
        }
               
        try {
            // Send HTTP Request via APICallLogger
            HttpResponse httpResponse = APICallLogger.send(httpRequest,requestHeaders);

            // Insert API Call Logs
            //APICallLogger.insertLogs();


            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
            return String.valueOf(jsonResponse.get('access_token'));
        } catch(Exception e) {
            return null;
        }
    }

 }