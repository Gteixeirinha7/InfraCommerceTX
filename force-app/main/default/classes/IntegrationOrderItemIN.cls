public with sharing class IntegrationOrderItemIN {
    
    public static List<TemplateDataIntegrationFields.Response> upsertOrderItem(Map<String, List<TemplateDataIntegrationFields.OrderItemINData>> mapKeyOrderToOrderMap, Map<String, Id> lookups) {
        // Map<String, Id> lookups = new Map<String, Id>();
        List<TemplateDataIntegrationFields.Response> responseList = new List<TemplateDataIntegrationFields.Response>();
        List<TemplateDataIntegrationFields.OrderItemINData> listOrderItemINData = new List<TemplateDataIntegrationFields.OrderItemINData>();
        List<OrderItem> listOrderItem = new List<OrderItem>();
        Map<String, Boolean> sfOrderItems = new Map<String, Boolean>();

        Set<String> setOrderExternalId = new Set<String>();
        Set<String> setProductExternalId = new Set<String>();
        Set<String> setOrderItemsExternalId = new Set<String>();

        Pricebook2 stdPcbook;

        if(Test.isRunningTest()){
            stdPcbook = new Pricebook2(Id = Test.getStandardPriceBookId());
        } else {
            stdPcbook = [SELECT id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
            lookups.put('StandardPb', stdPcbook.Id);
        }

        for (String key : mapKeyOrderToOrderMap.keySet()) {
            for (TemplateDataIntegrationFields.OrderItemINData ordItem : mapKeyOrderToOrderMap.get(key)) {
                setOrderItemsExternalId.add(ordItem.orderId + ordItem.sku);
            }
        }

        for (OrderItem ordIt : [SELECT Id, ExternalId__c FROM OrderItem WHERE ExternalId__c IN :setOrderItemsExternalId]) {
            sfOrderItems.put(ordIt.externalId__c, true);
        }

        for (String key : mapKeyOrderToOrderMap.keySet()) {
            setOrderExternalId.add(key);
            Integer index = 1;
            for (TemplateDataIntegrationFields.OrderItemINData ordItem : mapKeyOrderToOrderMap.get(key)) {
                ordItem.OrderId = key;
                ordItem.index = index;

                if (sfOrderItems.containsKey(ordItem.orderId + ordItem.sku) && sfOrderItems.get(ordItem.orderId + ordItem.sku)) {
                    ordItem.sfOrderItem = true;
                } else {
                    ordItem.sfOrderItem = false;
                }

                listOrderItemINData.add(ordItem);
                setProductExternalId.add(ordItem.sku);
                index++;
            }
        }

        System.debug('setProductExternalId => ' + JSON.serializePretty(setProductExternalId));

        //lookup para Pedido
        for (Order ord : [SELECT Id, internalOrderId__c FROM Order WHERE internalOrderId__c IN :setOrderExternalId]){
            lookups.put('OrderItem' + ord.internalOrderId__c, ord.Id);
        }

        Set<String> existingProducts = new Set<String>();

        for (Product2 prd : [SELECT Id, ExternalId__c FROM Product2 WHERE ExternalId__c IN :setProductExternalId]) {
            lookups.put('Product2' + prd.ExternalId__c, prd.id);
            existingProducts.add(prd.ExternalId__c);
        }

        Map<String, TemplateDataIntegrationFields.OrderItemINData> mapSkuToOrderItemINData = new Map<String, TemplateDataIntegrationFields.OrderItemINData>();
        Set<String> setNewProductsExternalId = new Set<String>();

        List<Product2> productsToUpsert = new List<Product2>();
        for (String key : mapKeyOrderToOrderMap.keySet()) {
            for (TemplateDataIntegrationFields.OrderItemINData ordItem : mapKeyOrderToOrderMap.get(key)) {
                System.debug('ordItem.sku => ' + ordItem.sku);
                if(ordItem.integrationType != 'StatusIN' && !existingProducts.contains(ordItem.sku)){
                    setNewProductsExternalId.add(ordItem.sku);
                    mapSkuToOrderItemINData.put(ordItem.sku, ordItem);
                    Product2 product = new Product2(
                        stockKeepingUnit = ordItem.sku,
                        externalId__c = ordItem.sku,
                        name = ordItem.name,
                        IsActive = true
                    );
                    productsToUpsert.add(product);
                }
            }
        }

        IntegrationUtils.upsertRecords(
            Database.upsert(productsToUpsert, Product2.ExternalId__c, false), 
            responseList, 
            productsToUpsert, 
            Product2.ExternalId__c
        );

        for (Product2 prd : [SELECT Id, ExternalId__c FROM Product2 WHERE ExternalId__c IN :setProductExternalId]) {
            lookups.put('Product2' + prd.ExternalId__c, prd.id);
        }

        List<PricebookEntry> pbEntriesToInsert = new List<PricebookEntry>();

        for(String skuId : setNewProductsExternalId) {
            PricebookEntry pbEntry = new PricebookEntry(
                UnitPrice = mapSkuToOrderItemINData.get(skuId).listPrice, 
                Pricebook2Id = stdPcbook.id, 
                Product2Id = lookups.get('Product2' + skuId),
                ExternalID__c = skuId
            );

            pbEntriesToInsert.add(pbEntry);
        }

        System.debug('pbEntriesToInsert => ' + JSON.serializePretty(pbEntriesToInsert));

        IntegrationUtils.upsertRecords(
            Database.upsert(pbEntriesToInsert, PricebookEntry.ExternalId__c, false), 
            responseList, 
            pbEntriesToInsert, 
            PricebookEntry.ExternalId__c
        );

        for (PricebookEntry pbEntry : [SELECT Id, ExternalId__c, Pricebook2.isStandard, Product2.ExternalID__c FROM PricebookEntry WHERE Pricebook2.isStandard = true AND ExternalId__c IN :setProductExternalId]) {
            lookups.put('StandardPbEntry' + pbEntry.ExternalID__c, pbEntry.id);
        }

        System.debug('lookups => ' + JSON.serializePretty(lookups));

        FactoryDataIntegration.convertSObject(new OrderItem(), 'IN', listOrderItemINData, responseList, listOrderItem, lookups);

        System.debug('listOrderItem => ' + JSON.serializePretty(listOrderItem));

        IntegrationUtils.upsertRecords(
            Database.upsert(listOrderItem, OrderItem.ExternalId__c, false), 
            responseList, 
            listOrderItem, 
            OrderItem.ExternalId__c
        );

        System.debug(responseList);

        return responseList;
    }
}