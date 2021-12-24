@isTest
public with sharing class IntegrationRefundOUTTest {
    private static final TestUtils testUtilsInstance = TestUtils.getInstance();

    @isTest
    public static void IntegrationRefundOUTTest() {

        Account acc  = new Account(
            Name     = 'Test Account',
            CPF__c   = '62599459060',
            Email__c = 'test@gmail.com',
            DocumentType__c = 'cpf'
        );
        acc = testUtilsInstance.createNewAccount(acc);
        insert acc;

        Product2 product1      = new Product2();
        product1.Name          = 'Test Product 1';
        product1.Description   = 'First Test Product';
        product1.ProductCode   = 'ABC';
        product1.IsActive      = true;
        product1.ExternalId__c = 'TestProduct1';
        
        Product2 product2      = new Product2();
        product2.Name          = 'Test Product 2';
        product2.Description   = 'Second Test Product';
        product2.ProductCode   = 'DEF';
        product2.IsActive      = true;
        product2.ExternalId__c = 'TestProduct2';
        insert new List<Product2>{product1, product2};

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry standardPrice    = new PricebookEntry();
        standardPrice.Pricebook2Id      = pricebookId;
        standardPrice.Product2Id        = product1.Id;
        standardPrice.UnitPrice         = 10;
        standardPrice.IsActive          = true;
        standardPrice.UseStandardPrice  = false;
        standardPrice.ExternalID__c     = 'PricebookEntry1';
        
        PricebookEntry standardPrice2   = new PricebookEntry();
        standardPrice2.Pricebook2Id     = pricebookId;
        standardPrice2.Product2Id       = product2.Id;
        standardPrice2.UnitPrice        = 20;
        standardPrice2.IsActive         = true;
        standardPrice2.UseStandardPrice = false;
        standardPrice2.ExternalID__c    = 'PricebookEntry2';
        insert new List<PricebookEntry>{standardPrice, standardPrice2};

        Brand__c brand         = new Brand__c();
        brand.ExternalID__c    = 'BrandA';
        brand.TokeniHub__c     = 'xxxx';
        insert brand;

        Brand__c brand3         = new Brand__c();
        brand3.ExternalID__c    = 'BrandB';
        insert brand3;


        Address__c address      = new Address__c();
        address.Account__c      = acc.Id;
        address.AddressType__c  = 'Residential';
        address.City__c         = 'Porto Alegre';
        address.Complement__c   = 'Aparento 409b';
        address.Country__c      = 'BRA';
        address.Neighborhood__c = 'Glória';
        address.Number__c       = '1123';
        address.PostalCode__c   = '90680-570';
        address.ReceiverName__c = 'Paulo Floss';
        address.State__c        = 'RS';
        address.Street__c       = 'Rua Coronel Aparício Borges';
        insert address;

        Centro_de_Distribuicao__c cd = new Centro_de_Distribuicao__c(); 
        cd.ExternalID__c             = 'cd';
        cd.BairroReversa__c          = 'Bairro Reversa';
        cd.CepReversa__c             = '09450-000';
        insert cd;
        
        Order order                   = new Order();
        order.AccountId               = acc.Id;
        order.Name                    = 'Test Order';
        order.Status                  = 'Draft';
        order.EffectiveDate           = System.today();
        order.EndDate                 = System.today() + 4;
        order.Pricebook2Id            = pricebookId;
        order.Endereco__c             = address.Id;
        order.CentrodeDistribuicao__c = cd.Id;
        order.Brand__c = brand.Id;
        insert order;

        Order order2                   = new Order();
        order2.AccountId               = acc.Id;
        order2.Name                    = 'Test Order';
        order2.Status                  = 'Draft';
        order2.EffectiveDate           = System.today();
        order2.EndDate                 = System.today() + 4;
        order2.Pricebook2Id            = pricebookId;
        order2.Endereco__c             = address.Id;
        order2.CentrodeDistribuicao__c = cd.Id;
        // order2.Brand__c = brand2.Id;
        insert order2;

        Order order3                   = new Order();
        order3.AccountId               = acc.Id;
        order3.Name                    = 'Test Order';
        order3.Status                  = 'Draft';
        order3.EffectiveDate           = System.today();
        order3.EndDate                 = System.today() + 4;
        order3.Pricebook2Id            = pricebookId;
        order3.Endereco__c             = address.Id;
        order3.CentrodeDistribuicao__c = cd.Id;
        order2.Brand__c = brand3.Id;
        insert order3;

        OrderItem orderItem1        = new OrderItem();
        orderItem1.OrderId          = order.Id;
        orderItem1.Quantity         = 2;
        orderItem1.UnitPrice        = 120;
        orderItem1.Product2Id       = product1.Id; 
        orderItem1.PricebookEntryId = standardPrice.Id;
        
        OrderItem orderItem2        = new OrderItem();
        orderItem2.OrderId          = order.Id;
        orderItem2.Quantity         = 2;
        orderItem2.UnitPrice        = 160;
        orderItem2.Product2Id       = product2.Id;
        orderItem2.PricebookEntryId = standardPrice2.Id;

        Invoice__c invoice       = new Invoice__c();
        invoice.Order__c         = order.Id;
        invoice.InvoiceNumber__c = '0000001';
        invoice.ExternalId__c    = 'ASD0F789GASD8FY';
        invoice.InvoiceSerie__c  = 'A';
        invoice.EmissionDate__c  = date.parse('07/09/2021');
        insert invoice;

        insert new List<OrderItem>{orderItem1, orderItem2};

        OrderItem orderItem12        = new OrderItem();
        orderItem12.OrderId          = order2.Id;
        orderItem12.Quantity         = 2;
        orderItem12.UnitPrice        = 120;
        orderItem12.Product2Id       = product1.Id; 
        orderItem12.PricebookEntryId = standardPrice.Id;
        
        OrderItem orderItem22        = new OrderItem();
        orderItem22.OrderId          = order2.Id;
        orderItem22.Quantity         = 2;
        orderItem22.UnitPrice        = 160;
        orderItem22.Product2Id       = product2.Id;
        orderItem22.PricebookEntryId = standardPrice2.Id;

        Invoice__c invoice2       = new Invoice__c();
        invoice2.Order__c         = order2.Id;
        invoice2.InvoiceNumber__c = '0000002';
        invoice2.ExternalId__c    = 'ASD0F789GASD8FG';
        invoice2.InvoiceSerie__c  = 'B';
        invoice2.EmissionDate__c  = date.parse('07/09/2021');
        insert invoice2;

        insert new List<OrderItem>{orderItem12, orderItem22};

        OrderItem orderItem13        = new OrderItem();
        orderItem13.OrderId          = order3.Id;
        orderItem13.Quantity         = 2;
        orderItem13.UnitPrice        = 120;
        orderItem13.Product2Id       = product1.Id; 
        orderItem13.PricebookEntryId = standardPrice.Id;
        
        OrderItem orderItem23        = new OrderItem();
        orderItem23.OrderId          = order3.Id;
        orderItem23.Quantity         = 2;
        orderItem23.UnitPrice        = 160;
        orderItem23.Product2Id       = product2.Id;
        orderItem23.PricebookEntryId = standardPrice2.Id;

        Invoice__c invoice3       = new Invoice__c();
        invoice3.Order__c         = order3.Id;
        invoice3.InvoiceNumber__c = '0000003';
        invoice3.ExternalId__c    = 'ASD0F789GASD8FF';
        invoice3.InvoiceSerie__c  = 'C';
        invoice3.EmissionDate__c  = date.parse('07/09/2021');
        insert invoice3;

        insert new List<OrderItem>{orderItem13, orderItem23};


        Case caseObj        = new Case();
        caseObj.AccountId   = acc.id;
        caseObj.Order__c    = order.Id;
        caseObj.Type        = 'Atendimento sobre a Troca';
        caseObj.Reason__c   = 'Cliente atesta não conformidade';
        caseObj.Description = 'Description';       
        insert caseObj;

        Case caseObj2        = new Case();
        caseObj2.AccountId   = acc.id;
        caseObj2.Order__c    = order2.Id;
        caseObj2.Type        = 'Atendimento sobre a Troca';
        caseObj2.Reason__c   = 'Cliente atesta não conformidade';
        caseObj2.Description = 'Description';       
        insert caseObj2;

        Case caseObj3       = new Case();
        caseObj3.AccountId   = acc.id;
        caseObj3.Order__c    = order3.Id;
        caseObj3.Type        = 'Atendimento sobre a Troca';
        caseObj3.Reason__c   = 'Cliente atesta não conformidade';
        caseObj3.Description = 'Description';       
        insert caseObj3;

        ObjetoPostagemReversa__c objetoPostagemReversaTeste = new ObjetoPostagemReversa__c();
        objetoPostagemReversaTeste.OrderItem__c = orderItem1.Id;
        objetoPostagemReversaTeste.Caso__c      = caseObj.Id;
        objetoPostagemReversaTeste.Product_Selling_Price_Reverse__c = 50;
        // objetoPostagemReversaTeste.idObjetoColeta__c = product1.Id;
        objetoPostagemReversaTeste.Product_Selling_Price_Reverse__c = null;
        objetoPostagemReversaTeste.idObjetoColeta__c        = '553379';
        objetoPostagemReversaTeste.NumeroEtiqueta__c        = 'QB201737764BR';
        insert objetoPostagemReversaTeste;

        ObjetoPostagemReversa__c objetoPostagemReversaTeste2 = new ObjetoPostagemReversa__c();
        objetoPostagemReversaTeste2.OrderItem__c = orderItem12.Id;
        objetoPostagemReversaTeste2.Caso__c      = caseObj2.Id;
        objetoPostagemReversaTeste2.Product_Selling_Price_Reverse__c = 50;
        // objetoPostagemReversaTeste.idObjetoColeta__c = product1.Id;
        objetoPostagemReversaTeste2.Product_Selling_Price_Reverse__c = null;
        objetoPostagemReversaTeste2.idObjetoColeta__c        = '553379';
        objetoPostagemReversaTeste2.NumeroEtiqueta__c        = 'QB201737764BR';
        insert objetoPostagemReversaTeste2;

        ObjetoPostagemReversa__c objetoPostagemReversaTeste3 = new ObjetoPostagemReversa__c();
        objetoPostagemReversaTeste3.OrderItem__c = orderItem13.Id;
        objetoPostagemReversaTeste3.Caso__c      = caseObj3.Id;
        // objetoPostagemReversaTeste2.Product_Selling_Price_Reverse__c = 50;
        // objetoPostagemReversaTeste.idObjetoColeta__c = product1.Id;
        objetoPostagemReversaTeste3.Product_Selling_Price_Reverse__c = null;
        objetoPostagemReversaTeste3.idObjetoColeta__c        = '553379';
        objetoPostagemReversaTeste3.NumeroEtiqueta__c        = 'QB201737764BR';
        insert objetoPostagemReversaTeste3;

        Payments__c payments = new Payments__c();
        payments.grupo__c    = 'creditCard';
        payments.Pedido__c   = order.Id;
        insert payments;

        Payments__c payments2 = new Payments__c();
        payments2.grupo__c    = 'bankInvoice';
        payments2.Pedido__c   = order2.Id;
        insert payments2;

        Payments__c payments3 = new Payments__c();
        payments3.grupo__c    = 'bankInvoice';
        payments3.Pedido__c   = order3.Id;
        insert payments3;

        GeneralSetting__mdt generalSetting = new GeneralSetting__mdt();
        generalSetting.Endpoint_iHub__c = 'https://stage-ihub.infracommerce.com.br/api';

      
        
      
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new IntegrationRefundOUTMock());
            IntegrationRefundOUT.RefundOUTResponse r = new IntegrationRefundOUT.RefundOUTResponse(true, 'message',200);

            IntegrationRefundOUT.sendRefundOUTFuture(caseObj.Id);
            IntegrationRefundOUT.sendRefundOUTFuture(caseObj2.Id);
            IntegrationRefundOUT.sendRefundOUTFuture(caseObj3.Id);


        Test.stopTest();
    }

}