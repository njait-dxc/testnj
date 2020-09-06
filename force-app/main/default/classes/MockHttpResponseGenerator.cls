/**
 * @author
 * @date
 * @description
 */

@IsTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
	// Implement this interface method
	global HttpResponse respond(HttpRequest req) {
		// Optionally, only send a mock response for a specific endpoint
		// and method.

		// Create a fake response
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody('{"access_token": "abcde","token_type": "Bearer","expires_in": 3600,"expires_on": 1505878109,"issued_at": 1505874509,"resource": "4ffc1b0e-de33-4a3e-8988-b6a0ec8a7ea4","scope": "service.access"}');
		res.setStatusCode(200);
		return res;
	}
}