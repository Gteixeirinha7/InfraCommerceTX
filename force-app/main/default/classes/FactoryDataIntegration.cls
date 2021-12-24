public with sharing class FactoryDataIntegration {
       
    //Object validation of required fields, adding error response and objects for upsert
    @TestVisible
    private static void validateObject(String fieldId, String fieldKey, SObject data, List<SObject> listToUpsert, List<TemplateDataIntegrationFields.Response> responseList, List<String> requiredField){
        TemplateDataIntegrationFields.Response response = new TemplateDataIntegrationFields.Response();
        if (responseList instanceOf List<TemplateDataIntegrationFields.ResponseParent>) {
			response = new TemplateDataIntegrationFields.ResponseParent();
        }
        response.status = true;
        
        for (String field : requiredField) {
            System.debug('field => ' + field);
            System.debug('data.get(field) => ' + data.get(field));
            if (IntegrationUtils.convertEmptyString(data.get(field) + '')) {
                if (String.isNotEmpty((String)data.get(fieldId))){
                    response.error(
                        data.get(fieldId) + '',
                        data.get(fieldKey) + '',
                        'Valor inválido para o campo obrigatório: ' + field,
                        String.valueOf(listToUpsert.getSObjectType())
                    );
                }
                else {
                    response.error(
                        data.get(fieldKey) + '',
                        'Valor inválido para o campo obrigatório: ' + field,
                        String.valueOf(listToUpsert.getSObjectType())
                    );
                }
                
                System.debug(response);
            	break;
            }
        }

        if(response.status){
            listToUpsert.add(data);
        }
        else{
            responseList.add(response);
        }
    }

    //Conversion of the template list into the object list
    public static void convertSObject(SObject sObj, String service, List<TemplateDataIntegrationFields.FieldData> fieldDataList, List<TemplateDataIntegrationFields.Response> responseList, List<SObject> listToUpsert, Map<String, String> lookups) {

        String sObjectName = String.valueOf(sObj.getSObjectType());

        Type t = Type.forName('TemplateDataIntegrationFields.' + sObjectName.replaceAll('__c|__mdt|__|_', '') +service+ 'Data');

        if (t == null) {
            throw new FactoryDataIntegrationException('Invalid defaults class.');
        }

        TemplateDataIntegrationFields.FieldData defaults = (TemplateDataIntegrationFields.FieldData) t.newInstance();

        for (TemplateDataIntegrationFields.FieldData Obj : fieldDataList) {
            validateObject(defaults.getFieldId(), defaults.getFieldKey(), Obj.serialize(lookups), listToUpsert, responseList, defaults.getRequiredFields());
        }
    }

    public class FactoryDataIntegrationException extends Exception {}
}