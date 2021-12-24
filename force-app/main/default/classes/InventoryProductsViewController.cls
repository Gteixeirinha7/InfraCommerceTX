public with sharing class InventoryProductsViewController {
    @AuraEnabled(cacheable=true)
    public static List<ProductData> getProduct(String brandId, String offSetValue, String searchGenericValue, List<String> productSkuList){
        System.debug('searchGenericValue: ' + searchGenericValue);
        searchGenericValue = searchGenericValue.replaceAll(' ', '%');
        List<ProductData> listProductData = new List<ProductData>();
        List<String> brandIds = new List<String>{brandId};

        
        string query = '';
        query   = 'SELECT Id, ExternalId__c, Name, Cor__c, Tamanho__c '
                + 'FROM Product2 '
                + 'WHERE Marca__c IN: brandIds';
        
        query   += searchGenericValue == ''? '' : ' AND (Name LIKE \'%' + searchGenericValue + '%\' OR ExternalId__c LIKE \'%' + searchGenericValue + '%\')';

        System.debug('productSkuList => ' + productSkuList);

        // if(productSkuList != null && !productSkuList.isEmpty()) {
        //     query   += ' AND ExternalId__c IN: productSkuList';
        // }

        if (!query.contains('LIMIT')) {
            query += offSetValue != '' ? ' Order by Product2.Name LIMIT 8 OFFSET ' + String.escapeSingleQuotes(offSetValue) : ' Order by Product2.Name LIMIT 8';
        }
		
        System.debug('query: ' + query);
        List<Product2> products = new List<Product2>();
        products = Database.query(query);

        List<String> skus = new List<String>();

        for(Product2 product : products){
            skus.add(product.ExternalId__c);
        }

        System.debug('skus => ' + skus);

        Map<String, Decimal> skuToUnitPrice = new Map<String, Decimal>();

        for(PricebookEntry pbEntry : [SELECT id, UnitPrice, Product2.ExternalID__c FROM PricebookEntry WHERE Product2.ExternalID__c IN :skus ORDER BY LastModifiedDate ASC]) {
            skuToUnitPrice.put(pbEntry.Product2.ExternalID__c, pbEntry.UnitPrice);
        }

        InventoriesCallout.InventoriesResponse inventoriesResponse = InventoriesCallout.getSpecificSkuListInventories(skus);

        System.debug('inventoriesResponse => ' + inventoriesResponse);

        Map<String, InventoryModel> skuToInventoryData = new Map<String, InventoryModel>();

        for(InventoryModel inventory : inventoriesResponse.inventories) {
            skuToInventoryData.put(inventory.sku, inventory);
        }

        for(Product2 product : products){

            InventoryModel inventory = skuToInventoryData.get(product.ExternalId__c);

            ProductData productData = new ProductData(product, skuToUnitPrice.get(product.ExternalId__c));

            productData.inventoryQuantity = inventory.available;
            productData.quantityMargin    = 10;
            productData.quantityAlert     = Integer.valueOf(inventory.available) <= 10? true : false;

            listProductData.add(productData);
        }

        return listProductData;
    }

    public class ProductData {
		@AuraEnabled public String  id                {get; set;}
		@AuraEnabled public String  sku               {get; set;}
		@AuraEnabled public String  name              {get; set;}
        @AuraEnabled public String  color             {get; set;}
        @AuraEnabled public String  size              {get; set;}
        @AuraEnabled public String  inventoryQuantity {get; set;}
        @AuraEnabled public Boolean quantityAlert     {get; set;}
        @AuraEnabled public String  productPrice      {get; set;}
        @AuraEnabled public Integer quantityMargin    {get; set;}

        public ProductData() {}
        
        public ProductData(Product2 product, Decimal productPrice) {
            this.id             = product.Id;
            this.sku            = product.ExternalId__c;
            this.name           = product.Name != null? product.Name : '-';
            this.color          = product.Cor__c != null? product.Cor__c : '-';
            this.size           = product.Tamanho__c != null? product.Tamanho__c : '-';
            this.productPrice   = productPrice != null? 'R$' + String.valueOf(productPrice).replace('.', ',') : '-';
        }
    }
}