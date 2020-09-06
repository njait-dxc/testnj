@IsTest
public with sharing class ProductPresentmentUtility_UT {

    @TestSetup static void setUpData()
    {
        LP_PP_Resource__c ppResource = new LP_PP_Resource__c();
        ppResource.Name='test123';
        insert ppResource;
        
        ProductPresentmentURL__c PrsntmntResource = new ProductPresentmentURL__c();
        PrsntmntResource.Name= 'https://sit-product-presentment';
        insert PrsntmntResource;
    }
    
    @IsTest static void getProductPresentmentResource()
    {
        LP_PP_Resource__c ppResource = [SELECT Id, Name FROM LP_PP_Resource__c];
        String resourceName = ProductPresentmentUtility.getProductPresentmentResource();
        System.assertEquals(resourceName, 'test123');
    }
    
    @IsTest static void getIDAMToken()
    {          
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        String IDAMToken = ProductPresentmentUtility.getIDAMToken('test123');
        System.assertEquals(IDAMToken, 'abcde');
    }
    
    @IsTest static void getPresentmentURL()
    {   
        ProductPresentmentURL__c PrsntmntResource = [SELECT Id, Name FROM ProductPresentmentURL__c];
        String reqURL = ProductPresentmentUtility.getPresentmentURL('catalog=PARTNER_PROGRAM');
        System.assertEquals(reqURL, 'https://sit-product-presentment.core-services.myob.com/api/products?catalog=PARTNER_PROGRAM');
    }
    
    @IsTest static void getProductPresentmentData()
    {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ProductPresentmentResponse');
        mock.setStatusCode(200); // Or other appropriate HTTP status code
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        String response = ProductPresentmentUtility.getProductPresentmentData('https://sit-product-presentment.core-services.myob.com/api/products?catalog=PARTNER_PROGRAM','12345');
        System.assertNotEquals(response,null);
    }
    
    @IsTest static void parseResponse()
    {          
        String responseJSON = '{"data":[{"type":"products","id":"20","attributes":{"termsOfUseLink":null,"productLine":{"code":"ONLINEPARTNER","name":"OnlinePartner","displayOrderSequence":40,"id":4},"productFeatures":[],"code":"OP","myPrice":{"currency":"AUD","priceTaxInclusive":0.0,"priceTaxExclusive":0.0,"taxAmount":0.0,"unitOfMeasure":"Month","details":null},"dealId":null,"name":"Online Partner","region":"AU","listPrice":{"currency":"AUD","priceTaxInclusive":0.0,"priceTaxExclusive":0.0,"taxAmount":0.0,"unitOfMeasure":"Month","details":null},"displayOrderSequence":0,"moreInfoLink":null,"status":"ACTIVE"},"relationships":{},"links":{"self":"https://sit-product-presentment.core-services.myob.com/api/products/20"}}],"included":[]}';
        String prodId = ProductPresentmentUtility.parseResponse(responseJSON,'AU','OP');
        System.assertEquals(prodId, '20');
    }
}