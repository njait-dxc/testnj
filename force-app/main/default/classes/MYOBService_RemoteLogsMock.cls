/**
 * @Author : Nikhil Jaitly
 * @Created Date : 29/06/2020
 * @Description : Mock class for MYOBService_RemoteLogsMock
 */
global with sharing class MYOBService_RemoteLogsMock implements HttpCalloutMock {
  global HTTPResponse respond(HTTPRequest req) {
    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setStatusCode(200);
    return res;
  }
}