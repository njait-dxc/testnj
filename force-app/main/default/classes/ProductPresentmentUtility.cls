public class ProductPresentmentUtility {

    public static String GetProductId(String region, String code, String searchCriteria)
    {   
        String presentmentResource = getProductPresentmentResource();
        String IDAMAPIToken = getIDAMToken(presentmentResource);
        String reqURL = getPresentmentURL(searchCriteria);
        String responseJSON = getProductPresentmentData(reqURL,IDAMAPIToken);
        String ProductId = parseResponse(responseJSON,region,code);
        return ProductId;
   } 
    public static String getProductPresentmentResource()
    {
        LP_PP_Resource__c ppResource = LP_PP_Resource__c.getOrgDefaults();
        return ppResource.Name;
    }
    
    public static String getIDAMToken(String resourceName)
    {
       String PPAPIToken = IDAM_Utilities.getToken(resourceName);
       return PPAPIToken;
    }
    
    public static String getPresentmentURL(String searchCriteria)
    {
        ProductPresentmentURL__c PrsntmntResource = ProductPresentmentURL__c.getOrgDefaults();
        String PrsntmntURL = PrsntmntResource.Name;
        String PrsntmntEndpoint = PrsntmntURL+'.core-services.myob.com/api/products?'+searchCriteria;
        return PrsntmntEndpoint;
    }
    
    public static String getProductPresentmentData(String PrsntmntEndpoint,String PPAPIToken)
    {
        String productPresentmentResponse = PP_Onboarding_Util.getData('GET',PrsntmntEndpoint,PPAPIToken);
        return productPresentmentResponse;
    }
    
    public static String parseResponse(String productPresentmentResponse,String region, String code)
    {
         String fetchedRegion;
         String fetchedCode;
         String ProductId;
         Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(productPresentmentResponse);
         List<Object> responseData = (List<Object>)responseMap.get('data'); 
    
        for (Object obj: responseData)
        {
             Map<String, Object> recordMap = (Map<String, Object>)obj;
             Map<String, Object> attributesMap = (Map<String, Object>)recordMap.get('attributes');
             fetchedRegion = String.valueOf(attributesMap.get('region'));
             fetchedCode = String.valueOf(attributesMap.get('code'));
        
            for(String key: recordMap.keySet())
            {
                if (fetchedRegion == region && fetchedCode == code)
                {
                    if (key == 'id')
                    {
                        ProductId = String.valueOf(recordMap.get('id'));
                        
                        
                    }
                }
            }
            
            if (ProductId != null)
             {
                break;
             }
            }
          return ProductId;
    }
}