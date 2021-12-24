@isTest
public with sharing class PosPostagemControllerTest {
    
    @isTest
    public static void controllerTest(){

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

        Account contaTesteERRO      = new Account();
        contaTesteERRO.Name         = 'Conta Teste';
        insert contaTesteERRO;

        Case casoTesteERRO                  = new Case();
        casoTesteERRO.AccountId             = contaTesteERRO.Id;
        casoTesteERRO.Status                = 'New';
        casoTesteERRO.Origin                = 'Commercial';
        casoTesteERRO.Priority              = 'Medium';
        casoTesteERRO.NumeroColeta__c       = '108518672';
        insert casoTesteERRO;

        ObjetoPostagemReversa__c objetoPostagemReversaTeste = new ObjetoPostagemReversa__c();
        objetoPostagemReversaTeste.Caso__c                  = casoTeste.Id;
        objetoPostagemReversaTeste.idObjetoColeta__c        = '553379';
        objetoPostagemReversaTeste.NumeroEtiqueta__c        = 'QB201737764BR';
        insert objetoPostagemReversaTeste;

        Test.setMock(HttpCalloutMock.class, new RastreioCalloutMock());
        Test.startTest();
        PosPostagemController.PosPostagemController(casoTeste.Id);
        PosPostagemController.PosPostagemController('0');
        PosPostagemController.PosPostagemController(casoTesteERRO.Id);
        Test.stopTest();
    }
}