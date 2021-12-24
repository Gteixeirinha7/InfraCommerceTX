@IsTest
public class IntegrationOrderINTest {
    
    @IsTest
    static void test() {
        TemplateDataIntegrationFields.PaymentsINData payments = new TemplateDataIntegrationFields.PaymentsINData();
        payments.paymentId        = '1';
        payments.originPaymentId  = 'C416E7C8E1B44919A5F86E882B5AFA86';
        payments.value            = 94.99;
        payments.interestAmount   = 0;
        payments.interestRate     = 0;
        payments.paymentGroup     = 'promissory';
        payments.installments     = 1;
        payments.tid              = '79429355';
        payments.nsu              = '1';
        payments.authId           = '12312312312351';
        payments.cardBrand        = 'VISA';
        payments.firstDigits      = '1234';
        payments.lastDigits       = '6789';

        List<TemplateDataIntegrationFields.PaymentsINData> paymentsList = new List<TemplateDataIntegrationFields.PaymentsINData>{payments};

        TemplateDataIntegrationFields.PickupStoreInfoINData pickupStoreInfo = new TemplateDataIntegrationFields.PickupStoreInfoINData();        
        pickupStoreInfo.additionalInfo = 'Portão 10';
        pickupStoreInfo.address        = 'Rod. dos Bandeirantes, s/n - KM 38 - Calcário, Caieiras - SP, 07700-000';
        pickupStoreInfo.dockId         = '2108374038371';
        pickupStoreInfo.friendlyName   = 'Magalu';
        pickupStoreInfo.isPickupStore  = true;


        TemplateDataIntegrationFields.LogisticInformationINData logisticInfo = new TemplateDataIntegrationFields.LogisticInformationINData();
        logisticInfo.pickupStoreInfo      = pickupStoreInfo;
        logisticInfo.itemIndex            = 0;
        logisticInfo.logisticContract     = 'Normal';
        logisticInfo.price                = 5;
        logisticInfo.listPrice            = 5;
        logisticInfo.sellingPrice         = 5;
        logisticInfo.deliveryCompany      = 'Transportadora';
        logisticInfo.shippingEstimate     = '3bd';
        logisticInfo.shippingEstimateDate = '2020-03-31T12:00:00.000Z';
        logisticInfo.deliveryChannel      = 'delivery';

        List<TemplateDataIntegrationFields.LogisticInformationINData> logisticInfoList = new List<TemplateDataIntegrationFields.LogisticInformationINData>{logisticInfo};

        TemplateDataIntegrationFields.AddressINData deliveryAddress = new TemplateDataIntegrationFields.AddressINData();
        deliveryAddress.addressType   = 'residential';
        deliveryAddress.receiverName  = 'Daniel Silva';
        deliveryAddress.postalCode    = '04548-005';
        deliveryAddress.city          = 'São Paulo';
        deliveryAddress.state         = 'SP';
        deliveryAddress.country       = 'BRA';
        deliveryAddress.street        = 'Av. Dr. Cardoso de Melo';
        deliveryAddress.addressNumber = '1855';
        deliveryAddress.neighborhood  = 'Vila Olímpia';
        deliveryAddress.complement    = '15º andar';
        deliveryAddress.reference     = null;

        TemplateDataIntegrationFields.AddressINData billingAddress = new TemplateDataIntegrationFields.AddressINData();
        billingAddress.addressType   = 'trabalho';
        billingAddress.postalCode    = '09770-000';
        billingAddress.city          = 'São Bernardo do Campo';
        billingAddress.state         = 'SP';
        billingAddress.country       = 'BRA';
        billingAddress.street        = 'Av. Francisco Prestes Maia';
        billingAddress.addressNumber = '275';
        billingAddress.neighborhood  = 'Centro';
        billingAddress.complement    = '15º andar';
        billingAddress.reference     = 'Posto Shell';

        TemplateDataIntegrationFields.PhoneINData phoneINData = new TemplateDataIntegrationFields.PhoneINData();
        phoneINData.phone = '+551155645421';
        phoneINData.type = 'residential';

        List<TemplateDataIntegrationFields.PhoneINData> listPhones = new List<TemplateDataIntegrationFields.PhoneINData>{phoneINData};

        TemplateDataIntegrationFields.AccountINData customer = new TemplateDataIntegrationFields.AccountINData();
        customer.phones           = listPhones;
        customer.email            = 'cb3047054a26455e8a021d9b0c0ae4b2@ct.vtex.com.br';
        customer.isCorporate      = false;
        customer.firstName        = 'Daniel';
        customer.lastName         = 'Silva';
        customer.document         = '27071449910';
        customer.documentType     = 'cpf';
        customer.stateInscription = 'ISENTO';

        TemplateDataIntegrationFields.OrderItemINData orderItemINData1 = new TemplateDataIntegrationFields.OrderItemINData();
        orderItemINData1.sku          = '9900000312999';
        orderItemINData1.name         = 'BERMUDA TESTE DE INTEGRACAO NA API';
        orderItemINData1.quantity     = 5;
        orderItemINData1.listPrice    = 106.99;
        orderItemINData1.price        = 106.99;
        orderItemINData1.sellingPrice = 103.99;
        orderItemINData1.isGift       = false;
        orderItemINData1.isSubsidized = false;
        orderItemINData1.imageUrl     = 'http://infra-950x0-3.jpg?v=636833729431770000';
        orderItemINData1.detailUrl    = '/bermuda/p';
        orderItemINData1.originSkuId  = '18';

        TemplateDataIntegrationFields.OrderItemINData orderItemINData2 = new TemplateDataIntegrationFields.OrderItemINData();
        orderItemINData2.sku          = '9900000312555';
        orderItemINData2.name         = 'CAMISETA TESTE DE INTEGRACAO NA API';
        orderItemINData2.quantity     = 1;
        orderItemINData2.listPrice    = 129.99;
        orderItemINData2.price        = 129.99;
        orderItemINData2.sellingPrice = 119.99;
        orderItemINData2.preSaleDate  = null;
        orderItemINData2.isGift       = false;
        orderItemINData2.isSubsidized = false;
        orderItemINData2.imageUrl     = 'http://infra-950x0-3.jpg?v=636833729431770000';
        orderItemINData2.detailUrl    = '/bermuda/p';
        orderItemINData2.originSkuId  = '18';

        List<TemplateDataIntegrationFields.OrderItemINData> items = new List<TemplateDataIntegrationFields.OrderItemINData>{orderItemINData1, orderItemINData2};

        TemplateDataIntegrationFields.TotalsINData totals = new TemplateDataIntegrationFields.TotalsINData();
        totals.items     = 99.99;
        totals.discounts = 10;
        totals.shipping  = 5;
        totals.tax       = 0;

        TemplateDataIntegrationFields.OrderINData order = new TemplateDataIntegrationFields.OrderINData();
        order.originOrderId       = '987654321';
        order.creationDate        = '2020-03-28T12:00:00.000Z';
        order.value               = 94.99;
        order.status              = 'payment-pending';
        order.visitorDevice       = 'Desktop';
        order.orderType           = 'sale';
        order.orderClassification = '';
        order.omniChannelId       = '';
        order.salesOperatorName   = '';
        order.origin              = null;
        order.salesLocation       = null;
        order.salesOperatorCode   = null;
        order.sellerName          = '';
        
        order.totals              = totals;
        order.items               = items;
        order.customer            = customer;
        order.billingAddress      = billingAddress;
        order.deliveryAddress     = deliveryAddress;
        order.logisticInfo        = logisticInfoList;
        order.payments            = paymentsList;

        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.addHeader('HttpMethod', 'POST');
        req.requestUri = '/services/apexrest/order-in-test';
        String jsonString = JSON.serialize(order);
        req.requestBody = Blob.valueof(jsonString);
        
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
            IntegrationOrderIN.upsertOrder();
        Test.stopTest();
    }

