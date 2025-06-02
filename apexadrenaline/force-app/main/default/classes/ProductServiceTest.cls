@isTest
private class ProductServiceTest {
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
    static void testGetPackageTrackingStatusSuccess() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(
            200, 'OK', SUCCESS_JSON, new Map<String, String>{'Content-Type' => 'application/json'}
        ));

        Test.startTest();
        ProductTrackingResponseVO result = ProductService.getInstance().getPackageTrackingStatus('PROD12345');
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals('PROD12345', result.trackingId);
        System.assertEquals('Entregue', result.status);
        System.assertEquals('Test User', result.recipient.name);
    }

    @isTest
    static void testGetPackageTrackingStatusNotFound() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(
            404, 'Not Found', '{"message": "Product not found"}', new Map<String, String>{'Content-Type' => 'application/json'}
        ));

        Test.startTest();
        Boolean caughtException = false;
        try {
            ProductService.getInstance().getPackageTrackingStatus('NONEXISTENT');
        } catch (ProductService.ProductServiceException e) {
            caughtException = true;
            System.assertEquals('404 - Produto não encontrado.', e.getMessage());
        }
        Test.stopTest();

        System.assert(caughtException);
    }

    @isTest
    static void testGetPackageTrackingStatusServiceUnavailable() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(
            500, 'Internal Server Error', '{"message": "Server error"}', new Map<String, String>{'Content-Type' => 'application/json'}
        ));

        Test.startTest();
        Boolean caughtException = false;
        try {
            ProductService.getInstance().getPackageTrackingStatus('ANYPROD');
        } catch (ProductService.ProductServiceException e) {
            caughtException = true;
            System.assertEquals('500 - Serviço indisponível.', e.getMessage());
        }
        Test.stopTest();

        System.assert(caughtException);
    }

    @isTest
    static void testGetPackageTrackingStatusUnexpectedError() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(
            401, 'Unauthorized', '{"message": "Authentication failed"}', new Map<String, String>{'Content-Type' => 'application/json'}
        ));

        Test.startTest();
        Boolean caughtException = false;
        try {
            ProductService.getInstance().getPackageTrackingStatus('SECUREPROD');
        } catch (ProductService.ProductServiceException e) {
            caughtException = true;
            System.assertEquals('401 - Erro Inesperado.', e.getMessage());
        }
        Test.stopTest();

        System.assert(caughtException);
    }
}