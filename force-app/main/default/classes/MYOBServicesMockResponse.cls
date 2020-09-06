@IsTest
global class MYOBServicesMockResponse implements HttpCalloutMock{

    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        String responseStr = '';
        MYOB_Service_API__mdt myobPricingServiceAPI = MYOBService.getMYOBService('Pricing Service API');
        MYOB_Service_API__mdt myobProductPresentmentServiceAPI = MYOBService.getMYOBService('Product Presentment API');
        MYOB_Service_API__mdt myobBillingServiceAPI = MYOBService.getMYOBService('Billing API');
        MYOB_Service_API__mdt myobPurchasingServiceAPI = MYOBService.getMYOBService('Purchasing API');
        MYOB_Service_API__mdt myobPubSubAPI = MYOBService.getMYOBService('PubSub Order Tracking Service');
    //    MYOB_Service_API__mdt myobPurchasingBulkServiceAPI = MYOBService.getMYOBService('Purchasing API Bulk');
        if(req.getEndpoint().startsWith(myobPricingServiceAPI.Endpoint__c)){
            responseStr = '[{ '
                    +'"deal" : {'
                    +'"availableUntil" : "2019-12-31",'
                    +'"freePeriod" : 0,'
                    +'"effectiveUntil" : "2020-04-03",'
                    +'"name" : "25% off Online 25% Off Discount AU EA"'
                    +'},'
                    +'"status" : "active",'
                    +'"promoCode" : "ONLINEONLY25PCTOFF",'
                    +'"promotionTerms" : "http://www.myob.com/",'
                    +'"displayName" : "25% Off",'
                    +'"name" : "Online 25% Off Discount",'
                    +'"id" : 155'
                    +'}, {'
                    +'"deal" : {'
                    +'"availableUntil" : "2019-04-30",'
                    +'"freePeriod" : 0,'
                    +'"effectiveUntil" : "2019-07-03",'
                    +'"name" : "50% off Online 50% Off Discount AU EA"'
                    +'},'
                    +'"status" : "active",'
                    +'"promoCode" : "ONLINEONLY50PCTOFF",'
                    +'"promotionTerms" : "http://www.myob.com/",'
                    +'"displayName" : "50% Off",'
                    +'"name" : "Online 50% Off Discount",'
                    +'"id" : 181'
                    +'}, {'
                    +'"deal" : {'
                    +'"availableUntil" : "2020-06-30",'
                    +'"freePeriod" : 60,'
                    +'"effectiveUntil" : "2020-06-30",'
                    +'"name" : "$19.0909 fixed BL Bespoke 1 60 Day Free AU EA"'
                    +'},'
                    +'"status" : "active",'
                    +'"promoCode" : "BLBS160DAYFREE",'
                    +'"promotionTerms" : "http://www.myob.com/",'
                    +'"displayName" : "BankLink loyalty",'
                    +'"name" : "BL Bespoke 1 60 Day Free",'
                    +'"id" : 118'
                    +'}, {'
                    +'"deal" : {'
                    +'"availableUntil" : "2019-06-30",'
                    +'"freePeriod" : 30,'
                    +'"effectiveUntil" : "2020-06-30",'
                    +'"name" : "Banklink Migration Bespoke 1 Partner AU - EA"'
                    +'},'
                    +'"status" : "active",'
                    +'"promoCode" : "Banklink Transition Pricing - Bespoke-1",'
                    +'"promotionTerms" : "http://www.myob.com/",'
                    +'"displayName" : "Banklink Transition Pricing - Bespoke-1",'
                    +'"name" : "Banklink Transition Pricing - Bespoke-1",'
                    +'"id" : 10'
                    +'}, {'
                    +'"deal" : {'
                    +'"availableUntil" : "2020-06-30",'
                    +'"freePeriod" : 90,'
                    +'"effectiveUntil" : "2020-06-30",'
                    +'"name" : "$19.0909 fixed BL Bespoke 1 90 Day Free AU EA"'
                    +'},'
                    +'"status" : "active",'
                    +'"promoCode" : "BLBS190DAYFREE",'
                    +'"promotionTerms" : "http://www.myob.com/",'
                    +'"displayName" : "BankLink loyalty",'
                    +'"name" : "BL Bespoke 1 90 Day Free",'
                    +'"id" : 103'
                    +'}]';
        }else if(req.getEndpoint().startsWith(myobProductPresentmentServiceAPI.Endpoint__c)){
            responseStr = '{'
                    +'"included" : [ ],'
                    +'"data" : [ {'
                    +'"links" : {'
                    +'"self" : "https://product-presentment.core-services.myob.com/api/products/7"'
                    +'},'
                    +'"relationships" : { },'
                    +'"attributes" : {'
                    +'"status" : "ACTIVE",'
                    +'"moreInfoLink" : "https://www.myob.com/au/accounting-software/essentials#anchor-pricing",'
                    +'"displayOrderSequence" : 50,'
                    +'"listPrice" : {'
                    +'"details" : null,'
                    +'"unitOfMeasure" : "Month",'
                    +'"taxAmount" : 4.36,'
                    +'"priceTaxExclusive" : 43.64,'
                    +'"priceTaxInclusive" : 48.0,'
                    +'"currency" : "AUD"'
                    +'},'
                    +'"region" : "AU",'
                    +'"name" : "Accounting",'
                    +'"myPrice" : {'
                    +'"details" : null,'
                    +'"unitOfMeasure" : "Month",'
                    +'"taxAmount" : 3.27,'
                    +'"priceTaxExclusive" : 32.73,'
                    +'"priceTaxInclusive" : 36.0,'
                    +'"currency" : "AUD"'
                    +'},'
                    +'"code" : "EA",'
                    +'"deal" : {'
                    +'"duration" : 24,'
                    +'"freePeriod" : 30,'
                    +'"priceModificationType" : "Percentage",'
                    +'"priceModificationValue" : 25.0,'
                    +'"promotionName" : "Gold status",'
                    +'"id" : 3'
                    +'},'
                    +'"productFeatures" : [ {'
                    +'"limit" : null,'
                    +'"name" : "Banking",'
                    +'"id" : 25'
                    +'}, {'
                    +'"limit" : null,'
                    +'"name" : "Invoices",'
                    +'"id" : 26'
                    +'}, {'
                    +'"limit" : null,'
                    +'"name" : "Purchases",'
                    +'"id" : 27'
                    +'}, {'
                    +'"limit" : null,'
                    +'"name" : "Online-Payments",'
                    +'"id" : 28'
                    +'}, {'
                    +'"limit" : 1,'
                    +'"name" : "Payroll",'
                    +'"id" : 29'
                    +'} ],'
                    +'"productLine" : {'
                    +'"id" : 2,'
                    +'"displayOrderSequence" : 10,'
                    +'"name" : "MYOB Essentials",'
                    +'"code" : "ESSENTIALS"'
                    +'},'
                    +'"termsOfUseLink" : "http://www.myob.com/essentials/terms"'
                    +'},'
                    +'"id" : "7",'
                    +'"type" : "products"'
                    +'} ]'
                    +'}';
        }else if(req.getEndpoint().startsWith(myobBillingServiceAPI.Endpoint__c)){
            responseStr = '[ {'
                    +'"direct_debit" : {'
                    +'"account_number" : "000000000",'
                    +'"bsb" : "123456",'
                    +'"bank_name" : "Test Data Ltd"'
                    +'},'
                    +'"primary_profile" : false,'
                    +'"status" : "Active",'
                    +'"payment_method" : "Direct Debit",'
                    +'"payment_schedule" : "Monthly",'
                    +'"contact" : {'
                    +'"id" : "1-ABCD4"'
                    +'},'
                    +'"id" : "1-DEFG3"'
                    +'}, {'
                    +'"credit_card" : {'
                    +'"expiry_year" : "2024",'
                    +'"expiry_month" : "1",'
                    +'"type" : "MasterCard",'
                    +'"last_four_digits" : "0008",'
                    +'"card_token" : "3IWDQQ7K2IGRW58T",'
                    +'"name_on_card" : "MYOB Team"'
                    +'},'
                    +'"primary_profile" : false,'
                    +'"status" : "Active",'
                    +'"payment_method" : "Credit Card",'
                    +'"payment_schedule" : "Monthly",'
                    +'"contact" : {'
                    +'"id" : "1-MX9UWX9"'
                    +'},'
                    +'"id" : "1-MXF90AD"'
                    +'}, {'
                    +'"direct_debit" : {'
                    +' "account_number" : "0000000000",'
                    +'"bsb" : "123456",'
                    +'"bank_name" : "Test Data Ltd"'
                    +'},'
                    +'"primary_profile" : false,'
                    +'"status" : "Inactive",'
                    +'"payment_method" : "Direct Debit",'
                    +'"payment_schedule" : "Monthly",'
                    +'"contact" : {'
                    +' "id" : "1-ABCD6"'
                    +'},'
                    +'"id" : "1-DEFG7"'
                    +'}]';
        }else if(req.getEndpoint().startsWith(myobPurchasingServiceAPI.Endpoint__c))
        {
            responseStr = '{ ' +
            '"data": [{' + '"id" : "P123456",' +
            '"type": "purchases",'+
            '"attributes": {' +
            '"account": {' +
            '"legalEntity": "MYOB Australia Pty Ltd",'+
            '"name": "business name",'+
            '"contact": {' +
            '"emailId": "testfullcc1234@cc.com",'+
            '"firstName": "Test",'+
            '"lastName": "Full CC",'+
            '"phoneNumber": "+611234567890"'+
            '}'+
            '},'+
            '"products": ['+
            '{'+
            '"productId": 7,'+
            '"productInstanceId": "A123456",'+
            //'"lineItemId": "245190",'+
            '"serialNumber": "12345678"'+
            '}'+
            '],'+
            '"referringAccount": {'+
            '"id": "8952613",'+
            '"referringContact": {'+
            '"id": "1-DG304PI"'+
            '}'+
            '},'+
            '"sourceInitiative": "PARTNERDASHBOARD"'+
            '},'+
            '"links": {' +
            '"self": "https://test.com"'+
            '},'+
            '"meta": {' +
            '"purchaseBatchId": "6746-15886",'+
            '"newProductPurchase": true'+
            '}'+
            '}]'+
            '}';
        }else if(req.getEndpoint().startsWith(myobPubSubAPI.Endpoint__c))
        {
            responseStr = '{' +
            '"data": [' +
            '{' +
            '"message": {' +
            '"id": "3456-0987654876",' +
            '"status": "PURCHASE_COMPLETE",' +
            '"type": "purchase_status"' +
            '},' +
            '"receiptId": "AQEB73fFUIKzLDbMbEs3Cocl3TrX83Ykapf8D%2B9uOXqgp1CcEiUyLyD8eb8rh%2FwxKjXyqfUQfPMZc989%2BzQ3DOyhpW2fAMumq",' +
            '"messageId": "3b70c061-067c-4e05-baa5-9b42874e6a94"' +
            '}' +
            ']' +
            '}';
        }
        else{
            responseStr = '{ '
                    +'"scope" : "service.access",'
                    +'"resource" : "4cef9258-82eb-42f0-94b2-147009b9302f",'
                    +'"issued_at" : 1554352175,'
                    +'"expires_on" : 1554353975,'
                    +'"expires_in" : 1800,'
                    +'"token_type" : "Bearer",'
                    +'"access_token" : "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6IjNBWHRCS1NVbzdPVW1PM1lva0NveThFR3g2byIsInR0eSI6ImFjY2Vzc190b2tlbiJ9.eyJpc3MiOiJodHRwczovL2xvZ2luLm15b2IuY29tLyIsInN1YiI6InNhbGVzZm9yY2UtZW50ZXJwcmlzZS1jcm0iLCJhdWQiOiI0Y2VmOTI1OC04MmViLTQyZjAtOTRiMi0xNDcwMDliOTMwMmYiLCJleHAiOjE1NTQzNTM5NzUsIm5iZiI6MTU1NDM1MjE3NSwiaWF0IjoxNTU0MzUyMTc1LCJqdGkiOiJjMjhiOGJjYS0xZGE4LTQ3NTItOWNlYy1mZjM2ODQ0MWUwYjQiLCJjbGllbnRfaWQiOiJzYWxlc2ZvcmNlLWVudGVycHJpc2UtY3JtIiwic2NwIjoic2VydmljZS5hY2Nlc3MifQ.NNaZm8vTEMsRAHxZKJIs09dBe-bf4ssV0o3_-ue0HckaIvkmIOeJvQz6U8zdaUWqrNl42UBAdfuD9nHHLtoseQww-lS3TtYhrtXPhcGUszzxtkJoFiCYJS68giJzgnD2Mrt1ra5eqT7DOtVehv-SDvwBjoXUhsai9LU69lMtbam8oYq7otISSL_rQiD9jfJPOBYA7ILbLUHjodOYL-SBQ46W9IWUgg1MDeFzU2jMpG9hzb14H5J-D6yQ8FdFd1x51lG-X5jDxkiZht5yzvyh4y3EaTMW-6Ii3DUdIOztREmh7owqkMiXq8i2K4nZD23Hwd7CBYBxgufhafHxAmJtcQ"'
                    +'}';
        }
        res.setBody(responseStr);
        res.setStatusCode(200);
        return res;
    }
}