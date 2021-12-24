@RestResource(urlMapping='/invoice-in')
global with sharing class IntegrationInvoiceIN {

    @HttpPost
    global static ResponseModel invoiceIN() {

        List<TemplateDataIntegrationFields.Response> responseList = new List<TemplateDataIntegrationFields.Response>();
        final RestResponse response = RestContext.response;

        Type requestType = Type.forName('TemplateDataIntegrationFields.InvoiceINData');

        TemplateDataIntegrationFields.InvoiceINData request = (TemplateDataIntegrationFields.InvoiceINData) JSON.deserialize(RestContext.request.requestBody.toString(), requestType);

        Map<String, Id> lookups = new Map<String, Id>();

        List<TemplateDataIntegrationFields.SefazInvoiceINData> sefazInvoiceINData        = new List<TemplateDataIntegrationFields.SefazInvoiceINData>();
        List<TemplateDataIntegrationFields.EmitterInvoiceINData> emitterInvoiceINData    = new List<TemplateDataIntegrationFields.EmitterInvoiceINData>();
        List<TemplateDataIntegrationFields.ReceiverInvoiceINData> receiverInvoiceINData  = new List<TemplateDataIntegrationFields.ReceiverInvoiceINData>();
        List<TemplateDataIntegrationFields.TotalInvoiceINData> totalInvoiceINData        = new List<TemplateDataIntegrationFields.TotalInvoiceINData>();
        List<TemplateDataIntegrationFields.ShippingCompanyInvoiceINData> shippingCompanyInvoiceINData = new List<TemplateDataIntegrationFields.ShippingCompanyInvoiceINData>();
        List<TemplateDataIntegrationFields.OrderInvoiceINData> orderInvoiceINData = new List<TemplateDataIntegrationFields.OrderInvoiceINData>();

        //List<InvoiceItems__c> listInvoiceItemsToUpsert = new List<InvoiceItems__c>();
        //List<TemplateDataIntegrationFields.InvoiceItemsINData> listItemsInvoiceINDataToUpsert = new List<TemplateDataIntegrationFields.InvoiceItemsINData>();

        List<Invoice__c> listInvoiceToUpsert = new List<Invoice__c>();
        List<TemplateDataIntegrationFields.InvoiceINData> listInvoiceINDataToUpsert = new List<TemplateDataIntegrationFields.InvoiceINData>();
        Set<String> setExternalId = new Set<String>();
        Set<String> setOrdersOriginNumber = new Set<String>();
        Map<String, List<TemplateDataIntegrationFields.InvoiceItemsINData>> mapKeyInvoiceToInvoiceItem = new Map<String, List<TemplateDataIntegrationFields.InvoiceItemsINData>>();

        Set<String> caseCodes = new Set<String>();

        List<TemplateDataIntegrationFields.InvoiceINData> requestList = new List<TemplateDataIntegrationFields.InvoiceINData>{request};

        for (TemplateDataIntegrationFields.InvoiceINData invoice : requestList) {

            String externalId      = invoice.sefaz.key;

            if (invoice.sefaz.key != null) {
                setExternalId.add(invoice.sefaz.key);
            }
            listInvoiceINDataToUpsert.add(invoice);

            if(invoice.caseCode != null) {
                caseCodes.add(invoice.caseCode);
            }

            //InvoiceItems__c
            if (invoice.items != null) {
                Integer i = 1;
                for (TemplateDataIntegrationFields.InvoiceItemsINData invItems : invoice.items) {
                    invItems.index = i;
                    if (!mapKeyInvoiceToInvoiceItem.containsKey(externalId)) {
                        mapKeyInvoiceToInvoiceItem.put(externalId, new List<TemplateDataIntegrationFields.InvoiceItemsINData>());
                    }
                    invItems.invoiceId = invoice.sefaz.key;
                    invItems.externalId = invoice.sefaz.key + i;
                    mapKeyInvoiceToInvoiceItem.get(externalId).add(invItems);
                    i++;
                }
            }

            System.debug('invoice.order.originNumber ' + invoice.order.originNumber);

            if (invoice.order?.originNumber != null) {
                setOrdersOriginNumber.add(invoice.order.originNumber);
                invoice.orderExternalId = invoice.order.originNumber;
            }
        }

        if(!caseCodes.isEmpty()) {
            List<Case> casesToUpdateStatus = [SELECT id FROM Case WHERE CaseNumber IN: caseCodes AND ReversaStatus__c = 'Aguardando Check-in Reversa'];

            for(Case caseObj : casesToUpdateStatus) {
                caseObj.ReversaStatus__c = 'Reversa Liberada';
            }

            update casesToUpdateStatus;
        }

        for (Order order : [SELECT Id, NumeroPedidoERP__c FROM Order WHERE NumeroPedidoERP__c IN :setOrdersOriginNumber]) {
            lookups.put('Order' + order.NumeroPedidoERP__c, order.Id);
        }

        Boolean hasError = false;

        if (!listInvoiceINDataToUpsert.isEmpty()) {
            FactoryDataIntegration.convertSObject(new Invoice__c(), 'IN', listInvoiceINDataToUpsert, responseList, listInvoiceToUpsert, lookups);

            System.debug('listInvoiceINDataToUpsert ' + JSON.serializePretty(listInvoiceToUpsert));

            hasError = IntegrationUtils.upsertRecords(
                Database.upsert(listInvoiceToUpsert, Invoice__c.ExternalId__c, false), 
                responseList, 
                listInvoiceToUpsert, 
                Invoice__c.ExternalId__c
            );
        }

        for (Invoice__c invoice : [SELECT Id, ExternalId__c FROM Invoice__c WHERE ExternalId__c IN: setExternalId]) {
            lookups.put('Invoice' + invoice.ExternalId__c, invoice.Id);
        }

        if (!mapKeyInvoiceToInvoiceItem.keySet().isEmpty()) {
            responseList.addAll(IntegrationInvoiceItemIN.invoiceItemsIN(mapKeyInvoiceToInvoiceItem, lookups));
        }

        for(TemplateDataIntegrationFields.Response res : responseList){
            if(res.status == false) hasError = true;
        }

        IntegrationUtils.WSLog('Nota Fiscal', 'Inbound', JSON.serialize(request), JSON.serialize(responseList), hasError);

        ResponseModel model = new ResponseModel();
        model.response      = responseList;
        return model;
    }
}