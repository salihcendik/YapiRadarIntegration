/**
 * @description       : 
 * @author            : salihcendik
 * @group             : 
 * @last modified on  : 09-12-2022
 * @last modified by  : salihcendik
**/
@isTest
public with sharing class HttpCalloutMockUtil implements HttpCalloutMock{
    String jsonBody;
    Integer statusCode;

    public HttpCalloutMockUtil(String jsonBody, Integer statusCode) {
        this.jsonBody = jsonBody;
        this.statusCode = statusCode;
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(statusCode);
        res.setHeader('Content-Type', 'application/json');
        res.setBody(jsonBody);
        return res;
    }
}