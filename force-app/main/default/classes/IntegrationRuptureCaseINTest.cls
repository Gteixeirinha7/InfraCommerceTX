@IsTest
public class IntegrationRuptureCaseINTest {
    
    @IsTest
    static void test() {
        
        Account accountTest       = new Account();
        accountTest.Name          = 'AccountTest';
        accountTest.ExternalId__c = '123456';
        accountTest.Email__c      = 'accountTest@gmail.com';
        accountTest.CPF__c        = '12835170006';
        accountTest.Phone         = '11999999999';

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

        TemplateDataIntegrationFields.CaseINData caseIN2 = new TemplateDataIntegrationFields.CaseINData();
        caseIN2.protocolType = 'exchange';
        caseIN2.invoiceNumber = '342190';
        caseIN2.erpOrderId = 'IHUB2-214150790';
        caseIN2.originOrderId = '8012f000000x92PAAQ';
        caseIN2.subject = 'teste';
        caseIN2.origem = 'ihub';
        caseIN2.mlnCaseId = '123';
        caseIN2.Customer = customer;


 
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.addHeader('HttpMethod', 'POST');
        req.requestUri = '/services/apexrest/rupture-case-in';
        String jsonString = JSON.serialize(caseIN2);
        req.requestBody = Blob.valueof(jsonString);
        
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
           IntegrationRuptureCaseIN.upsertCase();
        Test.stopTest();

    }
}