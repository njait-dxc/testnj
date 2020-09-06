public with sharing class MYOBService_ProductPresentmentAPI
{
    /*
    Available methods
    =================
    [1] MYOBService_ProductPresentmentAPI.getProductsForAccount(String clientId);
    [2] MYOBService_ProductPresentmentAPI.getPromotionalPricingForAccount(String clientId, String promoCode, List <String> productIds);
    */

    private static final String API_NAME = 'Product Presentment API';
    private static final String API_PATH_PRODUCTS = '/api/products';

    public static ProductList getProductsForAccount(String clientId)
    {
        // Retrive API details for custom metadata
        MYOB_Service_API__mdt myobServiceAPI = MYOBService.getMYOBService(API_NAME);

        // Retrieve access token from Authorisation API
        MYOBService_AuthorisationAPI.AccessToken_Response accessTokenResponse = MYOBService_AuthorisationAPI.getAccessToken(myobServiceAPI.Resource_Id__c);
        
        // Define HTTP Request
        HttpRequest httpRequest = new HttpRequest();
        
        // Set HTTP Request Method
        httpRequest.setMethod('GET');
        
        // Set HTTP Request Timeout
        httpRequest.setTimeout(30000);
        
        // Set HTTP Request Endpoint
        String endpoint = myobServiceAPI.Endpoint__c;
        endpoint += API_PATH_PRODUCTS;
        endpoint += '?clientId=' + EncodingUtil.urlEncode(clientId, 'UTF-8');
        httpRequest.setEndpoint(endpoint);

        // Set HTTP Request Headers
        Map <String, String> requestHeaders = new Map <String, String>();
        requestHeaders.put('X-MYOBAPI-VERSION', 'v2');
        requestHeaders.put('Content-Type', 'application/json');
        requestHeaders.put('Authorization', 'Bearer ' + accessTokenResponse.access_token);
        for (String key : requestHeaders.keySet())
        {
            httpRequest.setHeader(key, requestHeaders.get(key));
        }

        // Send HTTP Request via APICallLogger
        HttpResponse httpResponse = APICallLogger.send(httpRequest, requestHeaders);

        // Insert API Call Logs
        APICallLogger.insertLogs();

        // Replace reserved words
        String response = httpResponse.getBody();
        response = response.replace('"limit":','"limit_x":');
        response = response.replace('"currency":','"currency_x":');

         // Deserialise JSON Response
        ProductList productList = (ProductList) JSON.deserialize(response, ProductList.class);
        
        // Return deserialised JSON Response
        return productList;
    }

    public static ProductList getPromotionalPricingForAccount(String clientId, String promoCode, List <String> productIds, String channel)
    {
        // Retrive API details for custom metadata
        MYOB_Service_API__mdt myobServiceAPI = MYOBService.getMYOBService(API_NAME);

        // Retrieve access token from Authorisation API
        MYOBService_AuthorisationAPI.AccessToken_Response accessTokenResponse = MYOBService_AuthorisationAPI.getAccessToken(myobServiceAPI.Resource_Id__c);
        
        // Define HTTP Request
        HttpRequest httpRequest = new HttpRequest();
        
        // Set HTTP Request Method
        httpRequest.setMethod('GET');
        
        // Set HTTP Request Timeout
        httpRequest.setTimeout(30000);

        // Set HTTP Request Endpoint
        String endpoint = myobServiceAPI.Endpoint__c;
        endpoint += API_PATH_PRODUCTS;
        endpoint += '?clientId' + '=' + EncodingUtil.urlEncode(clientId, 'UTF-8');
        endpoint += '&promoCode' + '=' + EncodingUtil.urlEncode(promoCode, 'UTF-8');
        for (String productId : productIds)
        {
            endpoint += '&productId' + '=' + EncodingUtil.urlEncode(productId, 'UTF-8');
        }
        endpoint += '&Channel' + '=' + EncodingUtil.urlEncode(channel, 'UTF-8');
        httpRequest.setEndpoint(endpoint);

        // Set HTTP Request Headers
        Map <String, String> requestHeaders = new Map <String, String>();
        requestHeaders.put('X-MYOBAPI-VERSION', 'v2');
        requestHeaders.put('Content-Type', 'application/json');
        requestHeaders.put('Authorization', 'Bearer ' + accessTokenResponse.access_token);
        for (String key : requestHeaders.keySet())
        {
            httpRequest.setHeader(key, requestHeaders.get(key));
        }

        // Send HTTP Request via APICallLogger
        HttpResponse httpResponse = APICallLogger.send(httpRequest, requestHeaders);

        // Insert API Call Logs
        APICallLogger.insertLogs();

        // Replace reserved words
        String response = httpResponse.getBody();
        //response = response.replace('"limit":','"limit_x":');
        //response = response.replace('"currency":','"currency_x":');

         // Deserialise JSON Response
        ProductList productList = (ProductList) JSON.deserialize(response, ProductList.class);
        
        // Return deserialised JSON Response
        return productList;
    }

    public class ProductList
    {
        public List <ProductData> data;
        public List <Included> included;
        public String error;
        public String error_description;
    }

    public class ProductData 
    {
        public ProductAttributes attributes;
        public String id;
        public ProductLink links;
        public ProductRelationships relationships;
        public String type;
    }

    public class ProductAttributes 
    {   
        public String code;
        public ProductDeal deal;
        public Integer displayOrderSequence;
        public ProductPrice listPrice;
        public String moreInfoLink;
        public ProductPrice myPrice;
        public String name;
        public List <ProductFeature> productFeatures;
        public ProductLine productLine;
        public String region;
        public String status;
        public String termsOfUseLink;
    }

    public class ProductDeal
    {
        public Integer duration;
        public Integer freePeriod;
        public Integer id;
        public String priceModificationType;
        public Decimal priceModificationValue;
        public String promotionName;
    }

    public class ProductPrice
    {
        public String currency_x;
        public String details;
        public Decimal priceTaxExclusive;
        public Decimal priceTaxInclusive;
        public Decimal taxAmount;
        public String unitOfMeasure;
    }

    public class ProductFeature
    {
        public Integer id;
        public Integer limit_x;
        public String name;
    }

    public class ProductLine
    {
        public String code;
        public Integer displayOrderSequence;
        public Integer id;
        public String name;
    }

    public class ProductLink
    {
        public String self;
    }

    public class ProductRelationships
    {
    }

    public class Included
    {
    }
}