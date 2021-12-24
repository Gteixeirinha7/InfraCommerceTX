public class RastreioCallout {
    public RastreioCallout() {}

    public static SroXML2 getStatusRastreamento(List<String> objetos) {

        String usuario;
        String senha;
        String endpoint;

        if(Test.isRunningTest()) {
            usuario = '1542720700';
            senha = 'DV7V93W74A';
            endpoint = 'http://webservice.correios.com.br:80/service/rastro';
        } else {
            Correios__c correiosCustomSetting = [
                SELECT  id, usuarioSRO__c, senhaSRO__c, endpointSRO__c
                FROM    Correios__c 
                LIMIT 1
            ];

            usuario = correiosCustomSetting.usuarioSRO__c;
            senha = correiosCustomSetting.senhaSRO__c;
            endpoint = correiosCustomSetting.endpointSRO__c;
        }

        String envelopeHeader = 
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:res="http://resource.webservice.correios.com.br/">' +
            '<soapenv:Header/>' +
            '<soapenv:Body>' +
                '<res:buscaEventos>';


        String body = 	'<usuario>' + usuario + '</usuario>' + 
                        '<senha>' + senha + '</senha>' +
                        '<tipo>?</tipo>' +
                        '<resultado>?</resultado>' +
                        '<lingua>101</lingua>' +
                        '<objetos>' + String.join(objetos, '') + '</objetos>';
            
        String envelopeFooter = '</res:buscaEventos>' +
            '</soapenv:Body>' +
            '</soapenv:Envelope>';

        String payload = envelopeHeader + body + envelopeFooter;

        System.debug('payload => ' + payload);

		HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setTimeout(110000);
        request.setEndpoint(endpoint);
		request.setBody(payload);
		request.setHeader('Content-Type', 'text/xml; charset=utf-8');
		request.setHeader('soapaction', 'buscaEventos');

        HttpResponse response = (new Http()).send(request);

        System.debug('response => ' + response);
        System.debug('getHeaderKeys() => ' + JSON.serializePretty(response.getHeaderKeys()));
        for(String key : response.getHeaderKeys()) {
            System.debug('getHeader() => ' + response.getHeader(key));
        }
        System.debug('body => ' + response.getBody());

        String responseBody = response.getBody();

        String betweenReturnTags = responseBody.substringBetween('ns2:buscaEventosResponse xmlns:ns2="http://resource.webservice.correios.com.br/">', '</ns2:buscaEventosResponse>');

        System.debug('betweenReturnTags => ' + betweenReturnTags);

        XMLSerializer serializer = new XMLSerializer();

        String jsonString = serializer.XMLToJson(betweenReturnTags);
        System.debug('jsonString => ' + jsonString);

        if(jsonString.contains('"objeto":{')) {
            jsonString = jsonString.replace('"objeto":{', '"objeto":[{');
            jsonString = jsonString.replace('},"qtd"', '}],"qtd"');
        }

        Map<String, Object> deserializedJson = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        System.debug('deserializedJson => ' + JSON.serializePretty(deserializedJson));

        Map<String, Object> deserializedJson2 = (Map<String, Object>) deserializedJson.get('return');
        System.debug('deserializedJson2 => ' + JSON.serializePretty(deserializedJson2));

        Type requestType = Type.forName('SroXML2');
        SroXML2 request2 = (SroXML2) JSON.deserialize(JSON.serialize(deserializedJson2), requestType);
        System.debug('request2 => ' + JSON.serializePretty(request2));

        return request2;
    }
}