@isTest
public with sharing class IntegrationCaseOUTTest {

    private static final TestUtils testUtilsInstance = TestUtils.getInstance();

    @isTest
    public static void caseOUTTest() {

        Account acc  = new Account(
            Name     = 'Test Account',
            CPF__c   = '62599459060',
            Email__c = 'test@gmail.com'
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
        insert brand;

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
        insert order;

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

        Case caseObj        = new Case();
        caseObj.AccountId   = acc.id;
        caseObj.Order__c    = order.Id;
        caseObj.Type        = 'Atendimento sobre a Troca';
        caseObj.Reason__c   = 'Cliente atesta não conformidade';
        caseObj.Description = 'Description';
        insert caseObj;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IntegrationCaseOUTMock());
        IntegrationCaseOUT.sendCaseOUTFuture(caseObj.Id);
        Test.stopTest();
    }
}