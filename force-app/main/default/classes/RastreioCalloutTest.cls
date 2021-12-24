@IsTest
public with sharing class RastreioCalloutTest {
    
    static testMethod void test() {
        Test.setMock(HttpCalloutMock.class, new RastreioCalloutMock());
        
        Test.startTest();
            RastreioCallout rastreioCalloutInstance = new RastreioCallout();
            SroXML2 xml2 = RastreioCallout.getStatusRastreamento(new List<String>{'QB201737763BR'});
        Test.stopTest();
    }
}