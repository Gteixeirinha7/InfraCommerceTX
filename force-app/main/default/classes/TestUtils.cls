@IsTest
public class TestUtils {

    private static TestUtils testUtils;

    public final List<String> TEST_NAMES = new List<String>{'Marcos', 'Pedro', 'Bruno', 'Amanda', 'Evandro'};
    public final List<String> TEST_PHONE = new List<String>{'93749526181', '4193423528', '12934235284', '1137734844', '1165821795'};
    public final List<String> TEST_EMAILS = new List<String>{
        'marcos@uol.com',
        'pedro@gmail.com',
        'bruno@ymail.com',
        'amanda@hotmail.com',
        'evandro@bol.com'
    };

    public static TestUtils getInstance() {
        if (testUtils == null) {
            testUtils = new TestUtils();
        }
        return testUtils;
    }

    public Account createNewAccount(Account accountObject) {
        if (accountObject == null) {
            accountObject = new Account();
        }

        Integer index = getRandom();

        if (accountObject.name == null) {
            accountObject.name = TEST_NAMES.get(index);
        }

        if (accountObject.phone == null) {
            accountObject.phone = TEST_PHONE.get(index);
        }

        if (accountObject.email__c == null) {
            accountObject.email__c = TEST_EMAILS.get(index);
        }

        return accountObject;
    }

    public Case createNewCase(Case caseObject) {
        if (caseObject == null) {
            caseObject = new Case();
        }

        return caseObject;
    }

    public Case createNewCase(Case caseObject, Account accountObject) {
        caseObject = createNewCase(caseObject);

        if (accountObject.id == null) {
            insert accountObject;
        }

        caseObject.accountId = accountObject.id;

        return caseObject;
    }

    private Integer getRandom() {
        Double randomDouble = Math.random();
        randomDouble = randomDouble * TEST_NAMES.size();
        return randomDouble.intValue();
    }
}