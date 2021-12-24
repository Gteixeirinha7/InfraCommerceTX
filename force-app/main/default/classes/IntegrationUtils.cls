public class IntegrationUtils {

    public static Boolean convertEmptyString(String str) {
        return ((String.isBlank(str) || str == 'null' || str == null || str == '') ? true : false); 
    }
    
    public static Boolean upsertRecords(List<Database.UpsertResult> upsResults, List<TemplateDataIntegrationFields.Response> responseList, List<SObject> sObjectListToUpsert, Schema.SObjectField field){
        TemplateDataIntegrationFields.Response responseData;
        Boolean hasError = false;

        for(TemplateDataIntegrationFields.Response response : responseList){
            if(response.status == false)
				hasError = true;                
        }

        for(Integer i = 0; i < upsResults.size(); i++){
            responseData = new TemplateDataIntegrationFields.Response();

            SObject objResult = sObjectListToUpsert[i];
            Database.UpsertResult upsResult = upsResults[i];

            if(upsResult.isSuccess()){
                responseData.success(
                    upsResult.getId(), 
                    String.valueOf(objResult.get(field)), 
                    String.valueOf(objResult.getSObjectType())
                );
            }
            else {
                responseData.error(String.valueOf(objResult.get(field)),
                                   upsResult.getErrors()[0].getMessage().replace('Campos obrigatórios ausentes', 'Valor inválido para o campo obrigatório'), 
                                   String.valueOf(objResult.getSObjectType())
                );
                hasError = true;
            }
            responseList.add(responseData);
        }
        return hasError;
    }

    public static void WSLog(String integrationName, String recordTypeName, String payloadIN, String payloadOUT, Boolean hasAnyErrors){

        Boolean shouldUseAttachmentIN  = (payloadIN.length() > 100000);
        Boolean shouldUseAttachmentOUT = (payloadOUT.length() > 100000);

        Datetime tNow = System.now();

        IntegrationLog__c log = new IntegrationLog__c(
            RecordTypeId      = Schema.SObjectType.IntegrationLog__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId(),
            Integration__c    = integrationName,
            HasAttachment__c  = (shouldUseAttachmentIN || shouldUseAttachmentOUT),
            PayloadIN__c     = (shouldUseAttachmentIN  ? '' : payloadIN),
            PayloadOUT__c    = (shouldUseAttachmentOUT ? '' : payloadOUT),
            Status__c         = (hasAnyErrors ? 'ERROR' : 'SUCCESS'),
            ExecuteDate__c    = tNow
        );

        try{
            insert log;

            // Maximum Size for a String
            // 
            List<Attachment> attachmentListToInsert = new List<Attachment>();
            
            if (shouldUseAttachmentIN) {
                attachmentListToInsert.add(createAttachment(log.Id, integrationName, 'IN', log.Name, String.valueOf(tNow), payloadIN));
            }

            if (shouldUseAttachmentOUT) {
                attachmentListToInsert.add(createAttachment(log.Id, integrationName, 'OUT', log.Name, String.valueOf(tNow), payloadOUT));
            }

            if (attachmentListToInsert.size() != 0) {
                Database.insert(attachmentListToInsert);
            }
            
        }catch(Exception e){
            System.debug('EXCEPTION ON LOG - Please review parameters - '+e.getMessage()+' - '+e.getStackTraceString());
        }
    }

    @TestVisible
    private static Attachment createAttachment(String recordId, String integrationName, String inOrOut, String logName, String timeAsString, String payload){    	
    	return new Attachment(Name = 'LOG-'+integrationName+'-'+inOrOut+'-'+timeAsString+'.txt', Body = Blob.valueOf(payload), ParentId = recordId);
    }
}