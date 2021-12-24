public with sharing class CustomLookupController {

    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        
        List < sObject > returnList = new List < sObject > ();
      
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 5';
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }

    @AuraEnabled
    public static List<sObject> searchObject(String objectName, List<String> fields, String searchTerm){
        String searchKeyword = searchTerm + '*';
        String returningQuery = '';
        returningQuery = objectName+' ( Id, '+String.join(fields,',')+')';
        String query = 'FIND :searchKeyword IN ALL FIELDS RETURNING '+returningQuery+' LIMIT 20';
        System.debug(' query '+query);
        List<List<sObject>> searchRecords = Search.Query(Query);
        return searchRecords.get(0);
    }

    @AuraEnabled(cacheable=true)
    public static List<sObject> search(String searchTerm, string myObject, String filter) {
        String myQuery = null;
        if(filter != null && filter != ''){
            myQuery = 'SELECT Id, Name FROM '+myObject+' WHERE Name Like  \'%' + searchTerm + '%\' AND '+filter+' LIMIT  5';
        } else {
            if(searchTerm == null || searchTerm == ''){
                myQuery = 'SELECT Id, Name FROM '+myObject+' WHERE LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT  5';
            } else {
                myQuery = 'SELECT Id, Name FROM '+myObject+' WHERE Name Like  \'%' + searchTerm + '%\' LIMIT  5';
            }
        }
        List<sObject> lookUpList = database.query(myQuery);
        return lookUpList;
    }

    @AuraEnabled(cacheable=true)
    public static List<SObject> getRecordTypeIds(String objectApiName, String fieldApiName, String filter) {
        System.debug(objectApiName);

        if(String.isNotBlank(objectApiName)) {
            List<SObject> recordsList =
            Database.query(
                'SELECT Id, ' + fieldApiName  +
                ' FROM '      + objectApiName +
                ' WHERE '     + filter
            );
        return recordsList;
        }
        else {
            return NULL;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static string getAvailableData(String clientId, String condId, String filter, string checkType) {
        if(checkType == 'Brand'){
            return getAvailableCondicaoData(filter);
        }
        return '[]';
    }

    @AuraEnabled(cacheable=true)
    public static String getCaseBrandData(String caseId){
        try {
            Case caseObj = [SELECT id, Marca__c, Marca__r.Id, Marca__r.Name, Order__c, Order__r.Name, Order__r.Id FROM Case WHERE id =: caseId];

            if(caseObj.Marca__c == null) {
                return null;
            }
            
            BrandData brandData = new BrandData(caseObj.Marca__r);
            OrderData orderData;

            if(caseObj.Order__c != null) {
                orderData = new OrderData(caseObj.Order__c);
                List<OrderItem> orderItems = [SELECT id, product2.externalId__c FROM OrderItem WHERE orderId =: caseObj.order__c];

                List<String> itemSkus = new List<String>();

                for(OrderItem orderItem : orderItems) {
                    itemSkus.add(orderItem.product2.ExternalId__c);
                }

                orderData.orderItemSkus = itemSkus;
            }

            return JSON.serialize(new CaseData(brandData, orderData));

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static string getAvailableCondicaoData(String filter) {
        List<BrandData> brandList = new List<BrandData>();
        for(Brand__c brand : [SELECT id, name FROM Brand__c]){
            if(!brand.Name.toLowerCase().contains(filter.toLowerCase())) continue;
            brandList.add(new BrandData(brand));
        }
        return JSON.serialize(brandList);
    }

    @AuraEnabled(cacheable=true)
    public static String getRecords(String query, String checkType) {
        List<BrandData> listBrandData = new List<BrandData>();
        if (checkType == 'Brand') {
            for (Brand__c brand : Database.query(query)) {
                listBrandData.add(new BrandData(brand));
            }
            return JSON.serialize(listBrandData);
        }
        return null;
    }

    public class CaseData {
        public BrandData brandData {get;set;}
        public OrderData orderData {get;set;}

        public CaseData(){}

        public CaseData(BrandData brandData, OrderData orderData) {
            this.brandData = brandData;
            this.orderData = orderData;
        }
    }

    public class OrderData {
        public String       orderId       {get;set;}
        public List<String> orderItemSkus {get;set;}

        public OrderData(String orderId) {
            this.orderId = orderId;
            this.orderItemSkus = new List<String>();
        }
    }

    public class BrandData{
        public String id {get;set;}
        public String name {get;set;}
        
        public BrandData(Brand__c brand){
            this.id = brand.Id;
            this.name = brand.name;
        }
    }
}