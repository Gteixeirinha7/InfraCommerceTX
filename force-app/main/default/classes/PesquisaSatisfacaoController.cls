public without sharing class PesquisaSatisfacaoController {
    public PesquisaSatisfacaoController() {}

    @AuraEnabled
    public static ResponseModel verifySurvey(String encodedId){
        System.debug('encodedId => ' + encodedId);
        ResponseModel response;
        try {
            String decryptedId = decryptSurveyId(encodedId);
            System.debug('decryptedId => ' + decryptedId);
            List<Pesquisa_de_Satisfacao__c> surveyRecords = [
                SELECT id
                FROM Pesquisa_de_Satisfacao__c
                WHERE id = :decryptedId
                AND respondida__c = false
            ];
            
            if(surveyRecords.isEmpty()) {
                response = new ResponseModel('Essa pesquisa já foi respondida!', true);
            } else {
                response = new ResponseModel('Sucesso!', false);
            }
        } catch (Exception e) {
            System.debug('e.getMessage() => ' + e.getMessage());
            response = new ResponseModel('Erro: ' + e.getMessage() + ' ; ' + e.getStackTraceString(), true);
        }

        System.debug('response => ' + response);
        return response;
    }

    public static String decryptSurveyId(String encodedId) {
        Blob key = EncodingUtil.base64Decode([select Id, key__c from Encryption__c LIMIT 1].key__c);
        System.debug('key => ' + key);
        System.debug('EncodingUtil.urlEncode(encodedId, \'UTF-8\') => ' + EncodingUtil.urlEncode(encodedId, 'UTF-8'));
        Blob blobData = EncodingUtil.base64Decode(EncodingUtil.urlDecode(EncodingUtil.urlEncode(encodedId, 'UTF-8'), 'UTF-8'));
        Blob decryptedBlob = Crypto.decryptWithManagedIV('AES128', key, blobData);
        String decodedId = decryptedBlob.toString();
        System.debug('decodedId => ' + decodedId);
        return decodedId;
    }

    @AuraEnabled
    public static ResponseModel saveSurvey(String problemSolved, Integer rating, String encodedId, String observations) {
        ResponseModel response;
        System.debug('problemSolved => ' + problemSolved);
        System.debug('rating => ' + rating);
        System.debug('encodedId => ' + encodedId);

        try {
            if(encodedId != null){
                String decodedId = decryptSurveyId(encodedId);
                System.debug('decodedId => ' + decodedId);

                Pesquisa_de_Satisfacao__c pesquisaSatisfacaoRecord = new Pesquisa_de_Satisfacao__c(
                    o_seu_problema_foi_resolvido__c = problemSolved,
                    qual_a_nota_para_este_atendimento__c = rating,
                    id = decodedId,
                    respondida__c = true,
                    comentario__c = observations
                );

                update pesquisaSatisfacaoRecord;
                response = new ResponseModel('Sucesso!', false);
            }
        } catch (Exception e) {
            System.debug('e.getMessage() => ' + e.getMessage());
            response = new ResponseModel('Erro: ' + e.getMessage() + ' ; ' + e.getStackTraceString(), true);
        }

        return response;
    }

    // public class SurveyModel {
    //     public String problemSolved;
    //     public Integer rating;
    //     public String surveyRecordId;
    // }

    public class ResponseModel {
        @AuraEnabled
        public String message;
        @AuraEnabled
        public Boolean isError;

        public ResponseModel(){}

        public ResponseModel(String message, Boolean isError){
            this.message = message;
            this.isError = isError;
        }
    }
}