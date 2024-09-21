@isTest
global class ToolingApiMock implements HttpCalloutMock {
  global HTTPResponse respond(HTTPRequest req) {
    HttpResponse res = new HttpResponse();
    res.setStatusCode(200);
    res.setBody('{"id": "fakeTriggerId"}');
    return res;
  }
}
