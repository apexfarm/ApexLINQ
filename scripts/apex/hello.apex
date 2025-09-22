// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

string tempvar = 'Enter_your_name_here';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);

List<Account> accounts = new List<Account>();
Filter filter = new Filter();

// 50000
List<Account> result = (List<Account>) Q(accounts).whereBy(filter).toList();
List<AccountModel> result = (List<AccountModel>) Q(accounts).whereBy(filter).toList(AccountModel.class);


Filter filter = andx()
    .add(forDouble(Account.AnnualRevenue).greaterThan(50000))
    .add(forDouble(Account.AnnualRevenue).lessThan(1000000));

List<Account> result = (List<Account>) Q(accounts).whereBy(filter).orderBy(Account.Field1, Account.Field2, Account.Filed3).toList();






List<Id> accountIds = Q(accounts).toIdList();


public class AccountComparator implements Comparator {
    public Integer compare(Object a, Object b) {
        Account accA = (Account) a;
        Account accB = (Account) b;
        return accA.Name.compareTo(accB.Name);
    }
}

public class AccountFilter implements Filter {
    public AccountFilter(List<Contact> contacts>) {
    }

    public Boolean matches(Object obj) {
        Account acc = (Account) obj;
        return acc.Name != null && acc.Name.startsWith('A');
    }
}

public class AccountModel implements SObjectModel {
    public String Name;
    public String Phone;
    public String Website;

    public void fromSObject(SObject sobj) {
        Account acc = (Account) sobj;
        this.Name = acc.Name;
        this.Phone = acc.Phone;
        this.Website = acc.Website;
    }

    public SObject toSObject() {
        Account acc = new Account();
        acc.Name = this.Name;
        acc.Phone = this.Phone;
        acc.Website = this.Website;
        return acc;
    }
}

CPU Limit Mystery for Dynamic SOQL


