@isTest
public with sharing class BatchReclameAquiTest {
    public BatchReclameAquiTest() {}


    @isTest
    public static void BatchReclameAquiTest(){
        Pricebook2 priceTest = new Pricebook2();
        //priceTest.IsStandard = true;
        priceTest.Name       = 'Pricebook2Test';
        insert priceTest;

        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        
        multimock.setStaticResource('https://app.hugme.com.br/api/auth/oauth/token', 
            'ReclameAqui_AccessToken');

        multimock.setStaticResource('https://app.hugme.com.br/api/ticket/v1/tickets', 
            'ReclameAqui_RetrieveAllTickets');

        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');

        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);

        Test.startTest();
        Database.executeBatch(new BatchReclameAqui());
        Test.stopTest();
    }
}