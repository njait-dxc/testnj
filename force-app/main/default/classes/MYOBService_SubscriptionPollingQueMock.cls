/**
 * @Author : Nikhil Jaitly
 * @Created Date : 27/05/2020
 * @Description : Mock class for MYOBService_SubscriptionPollingQue
 */
global with sharing class MYOBService_SubscriptionPollingQueMock implements HttpCalloutMock {
  public String tokenBody;
  public String resBody;
  public MYOBService_SubscriptionPollingQueMock(String tknBdy, String res) {
    this.tokenBody = tknBdy;
    this.resBody = res;
  }
  global HTTPResponse respond(HTTPRequest req) {
    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setStatusCode(200);
    System.debug(req.getEndpoint());
    System.debug(req.getEndpoint().contains('token'));
    if(req.getEndpoint().contains('token') || req.getEndpoint().contains('OAuth')) {
      res.setBody(tokenBody);
    } else {
      res.setBody(resBody);
    }
    return res;
  }
}