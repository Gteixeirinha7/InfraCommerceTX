@isTest
public with sharing class IntegrationTroqueFacilINTest {

    @isTest
    public static void TroqueFacilINTest() {

        Brand__c brand        = new Brand__c();
        brand.ExternalId__c = 'NIKE';
        brand.Active__c = 'Active';
        insert brand;

        IntegrationTroqueFacilIN.Customer customer = new IntegrationTroqueFacilIN.Customer();
        customer.first_name = 'Afonso';
        customer.last_name  = 'Mendes';
        customer.email      = 'afonsohofmendes@gmail.com';
        customer.document   = '14232929797';
        customer.phone      = '27998060781';


        IntegrationTroqueFacilIN.Tracking tracking = new IntegrationTroqueFacilIN.Tracking();
        tracking.expire_date        = '2021-12-03 03:00:00';
        tracking.status             = null;
        tracking.message            = null;
        tracking.id                 = 1436928;
        tracking.authorization_code = '1936109250';
        tracking.tracking_code      = null;

        IntegrationTroqueFacilIN.Reason reason = new IntegrationTroqueFacilIN.Reason();
        reason.should_approve = false;
        reason.action         = 'EXG';
        reason.description    = 'Defeito';

        IntegrationTroqueFacilIN.Product product = new IntegrationTroqueFacilIN.Product();
        product.order_id       = 2315476;
        product.price          = '129.99';
        product.selling_price  = '129.99';
        product.sku            = '194276490020';
        product.name           = 'Camisa Nike Brasil II 2020/21 Torcedora Pro S';
        product.protocol       = 'tr_1508787';
        product.reverse_action = 'trocar';
        product.comments       = 'Pedi uma camisa \'G\". Embora a etiqueta diga \'L\', a camisa veio \'M\"';
        product.reason         = reason;
        product.reverse_id     = 1508787;

        List<IntegrationTroqueFacilIN.Product> productList = new List<IntegrationTroqueFacilIN.Product>{product};
       
       
        IntegrationTroqueFacilIN.DestinationData destinationData = new IntegrationTroqueFacilIN.DestinationData();
        destinationData.name             = 'CD Extrema';
        destinationData.type             = 'seller';
        destinationData.seller_id        = 'nike-extrema';
        destinationData.seller_info      = 'nike-extrema';
        destinationData.return_to_seller = true;

        IntegrationTroqueFacilIN.Reverse reverse = new IntegrationTroqueFacilIN.Reverse();
        reverse.id                 = 1508787;
        reverse.reverse_type       = 'courier';
        reverse.reverse_type_name  = 'correios';
        reverse.courier_collect    = false;
        reverse.ecommerce_order_id = 1508960;
        reverse.total_amount       = '144.98';
        reverse.origin             = 'customer';
        reverse.status_id          = 35;
        reverse.type               = 'reverse';
        reverse.destination_data   = destinationData;
        reverse.products           =  productList;
        reverse.tracking           = tracking;

        IntegrationTroqueFacilIN.Data data = new IntegrationTroqueFacilIN.Data();
        data.reverse = reverse;
        data.ecommerce_order = '11837624';
        data.customer = customer;
        
        
        IntegrationTroqueFacilIN.TroqueFacilIN troqueFacil = new IntegrationTroqueFacilIN.TroqueFacilIN();
        troqueFacil.event_name = 'reverse.status.changed.awaiting';
        troqueFacil.event_date = '2021-11-26 21:41:43';
        troqueFacil.data       =  data;
        troqueFacil.signature  = 'NameTest';
        
        

 
        RestRequest req  = new RestRequest();
        RestResponse res = new RestResponse();

        req.addHeader('HttpMethod', 'POST');
        req.requestUri    = '/services/apexrest/troque-facil-in';
        String jsonString = JSON.serialize(troqueFacil);
        req.requestBody   = Blob.valueof(jsonString);
        
        RestContext.request  = req;
        RestContext.response = res;

        Test.startTest();
            IntegrationTroqueFacilIN.upsertCase();
        Test.stopTest();
    
    }
}