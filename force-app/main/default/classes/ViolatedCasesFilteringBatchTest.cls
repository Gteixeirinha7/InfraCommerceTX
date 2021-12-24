@IsTest
public with sharing class ViolatedCasesFilteringBatchTest {
    
    private static final TestUtils testUtilsInstance = TestUtils.getInstance();

    public static EmailTemplate getViolatedCasesEmailTestTemplate() {
        return new EmailTemplate(
            DeveloperName = 'Caso_SLA_Violado', 
            TemplateType = 'html', 
            FolderId = UserInfo.getUserId(),
            Body = '{!UserName} {!CaseList}',
            Name = 'Casos com SLA Violado',
            HtmlValue = '{!BetweenTag}htmlValue{!BetweenTag}'
        );
    }

    @TestSetup
    static void makeData() {

        Profile systemAdmin = [SELECT Id FROM Profile WHERE Name = 'Administrador do sistema' OR Name = 'System Administrator'];

        User manager = new User(
            Alias = 'manag', Email = 'manager@testorg.com',  
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', ProfileId = systemAdmin.Id, 
            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'managerUserA@testorganise.com'
        );
        insert manager;

        User managerB = new User(
            Alias = 'manab', Email = 'managerb@testorg.com',  
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', ProfileId = systemAdmin.Id, 
            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'managerUserB@testorganise.com',
            managerId = manager.Id
        );
        insert managerB;

        User user = new User(
            Alias = 'usera', Email = 'user@testorg.com',  
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', ProfileId = systemAdmin.Id, 
            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'userA@testorganise.com',
            managerId = managerB.Id
        );
        insert user;
    }

    @IsTest
    static void testBatch() {

        User user = [SELECT id FROM User WHERE username = 'userA@testorganise.com'];

        System.runAs(user) {

            Account entitlementAccount = testUtilsInstance.createNewAccount(null);

            Account account = testUtilsInstance.createNewAccount(null);
            Account account2 = testUtilsInstance.createNewAccount(null);
            Account account3 = testUtilsInstance.createNewAccount(null);
            insert new List<Account>{entitlementAccount, account, account2, account3};

            List<SlaProcess> lstEntitlementProcess = [SELECT Id, Name FROM SlaProcess WHERE isActive = true AND name = 'SLA Nível 1 - Padrão' LIMIT 1];

            Entitlement entl = new Entitlement(
                name = 'Test Entitlement', 
                accountId = entitlementAccount.id,
                slaProcessId = lstEntitlementProcess[0].id
                // startDate = Date.today().addDays(-2), 
                // endDate = Date.today().addYears(2)
            );
            insert entl;

            BusinessHours businessHrs = [SELECT id, name FROM BusinessHours LIMIT 1];

            Case caseObj = testUtilsInstance.createNewCase(null, account);
            caseObj.slaStartDate = Datetime.now().addDays(-10);
            caseObj.entitlementId = entl.id;
            caseObj.status = 'In Progress';

            Case caseObj2 = testUtilsInstance.createNewCase(null, account2);
            Case caseObj3 = testUtilsInstance.createNewCase(null, account3);
            insert new List<Case>{caseObj, caseObj2, caseObj3};

            System.debug('caseMilestones => ' + [SELECT id, isViolated, isCompleted FROM CaseMilestone]);

            update caseObj;
            System.debug('caseMilestones => ' + [SELECT id, isViolated, isCompleted FROM CaseMilestone]);

            Test.startTest();
                Database.executeBatch(new ViolatedCasesFilteringBatch(), 200);
            Test.stopTest();
        }
    }
}