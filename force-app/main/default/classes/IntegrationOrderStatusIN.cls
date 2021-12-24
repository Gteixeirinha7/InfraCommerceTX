@RestResource(urlMapping='/order-status')
global with sharing class IntegrationOrderStatusIN {

    public static final String INTEGRATION_TYPE_STATUS_IN = 'StatusIN';

    @HttpPost 
    global static ResponseModel updateOrderStatus() {
        List<TemplateDataIntegrationFields.Response> responseList = new List<TemplateDataIntegrationFields.Response>();

        final RestResponse response = RestContext.response;

        Type requestType = Type.forName('TemplateDataIntegrationFields.OrderINData');

        TemplateDataIntegrationFields.OrderINData request = (TemplateDataIntegrationFields.OrderINData) JSON.deserialize(RestContext.request.requestBody.toString(), requestType);

        System.debug('REQUEST ' + JSON.serializePretty(request));

        List<Order> listOrderToUpsert = new List<Order>();
        List<Invoice__c> listInvoicesToUpsert = new List<Invoice__c>();
        
        Map<String, Id> lookups       = new Map<String, Id>();
        Set<String> setStoreCode      = new Set<String>();
        Set<String> setProductExternalId = new Set<String>();
        
        List<TemplateDataIntegrationFields.InvoiceINData> listInvoiceINDataToUpsert = new List<TemplateDataIntegrationFields.InvoiceINData>();
        Map<String, List<TemplateDataIntegrationFields.OrderItemINData>> mapKeyOrderToOrderItems = new Map<String, List<TemplateDataIntegrationFields.OrderItemINData>>();

        List<TemplateDataIntegrationFields.OrderINData> requestList = new List<TemplateDataIntegrationFields.OrderINData>{request};

        Pricebook2 stdPcbook;

        if(Test.isRunningTest()){
            stdPcbook = new Pricebook2(Id = Test.getStandardPriceBookId());
        } else {
            stdPcbook = [SELECT id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
            lookups.put('StandardPb', stdPcbook.Id);
        }

        for (TemplateDataIntegrationFields.OrderINData order : requestList) {
            String internalOrderId = order.internalOrderId;
            order.integrationType  = INTEGRATION_TYPE_STATUS_IN;
           
            if(order.storeCode != null) {
                setStoreCode.add(order.storeCode);
            }

            System.debug('order ' + JSON.serializePretty(order));

            //FATURADO
            if (order.status == 'invoiced' && order.invoice != null) {

                for(TemplateDataIntegrationFields.InvoiceINData invoice : order.invoice) {

                    invoice.integrationType = INTEGRATION_TYPE_STATUS_IN;

                    listInvoiceINDataToUpsert.add(invoice);

                    if(invoice.items != null) {
                        // for (TemplateDataIntegrationFields.OrderItemINData orderItem : invoice.orderItems) {
                        //     orderItem.orderId = internalOrderId;
                        //     orderItem.integrationType = INTEGRATION_TYPE_STATUS_IN;
                        //     if (!mapKeyOrderToOrderItems.containsKey(internalOrderId)) {
                        //         mapKeyOrderToOrderItems.put(internalOrderId, new List<TemplateDataIntegrationFields.OrderItemINData>());
                        //     }
                        //     mapKeyOrderToOrderItems.get(internalOrderId).add(orderItem);
                        //     setProductExternalId.add(orderItem.sku);
                        // }
                    }
                }
            }
        }
        for(Brand__c brand : [SELECT id, name, ExternalId__c FROM Brand__c WHERE ExternalId__c IN :setStoreCode]) {
            lookups.put('Brand' + brand.ExternalId__c, brand.Id);
        }

        for (Product2 prd : [SELECT Id, ExternalId__c FROM Product2 WHERE ExternalId__c IN :setProductExternalId]) {
            lookups.put('Product2' + prd.ExternalId__c, prd.id);
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

        if (!mapKeyOrderToOrderItems.keySet().isEmpty()) {
            responseList.addAll(IntegrationOrderItemIN.upsertOrderItem(mapKeyOrderToOrderItems, lookups));
        }

        if (!listInvoiceINDataToUpsert.isEmpty()) {
            System.debug('lookups => ' + JSON.serializePretty(lookups));
            
            FactoryDataIntegration.convertSObject(new Invoice__c(), 'IN', listInvoiceINDataToUpsert, responseList, listInvoicesToUpsert, lookups);

            System.debug('listInvoicesToUpsert => ' + JSON.serializePretty(listInvoicesToUpsert));

            IntegrationUtils.upsertRecords(
                Database.upsert(listInvoicesToUpsert, Invoice__c.ExternalId__c, false), 
                responseList, 
                listInvoicesToUpsert, 
                Invoice__c.ExternalId__c
            );
        }

        IntegrationUtils.WSLog('Status do Pedido', 'Inbound', JSON.serialize(request), JSON.serialize(responseList), hasError);

        ResponseModel model = new ResponseModel();
        model.response = responseList;
        return model;
    }
}