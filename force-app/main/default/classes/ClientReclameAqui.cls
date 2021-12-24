public with sharing class ClientReclameAqui {
    public ClientReclameAqui() {}

    private static final String AUTH_ENDPOINT = 'https://app.hugme.com.br/api/auth/oauth/token';

    //named credential -> Basic MTQ0NTo4NzMzZDg5ZS03ODY0LTRmY2EtOTgyMS03MDQ2N2Y5YjI5Nzg=
    public static String getAccessToken(){

       Map<String,String> headerParams = new Map<String,String>{ 
        'Content-Type'  => 'application/x-www-form-urlencoded',
        'Authorization' => 'Basic MTQ0NTo4NzMzZDg5ZS03ODY0LTRmY2EtOTgyMS03MDQ2N2Y5YjI5Nzg='
       };

       Map<String,String> body = new Map<String,String>{
        'grant_type' => 'client_credentials'
       };

       HttpRequest request = createRequest('POST', AUTH_ENDPOINT, headerParams, body);
       HttpResponse response = new Http().send(request);
       System.debug('RESPONSE ' + response);
       System.debug('RESPONSE BODY ' + response.getBody());
       System.debug('RESPONSE GET STATUS CODE ' + response.getStatusCode());

       if(response != null && response.getStatusCode() == 200){
           return ((Map<String, String>) JSON.deserialize(response.getBody(), Map<String, String>.class)).get('access_token');
        }
        return null;  
    }

    private static HttpRequest createRequest(String method, String url, Map<String, String> headerParams, Object body) {
        HttpRequest request = new HttpRequest();
        request.setMethod(method);
        request.setEndpoint(url);        
        if(headerParams != null) {
            for(String param : headerParams.keySet()) {
                request.setHeader(param, headerParams.get(param));
            }
        }
        if(body != null) {
            if(headerParams != null && headerParams.get('Content-Type').equalsIgnoreCase('application/json')) {
                if(body instanceof String) {
                    request.setBody(
                        (String) body
                    );
                } else {
                	request.setBody(JSON.serialize(
                        (Map<String, Object>) body
                    ));    
                }
            } else {
                String bodyString = '';
                for(String param : ((Map<String, Object>) body).keySet()) {
                    bodyString += '&' + param + '=' + ((Map<String, Object>) body).get(param);
                }
                request.setBody(bodyString);
            }
        }
        return request;
    }
}