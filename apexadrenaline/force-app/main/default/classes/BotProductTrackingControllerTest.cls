@isTest
private class BotProductTrackingControllerTest {
    private class MockHttpResponse implements HttpCalloutMock {
        private Integer statusCode;
        private String status;
        private String body;
        private Map<String, String> headers;

        public MockHttpResponse(Integer statusCode, String status, String body, Map<String, String> headers) {
            this.statusCode = statusCode;
            this.status = status;
            this.body = body;
            this.headers = headers;
        }

        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(this.statusCode);
            response.setStatus(this.status);
            response.setBody(this.body);
            for (String headerName : this.headers.keySet()) {
                response.setHeader(headerName, this.headers.get(headerName));
            }
            return response;
        }
    }

    private static final String SUCCESS_JSON = '{' +
        '"trackingId": "PROD12345",' +
        '"status": "Entregue",' +
        '"lastUpdate": "2025-05-20T10:00:00Z",' +
        '"estimatedDeliveryDate": "2025-05-20",' +
        '"recipient": {"name": "Test User", "address": "Test Address"},' +
        '"sender": {"name": "Test Seller", "address": "Test Seller Address"},' +
        '"packageDetails": {"weightKg": 1.5, "dimensionsCm": "10x10x10", "description": "Test Product"},' +
        '"trackingEvents": [{' +
        '  "timestamp": "2025-05-18T08:00:00Z",' +
        '  "location": "Origin",' +
        '  "status": "Item Processed" ' +
        '}],' +
        '"deliveryAttempts": []' +
    '}';


    @isTest
    static void testGetTrackingStatusForBotSuccess() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(
            200, 'OK', SUCCESS_JSON, new Map<String, String>{'Content-Type' => 'application/json'}
        ));
        
        Test.startTest();
        List<String> productNumbers = new List<String>{'PROD_OK'};
        List<BotProductTrackingController.BotTrackingResult> results = BotProductTrackingController.getTrackingStatusForBot(productNumbers);
        Test.stopTest();

        
        System.assertEquals(1, results.size());
        BotProductTrackingController.BotTrackingResult result = results[0];
        System.assertEquals(true, result.isSuccess);
        System.assertEquals('Entregue', result.status);
        System.assertEquals(Date.newInstance(2025, 5, 20), result.estimatedDeliveryDate);
    }

    @isTest
    static void testGetTrackingStatusForBotProductNotFound() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(
            404, 'Not Found', '{"message": "Product not found"}', new Map<String, String>{'Content-Type' => 'application/json'}
        ));
        
        Test.startTest();
        List<String> productNumbers = new List<String>{'PROD_404'};
        List<BotProductTrackingController.BotTrackingResult> results = BotProductTrackingController.getTrackingStatusForBot(productNumbers);
        Test.stopTest();

        System.assertEquals(1, results.size());
        BotProductTrackingController.BotTrackingResult result = results[0];
        System.assertEquals(false, result.isSuccess);
        System.assertEquals(true, result.isErrorNotFound);
        System.assertEquals(false, result.isErrorServiceUnavailable);
    }

    @isTest
    static void testGetTrackingStatusForBotServiceUnavailable() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(
            500, 'Internal Server Error', '{"message": "Server error"}', new Map<String, String>{'Content-Type' => 'application/json'}
        ));
        
        Test.startTest();
        List<String> productNumbers = new List<String>{'PROD_500'};
        List<BotProductTrackingController.BotTrackingResult> results = BotProductTrackingController.getTrackingStatusForBot(productNumbers);
        Test.stopTest();

        System.assertEquals(1, results.size());
        BotProductTrackingController.BotTrackingResult result = results[0];
        System.assertEquals(false, result.isSuccess);
        System.assertEquals(false, result.isErrorNotFound);
        System.assertEquals(true, result.isErrorServiceUnavailable);
    }

    @isTest
    static void testGetTrackingStatusForBotOtherProductServiceException() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(
            401, 'Unauthorized', '{"message": "Authentication failed"}', new Map<String, String>{'Content-Type' => 'application/json'}
        ));
        
        Test.startTest();
        List<String> productNumbers = new List<String>{'PROD_OTHER_ERROR'};
        List<BotProductTrackingController.BotTrackingResult> results = BotProductTrackingController.getTrackingStatusForBot(productNumbers);
        Test.stopTest();

        System.assertEquals(1, results.size());
        BotProductTrackingController.BotTrackingResult result = results[0];
        System.assertEquals(false, result.isSuccess);
        System.assertEquals(false, result.isErrorNotFound);
        System.assertEquals(false, result.isErrorServiceUnavailable);
    }

    @isTest
    static void testGetTrackingStatusForBotUnexpectedError() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(
            200, 'OK', 'Incorrect or Blank JSON', new Map<String, String>{'Content-Type' => 'application/json'}
        ));
        
        Test.startTest();
        List<String> productNumbers = new List<String>{'PROD_OTHER_ERROR'};
        List<BotProductTrackingController.BotTrackingResult> results = BotProductTrackingController.getTrackingStatusForBot(productNumbers);
        Test.stopTest();

        System.assertEquals(1, results.size());
        BotProductTrackingController.BotTrackingResult result = results[0];
        System.assertEquals(false, result.isSuccess);
        System.assertEquals(false, result.isErrorNotFound);
        System.assertEquals(false, result.isErrorServiceUnavailable);
    }
}