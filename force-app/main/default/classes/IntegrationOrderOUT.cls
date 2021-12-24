public with sharing class IntegrationOrderOUT {
    public IntegrationOrderOUT() {}

    @future(callout=true)
    public static void sendOrderOUTFuture(String idOrder) {
        sendOrderOUT(idOrder);
    }

    public static OrderOUTResponse sendOrderOUT(String idOrder) {
        
        OrderOUTResponse response = new OrderOUTResponse();

        Order order = [ SELECT Id, status, RazaoCancelamento__c, CanceladoPor__c, canalVenda__c, OriginalOrderId, OrderTotals__c,
                              DataCancelamento__c, Data_Aprovacao__c, DataOcorrencia__c, DataEmissao__c, creationDate__c, TotalItems__c,
                              NumeroFatura__c, NumeroSerieFatura__c, ChaveEletronica__c, NomeEntregadora__c, TotalAmount, DiscountSUM__c,
                              NumeroRastreio__c, URLRastreio__c, EffectiveDate, OriginOrderId__c, internalOrderId__c, 
                              Tax__c, Discounts__c, Shipping__c, NumeroPedidoCliente__c, NumeroPedidoERP__c, Type, affiliateId__c,
                              AccountId, Account.Name, Account.ExternalId__c, Account.Email__c, Account.FirstName__c, Account.LastName__c, 
                              Account.Phone, Account.CPF__c, Account.CNPJ__c, Account.PhoneType__c, Brand__c, Brand__r.TokeniHub__c
                        FROM Order 
                        WHERE Id =: idOrder
        ];

        Account account     = order.Account;

        Address__c address  = [ SELECT Id, AddressType__c, 
                                    ReceiverName__c, PostalCode__c, 
                                    City__c, State__c, Street__c, 
                                    Country__c, Number__c, Neighborhood__c, 
                                    Complement__c, Reference__c
                                FROM Address__c 
                                WHERE Account__c =: order.AccountId 
                                LIMIT 1
                                ];

        List<LogisticInformation__c> listLogisticInformation = [SELECT Id, deliveryChannel__c, deliveryCompany__c, logisticContract__c,
                                                                       listPrice__c, Pedido__c, additionalInfo__c, address__c, 
                                                                       dockId__c, friendlyName__c, isPickupStore__c, price__c,
                                                                       sellingPrice__c, shippingEstimate__c, shippingEstimateDate__c
                                                                FROM LogisticInformation__c 
                                                                WHERE Pedido__c =: order.Id
                                                                ];

        System.debug('logisticInformation ' + listLogisticInformation);
        List<Payments__c> listPayments = [SELECT Id, authId__c, cardBrand__c, 
                                                cardHoldersName__c, dueDate__c, firstDigits__c,
                                                installments__c, interestAmount__c, interestRate__c,
                                                lastDigits__c, Pedido__c, originPaymentId__c, Grupo__c,
                                                redemptionCode__c, tid__c, value__c  
                                          FROM Payments__c 
                                          WHERE Pedido__c =: order.Id
                                          ];

        List<OrderItem> listOrderItem = [SELECT Id, Sku__c, Description, Quantity, 
                                            ListPrice, Preco__c, UnitPrice, PreSaleDate__c, 
                                            IsGift__c, IsSubsidized__c, ImageUrl__c, DetailUrl__c, OriginSkuId__c
                                        FROM OrderItem
                                        WHERE OrderId =: order.Id
                                        ];

        TemplateDataIntegrationFields.AccountOUTData accountOUTData                 = new TemplateDataIntegrationFields.AccountOUTData(account);
        TemplateDataIntegrationFields.AddressBillingOUTData billingAddressOUTData   = new TemplateDataIntegrationFields.AddressBillingOUTData(address);
        TemplateDataIntegrationFields.AddressDeliveryOUTData deliveryAddressOUTData = new TemplateDataIntegrationFields.AddressDeliveryOUTData(address);
        
        List<TemplateDataIntegrationFields.LogisticInformationOUTData> listLogisticInfoOUTData = new List<TemplateDataIntegrationFields.LogisticInformationOUTData>();
        List<TemplateDataIntegrationFields.PaymentsOUTData> listPaymentsOUTData                = new List<TemplateDataIntegrationFields.PaymentsOUTData>();
        List<TemplateDataIntegrationFields.ItemsOUTData> listOrderItemsOUTData                 = new List<TemplateDataIntegrationFields.ItemsOUTData>();
        
        for (LogisticInformation__c logisticInformation : listLogisticInformation) {
            TemplateDataIntegrationFields.LogisticInformationOUTData logisticInformationOUTData = new TemplateDataIntegrationFields.LogisticInformationOUTData(logisticInformation);
            listLogisticInfoOUTData.add(logisticInformationOUTData);
        }

        for (Payments__c payments : listPayments) {
            TemplateDataIntegrationFields.PaymentsOUTData paymentsOUTData = new TemplateDataIntegrationFields.PaymentsOUTData(payments);
            listPaymentsOUTData.add(paymentsOUTData);
        }

        for (OrderItem orderItem : listOrderItem) {
            TemplateDataIntegrationFields.ItemsOUTData orderItemOUTData = new TemplateDataIntegrationFields.ItemsOUTData(orderItem);
            listOrderItemsOUTData.add(orderItemOUTData);
        }

        if (account != null && address != null && listLogisticInformation != null && listPayments != null && listOrderItem != null) {

            TemplateDataIntegrationFields.OrderOUTData orderOUTData = new TemplateDataIntegrationFields.OrderOUTData(order);
            orderOUTData.customer        = accountOUTData;
            orderOUTData.billingAddress  = billingAddressOUTData;
            orderOUTData.deliveryAddress = deliveryAddressOUTData;
            orderOUTData.logisticInfo    = listLogisticInfoOUTData;
            orderOUTData.payments        = listPaymentsOUTData;
            orderOUTData.items           = listOrderItemsOUTData;

            Http conexao     = new Http();
            HttpRequest resq = new HttpRequest();
    
            String endpoint = [SELECT Id, Endpoint_iHub__c FROM GeneralSetting__mdt LIMIT 1].Endpoint_iHub__c;
            // String token    = [SELECT Id, TokeniHub__c    FROM GeneralSetting__mdt LIMIT 1].TokeniHub__c;
            String token;

            if(order.brand__c == null) {
                response.hasError   = true;
                response.message    = 'Não foi possível integrar com o ERP pois o Pedido não possui marca. Favor verificar com o administrador.';
            } else if (order.brand__r.TokeniHub__c == null) {
                response.hasError   = true;
                response.message    = 'Não foi possível integrar com o ERP pois a marca do pedido não possui o token necessário para integrar com o ERP. Favor verificar com o administrador.';
            } else {
                // token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiaW50ZWdyYXRpb24iLCJzdG9yZXMiOlsiNWU4YjhlYTgyMTRmNWQwMDE5ZjMwNzQxIl0sImFjdGl2ZSI6dHJ1ZSwiYWNsIjpbIkludGVncmF0aW9uIl0sIl9pZCI6IjYxOTUzYTk1MDM0MDMyMDAxMmJhOTNmYyIsImNyZWF0ZWRCeSI6IjVkODIxNjQ1ZmViMWJjMDAxMTRkOTM3YyIsIm5hbWUiOiJJbnRlZ3JhdGlvbiIsIm9yaWdpbiI6ImlodWIiLCJpYXQiOjE2MzcxNjk4MTN9.eQix8Uj3uhaXTGpoMroOgXqshfiG5_WM6xj4fHhHT8g';
                token = order.brand__r.TokeniHub__c;
            }
    
            System.debug('endpoint ' + endpoint + '/orders');
            System.debug('token ' + token);
            System.debug('body ' + JSON.serializePretty(orderOUTData));
            System.debug('body ' + JSON.serialize(orderOUTData));
    
            resq.setEndpoint(endpoint + '/orders');
            //resq.setEndpoint('https://enae1e1qmbgjmqv.m.pipedream.net');
            
            resq.setHeader('Authorization', 'Bearer ' + token);
            resq.setHeader('Content-Type', 'application/json');
            resq.setBody(serializeWithReplacedKeywords(orderOUTData));
            resq.setMethod('POST');
    
            HttpResponse retorno = conexao.send(resq);
            
            response.statusCode = retorno.getStatusCode();
            response.hasError   = response.statusCode != 200? true : false;
            response.message    = retorno.getBody();
            
            IntegrationUtils.WSLog('Pedido Out', 'Outbound', retorno.getBody(), resq.getBody(), false);

            System.debug('status code ' + retorno.getStatusCode());
            System.debug('retorno ' + retorno.getStatus());
            System.debug('body ' + retorno.getBody());
            System.debug('body ' + JSON.serializePretty(retorno.getBody()));
            
            if (retorno.getStatusCode() == 200) {
                order.Sended__c = true;
                update order;
            }
        } else {
            order.OkForSending__c = false;
            update order;

            response.hasError   = true;
            response.message    = 'As informações ou registros relacionados não estão corretamente preenchidos';
            response.statusCode = null;
        }

        return response;
    }

    private static String serializeWithReplacedKeywords(TemplateDataIntegrationFields.OrderOUTData orderOUTDataToSerialize) {

        return JSON.serialize(orderOUTDataToSerialize).replace('paymentGroup', 'group').replace('addressNumber', 'number');

    }

    public class OrderOUTResponse {
        public String message;
        public Boolean hasError;
        public Integer statusCode;
        public String orderId;

        public OrderOUTResponse(){}

        public OrderOUTResponse(Boolean hasError, String message, Integer statusCode){
            this.hasError = hasError;
            this.message = message;
            this.statusCode = statusCode;
        }
    }
}