    @IsTest
    static void test2() {
        TemplateDataIntegrationFields.PaymentsINData payments = new TemplateDataIntegrationFields.PaymentsINData();
        payments.paymentId        = '1';
        payments.originPaymentId  = 'C416E7C8E1B44919A5F86E882B5AFA86';
        payments.value            = 94.99;
        payments.interestAmount   = 0;
        payments.interestRate     = 0;
        payments.paymentGroup     = 'promissory';
        payments.installments     = 1;
        payments.tid              = '79429355';
        payments.nsu              = '1';
        payments.authId           = '12312312312351';
        payments.cardBrand        = 'VISA';
        payments.firstDigits      = '1234';
        payments.lastDigits       = '6789';

        List<TemplateDataIntegrationFields.PaymentsINData> paymentsList = new List<TemplateDataIntegrationFields.PaymentsINData>{payments};

        TemplateDataIntegrationFields.PickupStoreInfoINData pickupStoreInfo = new TemplateDataIntegrationFields.PickupStoreInfoINData();        
        pickupStoreInfo.additionalInfo = 'Portão 10';
        pickupStoreInfo.address        = 'Rod. dos Bandeirantes, s/n - KM 38 - Calcário, Caieiras - SP, 07700-000';
        pickupStoreInfo.dockId         = '2108374038371';
        pickupStoreInfo.friendlyName   = 'Magalu';
        pickupStoreInfo.isPickupStore  = true;


        TemplateDataIntegrationFields.LogisticInformationINData logisticInfo = new TemplateDataIntegrationFields.LogisticInformationINData();
        logisticInfo.pickupStoreInfo      = pickupStoreInfo;
        logisticInfo.itemIndex            = 0;
        logisticInfo.logisticContract     = 'Normal';
        logisticInfo.price                = 5;
        logisticInfo.listPrice            = 5;
        logisticInfo.sellingPrice         = 5;
        logisticInfo.deliveryCompany      = 'Transportadora';
        logisticInfo.shippingEstimate     = '3bd';
        logisticInfo.shippingEstimateDate = '2020-03-31T12:00:00.000Z';
        logisticInfo.deliveryChannel      = 'delivery';

        List<TemplateDataIntegrationFields.LogisticInformationINData> logisticInfoList = new List<TemplateDataIntegrationFields.LogisticInformationINData>{logisticInfo};

        TemplateDataIntegrationFields.AddressINData deliveryAddress = new TemplateDataIntegrationFields.AddressINData();
        deliveryAddress.addressType   = 'residential';
        deliveryAddress.receiverName  = 'Daniel Silva';
        deliveryAddress.postalCode    = null;
        deliveryAddress.city          = 'São Paulo';
        deliveryAddress.state         = 'SP';
        deliveryAddress.country       = 'BRA';
        deliveryAddress.street        = 'Av. Dr. Cardoso de Melo';
        deliveryAddress.addressNumber = '1855';
        deliveryAddress.neighborhood  = 'Vila Olímpia';
        deliveryAddress.complement    = '15º andar';
        deliveryAddress.reference     = null;

        TemplateDataIntegrationFields.AddressINData billingAddress = new TemplateDataIntegrationFields.AddressINData();
        billingAddress.addressType   = 'trabalho';
        deliveryAddress.postalCode   = '';
        billingAddress.city          = 'São Bernardo do Campo';
        billingAddress.state         = 'SP';
        billingAddress.country       = 'BRA';
        billingAddress.street        = 'Av. Francisco Prestes Maia';
        billingAddress.addressNumber = '275';
        billingAddress.neighborhood  = 'Centro';
        billingAddress.complement    = '15º andar';
        billingAddress.reference     = 'Posto Shell';

        TemplateDataIntegrationFields.PhoneINData phoneINData = new TemplateDataIntegrationFields.PhoneINData();
        phoneINData.phone = '+551155645421';
        phoneINData.type = 'residential';

        List<TemplateDataIntegrationFields.PhoneINData> listPhones = new List<TemplateDataIntegrationFields.PhoneINData>{phoneINData};

        TemplateDataIntegrationFields.AccountINData customer = new TemplateDataIntegrationFields.AccountINData();
        customer.phones           = listPhones;
        customer.email            = 'cb3047054a26455e8a021d9b0c0ae4b2@ct.vtex.com.br';
        customer.isCorporate      = false;
        customer.firstName        = 'Daniel';
        customer.lastName         = 'Silva';
        customer.document         = '27071449910';
        customer.documentType     = 'cpf';
        customer.stateInscription = 'ISENTO';

        TemplateDataIntegrationFields.OrderItemINData orderItemINData1 = new TemplateDataIntegrationFields.OrderItemINData();
        orderItemINData1.sku          = '9900000312999';
        orderItemINData1.name         = 'BERMUDA TESTE DE INTEGRACAO NA API';
        orderItemINData1.quantity     = 5;
        orderItemINData1.listPrice    = 106.99;
        orderItemINData1.price        = 106.99;
        orderItemINData1.sellingPrice = 103.99;
        orderItemINData1.isGift       = false;
        orderItemINData1.isSubsidized = false;
        orderItemINData1.imageUrl     = 'http://infra-950x0-3.jpg?v=636833729431770000';
        orderItemINData1.detailUrl    = '/bermuda/p';
        orderItemINData1.originSkuId  = '18';

        TemplateDataIntegrationFields.OrderItemINData orderItemINData2 = new TemplateDataIntegrationFields.OrderItemINData();
        orderItemINData2.sku          = '9900000312555';
        orderItemINData2.name         = 'CAMISETA TESTE DE INTEGRACAO NA API';
        orderItemINData2.quantity     = 1;
        orderItemINData2.listPrice    = 129.99;
        orderItemINData2.price        = 129.99;
        orderItemINData2.sellingPrice = 119.99;
        orderItemINData2.preSaleDate  = null;
        orderItemINData2.isGift       = false;
        orderItemINData2.isSubsidized = false;
        orderItemINData2.imageUrl     = 'http://infra-950x0-3.jpg?v=636833729431770000';
        orderItemINData2.detailUrl    = '/bermuda/p';
        orderItemINData2.originSkuId  = '18';

        List<TemplateDataIntegrationFields.OrderItemINData> items = new List<TemplateDataIntegrationFields.OrderItemINData>{orderItemINData1, orderItemINData2};

        TemplateDataIntegrationFields.TotalsINData totals = new TemplateDataIntegrationFields.TotalsINData();
        totals.items     = 99.99;
        totals.discounts = 10;
        totals.shipping  = 5;
        totals.tax       = 0;

        TemplateDataIntegrationFields.OrderINData order = new TemplateDataIntegrationFields.OrderINData();
        order.originOrderId       = '987654321';
        order.creationDate        = '2020-03-28T12:00:00.000Z';
        order.value               = 94.99;
        order.status              = 'payment-pending';
        order.visitorDevice       = 'Desktop';
        order.orderType           = 'sale';
        order.orderClassification = '';
        order.omniChannelId       = '';
        order.salesOperatorName   = '';
        order.origin              = null;
        order.salesLocation       = null;
        order.salesOperatorCode   = null;
        order.sellerName          = '';
        
        order.totals              = totals;
        order.items               = items;
        order.customer            = customer;
        order.billingAddress      = billingAddress;
        order.deliveryAddress     = deliveryAddress;
        order.logisticInfo        = logisticInfoList;
        order.payments            = paymentsList;

        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.addHeader('HttpMethod', 'POST');
        req.requestUri = '/services/apexrest/order-in-test';
        String jsonString = JSON.serialize(order);
        req.requestBody = Blob.valueof(jsonString);
        
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
            IntegrationOrderIN.upsertOrder();
        Test.stopTest();
    }
}