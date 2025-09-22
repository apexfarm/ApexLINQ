@isTest
public class QTest extends Q {
    @isTest
    static void testQ() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 2000; i++) {
            accounts.add(new Account(Name = 'Account ' + i, AnnualRevenue = i * 10000));
        }

        Test.startTest();
        Filter filter = andx()
            .add(forString('Name').startsWith('Account'))
            .add(forString('Name').startsWith('Account'))
            .add(forString('Name').startsWith('Account'))
            .add(forString('Name').startsWith('Account'))
            .add(forString('Name').startsWith('Account'));
        List<Account> result = (List<Account>) Q(accounts).whereBy(filter).toList();
        Test.stopTest();

        Assert.areEqual(2000, result.size());
    }

    @isTest
    static void testQ2() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 10000; i++) {
            accounts.add(new Account(Name = 'Account ' + i, AnnualRevenue = i * 10000));
        }

        Test.startTest();
        List<Account> result = new List<Account>();
        for (Account acc : accounts) {
            if (acc.Name.startsWith('Account')) {
                result.add(acc);
            }
        }
        Test.stopTest();

        Assert.areEqual(10000, result.size());
    }
}
