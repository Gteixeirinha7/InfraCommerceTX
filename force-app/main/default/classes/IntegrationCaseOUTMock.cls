public with sharing class IntegrationCaseOUTMock implements HttpCalloutMock {

    public HttpResponse respond(HttpRequest requisicao) {
        HttpResponse resposta = new HttpResponse();
        resposta.setHeader('Content-Type', 'application/json');
        resposta.setBody('{"protocolType": "exchange","externalProtocolId": "KOP-Troca-01","invoiceNumber": 95708,"erpOrderId": "IHUB2-210274890","description": "Cliente solicita a troca de uma Lingua de Gato 85g","customer": {"email": "daniel.silva@infracommerce.com.br","document": "337.963.318-66"},"items": [{"sku": "7891823044363","quantity": 1,"price": 48.84}]}');
        resposta.setStatusCode(200);

        return resposta;
    }
}