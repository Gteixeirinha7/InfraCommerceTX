@RestResource(urlMapping='/order')
global with sharing class IntegrationStatusPedidos {

    @HttpPost
    global static ResponseModel statusPedidosCancelados() {
        List<TemplateDataIntegrationFields.Response> responseList = new List<TemplateDataIntegrationFields.Response>();

        final RestResponse response = RestContext.response;

        Type requestType = Type.forName('TemplateDataIntegrationFields.OrderINData');

        TemplateDataIntegrationFields.OrderINData request = (TemplateDataIntegrationFields.OrderINData) JSON.deserialize(RestContext.request.requestBody.toString(), requestType);

        System.debug('REQUEST ' + JSON.serializePretty(request));

        List<Order> listOrderToUpsert = new List<Order>();
        Map<String, Id> lookups       = new Map<String, Id>();
        Set<String> setStoreCode      = new Set<String>();
        Map<String, List<TemplateDataIntegrationFields.OrderItemINData>> mapKeyOrderToOrderItem = new Map<String, List<TemplateDataIntegrationFields.OrderItemINData>>();

        List<TemplateDataIntegrationFields.OrderINData> requestList = new List<TemplateDataIntegrationFields.OrderINData>{request};

        for (TemplateDataIntegrationFields.OrderINData order : requestList) {
            String internalOrderId = order.internalOrderId;
            order.integrationType  = 'StatusIN';
           
            if(order.storeCode != null) {
                setStoreCode.add(order.storeCode);
            }

            System.debug('order ' + JSON.serializePretty(order));

            //FATURADO
            if (order.status == 'invoiced') {
                if(order.items != null) {
                    for (TemplateDataIntegrationFields.OrderItemINData orderItem : order.items) {
                        orderItem.orderId = internalOrderId;
                        orderItem.integrationType = 'StatusIN';
                        if (!mapKeyOrderToOrderItem.containsKey(internalOrderId)) {
                            mapKeyOrderToOrderItem.put(internalOrderId, new List<TemplateDataIntegrationFields.OrderItemINData>());
                        }
                        mapKeyOrderToOrderItem.get(internalOrderId).add(orderItem); 
                    }
                }
            }
        }
        for(Brand__c brand : [SELECT id, name, ExternalId__c FROM Brand__c WHERE ExternalId__c IN :setStoreCode]) {
            lookups.put('Brand' + brand.ExternalId__c, brand.Id);
        }

        FactoryDataIntegration.convertSObject(new Order(), 'IN', requestList, responseList, listOrderToUpsert, lookups);

        Boolean hasError = IntegrationUtils.upsertRecords(
            Database.upsert(listOrderToUpsert, Order.internalOrderId__c, false), 
            responseList, 
            listOrderToUpsert, 
            Order.internalOrderId__c
        );
        
        for(TemplateDataIntegrationFields.Response res : responseList){
            if(res.status == false) hasError = true;
        }

        if (!mapKeyOrderToOrderItem.keySet().isEmpty()) {
            responseList.addAll(IntegrationOrderItemIN.upsertOrderItem(mapKeyOrderToOrderItem, lookups));
        }

        ResponseModel model = new ResponseModel();
        model.response = responseList;
        return model;
    }

    // @HttpPost 
    // global static ResponseModel statusPedidosPagamentosAprovados() {
    //     List<TemplateDataIntegrationFields.Response> responseList = new List<TemplateDataIntegrationFields.Response>();

    //     final ResponseModel response = RestContext.response;

    //     Type requestType = Type.forName('TemplateDataIntegrationFields.StatusProdutosPagamentoAprovadoINData');

    //     TemplateDataIntegrationFields.StatusProdutosPagamentoAprovadoINData request = (TemplateDataIntegrationFields.StatusProdutosPagamentoAprovadoINData) JSON.deserialize(RestContext.request.requestBody.toString(), requestType);
    
    // }

    // @HttpPost
    // global static ResponseModel statusPedidosFaturados() {
    //     List<TemplateDataIntegrationFields.Response> responseList = new List<TemplateDataIntegrationFields.Response>();

    //     final ResponseModel response = RestContext.response;

    //     Type requestType = Type.forName('TemplateDataIntegrationFields.StatusProdutosFaturadosINData');

    //     TemplateDataIntegrationFields.StatusProdutosFaturadosINData request = (TemplateDataIntegrationFields.StatusProdutosFaturadosINData) JSON.deserialize(RestContext.request.requestBody.toString(), requestType);
    // }

    // @HttpPost
    // global static ResponseModel statusPedidosEntregues() {
    //     List<TemplateDataIntegrationFields.Response> responseList = new List<TemplateDataIntegrationFields.Response>();

    //     final ResponseModel response = RestContext.response;

    //     Type requestType = Type.forName('TemplateDataIntegrationFields.StatusProdutosEntreguesINData');

    //     TemplateDataIntegrationFields.StatusProdutosEntreguesINData request = (TemplateDataIntegrationFields.StatusProdutosEntreguesINData) JSON.deserialize(RestContext.request.requestBody.toString(), requestType);
   
    // }

    

}