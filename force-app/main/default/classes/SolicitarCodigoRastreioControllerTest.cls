@isTest
public with sharing class SolicitarCodigoRastreioControllerTest {
    
    @isTest
    public static void solicitaCodigoRastreioTest() {
        Account contaTeste = new Account();
        contaTeste.Name    = 'Conta Teste';
        insert contaTeste;

        Case casoTeste              = new Case();
        casoTeste.AccountId         = contaTeste.Id;
        casoTeste.Status            = 'New';
        casoTeste.Origin            = 'Commercial';
        casoTeste.Priority          = 'Medium';
        casoTeste.NumeroColeta__c   = '108518672';
        insert casoTeste;

        Account contaTeste2 = new Account();
        contaTeste2.Name    = 'Conta Teste';
        insert contaTeste2;

        Case casoTeste2              = new Case();
        casoTeste2.AccountId         = contaTeste.Id;
        casoTeste2.Status            = 'New';
        casoTeste2.Origin            = 'Commercial';
        casoTeste2.Priority          = 'Medium';
        casoTeste2.NumeroColeta__c   = '108518672';
        insert casoTeste2;

        ObjetoPostagemReversa__c objetoPostagemReversaTeste = new ObjetoPostagemReversa__c();
        objetoPostagemReversaTeste.Caso__c                  = casoTeste.Id;
        objetoPostagemReversaTeste.idObjetoColeta__c        = '553379';
        insert objetoPostagemReversaTeste;

        Test.setMock(WebServiceMock.class, new SolicitarCodigoRastreioMock());
        Test.startTest();
        SolicitarCodigoRastreioController.recordIdCaso(casoTeste.Id);
        SolicitarCodigoRastreioController.recordIdCaso(casoTeste2.Id);
        SolicitarCodigoRastreioController.solicitaCodigoRastreio(casoTeste.Id);
        SolicitarCodigoRastreioController.solicitaCodigoRastreio(casoTeste2.Id);
        Test.stopTest();
    }
}