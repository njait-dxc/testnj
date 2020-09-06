@isTest
global class TEST_CreditCardPaymentProfileMock implements HttpCalloutMock
{
    global HttpResponse respond(HTTPRequest req)
    {
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody('{"id":"1-NML16UQ","account":{"id":"10131271"},"contact":{"id":"1-4ZX1403"},"payment_schedule":"Monthly","payment_method":"Credit Card","credit_card":{"name_on_card":"rrr","card_token":"C4NDGLAM1YA1C5HK","last_four_digits":"1111"}}');
        return res;
    }
}