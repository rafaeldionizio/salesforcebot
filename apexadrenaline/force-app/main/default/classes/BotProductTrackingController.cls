public class BotProductTrackingController {

    @InvocableMethod(label='Consultar Status de Rastreamento do Pedido' description='Consulta o status de rastreamento de um pedido.')
    public static List<BotTrackingResult> getTrackingStatusForBot(List<String> productNumbers) {
        List<BotTrackingResult> listObjResults = new List<BotTrackingResult>();
        String strProductNumber = productNumbers[0];

        try {
            ProductTrackingResponseVO trackingData = ProductService.getInstance().getPackageTrackingStatus(strProductNumber);

            listObjResults.add(new BotTrackingResult(
                true,
                trackingData.status,
                trackingData.estimatedDeliveryDate
            ));

        } catch (ProductService.ProductServiceException e) {
            Boolean isErrorNotFound = e.getMessage().startsWith('404') ? true : false;
            Boolean isErrorServiceUnavailable = e.getMessage().startsWith('500') ? true : false;
            listObjResults.add(new BotTrackingResult(false, isErrorNotFound, isErrorServiceUnavailable));
        } catch (Exception e) {
            System.debug('Erro inesperado no TrackingBotController: ' + e.getMessage() + ' na linha ' + e.getLineNumber());
            listObjResults.add(new BotTrackingResult(false, false, false));
        }

        return listObjResults;
    }

    public class BotTrackingResult {
        @InvocableVariable(label='Sucesso' description='Indica se a consulta foi bem-sucedida.')
        public Boolean isSuccess;

        @InvocableVariable(label='Produto não Encontrado' description='Produto não Encontrado.')
        public Boolean isErrorNotFound;

        @InvocableVariable(label='Serviço Indisponível' description='Serviço Indisponível.')
        public Boolean isErrorServiceUnavailable;

        @InvocableVariable(label='Status do Pedido' description='O status atual do pedido.')
        public String status;

        @InvocableVariable(label='Data Estimada de Entrega' description='Data estimada para a entrega do pedido.')
        public Date estimatedDeliveryDate;


        public BotTrackingResult(Boolean isSuccess, String status, Date estimatedDeliveryDate) {
            this.isSuccess = isSuccess;
            this.status = status;
            this.estimatedDeliveryDate = estimatedDeliveryDate;
        }

        public BotTrackingResult(Boolean isSuccess, Boolean isErrorNotFound, Boolean isErrorServiceUnavailable) {
            this.isSuccess = isSuccess;
            this.isErrorNotFound = isErrorNotFound;
            this.isErrorServiceUnavailable = isErrorServiceUnavailable;
        }
    }
}