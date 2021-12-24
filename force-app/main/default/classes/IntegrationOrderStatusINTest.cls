@isTest
public with sharing class IntegrationOrderStatusINTest {

    @isTest
    public static void orderStatusINTest(){

        TemplateDataIntegrationFields.OrderItemINData orderItemINData1 = new TemplateDataIntegrationFields.OrderItemINData();
        orderItemINData1.isSubsidized = false;
        orderItemINData1.quantity     = 5;
        orderItemINData1.price        = 106.99;
        orderItemINData1.sku          = '9900000312999';
        
        List<TemplateDataIntegrationFields.OrderItemINData> items = new List<TemplateDataIntegrationFields.OrderItemINData>{orderItemINData1};

        TemplateDataIntegrationFields.OrderINData order = new TemplateDataIntegrationFields.OrderINData();
        order.storeCode           = 'TEST';
        order.internalOrderId     = '9876543210';
        order.status              = 'invoiced';
        order.invoiceNumber       = '12399';
        order.invoiceSerialNumber = '001';
        order.emissionDate        = '2021-09-08T18:19:00.000Z';
        order.eletronicKey        = '95135785245635715901479532012456987000145668';
        order.items               = items;


        RestRequest req  = new RestRequest();
        RestResponse res = new RestResponse();

        req.addHeader('HttpMethod', 'POST');
        req.requestUri    = '/services/apexrest/order-status-test';
        String jsonString = JSON.serialize(order);
        req.requestBody   = Blob.valueof(jsonString);
        
        RestContext.request  = req;
        RestContext.response = res;

        Test.startTest();
        IntegrationOrderStatusIN.updateOrderStatus();
        Test.stopTest();
    }
}