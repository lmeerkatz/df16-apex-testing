@isTest
public class EmployeeBonusCompareMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        // Look at req.getMethod(), req.getEndpoint() to decide what to return

        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type', 'application/json');
        resp.setBody('{"id": 10000, "industry_average": 0.30}');
        resp.setStatusCode(200);
        return resp;
    }
}