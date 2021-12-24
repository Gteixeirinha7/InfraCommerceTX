public class InventoriesCalloutMock implements HttpCalloutMock{

    public Boolean isError;

    public InventoriesCalloutMock() {
        this(false);
    }

    public InventoriesCalloutMock(Boolean isError){
        this.isError = isError;
    }

    public HttpResponse respond(HttpRequest request){

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type','application/json; charset=utf-8');
        response.setBody(this.isError? '<<<<<>>>>>' : '{"inventories": [{"seller": null,"stockFactor": null,"externalWarehouseId": null,"availableAdjusted": 0,"_id": "60fa93b5780e4ff72618b203","sku": "100003439500004G","storeId": {"_id": "5bd10dd619c52b0027ad29a5","code": "IFC","description": "Loja teste VTEX -> MLN Infracommerce","icon": "https://assets.website-files.com/60625f8508d07c3d896ed5a1/60ad38f7ee5237e42f3094ee_infracommerce-32x32-.png","name": "Infracommerce","siteUrl": "https://infracommerce.vtexcommercestable.com.br/"},"appliedFactor": 0,"available": 0,"createdAt": "2021-07-23T10:02:29.263Z","description": "SHORTS MALWEELIBERTA 1000034395 - 173 - G","notIntegratedOnOrder": 0,"origin": "Millennium","queryDate": "2021-08-06T10:45:28.252Z","queryMethod": "delta","reserved": 0,"status": "done","storeCode": "IFC","total": 0,"updatedAt": "2021-08-07T07:54:05.292Z"}, {"seller": null,"stockFactor": null,"externalWarehouseId": null,"availableAdjusted": 0,"_id": "60fa93b7780e4ff72618b5a6","sku": "1000037152018774","storeId": {"_id": "5bd10dd619c52b0027ad29a5","code": "IFC","description": "Loja teste VTEX -> MLN Infracommerce","icon": "https://assets.website-files.com/60625f8508d07c3d896ed5a1/60ad38f7ee5237e42f3094ee_infracommerce-32x32-.png","name": "Infracommerce","siteUrl": "https://infracommerce.vtexcommercestable.com.br/"},"appliedFactor": 0,"available": 0,"createdAt": "2021-07-23T10:02:31.615Z","description": "PIJAMA MALWEE LIBERTA 1000037152 - 7498 - 4","notIntegratedOnOrder": 0,"origin": "Millennium","queryDate": "2021-08-06T10:45:28.252Z","queryMethod": "delta","reserved": 0,"status": "done","storeCode": "IFC","total": 0,"updatedAt": "2021-08-07T07:54:08.407Z"}],"perPage": 50,"currentPage": 1,"pages": 1,"count": 2,"total": 2}');
        response.setStatusCode(200);

        return response;
    }
}