@IsTest
public with sharing class InventoriesCalloutTest {
    
    public static GeneralSetting__mdt getGeneralSettingsMDT() {
        return new GeneralSetting__mdt(
            Endpoint_iHub__c = 'https://stage-ihub-test.com',
            Token_iHub__c    = 'Token'
        );
    }

    static testMethod void getAllInventoriesTest() {

        InventoryModel inventoryModel = new InventoryModel();

        Test.setMock(HttpCalloutMock.class, new InventoriesCalloutMock());
        Test.startTest();
            InventoriesCallout.InventoriesResponse response = InventoriesCallout.getAllInventories(1);
        Test.stopTest();
    }

    static testMethod void getAllInventoriesTestError() {
        Test.setMock(HttpCalloutMock.class, new InventoriesCalloutMock(true));
        Test.startTest();
            InventoriesCallout.InventoriesResponse response = InventoriesCallout.getAllInventories(1);
        Test.stopTest();
    }

    static testMethod void getSpecificSkuListInventories() {
        Test.setMock(HttpCalloutMock.class, new InventoriesCalloutMock());
        Test.startTest();
            List<String> skus = new List<String>{'100003439500004G', '1000037152018774'};
            InventoriesCallout.InventoriesResponse response = InventoriesCallout.getSpecificSkuListInventories(skus);
        Test.stopTest();
    }

    static testMethod void getSpecificSkuListInventoriesError() {
        Test.setMock(HttpCalloutMock.class, new InventoriesCalloutMock(true));
        Test.startTest();
            List<String> skus = new List<String>{'100003439500004G', '1000037152018774'};
            InventoriesCallout.InventoriesResponse response = InventoriesCallout.getSpecificSkuListInventories(skus);
        Test.stopTest();
    }
}