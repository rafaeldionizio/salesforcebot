public with sharing class ProductService {
    public static final ProductService INSTANCE = new ProductService();

    public static ProductService getInstance() {
        return INSTANCE;
    }

    public ProductTrackingResponseVO getPackageTrackingStatus(String strProductNumber) {
        ProductTrackingResponseVO ObjProductTrackingData = new ProductTrackingResponseVO();
        String strEndpoint = 'callout:ProductsCallout/' + strProductNumber;

        try {
            HttpResponse objHttpResponse = Util.executeHttpRequest(
                strEndpoint,
                'GET',
                new Map<String, String>{
                    'Content-Type' => 'application/json;charset=UTF-8'
                },
                null, 
                60000
            );

            if(objHttpResponse.getStatusCode() == 200) {
                ObjProductTrackingData = ProductTrackingResponseVO.parse(objHttpResponse.getBody());
            } else if(objHttpResponse.getStatusCode() == 404){
                throw new ProductServiceException(objHttpResponse.getStatusCode() + ' - Produto não encontrado.');
            } else if(objHttpResponse.getStatusCode() == 500){
                throw new ProductServiceException(objHttpResponse.getStatusCode() + ' - Serviço indisponível.');
            } else{
                throw new ProductServiceException(objHttpResponse.getStatusCode() + ' - Erro Inesperado.');
            }
        } catch (Exception e) {
            System.debug('Exceção ' + e.getMessage() + ' em ' + e.getLineNumber());
            throw e;
        }

        return ObjProductTrackingData;
    }

    public class ProductServiceException extends Exception { }
}