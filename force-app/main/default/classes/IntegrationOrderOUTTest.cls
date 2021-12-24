@isTest
public with sharing class IntegrationOrderOUTTest {

    @isTest
    public static void sendOrderOUT () {
        Brand__c marcaTest        = new Brand__c();
        marcaTest.Name            = 'Test';
        marcaTest.Active__c       = 'Active';
        marcaTest.BusinessName__c = 'Marca de Test';
        marcaTest.ExternalId__c   = 'TEST';
        marcaTest.Type__c         = 'B2B';
        marcaTest.TokeniHub__c   = 'TokenTest023i01j0aijr083j0q8f4hja08';
        insert marcaTest;

        Centro_de_Distribuicao__c cdTest = new Centro_de_Distribuicao__c();
        cdTest.Name             = 'Test';
        cdTest.BairroCD__c      = 'Bairro';
        cdTest.BairroReversa__c = 'Bairro Reversa';
        cdTest.CD__c            = 'DCR';
        cdTest.CepCD__c         = '01153-000';
        cdTest.CepReversa__c    = '86010-360';
        cdTest.CidadeCD__c      = 'São Paulo';
        cdTest.CidadeReversa__c = 'Londrina';
        cdTest.UFCD__c          = 'SP';
        cdTest.UFReversa__c     = 'PR';
        cdTest.ExternalId__c    = 'text-classe';
        insert cdTest;

        Account accountTest       = new Account();
        accountTest.Name          = 'AccountTest';
        accountTest.ExternalId__c = '123456';
        accountTest.Email__c      = 'accountTest@gmail.com';
        accountTest.CPF__c        = '12835170006';
        accountTest.Phone         = '11999999999';
        insert accountTest;

        Address__c addressTest      = new Address__c();
        addressTest.Account__c      = accountTest.Id;
        addressTest.AddressType__c  = 'Residencial';
        addressTest.City__c         = 'Londrina';
        addressTest.Country__c      = 'Brasil';
        addressTest.Neighborhood__c = 'Centro';
        addressTest.State__c        = 'PR';
        addressTest.Street__c       = 'Av. Higienópolis';
        addressTest.ReceiverName__c = 'Test';
        insert addressTest;

        Order orderTest                   = new Order();
        //orderTest.ExternalId__c           = '123456';
        orderTest.AccountId               = accountTest.Id;
        orderTest.CentrodeDistribuicao__c = cdTest.Id;
        orderTest.Brand__c                = marcaTest.Id;
        orderTest.Endereco__c             = addressTest.Id;
        orderTest.EffectiveDate           = date.parse('05/11/2021');
        orderTest.Status                  = 'invoiced';
        insert orderTest;

        LogisticInformation__c logisticInformationTest = new LogisticInformation__c();
        logisticInformationTest.ExternalId__c          = '123456789TEST';
        logisticInformationTest.logisticContract__c    = 'Test';
        logisticInformationTest.price__c               = 7;
        logisticInformationTest.sellingPrice__c        = 7;
        logisticInformationTest.listPrice__c           = 7;
        logisticInformationTest.deliveryCompany__c     = 'Test LTDA';
        logisticInformationTest.Pedido__c              =  orderTest.Id;
        insert logisticInformationTest;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IntegrationOrderOUTMock());
        IntegrationOrderOUT.sendOrderOUT(orderTest.Id);
        Test.stopTest();
    }
}