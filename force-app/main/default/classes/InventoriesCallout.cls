public with sharing class InventoriesCallout {

    public static String endpoint;
    public static String token;
    public static String inventoriesURLPath;

    static {
        GeneralSetting__mdt mdt = [SELECT Id, Endpoint_iHub__c, Token_iHub__c FROM GeneralSetting__mdt LIMIT 1];
        endpoint = mdt.Endpoint_iHub__c;
        token = mdt.Token_iHub__c;
        inventoriesURLPath = '/inventories/';
    }

    public static InventoriesResponse getAllInventories(Integer pageNumber) {

        try {

            Map<String, String> body = new Map<String, String> {
                'perPage' => '50',
                'page' => String.valueOf(pageNumber)
            };

            String endpointWithPath = endpoint + '/inventories/';
            HttpRequest request = makeCallout(endpointWithPath, body);
            
            HttpResponse response = new Http().send(request);

            InventoriesResponseFromCallout responseData = (InventoriesResponseFromCallout) JSON.deserialize(response.getBody(), InventoriesResponseFromCallout.class);

            return new InventoriesResponse(responseData.inventories);

        } catch (Exception e) {
            return new InventoriesResponse(true, e.getMessage(), e.getStackTraceString());
        }
    }

    public static InventoriesResponse getSpecificSkuListInventories(List<String> skus) {
        try {

            Map<String, List<String>> body = new Map<String, List<String>> {
                'sku' => skus
            };

            String endpointWithPath = endpoint + '/inventories/';
            HttpRequest request = makeCallout(endpointWithPath, body);

            System.debug('request => ' + request);
            
            HttpResponse response = new Http().send(request);

            System.debug('response => ' + response);

            InventoriesResponseFromCallout responseData = (InventoriesResponseFromCallout) JSON.deserialize(response.getBody(), InventoriesResponseFromCallout.class);

            System.debug('responseData => ' + responseData);

            return new InventoriesResponse(responseData.inventories);

        } catch (Exception e) {
            return new InventoriesResponse(true, e.getMessage(), e.getStackTraceString());
        }
    }

    public static HttpRequest makeCallout(String endpoint, Map<String, Object> body) {
        Map<String, String> headerParams = new Map<String, String> {
            'accept' => '*/*', 
            'Accept-Encoding' => 'gzip, deflate, br', 
            'Authorization' => 'Bearer ' + token
        };

        return createRequest('GET', endpoint, headerParams, body);
    }

    private static HttpRequest createRequest(String method, String url, Map<String, String> headerParams, Object body) {
        HttpRequest request = new HttpRequest();
        request.setMethod(method);
        request.setEndpoint(url);        
        request.setTimeout(120000);
        if(headerParams != null) {
            for(String param : headerParams.keySet()) {
                request.setHeader(param, headerParams.get(param));
            }
        }

        String urlParams = '';
        Map<String, Object> mapObjAux = (Map<String, Object>) body;

        for(String param : mapObjAux.keySet()) {
            if(mapObjAux.get(param) instanceOf List<String>) {
                for(String value : (List<String>) mapObjAux.get(param)) {
                    urlParams += '&' + param + '=' + value;
                }
            } else {
                urlParams += '&' + param + '=' + mapObjAux.get(param);
            }
            urlParams = urlParams.removeStart('&');
        }
        request.setEndpoint(url + '?' + urlParams);
        // request.setEndpoint('https://enrbjiebo0yeume.m.pipedream.net');

        return request;
    }

    public class InventoriesResponseFromCallout {
        public Integer perPage; //10,
        public String  currentPage; //"1",
        public Integer pages; //11912,
        public Integer count; //10,
        public Integer total; //119115
        public List<InventoryModel> inventories;
    }

    public class InventoriesResponse {
        public Boolean isError;
        public String message;
        public String stackTrace;
        public List<InventoryModel> inventories;

        public InventoriesResponse(){}

        public InventoriesResponse(List<InventoryModel> inventories) {
            this.isError     = false;
            this.message     = 'Success';
            this.stackTrace  = null;
            this.inventories = inventories;
        }
        
        public InventoriesResponse(Boolean isError, String message, String stackTrace) {
            this.isError     = isError;
            this.message     = message;
            this.stackTrace  = stackTrace;
            this.inventories = null;
        }
    }
}