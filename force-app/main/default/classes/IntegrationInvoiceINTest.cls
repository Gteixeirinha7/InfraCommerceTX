@isTest
public with sharing class IntegrationInvoiceINTest {

    @isTest
    public static void invoiceINTest() {
        
        Account acc  = new Account();
        acc.Name     = 'AccTest';
        acc.CPF__c   = '57850088077';
        acc.Email__c = 'AccTest@gmail.com';
        acc.Phone    = '43999999999';
        insert acc;

        Brand__c brand        = new Brand__c();
        brand.Name            = 'Test';
        brand.BusinessName__c = 'Test Apex';
        brand.Type__c         = 'B2C';
        insert brand;

        Order order                  = new Order();
        order.Status                 = 'handling';
        order.Brand__c               = brand.Id;
        order.AccountId              = acc.Id;
        order.NumeroFatura__c        = '18320';
        order.NumeroSerieFatura__c   = '001';
        order.NumeroPedidoCliente__c = '11061692';
        order.NumeroPedidoERP__c     = 'WEB-347872570';
        order.CanalVenda__c          = 'apexClassTest';
        order.Type                   = 'sale';
        order.EffectiveDate          = date.parse('16/09/2021');
        insert order;

        TemplateDataIntegrationFields.IcmsInvoiceINData icmsItemsInvoice = new TemplateDataIntegrationFields.IcmsInvoiceINData();
        icmsItemsInvoice.icmsBase                = 225.75;
        icmsItemsInvoice.icmsAliquot             = 18;
        icmsItemsInvoice.icmsValue               = 40.64;
        icmsItemsInvoice.sharingValueOrigin      = 0;
        icmsItemsInvoice.sharingAliquotOrigin    = '100';
        icmsItemsInvoice.sharingAliquotDestiny   = '0';
        icmsItemsInvoice.taxSituation            = '000';
        icmsItemsInvoice.fcpAliquot              = 0;
        icmsItemsInvoice.fcpBase                 = 225.75;
        icmsItemsInvoice.sharingBaseValueDestiny = 0;

        TemplateDataIntegrationFields.PisInvoiceINData pisItemsInvoice = new TemplateDataIntegrationFields.PisInvoiceINData();
        pisItemsInvoice.pisBase      = 225.75;
        pisItemsInvoice.pisAliquot   = 1.65;
        pisItemsInvoice.pisValue     = 3.73;
        pisItemsInvoice.taxSituation = '01';

        TemplateDataIntegrationFields.CofinsInvoiceINData cofinsItemsInvoice = new TemplateDataIntegrationFields.CofinsInvoiceINData();
        cofinsItemsInvoice.cofinsBase    = 225.75;
        cofinsItemsInvoice.cofinsAliquot = 7.6;
        cofinsItemsInvoice.cofinsValue   = 17.16;
        cofinsItemsInvoice.taxSituation  = '01';

        TemplateDataIntegrationFields.IpiInvoiceINData ipiItemsInvoice = new TemplateDataIntegrationFields.IpiInvoiceINData();
        ipiItemsInvoice.ipiBase      = 0;
        ipiItemsInvoice.ipiAliquot   = 0;
        ipiItemsInvoice.ipiValue     = 0;
        ipiItemsInvoice.taxSituation = '01';

        TemplateDataIntegrationFields.TaxesItemsInvoiceINData taxesItemsInvoice = new TemplateDataIntegrationFields.TaxesItemsInvoiceINData();
        taxesItemsInvoice.icms   = icmsItemsInvoice;
        taxesItemsInvoice.pis    = pisItemsInvoice;
        taxesItemsInvoice.cofins = cofinsItemsInvoice;
        taxesItemsInvoice.ipi    = ipiItemsInvoice;

        TemplateDataIntegrationFields.InvoiceItemsINData itemsInvoice = new TemplateDataIntegrationFields.InvoiceItemsINData();
        itemsInvoice.productId         = 'MAL-1000086017AN68A';
        itemsInvoice.ean               = '7909706573043';
        itemsInvoice.description       = 'test';
        itemsInvoice.ncm               = '62046300';
        itemsInvoice.cfop              = '5102';
        itemsInvoice.unitOfMeasurement = 'UN';
        itemsInvoice.quantityFiscal    = 1;
        itemsInvoice.quantityPhisical  = 1;
        itemsInvoice.unitaryValue      = 215.91;
        itemsInvoice.totalValue        = 215.91;
        itemsInvoice.freightValue      = 9.84;
        itemsInvoice.barcode           = '1000086017AN68AM';    
        itemsInvoice.taxes             = taxesItemsInvoice;

        List<TemplateDataIntegrationFields.InvoiceItemsINData> listItemsInvoice = new List<TemplateDataIntegrationFields.InvoiceItemsINData>{itemsInvoice};

        TemplateDataIntegrationFields.SefazInvoiceINData sefazInvoice = new TemplateDataIntegrationFields.SefazInvoiceINData();
        sefazInvoice.key                           = '35210984429737000700550010003315971041629583';
        //sefazInvoice.originalKey                   = null;
        sefazInvoice.status                        = 'NF AUTORIZADA';
        sefazInvoice.protocol                      = '135211046847525';
        //sefazInvoice.cancellationProtocol          = null;
        //sefazInvoice.cancellationAuthorizationDate = null;
        sefazInvoice.gnreValue                     = 0;
        sefazInvoice.freigthType                   = 'F';

        TemplateDataIntegrationFields.EmitterInvoiceINData emitterInvoice = new TemplateDataIntegrationFields.EmitterInvoiceINData();
        emitterInvoice.document         = '84429737000700';
        emitterInvoice.documentType     = 'cnpj';
        emitterInvoice.stateInscription = '298214441112';
        emitterInvoice.corporateName    = 'MALWEE MALHAS LTDA';
        emitterInvoice.tradeName        = 'MALWEE';
        emitterInvoice.street           = 'AV HELIO OSSAMU DAIKUARA';
        emitterInvoice.neighborhood     = 'JARDIM VISTA ALEGRE';
        emitterInvoice.cityNumber       = 15004;
        emitterInvoice.cityName         = 'EMBU DAS ARTES';
        emitterInvoice.state            = 'SP';
        emitterInvoice.zipCode          = '06807000';
        emitterInvoice.countryNumber    = 1058;
        emitterInvoice.countryName      = 'BRASIL';
        emitterInvoice.phone            = '2107-7200 / 2107-731';
        emitterInvoice.email            = '';

        TemplateDataIntegrationFields.ReceiverInvoiceINData receiverInvoice = new TemplateDataIntegrationFields.ReceiverInvoiceINData();
        receiverInvoice.personType       = 'PF';
        receiverInvoice.document         = '32231255820';
        //receiverInvoice.stateInscription = null;
        receiverInvoice.documentType     = 'CPF';
        receiverInvoice.name             = 'MELINA ALMEIDA';
        receiverInvoice.street           = 'RUA OTÍLIA';
        receiverInvoice.neighborhood     = 'VILA ESPERANÇA';
        receiverInvoice.cityNumber       = 0;
        receiverInvoice.cityName         = 'SAO PAULO';
        receiverInvoice.state            = 'SP';
        receiverInvoice.zipCode          = '03649-000';
        receiverInvoice.countryNumber    = 1058;
        receiverInvoice.countryName      = 'BRASIL';
        receiverInvoice.phone            = '+5511987588625';
        receiverInvoice.email            = 'MELINAALM@GMAIL.COM-213000652723B.CT.VTEX.COM.BR';

        TemplateDataIntegrationFields.TotalInvoiceINData totalInvoice = new TemplateDataIntegrationFields.TotalInvoiceINData();
        totalInvoice.icmsBaseValue = 319.75;
        totalInvoice.icmsValue     = 57.56;
        totalInvoice.icmsBaseST    = 0;
        totalInvoice.icmsValueST   = 0;
        totalInvoice.productsValue = 305.81;
        totalInvoice.freigth       = 13.94;
        totalInvoice.insurance     = 0;
        totalInvoice.discount      = 0;
        totalInvoice.ipiValue      = 0;
        totalInvoice.pisValue      = 5.28;
        totalInvoice.cofinsValue   = 24.3;
        totalInvoice.invoiceValue  = 319.75;
        totalInvoice.quantity      = 2;
        totalInvoice.distinctItem  = 2;
        totalInvoice.volumes       = 1;
        totalInvoice.grossWeight   = 3.23;
        totalInvoice.netWeight     = 3.23;

        TemplateDataIntegrationFields.ShippingCompanyInvoiceINData shippingCompanyInvoice = new TemplateDataIntegrationFields.ShippingCompanyInvoiceINData();
        shippingCompanyInvoice.name             = 'TEX COURIER';
        shippingCompanyInvoice.document         = '73939449000193';
        shippingCompanyInvoice.documentType     = 'cnpj';
        shippingCompanyInvoice.stateInscription = 'ISENTO';
        shippingCompanyInvoice.street           = 'AV. DR. HUMBERTO GIANNELLA, 611';
        shippingCompanyInvoice.neighborhood     = 'JARDIM BELVAL';
        shippingCompanyInvoice.city             = 'SAO PAULO';
        shippingCompanyInvoice.state            = 'SP';
        shippingCompanyInvoice.zipCode          = '06422130';

        TemplateDataIntegrationFields.OrderInvoiceINData orderInvoice = new TemplateDataIntegrationFields.OrderInvoiceINData();
        orderInvoice.internalNumber = 'A';
        orderInvoice.originNumber   = 'WEB-347872570';

        TemplateDataIntegrationFields.InvoiceINData invoice = new TemplateDataIntegrationFields.InvoiceINData();
        invoice.storeCode        = 'MALWEE';
        invoice.storeId          = '5cc76a50ad27490017df3e50';
        invoice.status           = 'pending';
        invoice.invoiceNumber    = '331597';
        invoice.invoiceSerie     = '1';
        invoice.operationType    = 'COMERCIALIZACAO DE MERCADORIAS';
        invoice.emissionDate     = '2021-09-09T00:00:00.000-03:00';
        invoice.isOut            = true;
        invoice.transId          = 33274707;
        invoice.additionalInfo   = 'PEDIDO:WEB-347872570   ENDERECO ENTREGA:RUA OTILIA, 596 - AP 62      CONTATO:MELINA ALMEIDA CANAL DE VENDA IMPOSTOS PAGOS (FEDERAL  R$ 41.13, ESTADUAL  R$ 55.04, TOTAL R$ 96.17)       FONTE: IBPT/EMPRESOMETRO.COM.BR  VERSAO: 21.2.A  CHAVE: 11AEAD';
        invoice.salesChannel     = 'INT';
        invoice.businessUnitCode = 'MALWEE_2';
        invoice.eventCode        = '00936';
        invoice.sefaz            = sefazInvoice;
        invoice.emitter          = emitterInvoice;
        invoice.receiver         = receiverInvoice;
        invoice.total            = totalInvoice;
        invoice.shippingCompany  = shippingCompanyInvoice;
        invoice.order            = orderInvoice;
        invoice.items            = listItemsInvoice;

        RestRequest req  = new RestRequest();
        RestResponse res = new RestResponse();

        req.addHeader('HttpMethod', 'POST');
        req.requestUri    = '/services/apexrest/order-invoice-test';
        String jsonString = JSON.serialize(invoice);
        req.requestBody   = Blob.valueof(jsonString);
        
        RestContext.request  = req;
        RestContext.response = res;

        Test.startTest();
            IntegrationInvoiceIN.invoiceIN();
        Test.stopTest();
    }
}