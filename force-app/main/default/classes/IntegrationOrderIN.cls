@RestResource(urlMapping='/order-in')
global with sharing class IntegrationOrderIN {

    @HttpPost
    global static ResponseModel upsertOrder() {
        List<TemplateDataIntegrationFields.Response> responseList = new List<TemplateDataIntegrationFields.Response>();

        final RestResponse response = RestContext.response;

        Type requestType = Type.forName('TemplateDataIntegrationFields.OrderINData');
        TemplateDataIntegrationFields.OrderINData request = (TemplateDataIntegrationFields.OrderINData) JSON.deserialize(RestContext.request.requestBody.toString(), requestType);

        Map<String, Id> lookups = new Map<String, Id>();
        
        List<Order> listOrderToUpsert = new List<Order>();
        List<Account> listAccountToUpsert = new List<Account>();
        List<Address__c> listAddressesToUpsert = new List<Address__c>();
        List<LogisticInformation__c> listLogisticInfoToUpsert = new List<LogisticInformation__c>();
        List<Payments__c> listPaymentsToUpsert = new List<Payments__c>();
        
        Set<String> setAccountExternalId = new Set<String>();
        Set<String> setDeliveryAddressExternalId = new Set<String>();
        Set<String> setSellerCode = new Set<String>{'DCR'};
        Set<String> setStoreCode = new Set<String>();
        
        Map<String, List<TemplateDataIntegrationFields.OrderItemINData>> mapKeyOrderToOrderItem = new Map<String, List<TemplateDataIntegrationFields.OrderItemINData>>();
        Map<String, TemplateDataIntegrationFields.AccountINData> mapKeyOrderToCustomer = new Map<String, TemplateDataIntegrationFields.AccountINData>();
        List<TemplateDataIntegrationFields.AddressINData> listAddressesINDataToUpsert = new List<TemplateDataIntegrationFields.AddressINData>();
        List<TemplateDataIntegrationFields.LogisticInformationINData> listLogisticInfoINDataToUpsert = new List<TemplateDataIntegrationFields.LogisticInformationINData>();
        List<TemplateDataIntegrationFields.PaymentsINData> listPaymentsINDataToUpsert = new List<TemplateDataIntegrationFields.PaymentsINData>();

        Pricebook2 stdPcbook;

        if(Test.isRunningTest()){
            stdPcbook = new Pricebook2(Id = Test.getStandardPriceBookId());
        } else {
            stdPcbook = [SELECT id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
            lookups.put('StandardPb', stdPcbook.Id);
        }

        List<TemplateDataIntegrationFields.OrderINData> requestList = new List<TemplateDataIntegrationFields.OrderINData>{request};

        for (TemplateDataIntegrationFields.OrderINData order : requestList) {

            String internalOrderId = order.internalOrderId;

            if(order.sellerCode != null) {
                setSellerCode.add(order.sellerCode);
            }
            
            if(order.storeCode != null) {
                setStoreCode.add(order.storeCode);
            }

            // OrderItem
            if(order.items != null) {
                for (TemplateDataIntegrationFields.OrderItemINData orderItem : order.items) {
                    orderItem.orderId = internalOrderId;
                    if (!mapKeyOrderToOrderItem.containsKey(internalOrderId)) {
                        mapKeyOrderToOrderItem.put(internalOrderId, new List<TemplateDataIntegrationFields.OrderItemINData>());
                    }
                    mapKeyOrderToOrderItem.get(internalOrderId).add(orderItem); 
                }
            }
            
            // Account
            if(order.customer != null) {
                setAccountExternalId.add(order.customer.document);
                mapKeyOrderToCustomer.put(internalOrderId, order.customer);
            }

            // Address__c
            if(order.billingAddress != null) {
                order.billingAddress.accountExternalId = order.customer?.document;
                
                String externalId = order.billingAddress.postalCode + order.billingAddress.addressNumber + order.billingAddress.complement;
                order.billingAddress.externalId = externalId.replaceAll('[^0-9]+', '');
            }

            if(order.deliveryAddress != null) {
                order.deliveryAddress.accountExternalId = order.customer?.document;
                
                String externalId = order.deliveryAddress.postalCode + order.deliveryAddress.addressNumber + order.deliveryAddress.complement;
                String formattedExternalId = externalId.replaceAll('[^0-9]+', '');
                order.deliveryAddress.externalId = formattedExternalId;
                setDeliveryAddressExternalId.add(formattedExternalId);
            }

            if(order.billingAddress.externalId == order.deliveryAddress.externalId) {
                listAddressesINDataToUpsert.add(order.deliveryAddress);
            } else {
                listAddressesINDataToUpsert.add(order.billingAddress);
                listAddressesINDataToUpsert.add(order.deliveryAddress);
            }

            // LogisticInformation__c
            if(order.logisticInfo != null) {
                for (TemplateDataIntegrationFields.LogisticInformationINData logisticInfo : order.logisticInfo) {
                    logisticInfo.orderId = internalOrderId;
                    listLogisticInfoINDataToUpsert.add(logisticInfo);
                }
            }

            // Payments__c
            if(order.payments != null) {

                order.paymentGroups = '';

                Set<String> paymentGroups = new Set<String>();
                for (TemplateDataIntegrationFields.PaymentsINData payment : order.payments) {
                    payment.orderId = internalOrderId;
                    paymentGroups.add(payment.paymentGroup);
                    listPaymentsINDataToUpsert.add(payment);
                }

                for(String paymentGroup : paymentGroups) {
                    order.paymentGroups += paymentGroup + ';';
                }
            }
        }

        // Upsert de Account 
        FactoryDataIntegration.convertSObject(new Account(), 'IN', mapKeyOrderToCustomer.values(), responseList, listAccountToUpsert, lookups);

        IntegrationUtils.upsertRecords(
            Database.upsert(listAccountToUpsert, Account.ExternalId__c, false), 
            responseList, 
            listAccountToUpsert, 
            Account.ExternalId__c
        );

        for (Account acc : [SELECT Id, ExternalId__c FROM Account WHERE ExternalId__c IN: setAccountExternalId]) {
            lookups.put('Account' + acc.ExternalId__c, acc.Id);
        }

        FactoryDataIntegration.convertSObject(new Address__c(), 'IN', listAddressesINDataToUpsert, responseList, listAddressesToUpsert, lookups);

        // System.debug('listAddressesToUpsert => ' + JSON.serializePretty(listAddressesToUpsert));

        IntegrationUtils.upsertRecords(
            Database.upsert(listAddressesToUpsert, Address__c.ExternalId__c, false), 
            responseList, 
            listAddressesToUpsert, 
            Address__c.ExternalId__c
        );

        for (Address__c address : [SELECT Id, ExternalId__c FROM Address__c WHERE ExternalId__c IN: setDeliveryAddressExternalId]) {
            lookups.put('Address' + address.ExternalId__c, address.Id);
        }

        for(Centro_de_Distribuicao__c cd : [SELECT id, name, externalId__c/*, marca__c, marca__r.ExternalId__c*/ FROM Centro_de_Distribuicao__c WHERE externalId__c IN :setSellerCode]) {
            if(cd.externalId__c != 'DCR') {
                lookups.put('CD' + cd.externalId__c, cd.Id);
            } else {
                lookups.put('StandardCD', cd.Id);
            }
        }

        for(Brand__c brand : [SELECT id, name, externalId__c FROM Brand__c WHERE externalId__c IN :setStoreCode]) {
            lookups.put('Brand' + brand.externalId__c, brand.Id);
        }

        //Upsert de Order
        FactoryDataIntegration.convertSObject(new Order(), 'IN', requestList, responseList, listOrderToUpsert, lookups);

        System.debug('listOrderToUpsert => ' + JSON.serializePretty(listOrderToUpsert));

        Boolean hasError = IntegrationUtils.upsertRecords(
            Database.upsert(listOrderToUpsert, Order.internalOrderId__c, false), 
            responseList, 
            listOrderToUpsert, 
            Order.internalOrderId__c
        );
        
        if (!mapKeyOrderToOrderItem.keySet().isEmpty()) {
            responseList.addAll(IntegrationOrderItemIN.upsertOrderItem(mapKeyOrderToOrderItem, lookups));
        }

        if (!listLogisticInfoINDataToUpsert.isEmpty()) {
            System.debug('lookups => ' + JSON.serializePretty(lookups));
            
            FactoryDataIntegration.convertSObject(new LogisticInformation__c(), 'IN', listLogisticInfoINDataToUpsert, responseList, listLogisticInfoToUpsert, lookups);

            System.debug('listLogisticInfoToUpsert => ' + JSON.serializePretty(listLogisticInfoToUpsert));

            IntegrationUtils.upsertRecords(
                Database.upsert(listLogisticInfoToUpsert, LogisticInformation__c.ExternalId__c, false), 
                responseList, 
                listLogisticInfoToUpsert, 
                LogisticInformation__c.ExternalId__c
            );
        }

        if(!listPaymentsINDataToUpsert.isEmpty()) {
            FactoryDataIntegration.convertSObject(new Payments__c(), 'IN', listPaymentsINDataToUpsert, responseList, listPaymentsToUpsert, lookups);

            System.debug('listPaymentsToUpsert => ' + JSON.serializePretty(listPaymentsToUpsert));

            IntegrationUtils.upsertRecords(
                Database.upsert(listPaymentsToUpsert, Payments__c.originPaymentId__c, false), 
                responseList, 
                listPaymentsToUpsert, 
                Payments__c.originPaymentId__c
            );
        }

        for(TemplateDataIntegrationFields.Response res : responseList){
            if(res.status == false) hasError = true;
        }

        System.debug('responseList');

        IntegrationUtils.WSLog('Pedido', 'Inbound', JSON.serialize(request), JSON.serialize(responseList), hasError);
    
        ResponseModel model = new ResponseModel();
        model.response = responseList;
        return model;
    }
}