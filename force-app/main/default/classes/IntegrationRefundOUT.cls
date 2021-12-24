public with sharing class IntegrationRefundOUT {
    public IntegrationRefundOUT() {}

    @future(callout=true)
    public static void sendRefundOUTFuture(String idCase) {
        sendRefundOUT(idCase);
    }

    public static RefundOUTResponse sendRefundOUT(String idCase) {
        RefundOUTResponse response = new RefundOUTResponse();

        TemplateDataIntegrationFields.RefundOUTData refundOUTData = new TemplateDataIntegrationFields.RefundOUTData();

        Case caseObj = [
            SELECT  Id, CaseNumber, AccountId, Account.ExternalId__c, Account.DocumentType__c,
                    Order__c, Order__r.Brand__c, Order__r.Brand__r.TokeniHub__c, BankCode__c,
                    ContaCorrente__c, DigitoConta__c, AccountType__c, Agencia__c, Status, ReassignCase__c,
                    Account.Name, Order__r.NumeroPedidoERP__c
            FROM Case 
            WHERE id =: idCase
        ];

        List<Payments__c> paymentMethods = [
            SELECT id, grupo__c, value__c 
            FROM Payments__c 
            WHERE pedido__c =: caseObj.order__c
        ];

        List<ObjetoPostagemReversa__c> itensPostagemReversa = [
            SELECT id, OrderItem__c, OrderItem__r.TotalPrice, Caso__c, Product_Selling_Price_Reverse__c  
            FROM ObjetoPostagemReversa__c 
            WHERE Caso__c =: caseObj.Id
        ];

        Decimal sumPrice = 0; 
        for(ObjetoPostagemReversa__c objPostReversa : itensPostagemReversa) {
            if(objPostReversa.OrderItem__r.TotalPrice != null){
                sumPrice += objPostReversa.OrderItem__r.TotalPrice;
            } else {
                sumPrice += objPostReversa.Product_Selling_Price_Reverse__c;
            }
        }

        refundOUTData.type          = paymentMethods[0].grupo__c;
        refundOUTData.protocol      = caseObj.CaseNumber;
        // refundOUTData.refundValue   = paymentMethods[0].value__c;
        refundOUTData.refundValue   = sumPrice;
        refundOUTData.originOrderId = caseObj.order__r.NumeroPedidoERP__c;

        // if(paymentMethods[0].grupo__c == 'bankInvoice') {

        //     if( String.isBlank(caseObj.ContaCorrente__c) || 
        //         String.isBlank(caseObj.DigitoConta__c) || 
        //         String.isBlank(caseObj.AccountType__c) || 
        //         String.isBlank(caseObj.Agencia__c) || 
        //         String.isBlank(caseObj.BankCode__c)
        //     ) {
        //         response.hasError   = true;
        //         response.message    = 'Estão faltando informações bancárias no Caso.';

        //         return response;
        //     }
        //     TemplateDataIntegrationFields.BankInvoiceOUTData bankAccountOUTData = new TemplateDataIntegrationFields.BankInvoiceOUTData();
        //     bankAccountOUTData.account      = caseObj.ContaCorrente__c; //bank account
        //     bankAccountOUTData.accountDigit = caseObj.DigitoConta__c; //bank account digit
        //     bankAccountOUTData.accountType  = caseObj.AccountType__c; //bank account type
        //     bankAccountOUTData.bankAgency   = caseObj.Agencia__c; //bank account agency
        //     bankAccountOUTData.bankCode     = caseObj.BankCode__c; //bank account code
        //     bankAccountOUTData.customerName = caseObj.Account.Name;
        //     // bankAccountOUTData.document     = caseObj.Account.ExternalId__c;
        //     // bankAccountOUTData.documentType = caseObj.Account.DocumentType__c;
        //     String documentFormated = String.valueOf(caseObj.Account.ExternalId__c);
        //     System.debug('documentFormated ' + documentFormated);
        //     bankAccountOUTData.document     = caseObj.Account.DocumentType__c == 'cpf'? documentFormated.substring(0,3) + '.' + documentFormated.substring(3,6) + '.' + documentFormated.substring(6,9) + '-' + documentFormated.substring(9,11) : 
        //                                                                                 documentFormated.substring(0,2) + '.' + documentFormated.substring(2,5) + '.' + documentFormated.substring(5,8) + '/' + documentFormated.substring(8,12)  + '-' + documentFormated.substring(12,14); 
        //     bankAccountOUTData.documentType = caseObj.Account.DocumentType__c;


        //     refundOUTData.bankAccount = bankAccountOUTData;
        // } else
        if(paymentMethods[0].grupo__c == 'creditCard') {

            TemplateDataIntegrationFields.BankAccountOUTData bankAccountOUTData = new TemplateDataIntegrationFields.BankAccountOUTData();
            // bankAccountOUTData.document = caseObj.Account.ExternalId__c;

            String documentFormated = String.valueOf(caseObj.Account.ExternalId__c);
            bankAccountOUTData.document     = caseObj.Account.DocumentType__c == 'cpf'? documentFormated.substring(0,3) + '.' + documentFormated.substring(3,6) + '.' + documentFormated.substring(6,9) + '-' + documentFormated.substring(9,11) : 
                                                                                        documentFormated.substring(0,2) + '.' + documentFormated.substring(2,5) + '.' + documentFormated.substring(5,8) + '/' + documentFormated.substring(8,12)  + '-' + documentFormated.substring(12,14); 
            refundOUTData.bankAccount       = bankAccountOUTData;
        }

        Http httpConection = new Http();
        HttpRequest resq   = new HttpRequest();

        String endpoint = [SELECT Id, Endpoint_iHub__c FROM GeneralSetting__mdt LIMIT 1].Endpoint_iHub__c;
        // String token    = [SELECT Id, Token_iHub__c    FROM GeneralSetting__mdt LIMIT 1].Token_iHub__c;
        String token;

        if(caseObj.order__r.brand__c == null) {
            response.hasError   = true;
            response.message    = 'Não foi possível integrar com o ERP pois o Pedido não possui marca. Favor verificar com o administrador.';
        } else if (caseObj.order__r.brand__r.TokeniHub__c == null) {
            response.hasError   = true;
            response.message    = 'Não foi possível integrar com o ERP pois a marca do pedido não possui o token necessário para integrar com o ERP. Favor verificar com o administrador.';
        } else {
            // token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiaW50ZWdyYXRpb24iLCJzdG9yZXMiOlsiNWU4YjhlYTgyMTRmNWQwMDE5ZjMwNzQxIl0sImFjdGl2ZSI6dHJ1ZSwiYWNsIjpbIkludGVncmF0aW9uIl0sIl9pZCI6IjYxOTUzYTk1MDM0MDMyMDAxMmJhOTNmYyIsImNyZWF0ZWRCeSI6IjVkODIxNjQ1ZmViMWJjMDAxMTRkOTM3YyIsIm5hbWUiOiJJbnRlZ3JhdGlvbiIsIm9yaWdpbiI6ImlodWIiLCJpYXQiOjE2MzcxNjk4MTN9.eQix8Uj3uhaXTGpoMroOgXqshfiG5_WM6xj4fHhHT8g';
            token = caseObj.order__r.brand__r.TokeniHub__c;
        }

        System.debug('endpoint ' + endpoint + '/finance/refunds');
        System.debug('token ' + token);
        System.debug('body ' + JSON.serializePretty(refundOUTData));
        System.debug('body ' + JSON.serialize(refundOUTData));

        resq.setEndpoint(endpoint + '/finance/refunds');
        //resq.setEndpoint('https://enae1e1qmbgjmqv.m.pipedream.net');
        
        resq.setHeader('Authorization', 'Bearer ' + token);
        resq.setHeader('Content-Type', 'application/json');
        resq.setBody(JSON.serialize(refundOUTData));
        resq.setMethod('POST');

        HttpResponse retorno = httpConection.send(resq);

        response.statusCode = retorno.getStatusCode();
        response.hasError   = response.statusCode != 200? true : false;
        response.message    = retorno.getBody();

        System.debug('status code ' + retorno.getStatusCode());
        System.debug('retorno ' + retorno.getStatus());
        System.debug('body ' + retorno.getBody());
        System.debug('body ' + JSON.serializePretty(retorno.getBody()));
        
        if (retorno.getStatusCode() == 200) {
            System.debug('retorno ok');
            IntegrationUtils.WSLog('Refund Out', 'Outbound', retorno.getBody(), JSON.serialize(refundOUTData), false);
            Map<String, Object> deserializedBody = (Map<String, Object>) JSON.deserializeUntyped(retorno.getBody());
            String refundId = String.valueOf(deserializedBody.get('_id'));
            caseObj.RefundId__c = refundId;

        } else {

            caseObj.Status = 'New';
            caseObj.ReassignCase__c = true;

            IntegrationUtils.WSLog('Refund Out', 'Outbound', retorno.getBody(), JSON.serialize(refundOUTData), true);
        }

        try {

            Boolean previousTriggerState = CaseTriggerHandler.isTriggerEnabled();
            CaseTriggerHandler.disableTrigger();
                update caseObj;
            if(previousTriggerState) {
                CaseTriggerHandler.enableTrigger();
            }
        } catch (Exception e) {
            System.debug('e => ' + e.getMessage());
        }

        return response;
    }

    public class RefundOUTResponse {
        public String message;
        public Boolean hasError;
        public Integer statusCode;

        public RefundOUTResponse(){}

        public RefundOUTResponse(Boolean hasError, String message, Integer statusCode){
            this.hasError = hasError;
            this.message = message;
            this.statusCode = statusCode;
        }
    }
}