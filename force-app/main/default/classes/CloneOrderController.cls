public with sharing class CloneOrderController {
    public CloneOrderController() {}

    @AuraEnabled
    public static IntegrationOrderOUT.OrderOUTResponse sendOrderToIntegration(String idCaso, String idOrder) {
        System.debug('idCaso => ' + idCaso);
        System.debug('idOrder => ' + idOrder);

        IntegrationOrderOUT.OrderOUTResponse response = new IntegrationOrderOUT.OrderOUTResponse();

        Case caseObj = [SELECT Id, Order__c, NewOrder__c, ProtocolType__c FROM Case WHERE Id =: idCaso];
        if(caseObj.ProtocolType__c == 'exchange') {
            response = IntegrationOrderOUT.sendOrderOUT(idOrder);
        } else {
            response.hasError   = true;
            response.message    = 'O Caso (Protocolo) não é do Tipo "Troca". Não foi possível seguir com o envio para o iHub.';
        }

        System.debug('response => ' + JSON.serializePretty(response));

        return response;
    }

    @AuraEnabled
    public static IntegrationCaseOUT.CaseOUTResponse sendCaseToIntegration(String idCaso) {
        System.debug('idCaso => ' + idCaso);

        // Case caseObj = [SELECT Id, Order__c, NewOrder__c, ProtocolType__c FROM Case WHERE Id =: idCaso];
        IntegrationCaseOUT.CaseOUTResponse response = IntegrationCaseOUT.sendCaseOUT(idCaso);

        System.debug('response => ' + JSON.serializePretty(response));

        return response;
    }

    @AuraEnabled
    public static CloneOrderResponse createCloneOrder(String idCaso, LogisticInformation__c logisticInformationToClone, String shippingEstimatedDate, String listOrderItemsJSON){

        CloneOrderResponse cloneOrderResponse;

        try {

            System.debug('LOGISTIC INFORMATION ' + JSON.serializePretty(logisticInformationToClone));
            
            List<OrderItemModel> listOrderItems = new List<OrderItemModel>();

            listOrderItems = (List<OrderItemModel>) JSON.deserialize(listOrderItemsJSON, List<OrderItemModel>.class);
            
            System.debug('LISTA DE ORDER ITEMS ' + listOrderItems);

            Case caseObj = [SELECT Id, Order__c, NewOrder__c, ProtocolType__c FROM Case WHERE Id =: idCaso];
            String idOrder = caseObj.Order__c;
            System.debug('Id PEDIDO ' + idOrder);
            Order pedido = [SELECT Id, Status, Brand__c, CentrodeDistribuicao__c, AccountId, Grupo__c, Type, EffectiveDate, OriginOrderId__c,
                                    CanalVenda__c, affiliateId__c, NumeroPedidoCliente__c, NumeroPedidoERP__c, internalOrderId__c, RazaoCancelamento__c,
                                    DataOcorrencia__c, NomeEntregadora__c, NumeroRastreio__c, CanceladoPor__c, URLRastreio__c, IntegrationOrder__c,
                                    Shipping__c, OrderTotals__c, Tax__c, NumeroFatura__c, NumeroSerieFatura__c, DataEmissao__c, ChaveEletronica__c,
                                    Endereco__c, Pricebook2Id, 
                                    (   
                                        SELECT  value__c, interestAmount__c, interestRate__c, grupo__c, dueDate__c, installments__c, 
                                                redemptionCode__c, cardBrand__c, cardHoldersName__c, tid__c, authId__c, firstDigits__c, lastDigits__c
                                        FROM Dados_de_Pagamento__r
                                        ORDER BY value__c DESC
                                    )
                            FROM Order
                            WHERE Id =: idOrder];
            System.debug('PEDIDO ' + pedido);

            Order orderClone                    = new Order();
            orderClone.Brand__c                 = pedido.Brand__c;
            orderClone.CentrodeDistribuicao__c  = pedido.CentrodeDistribuicao__c;
            orderClone.AccountId                = pedido.AccountId;
            orderClone.Type                     = 'exchange';
            
            orderClone.OriginOrderId__c         = null; //pedido.OriginOrderId__c;
            orderClone.NumeroPedidoCliente__c   = null; //pedido.NumeroPedidoCliente__c;
            orderClone.NumeroPedidoERP__c       = pedido.numeroPedidoERP__c.replace('WEB', 'SF') + orderClone.Type == 'exchange'? 'TR' : ''; //pedido.NumeroPedidoERP__c;
            
            orderClone.InternalOrderId__c       = pedido.InternalOrderId__c + 'CLONE';

            orderClone.Status                   = orderClone.Type == 'exchange'? 'ready-for-handling' : 'payment-pending';
            orderClone.Grupo__c                 = pedido.Grupo__c                == null ? ''    : pedido.Grupo__c;
            orderClone.EffectiveDate            = pedido.EffectiveDate           == null ? null  : pedido.EffectiveDate;
            orderClone.CanalVenda__c            = pedido.CanalVenda__c           == null ? ''    : pedido.CanalVenda__c;
            orderClone.affiliateId__c           = pedido.affiliateId__c          == null ? ''    : pedido.affiliateId__c;
            orderClone.RazaoCancelamento__c     = pedido.RazaoCancelamento__c    == null ? ''    : pedido.RazaoCancelamento__c;
            orderClone.DataOcorrencia__c        = pedido.DataOcorrencia__c       == null ? null  : pedido.DataOcorrencia__c;
            orderClone.NomeEntregadora__c       = pedido.NomeEntregadora__c      == null ? ''    : pedido.NomeEntregadora__c;
            orderClone.NumeroRastreio__c        = pedido.NumeroRastreio__c       == null ? ''    : pedido.NumeroRastreio__c;
            orderClone.CanceladoPor__c          = pedido.CanceladoPor__c         == null ? ''    : pedido.CanceladoPor__c;
            orderClone.URLRastreio__c           = pedido.URLRastreio__c          == null ? ''    : pedido.URLRastreio__c;
            orderClone.IntegrationOrder__c      = false;
            orderClone.Shipping__c              = pedido.Shipping__c             == null ? 0     : pedido.Shipping__c;
            orderClone.Tax__c                   = pedido.Tax__c                  == null ? 0     : pedido.Tax__c;
            orderClone.NumeroFatura__c          = pedido.NumeroFatura__c         == null ? ''    : pedido.NumeroFatura__c;
            orderClone.NumeroSerieFatura__c     = pedido.NumeroSerieFatura__c    == null ? ''    : pedido.NumeroSerieFatura__c;
            orderClone.DataEmissao__c           = pedido.DataEmissao__c          == null ? null  : pedido.DataEmissao__c;
            orderClone.ChaveEletronica__c       = pedido.ChaveEletronica__c      == null ? ''    : pedido.ChaveEletronica__c;
            orderClone.Endereco__c              = pedido.Endereco__c             == null ? ''    : pedido.Endereco__c;
            orderClone.Pricebook2Id             = pedido.Pricebook2Id;
            orderClone.creationDate__c          = Date.today();
            System.debug('orderClone => ' + JSON.serializePretty(orderClone));
            insert orderClone; 

            LogisticInformation__c logisticInformationClone  = new LogisticInformation__c();
            logisticInformationClone.Name                    = logisticInformationToClone.Name                     == null ? ''    : logisticInformationToClone.Name;
            logisticInformationClone.additionalInfo__c       = logisticInformationToClone.additionalInfo__c        == null ? ''    : logisticInformationToClone.additionalInfo__c;
            logisticInformationClone.address__c              = logisticInformationToClone.address__c               == null ? ''    : logisticInformationToClone.address__c;
            logisticInformationClone.dockId__c               = logisticInformationToClone.dockId__c                == null ? 0     : logisticInformationToClone.dockId__c;
            logisticInformationClone.friendlyName__c         = logisticInformationToClone.friendlyName__c          == null ? ''    : logisticInformationToClone.friendlyName__c;
            logisticInformationClone.isPickupStore__c        = logisticInformationToClone.isPickupStore__c         == null ? false : logisticInformationToClone.isPickupStore__c;
            logisticInformationClone.logisticContract__c     = logisticInformationToClone.logisticContract__c      == null ? ''    : logisticInformationToClone.logisticContract__c;
            logisticInformationClone.price__c                = logisticInformationToClone.price__c                 == null ? 0     : logisticInformationToClone.price__c;
            logisticInformationClone.listPrice__c            = logisticInformationToClone.listPrice__c             == null ? 0     : logisticInformationToClone.listPrice__c;
            logisticInformationClone.sellingPrice__c         = logisticInformationToClone.sellingPrice__c          == null ? 0     : logisticInformationToClone.sellingPrice__c;
            logisticInformationClone.deliveryCompany__c      = logisticInformationToClone.deliveryCompany__c       == null ? ''    : logisticInformationToClone.deliveryCompany__c;
            logisticInformationClone.shippingEstimate__c     = logisticInformationToClone.shippingEstimate__c      == null ? ''    : logisticInformationToClone.shippingEstimate__c;
            logisticInformationClone.shippingEstimateDate__c = logisticInformationToClone.shippingEstimateDate__c  == null ? null  : DateTime.newInstanceGMT(Date.valueOf(shippingEstimatedDate), Datetime.now().time());
            logisticInformationClone.deliveryChannel__c      = logisticInformationToClone.deliveryChannel__c       == null ? ''    : logisticInformationToClone.deliveryChannel__c;
            logisticInformationClone.ExternalId__c           = logisticInformationToClone.ExternalId__c            == null ? ''    : orderClone.InternalOrderId__c + logisticInformationToClone.deliveryCompany__c + 1;
            logisticInformationClone.Pedido__c               = orderClone.Id;
            System.debug('logisticInformationClone => ' + JSON.serializePretty(logisticInformationClone));
            insert logisticInformationClone;

            System.debug('listOrderItems => ' + JSON.serializePretty(listOrderItems));

            List<OrderItem> listorderItemClone = new List<OrderItem>();
            for (OrderItemModel item : listOrderItems) {

                OrderItem orderItem        = new OrderItem();
                orderItem.OrderId          = orderClone.Id;
                orderItem.Product2Id       = item.Id; 
                orderItem.Quantity         = Integer.valueOf(item.Quantity);
                orderItem.UnitPrice        = Decimal.valueOf(item.price);
                orderItem.PricebookEntryId = item.pbEntryId;
                orderItem.Sku__c           = item.sku;
                orderItem.Description      = item.productName;
                orderItem.ListPrice        = orderItem.UnitPrice;
                orderItem.Preco__c         = orderItem.UnitPrice * orderItem.Quantity;
                orderItem.ExternalId__c    = orderClone.InternalOrderId__c + item.sku;            

                System.debug('orderItem => ' + orderItem);
                listorderItemClone.add(orderItem);
            }
            insert listorderItemClone;
            
            orderClone = [SELECT id, OrderTotals__c FROM Order WHERE id =: orderClone.Id];

            Payments__c paymentToClone = pedido.Dados_de_Pagamento__r[0];
            Payments__c paymentClone = new Payments__c();
            paymentClone.pedido__c          = orderClone.Id;
            paymentClone.value__c           = orderClone.OrderTotals__c;
            paymentClone.interestAmount__c  = paymentToClone.interestAmount__c;
            paymentClone.interestRate__c    = paymentToClone.interestRate__c;
            paymentClone.grupo__c           = paymentToClone.grupo__c;
            paymentClone.dueDate__c         = paymentToClone.dueDate__c;
            paymentClone.installments__c    = paymentToClone.installments__c;
            paymentClone.redemptionCode__c  = paymentToClone.redemptionCode__c;
            paymentClone.cardBrand__c       = paymentToClone.cardBrand__c;
            paymentClone.cardHoldersName__c = paymentToClone.cardHoldersName__c;
            paymentClone.tid__c             = paymentToClone.tid__c;
            paymentClone.authId__c          = paymentToClone.authId__c;
            paymentClone.firstDigits__c     = paymentToClone.firstDigits__c;
            paymentClone.lastDigits__c      = paymentToClone.lastDigits__c;
            insert paymentClone;

            caseObj.NewOrder__c = orderClone.Id;
            update caseObj;

            // if(caseObj.ProtocolType__c == 'exchange') {
            //     IntegrationOrderOUT.sendOrderOUTFuture(orderClone.Id);
            //     IntegrationCaseOUT.sendCaseOUTFuture(caseObj.Id);
            // }

            cloneOrderResponse = new CloneOrderResponse(orderClone.Id);
        } catch (Exception e) {
            cloneOrderResponse = new CloneOrderResponse(true, 'Ocorreu um erro. Verifique com o administrador: ' + e.getMessage());
        }

        System.debug('cloneOrderResponse => ' + cloneOrderResponse);
        return cloneOrderResponse;
    }

    @AuraEnabled
    public static List<String> holidays(){
        List<Holiday> listHolidays = [SELECT ActivityDate FROM Holiday];
        List<String> listReturnHolidays = new List<String>();
        for(Holiday holidays : listHolidays){
        listReturnHolidays.add(String.valueOf(holidays.ActivityDate));
        }
        return listReturnHolidays;
    }

    @AuraEnabled
    public static OrderModel cloneOrder(String idCaso) {
        System.debug('ID de ENTRADA ' + idCaso);
        String retorno = [SELECT Id, Order__c FROM Case WHERE Id =: idCaso].Order__c;

        Order ord = [SELECT Id, Brand__c, EffectiveDate, Endereco__c, 
                            NumeroPedidoCliente__c, NumeroPedidoERP__c, OrderNumber, 
                            OrderTotals__c, CentrodeDistribuicao__c, Pricebook2Id,
                            Endereco__r.Street__c, Endereco__r.City__c, Endereco__r.Country__c, Endereco__r.PostalCode__c,
                            Shipping__c, ShippingAddress, ShippingCity, ShippingCountry,
                            ShippingPostalCode, ShippingState, ShippingStreet, toLabel(Status),
                            Tax__c, TotalAmount, TotalItems__c 
                    FROM Order
                    WHERE Id =: retorno]; 
        System.debug('ORDER ' +ord);
        //OrderItem ordItems = [SELECT    FROM OrderItem];
        return new OrderModel(ord);
    }

    @AuraEnabled
    public static Address__c cloneAddress(String idAddress) {
        Address__c add = [SELECT Id, Name, Address__c, AddressType__c
                      FROM Address__c
                      WHERE Id =: idAddress];
        
        return add;
    }

    @AuraEnabled
    public static Centro_de_Distribuicao__c cloneCD(String idCD) {
        Centro_de_Distribuicao__c cd = [SELECT Id, Name, Endereco__c
                                        FROM Centro_de_Distribuicao__c
                                        WHERE Id =: idCD];
        
        return cd;
    }

    @AuraEnabled
    public static Pricebook2 clonePricebook(String idPricebook) {
        Pricebook2 pricebook = [SELECT Id, Name
                                FROM Pricebook2
                                WHERE Id =: idPricebook];
        
        return pricebook;
    }

    @AuraEnabled
    public static String totalPriceOrderItems(String idCase) {
        Decimal calculoTotalPrice = 0;

        Case caso = [SELECT Id, Description, CaseNumber, Reason__c, Type FROM Case WHERE id =: idCase];

        List<ObjetoPostagemReversa__c> objPostagem = [SELECT Id, OrderItem__c FROM ObjetoPostagemReversa__c WHERE Caso__c =: idCase];

        Set<Id> idsOrderItems = new Set<Id>();
        for (ObjetoPostagemReversa__c postagemReversa : objPostagem) {
            idsOrderItems.add(postagemReversa.OrderItem__c);
        }

        List<OrderItem> listOrderItems = [SELECT Id, Sku__c, Quantity, UnitPrice, OrderId FROM OrderItem WHERE Id IN: idsOrderItems];
        System.debug('TOTAL ITEMS ' + listOrderItems);
        for (OrderItem item : listOrderItems) {
            calculoTotalPrice = calculoTotalPrice + item.UnitPrice * item.Quantity;
        }

        String totalPrice = String.valueOf(calculoTotalPrice.format());
        return totalPrice;
    }

    @AuraEnabled
    public static LogisticInformation__c cloneLogisticInformation(String idCaso) {

        String OrderId = [SELECT Id, Order__c FROM Case WHERE Id =: idCaso].Order__c;

        LogisticInformation__c logisticInformation = [SELECT Id, address__c, deliveryChannel__c, deliveryCompany__c, 
                                                             ExternalId__c, isPickupStore__c, Name, logisticContract__c, 
                                                             Pedido__c, price__c, sellingPrice__c, shippingEstimate__c, shippingEstimateDate__c
                                                     FROM LogisticInformation__c
                                                     WHERE Pedido__c =: OrderId
                                                     LIMIT 1];
        System.debug('logisticInformation ' + logisticInformation);
        logisticInformation.shippingEstimate__c = null;
        logisticInformation.shippingEstimateDate__c = null;
        return logisticInformation;
    }

    @AuraEnabled(Cacheable = true)
    public static List<OrderItemModel> getorderItemsClone(String caseId) {

        System.debug('caseId => ' + caseId);

        String orderId = [SELECT order__c FROM Case WHERE id =: caseId LIMIT 1].order__c;
        
        List<OrderItem> orderItems = [SELECT id, product2.name, unitPrice, quantity, totalPrice, sku__c FROM OrderItem WHERE OrderId =: orderId];

        List<OrderItemModel> result = new List<OrderItemModel>();

        for(OrderItem orderItem : orderItems) {
            OrderItemModel model = new OrderItemModel(orderItem);
            result.add(model);
        }

        System.debug('result => ' + JSON.serializePretty(result));

        return result;
    }

    @AuraEnabled(Cacheable = true)
    public static List<OrderItemModel> getProductsToClone(List<InventoryProductsViewController.ProductData> productInventories) {

        System.debug('productInventories => ' + JSON.serializePretty(productInventories));

        Map<String, InventoryProductsViewController.ProductData> skuToProductData = new Map<String, InventoryProductsViewController.ProductData>();

        for(InventoryProductsViewController.ProductData productData : productInventories) {
            skuToProductData.put(productData.sku, productData);
        }

        List<OrderItemModel> result = new List<OrderItemModel>();

        List<PricebookEntry> pricebookEntries = [SELECT Id, Product2Id, UnitPrice, Product2.ExternalId__c, Product2.Name FROM PricebookEntry WHERE Product2.ExternalId__c IN: skuToProductData.keySet()];

        for(PricebookEntry pricebookEntry : pricebookEntries) {
            OrderItemModel model = new OrderItemModel(pricebookEntry, skuToProductData.get(pricebookEntry.Product2.ExternalId__c).inventoryQuantity);
            model.quantityMargin = 10; //alterar para o custom setting
            result.add(model);
        }

        System.debug('result => ' + JSON.serializePretty(result));

        return result;
    }

    public class OrderModel {
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String OrderNumber;
        @AuraEnabled
        public Date EffectiveDate;
        @AuraEnabled
        public String NumeroPedidoERP;
        @AuraEnabled
        public String Shipping;
        @AuraEnabled
        public String ShippingAddressId;
        @AuraEnabled
        public String ShippingAddressStreet;
        @AuraEnabled
        public String ShippingAddressCity;
        @AuraEnabled
        public String ShippingAddressCountry;
        @AuraEnabled
        public String ShippingAddressPostalCode;
        @AuraEnabled
        public String Status;
        @AuraEnabled
        public String Tax;
        @AuraEnabled
        public String TotalItems;
        @AuraEnabled
        public String DistributionCenterId;
        @AuraEnabled
        public String Pricebook2Id;

        public OrderModel(Order order) {
            this.Id = order.Id;
            this.OrderNumber = order.OrderNumber;
            this.EffectiveDate = order.EffectiveDate;
            this.NumeroPedidoERP = order.NumeroPedidoERP__c;
            this.Shipping = String.valueOf(order.Shipping__c);
            this.ShippingAddressId = order.Endereco__c;
            this.ShippingAddressStreet = order.Endereco__r?.Street__c;
            this.ShippingAddressCity = order.Endereco__r?.City__c;
            this.ShippingAddressCountry = order.Endereco__r?.Country__c;
            this.ShippingAddressPostalCode = order.Endereco__r?.PostalCode__c;
            this.Status = order.Status;
            this.Tax = String.valueOf(order.Tax__c);
            this.TotalItems = String.valueOf(order.TotalItems__c);
            this.DistributionCenterId = order.CentrodeDistribuicao__c;
            this.Pricebook2Id = order.Pricebook2Id;
        }
    }

    public class OrderItemModel {
        @AuraEnabled
        public String productName;
        @AuraEnabled
        public String price;
        @AuraEnabled
        public String sku;
        @AuraEnabled
        public String id;
        @AuraEnabled
        public Integer quantity;
        @AuraEnabled
        public Integer inventoryQuantity;
        @AuraEnabled
        public String pbEntryId;
        @AuraEnabled 
        public Integer quantityMargin;

        public OrderItemModel() {}

        public OrderItemModel(OrderItem orderItem) {
            this.id          = orderItem.id;
            this.quantity    = Integer.valueOf(orderItem.quantity);
            this.productName = orderItem.product2.name;
            this.sku         = orderItem.sku__c;
            this.price       = String.valueOf(orderItem.unitPrice);
        }

        public OrderItemModel(PricebookEntry pbEntry, String inventoryQuantity) {
            this.id                = pbEntry.product2Id;
            this.pbEntryId         = pbEntry.Id;
            this.quantity          = 1;
            this.sku               = pbEntry.product2.ExternalId__c;
            this.price             = String.valueOf(pbEntry.UnitPrice);
            this.productName       = pbEntry.product2.Name;
            this.inventoryQuantity = Integer.valueOf(inventoryQuantity);
        }
    }

    public class CloneOrderResponse {
        @AuraEnabled
        public String  orderId;
        @AuraEnabled
        public String  message;
        @AuraEnabled
        public Boolean hasError;

        public CloneOrderResponse() {}

        public CloneOrderResponse(Id orderId) {
            this.orderId = orderId;
            this.hasError = false;
            this.message = 'success';
        }

        public CloneOrderResponse(Boolean hasError, String message) {
            this.orderId = null;
            this.hasError = hasError;
            this.message = message;
        }
    }
}