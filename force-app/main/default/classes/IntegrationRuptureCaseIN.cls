@RestResource(urlMapping='/rupture-case-in')
global with sharing class IntegrationRuptureCaseIN {

    @HttpPost
    global static ResponseModel upsertCase() {
        
        List<TemplateDataIntegrationFields.Response> responseList = new List<TemplateDataIntegrationFields.Response>();
        
        final RestResponse response = RestContext.response;

        Type requestType = Type.forName('TemplateDataIntegrationFields.CaseINData');
        TemplateDataIntegrationFields.CaseINData caseIN = (TemplateDataIntegrationFields.CaseINData) JSON.deserialize(RestContext.request.requestBody.toString(), requestType);

        Map<String, Id> lookups = new Map<String, Id>();
        List<Case> listCaseToUpsert = new List<Case>();
        List<Account> listAccountToUpsert = new List<Account>();

        List<TemplateDataIntegrationFields.CaseINData> requestList = new List<TemplateDataIntegrationFields.CaseINData>{caseIN};

        for (TemplateDataIntegrationFields.CaseINData request : requestList) {

            if(request.customer != null) {
                // String customerDocument = request.customer.document;
                String customerDocument = request.customer.document.replaceAll('[^0-9]+', '');


                for(Account acc : [SELECT id FROM Account WHERE ExternalId__c =: customerDocument]) {
                    lookups.put('Account' + customerDocument, acc.Id);
                }

                if(lookups.keySet().size() == 0) {

                    List<TemplateDataIntegrationFields.AccountINData> customerINData = new List<TemplateDataIntegrationFields.AccountINData>{request.customer};

                    FactoryDataIntegration.convertSObject(new Account(), 'IN', customerINData, responseList, listAccountToUpsert, lookups);

                    IntegrationUtils.upsertRecords(
                        Database.upsert(listAccountToUpsert, Account.ExternalId__c, false), 
                        responseList, 
                        listAccountToUpsert, 
                        Account.ExternalId__c
                    );

                    for(Account acc : [SELECT id FROM Account WHERE ExternalId__c =: customerDocument]) {
                        lookups.put('Account' + customerDocument, acc.Id);
                    }
                }
            }
            if(request.erpOrderId != null) {
                for(Order order : [SELECT id, numeroPedidoERP__c FROM Order WHERE NumeroPedidoERP__c =: request.erpOrderId]) {

                    lookups.put('Order' + request.erpOrderId, order.Id);
                }

                List<Case> existentCases = [SELECT id FROM Case WHERE Order__c IN : lookups.values()];

                request.mlnCaseId = '' + request.erpOrderId + (existentCases.size() + 1);
            }

        }

        // Insert do Caso
        FactoryDataIntegration.convertSObject(new Case(), 'IN', requestList, responseList, listCaseToUpsert, lookups);

        System.debug('listCaseToUpsert => ' + JSON.serializePretty(listCaseToUpsert));

        Boolean hasError = IntegrationUtils.upsertRecords(
            Database.upsert(listCaseToUpsert, Case.ExternalCaseId__c, false), 
            responseList, 
            listCaseToUpsert, 
            Case.ExternalCaseId__c
        );

        for(TemplateDataIntegrationFields.Response res : responseList){
            if(res.status == false) hasError = true;
        }

        System.debug('responseList => ' + JSON.serializePretty(responseList));

        IntegrationUtils.WSLog('Ruptura', 'Inbound', JSON.serialize(caseIN), JSON.serialize(responseList), hasError);

        ResponseModel model = new ResponseModel();
        model.response = responseList;
        return model;
    }
}