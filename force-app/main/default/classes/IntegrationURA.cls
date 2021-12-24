@RestResource(urlMapping='/integration-ura')
global with sharing class IntegrationURA {
    public IntegrationURA() {}

    @HttpPost
    global static void integracaoLigacao(){
        // Http conex       = new Http();
        // HttpRequest resq = new HttpRequest();

        // resq.setEndpoint('INDEFINIDO');
        // resq.setMethod('GET');
        // resq.setHeader('Content-Type', 'application/json');

        // HttpResponse response  = conex.send(resq);
        // System.debug('BODY DE RETORNO ' + JSON.serializePretty(response.getBody()));

        // if (response.getStatusCode() == 0) {
        //     System.debug('INTEGRAÇÃO FEITA COM SUCESSO');
        // } else {
        //     System.debug('STATUS CODE DE RETORNO ' + response.getStatusCode());
        // }

    }
}