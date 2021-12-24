@IsTest
public with sharing class CaseTriggerHelperTest {

    private static final TestUtils testUtilsInstance = TestUtils.getInstance();
    

    @IsTest
    static void sendCorreiosExpiredTermEmail6() {
        Account acc = [SELECT id FROM Account LIMIT 1];
        Brand__c brand = [SELECT id FROM Brand__c LIMIT 1];
        Case caseObj = testUtilsInstance.createNewCase(null, acc);
        caseObj.marca__c = brand.id;
        insert caseObj;

        caseObj.ReversaStatus__c = 'Aguardando Check-in Reversa';
        update caseObj;

        Test.startTest();
            caseObj.ReversaStatus__c = 'Aguardando Check-in Reversa';
            update caseObj;
        Test.stopTest();

        // System.assert(!new List<Pesquisa_de_Satisfacao__c>([SELECT id FROM Pesquisa_de_Satisfacao__c WHERE conta__c = :acc.id AND caso__c = :caseObj.id]).isEmpty());
    }

    @IsTest
    static void sendCorreiosExpiredTermEmail5() {
        Account acc = [SELECT id FROM Account LIMIT 1];
        Brand__c brand = [SELECT id FROM Brand__c LIMIT 1];
        Case caseObj = testUtilsInstance.createNewCase(null, acc);
        
        caseObj.marca__c = brand.id;
        insert caseObj;

        caseObj.ReversaStatus__c = 'Entrega não realizada';
        update caseObj;


        Test.startTest();
            caseObj.ReversaStatus__c = 'Entrega não realizada';
            update caseObj;
        Test.stopTest();

        // System.assert(!new List<Pesquisa_de_Satisfacao__c>([SELECT id FROM Pesquisa_de_Satisfacao__c WHERE conta__c = :acc.id AND caso__c = :caseObj.id]).isEmpty());
    }
    
    @IsTest
    static void sendCorreiosExpiredTermEmail4() {
        Account acc = [SELECT id FROM Account LIMIT 1];
        Brand__c brand = [SELECT id FROM Brand__c LIMIT 1];
        Case caseObj = testUtilsInstance.createNewCase(null, acc);
        caseObj.marca__c = brand.id;
        insert caseObj;

        caseObj.ReversaStatus__c = 'Reversa Liberada';
        update caseObj;

        Test.startTest();
            caseObj.ReversaStatus__c = 'Reversa Liberada';
            update caseObj;
        Test.stopTest();

        // System.assert(!new List<Pesquisa_de_Satisfacao__c>([SELECT id FROM Pesquisa_de_Satisfacao__c WHERE conta__c = :acc.id AND caso__c = :caseObj.id]).isEmpty());
    }
    

    @IsTest
    static void sendCorreiosExpiredTermEmail3() {
        Account acc = [SELECT id FROM Account LIMIT 1];
        Brand__c brand = [SELECT id FROM Brand__c LIMIT 1];
        Case caseObj = testUtilsInstance.createNewCase(null, acc);
        caseObj.marca__c = brand.id;
        insert caseObj;

        caseObj.ReversaStatus__c = 'Coletado';
        update caseObj;

        Test.startTest();
            caseObj.ReversaStatus__c = 'Coletado';
            update caseObj;
        Test.stopTest();

        // System.assert(!new List<Pesquisa_de_Satisfacao__c>([SELECT id FROM Pesquisa_de_Satisfacao__c WHERE conta__c = :acc.id AND caso__c = :caseObj.id]).isEmpty());
    }

    
    @IsTest
    static void sendCorreiosExpiredTermEmail2() {
        Account acc = [SELECT id FROM Account LIMIT 1];
        Brand__c brand = [SELECT id FROM Brand__c LIMIT 1];
        Case caseObj = testUtilsInstance.createNewCase(null, acc);
        caseObj.marca__c = brand.id;
        insert caseObj;

    
        caseObj.ReversaStatus__c = 'Prazo de Utilização Expirado';
        update caseObj;

        Test.startTest();
            caseObj.ReversaStatus__c = 'Prazo de Utilização Expirado';
            update caseObj;
        Test.stopTest();

        // System.assert(!new List<Pesquisa_de_Satisfacao__c>([SELECT id FROM Pesquisa_de_Satisfacao__c WHERE conta__c = :acc.id AND caso__c = :caseObj.id]).isEmpty());
    }
    

    @IsTest
    static void sendCorreiosExpiredTermEmail() {
        Account acc = [SELECT id FROM Account LIMIT 1];
        Brand__c brand = [SELECT id FROM Brand__c LIMIT 1];
        Case caseObj = testUtilsInstance.createNewCase(null, acc);
        insert caseObj;

        Test.startTest();
            caseObj.ReversaStatus__c = 'Aguardando Objeto na Agência';
            update caseObj;
        Test.stopTest();

        // System.assert(!new List<Pesquisa_de_Satisfacao__c>([SELECT id FROM Pesquisa_de_Satisfacao__c WHERE conta__c = :acc.id AND caso__c = :caseObj.id]).isEmpty());
    }

    @IsTest
    static void fillProtocolType() {
        Account acc = [SELECT id FROM Account LIMIT 1];
        Brand__c brand = [SELECT id FROM Brand__c LIMIT 1];
        //First case
        Case caseObj = testUtilsInstance.createNewCase(null, acc);
        caseObj.Reason__c = 'Cliente atesta não conformidade';
        caseObj.Type = 'Atendimento sobre a Troca';
        insert caseObj;

        //Second case
        Case caseObj2 = testUtilsInstance.createNewCase(null, acc);
        caseObj2.Reason__c = 'Cliente não gostou do produto';
        caseObj2.Type = 'Atendimento sobre a Devolução';
        insert caseObj2;


        Test.startTest();
            update caseObj;
            update caseObj2;
        Test.stopTest();

        // System.assert(!new List<Pesquisa_de_Satisfacao__c>([SELECT id FROM Pesquisa_de_Satisfacao__c WHERE conta__c = :acc.id AND caso__c = :caseObj.id]).isEmpty());
    }

    public static EmailTemplate getPesquisaSatisfacaoEmailTestTemplate(){
        return new EmailTemplate(
            DeveloperName = 'PesquisaSatisfacao', 
            TemplateType = 'html', 
            FolderId = UserInfo.getUserId(),
            Body = '{!NomeConta} {!NumeroCaso} {!link}',
            HtmlValue = '{!NomeConta} {!NumeroCaso} {!link}',
            Name = 'Pesquisa Satisfação'
        ); 
    }

    @TestSetup
    static void makeData(){
        CaseTriggerHandler.enableTrigger();
        CaseTriggerHandler.disableTrigger();

        Blob key = Crypto.generateAesKey(128);

        Encryption__c encryption = new Encryption__c(
            key__c = EncodingUtil.base64Encode(key)
        );
        insert encryption;

        Account account = testUtilsInstance.createNewAccount(null);
        insert account;

        Brand__c brand = new Brand__c(name = 'Armani', externalId__c = 'Armani', businessName__c = 'Armani', SupportEmail__c = 'armaniatendimento@sac.com.br');
        insert brand;
    }

    @IsTest
    static void sendSurveyEmailTest() {
        Account acc = [SELECT id FROM Account LIMIT 1];
        Brand__c brand = [SELECT id FROM Brand__c LIMIT 1];
        Case caseObj = testUtilsInstance.createNewCase(null, acc);
        caseObj.marca__c = brand.id;
        insert caseObj;

        Test.startTest();
            caseObj.status = 'Closed';
            update caseObj;
        Test.stopTest();

        // System.assert(!new List<Pesquisa_de_Satisfacao__c>([SELECT id FROM Pesquisa_de_Satisfacao__c WHERE conta__c = :acc.id AND caso__c = :caseObj.id]).isEmpty());
    }

    @IsTest
    //testing Pesquisa_de_Satisfacao__c record creation limit
    static void sendSurveyEmailTest2() {
        Account acc = [SELECT id FROM Account LIMIT 1];
        Brand__c brand = [SELECT id FROM Brand__c LIMIT 1];
        Case caseObj = testUtilsInstance.createNewCase(null, acc);
        caseObj.marca__c = brand.id;
        insert caseObj;

        caseObj.status = 'Closed';
        update caseObj;

        // System.assert(!new List<Pesquisa_de_Satisfacao__c>([SELECT id FROM Pesquisa_de_Satisfacao__c WHERE conta__c = :acc.id AND caso__c = :caseObj.id]).isEmpty());

        caseObj.status = 'Em atendimento';
        update caseObj;

        Test.startTest();
            caseObj.status = 'Closed';
            update caseObj;
        Test.stopTest();

        // System.assert([SELECT id FROM Pesquisa_de_Satisfacao__c WHERE conta__c = :acc.id AND caso__c = :caseObj.id].size() == 1);
    }

    @IsTest
    static void createTaskToIntegrationRuptureCaseTest() {
        Account acc = [SELECT id FROM Account LIMIT 1];
        System.debug('acc ' + acc);
        Brand__c brand = [SELECT id FROM Brand__c LIMIT 1];
        System.debug('brand ' + brand);

        // Case caseObj = testUtilsInstance.createNewCase(null, acc);
        // caseObj.Reason__c = 'Cliente atesta não conformidade';
        // caseObj.Type = 'Atendimento sobre a Troca';
        // caseObj.Subject  = 'Ruptura de Pedido';
        // caseObj.ExternalCaseId__c  = 'IHUB2-2121633199';
        
        // insert caseObj;

        Case caseObj = testUtilsInstance.createNewCase(null, acc);
        // caseObj.Type = 'Atendimento sobre o Pedido';
        caseObj.Subject  = 'Ruptura';
        caseObj.ExternalCaseId__c  = 'IHUB2-2121633199';

        System.debug('caseObj pré' + caseObj);
        insert caseObj;
        System.debug('caseObj pós' + caseObj);


    }
}