public with sharing class IntegrationInvoiceItemIN {

    public static List<TemplateDataIntegrationFields.Response> invoiceItemsIN(Map<String, List<TemplateDataIntegrationFields.InvoiceItemsINData>> mapKeyInvoiceToInvoiceMap, Map<String,Id> lookups) {

        List<TemplateDataIntegrationFields.Response>  responseList                   = new List<TemplateDataIntegrationFields.Response>();
        List<TemplateDataIntegrationFields.InvoiceItemsINData> listInvoiceItemINData = new List<TemplateDataIntegrationFields.InvoiceItemsINData>();

        List<InvoiceItems__c> listInvoiceItem = new List<InvoiceItems__c>();
        Set<String> setInvoiceItemExternalId  = new Set<String>(); 
        Map<String, Boolean> setInvoiceItems = new Map<String, Boolean>();

        for (String key : mapKeyInvoiceToInvoiceMap.keySet()) {            
            for (TemplateDataIntegrationFields.InvoiceItemsINData invItem : mapKeyInvoiceToInvoiceMap.get(key)) {
                if (invItem.externalId != null) {
                    setInvoiceItemExternalId.add(invItem.externalId);
                }
                listInvoiceItemINData.add(invItem);
            }
        }

        if (!listInvoiceItemINData.isEmpty()) {
            FactoryDataIntegration.convertSObject(new InvoiceItems__c(), 'IN', listInvoiceItemINData, responseList, listInvoiceItem, lookups);

            System.debug('listInvoiceItem ' + JSON.serializePretty(listInvoiceItem));
    
            IntegrationUtils.upsertRecords(
                Database.upsert(listInvoiceItem, InvoiceItems__c.ExternalId__c, false),
                responseList, 
                listInvoiceItem, 
                InvoiceItems__c.ExternalId__c
            );
        }
        return responseList;
    }
}