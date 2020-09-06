public class PP_Onboarding_Util {    

   // Post to endpoint    
    public static Integer postData(String requestType, String endPoint, String accessToken, String jsonData) {
      
    HttpRequest request = new HttpRequest();
    request.setMethod('POST');
    request.setEndpoint(endPoint);
  //  request.setHeader('X-MYOBAPI-VERSION', 'v2');
    //request.setHeader('Authorization', 'Bearer ' + accessToken);
    //request.setHeader('Content-Type','application/json');
    request.setTimeout(90000);
    if (jsonData != null)
    {
        request.setBody(jsonData);   
    }

      Map <String, String> requestHeaders = new Map <String, String>();
        requestHeaders.put('X-MYOBAPI-VERSION', 'v2');
        requestHeaders.put('Authorization', 'Bearer ' + accessToken);
         requestHeaders.put('Content-Type', 'application/json');
        for (String key : requestHeaders.keySet())
        {
            request.setHeader(key, requestHeaders.get(key));
        }
    
    Http http = new Http();
    //HttpResponse response = http.send(request);
     HttpResponse response = APICallLogger.send(request,requestHeaders);
    return response.getStatusCode();
    }  
    
    public static String getData(String requestType, String endPoint, String accessToken) {     
    HttpRequest request = new HttpRequest();
    request.setMethod(requestType);
    request.setEndpoint(endPoint);
   // request.setHeader('X-MYOBAPI-VERSION', 'v2');
  //  request.setHeader('Authorization', 'Bearer ' + accessToken);
   // request.setHeader('Content-Type','application/json');
    request.setTimeout(30000);    
    Map <String, String> requestHeaders = new Map <String, String>();
        requestHeaders.put('X-MYOBAPI-VERSION', 'v2');
        requestHeaders.put('Authorization', 'Bearer ' + accessToken);
         requestHeaders.put('Content-Type', 'application/json');
        for (String key : requestHeaders.keySet())
        {
            request.setHeader(key, requestHeaders.get(key));
        }

    Http http = new Http();
      HttpResponse response = APICallLogger.send(request,requestHeaders);
    return response.getBody();
    }       
}