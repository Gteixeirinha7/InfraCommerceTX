@isTest
public with sharing class IntegrationReclameAquiTest {
    public IntegrationReclameAquiTest() {}

    @isTest
    public static void retrieveAllTicketsTest(){
        MultiStaticResourceCalloutMock multiMock = new MultiStaticResourceCalloutMock();

        multimock.setStaticResource('https://app.hugme.com.br/api/auth/oauth/token', 
            'ReclameAqui_AccessToken');

        multiMock.setStaticResource('https://app.hugme.com.br/api/ticket/v1/tickets', 
            'ReclameAqui_RetrieveAllTickets');

        multiMock.setStatusCode(200);
        multiMock.setHeader('Content-Type', 'application/json');

        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multiMock);

        Test.startTest();
        IntegrationReclameAqui.retrieveAllTickets();
        Test.stopTest();
    }

    @isTest
    public static void sendPublicMessageTest(){

        MultiStaticResourceCalloutMock multiMock = new MultiStaticResourceCalloutMock();

        multimock.setStaticResource('https://app.hugme.com.br/api/auth/oauth/token', 
            'ReclameAqui_AccessToken');

        multimock.setStaticResource('https://app.hugme.com.br/api/ticket/v1/tickets/message/public', 
            'ReclameAqui_SendPublicMessage');

        multiMock.setStatusCode(200);
        multiMock.setHeader('Content-Type', 'application/json');

        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multiMock);


        IntegrationReclameAqui.SendPublicMessageModel modelPublicMessage = new IntegrationReclameAqui.SendPublicMessageModel('45543619', 'Mensagem de Teste');

        Test.startTest();
        IntegrationReclameAqui.sendPublicMessage(modelPublicMessage);
        Test.stopTest();
    }

    @isTest
    public static void requestTicketEvaluationTest(){

        MultiStaticResourceCalloutMock multiMock = new MultiStaticResourceCalloutMock();

        multimock.setStaticResource('https://app.hugme.com.br/api/auth/oauth/token', 
            'ReclameAqui_AccessToken');

        multimock.setStaticResource('https://app.hugme.com.br/api/ticket/v1/tickets/evaluation', 
            'ReclameAqui_RequestTicketEvaluation');

        multiMock.setStatusCode(200);
        multiMock.setHeader('Content-Type', 'application/json');

        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multiMock);

        IntegrationReclameAqui.RequestTicketEvaluationModel modelTicketsEvaluation = new IntegrationReclameAqui.RequestTicketEvaluationModel('45543619');

        Test.startTest();
        IntegrationReclameAqui.requestTicketEvaluation(modelTicketsEvaluation);
        Test.stopTest();

    }
}