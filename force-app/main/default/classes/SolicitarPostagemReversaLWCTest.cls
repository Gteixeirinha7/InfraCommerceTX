@IsTest
public class SolicitarPostagemReversaLWCTest {
    
    private static final TestUtils testUtilsInstance = TestUtils.getInstance();

    @TestSetup
    static void makeData() {
        Account acc = new Account(Name = 'Test Account');
        acc = testUtilsInstance.createNewAccount(acc);
        insert acc;

        Product2 product1 = new Product2(
            Name = 'Test Product 1',
            Description = 'First Test Product',
            ProductCode = 'ABC',
            IsActive = true,
            ExternalId__c = 'TestProduct1'
        );

        Product2 product2 = new Product2(
            Name = 'Test Product 2',
            Description = 'Second Test Product',
            ProductCode = 'DEF',
            IsActive = true,
            ExternalId__c = 'TestProduct2'
        );
        insert new List<Product2>{product1, product2};

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = product1.Id,
            UnitPrice = 10,
            IsActive = true,
            UseStandardPrice = false,
            ExternalID__c = 'PricebookEntry1'
        );

        PricebookEntry standardPrice2 = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = product2.Id,
            UnitPrice = 20,
            IsActive = true,
            UseStandardPrice = false,
            ExternalID__c = 'PricebookEntry2'
        );

        insert new List<PricebookEntry>{standardPrice, standardPrice2};

        Brand__c brand = new Brand__c(
            ExternalID__c = 'BrandA'
        );
        insert brand;

        Address__c address = new Address__c(
            Account__c = acc.Id, 
            AddressType__c = 'Residential',
            City__c = 'Porto Alegre',
            Complement__c = 'Aparento 409b',
            Country__c = 'BRA',
            Neighborhood__c = 'Glória',
            Number__c = '1123',
            PostalCode__c = '90680-570',
            ReceiverName__c = 'Paulo Floss',
            State__c = 'RS',
            Street__c = 'Rua Coronel Aparício Borges'
        );
        insert address;

        Centro_de_Distribuicao__c cd = new Centro_de_Distribuicao__c(
            ExternalID__c = 'cd',
            BairroReversa__c = 'Bairro Reversa',
            CepReversa__c = '09450-000'/*,
            Marca__c = brand.Id*/
        );
        // insert cd;
        
        Order order = new Order(
            AccountId = acc.Id,
            Name = 'Test Order',
            Status = 'Draft',
            EffectiveDate = System.today(),
            EndDate = System.today() + 4,
            Pricebook2Id = pricebookId,
            Endereco__c = address.Id
            // CentrodeDistribuicao__c = cd.Id
        );
        insert order;

        OrderItem orderItem1 = new OrderItem(
            OrderId = order.Id,
            Quantity = 2,
            UnitPrice = 120,
            Product2Id = product1.Id, 
            PricebookEntryId = standardPrice.Id
        );

        OrderItem orderItem2 = new OrderItem(
            OrderId = order.Id,
            Quantity = 2,
            UnitPrice = 160,
            Product2Id = product2.Id, 
            PricebookEntryId = standardPrice2.Id
        );

        insert new List<OrderItem>{orderItem1, orderItem2};

        Case caseObj = new Case(AccountId = acc.id, Order__c = order.Id);
        insert caseObj;
    }
    
    static testMethod void getOrderItemsTest() {
        Case caseObj = [SELECT id FROM Case LIMIT 1];
        List<SolicitarPostagemReversaLWCController.OrderItemModel> orderItemModels = SolicitarPostagemReversaLWCController.getOrderItems(caseObj.Id);
    }

    static testMethod void createReversePostTest() {
        Case caseObj = [SELECT id FROM Case LIMIT 1];
        Map<Id, OrderItem> orderItemsMap = new Map<Id, OrderItem>([SELECT id FROM OrderItem]);
        
        SolicitarPostagemReversaLWCController.Response response = SolicitarPostagemReversaLWCController.createReversePost(caseObj.Id, JSON.serialize(orderItemsMap.keySet()));
    }
}