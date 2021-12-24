public with sharing class IntegrationCaseOUT {

    @future(callout=true)
    public static void sendCaseOUTFuture(String idCase) {
        IntegrationCaseOUT.sendCaseOUT(idCase);
    }

    public static CaseOUTResponse sendCaseOUT(String idCase) {

        CaseOUTResponse response = new CaseOUTResponse();

        Case caso = [SELECT Id, Description, Subject, CaseNumber, Reason__c, SubReason__c, Type, ProtocolType__c FROM Case WHERE id =: idCase];

        List<ObjetoPostagemReversa__c> objPostagem = [SELECT Id, OrderItem__c FROM ObjetoPostagemReversa__c WHERE Caso__c =: idCase];

        Set<Id> idsOrderItems = new Set<Id>();
        for (ObjetoPostagemReversa__c postagemReversa : objPostagem) {
            idsOrderItems.add(postagemReversa.OrderItem__c);
        }

        String idOrder = [SELECT Id, Order__c FROM Case WHERE Id =: idCase].Order__c;

        Order order = [ SELECT Id, NumeroPedidoERP__c, NumeroPedidoCliente__c, Name, AccountId, Account.Name, Account.ExternalId__c, 
                            Account.Email__c, Account.Phone, Account.CPF__c, Account.CNPJ__c, Brand__c, Brand__r.TokeniHub__c
                        FROM Order
                        WHERE Id =: idOrder];

        Account account = order.Account;
                        
        Invoice__c invoice;

        List<Invoice__c> listInvoice = [SELECT Id, Order__c, InvoiceNumber__c FROM Invoice__c WHERE Order__c =: idOrder];

        if(listInvoice.size() > 0){
            invoice = listInvoice.get(0);
        }
        System.debug('invoice ' + invoice);

        List<OrderItem> listOrderItems;
        
        if(caso.ProtocolType__c == 'exchange') {
            listOrderItems = [SELECT Id, Sku__c, Quantity, UnitPrice, OrderId FROM OrderItem WHERE OrderId =: idOrder];
        } else {
            listOrderItems = [SELECT Id, Sku__c, Quantity, UnitPrice, OrderId FROM OrderItem WHERE Id IN: idsOrderItems];
        }

        TemplateDataIntegrationFields.AccountCaseOUTData accountOUT           = new TemplateDataIntegrationFields.AccountCaseOUTData(account);
        List<TemplateDataIntegrationFields.ItemsCaseOUTData> listItemsCaseOUT = new List<TemplateDataIntegrationFields.ItemsCaseOUTData>();

        for (OrderItem orderItem : listOrderItems) {
            TemplateDataIntegrationFields.ItemsCaseOUTData itemCaseOUT = new TemplateDataIntegrationFields.ItemsCaseOUTData(orderItem);
            listItemsCaseOUT.add(itemCaseOUT);
        }
        System.debug('invoice ' + invoice);

        Http conexao     = new Http();
        HttpRequest req = new HttpRequest();

        String endpoint  = [SELECT Id, Endpoint_iHub__c FROM GeneralSetting__mdt LIMIT 1].Endpoint_iHub__c;
        //String token     = [SELECT Id, Token_iHub__c    FROM GeneralSetting__mdt LIMIT 1].Token_iHub__c;
        // String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiaW50ZWdyYXRpb24iLCJzdG9yZXMiOlsiNWJkMTBkZDYxOWM1MmIwMDI3YWQyOWE1Il0sImFjdGl2ZSI6dHJ1ZSwiYWNsIjpbIkludGVncmF0aW9uIl0sIl9pZCI6IjYxNTQ5N2U0MjY0YmQyMDAxMmNlMDNkZiIsImNyZWF0ZWRCeSI6IjVkOTRmODdjYTc1OGFkMDAxMWRkYjk2ZSIsIm5hbWUiOiJQcm90b2NvbG8gU2FsZXNmb3JjZSIsIm9yaWdpbiI6InRyb2NhLWZhY2lsIiwiaWF0IjoxNjMyOTMzODYwfQ.Lfj6R0pcD3HdLnPTeqzTRg09tRX5Hu39kvuFvrCULbA';
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

        //req.setEndpoint('https://enae1e1qmbgjmqv.m.pipedream.net');

        String body;

        if(caso.ProtocolType__c == 'exchange') {
            
            TemplateDataIntegrationFields.ExchangeCaseOUTData exchangeCaseOUT = new TemplateDataIntegrationFields.ExchangeCaseOUTData(invoice, order, caso);
            exchangeCaseOUT.customer = accountOUT;
            exchangeCaseOUT.items    = listItemsCaseOUT;
            System.debug('Custumer ' + exchangeCaseOUT.customer);
            System.debug('Items ' + exchangeCaseOUT.items);
            System.debug('CaseOUT ' + exchangeCaseOUT);

            body = JSON.serialize(exchangeCaseOUT);
        
        } else {

            TemplateDataIntegrationFields.CaseOUTData caseOUT = new TemplateDataIntegrationFields.CaseOUTData(invoice, order, caso);
            caseOUT.customer = accountOUT;
            caseOUT.items    = listItemsCaseOUT;
            System.debug('Custumer ' + caseOUT.customer);
            System.debug('Items ' + caseOUT.items);
            System.debug('CaseOUT ' + caseOUT);
            
            body = JSON.serialize(caseOUT);
        }

        req.setEndpoint(endpoint + '/orders/protocols');
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(body);
        req.setMethod('POST');

        HttpResponse resp = conexao.send(req);

        System.debug('resp => ' + resp);
        System.debug('resp.getStatusCode() => ' + resp.getStatusCode());
        System.debug('resp.getBody() => ' + JSON.serialize(resp.getBody()));

        if (resp.getStatusCode() == 201) {
            response.hasError = false;
            response.statusCode = resp.getStatusCode();

            response.message = resp.getBody();

            System.debug('DEU CERTO ' + resp.getStatusCode());
            IntegrationUtils.WSLog('Protocol Out', 'Outbound', body, resp.getBody(), false);
        } else {
            response.hasError = true;
            response.statusCode = resp.getStatusCode();

            response.message = resp.getBody();
            System.debug('STATUS CODE ' + resp.getStatusCode());
            System.debug('Body ' + JSON.serialize(resp.getBody()));
            IntegrationUtils.WSLog('Protocol Out', 'Outbound', body, resp.getBody(), false);
        }

        return response;
    }

    public class CaseOUTResponse {
        public String message;
        public Boolean hasError;
        public Integer statusCode;

        public CaseOUTResponse(){}

        public CaseOUTResponse(Boolean hasError, String message, Integer statusCode){
            this.hasError = hasError;
            this.message = message;
            this.statusCode = statusCode;
        }
    }
}