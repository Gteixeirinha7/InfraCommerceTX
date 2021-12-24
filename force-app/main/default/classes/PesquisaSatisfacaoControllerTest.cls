@IsTest
public with sharing class PesquisaSatisfacaoControllerTest {

    private static final TestUtils testUtilsInstance = TestUtils.getInstance();
    
    @TestSetup
    static void makeData(){
        Blob key = Crypto.generateAesKey(128);

        Encryption__c encryption = new Encryption__c(
            key__c = EncodingUtil.base64Encode(key)
        );
        insert encryption;

        Account account = testUtilsInstance.createNewAccount(null);
        insert account;

        Pesquisa_de_Satisfacao__c survey = new Pesquisa_de_Satisfacao__c(
            conta__c = account.id
        );
        insert survey;
    }

    @IsTest
    static void saveSurveyTest() {

        Blob key = EncodingUtil.base64Decode([select Id, key__c from Encryption__c LIMIT 1].key__c);

        Id surveyId = [SELECT id FROM Pesquisa_de_Satisfacao__c LIMIT 1].id;

        String encodedCipherText = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(surveyId)));
        String problemSolved = 'Sim';
        String comments = 'Comentários';
        Integer rating = 5;

        PesquisaSatisfacaoController.ResponseModel response = PesquisaSatisfacaoController.saveSurvey(problemSolved, rating, encodedCipherText, comments);
        System.debug('response => ' + JSON.serializePretty(response));
    }

    @IsTest
    static void saveSurveyTestError() {

        Blob key = EncodingUtil.base64Decode([select Id, key__c from Encryption__c LIMIT 1].key__c);

        Id surveyId = [SELECT id FROM Pesquisa_de_Satisfacao__c LIMIT 1].id;

        String encodedCipherText = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(surveyId)));
        String encodedId = encodingUtil.URLEncode(encodedCipherText, 'UTF-8');
        String problemSolved = 'Talvez';
        String comments = 'Comentários';
        Integer rating = 10;

        PesquisaSatisfacaoController.ResponseModel response = PesquisaSatisfacaoController.saveSurvey(problemSolved, rating, encodedId, comments);
        System.debug('response => ' + JSON.serializePretty(response));
    }

    @IsTest
    static void verifySurveyTest() {
        Blob key = EncodingUtil.base64Decode([select Id, key__c from Encryption__c LIMIT 1].key__c);

        Id surveyId = [SELECT id FROM Pesquisa_de_Satisfacao__c LIMIT 1].id;

        String encodedCipherText = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(surveyId)));
        // String encodedId = encodingUtil.URLEncode(encodedCipherText, 'UTF-8');

        PesquisaSatisfacaoController.ResponseModel response = PesquisaSatisfacaoController.verifySurvey(encodedCipherText);
    }

}