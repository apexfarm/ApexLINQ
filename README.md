# Apex LINQ

![](https://img.shields.io/badge/version-1.0.0-brightgreen.svg) ![](https://img.shields.io/badge/build-passing-brightgreen.svg) ![](https://img.shields.io/badge/coverage-100%25-brightgreen.svg)

Apex LINQ is a high-performance Salesforce LINQ library designed to work seamlessly with object collections, delivering performance close to native operations. For optimal results, refer to the guidelines in [Apex CPU Limit Optimization](https://medium.com/@jeff.jianfeng.jin/apex-cpu-limit-optimization-9451e9c4b79c).

| Environment           | Installation Link                                                                                                                                         | Version   |
| --------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| Production, Developer | <a target="_blank" href="https://login.salesforce.com/packaging/installPackage.apexp?p0=04tGC000007TPsvYAG"><img src="docs/images/deploy-button.png"></a> | ver 1.0.0 |
| Sandbox               | <a target="_blank" href="https://test.salesforce.com/packaging/installPackage.apexp?p0=04tGC000007TPsvYAG"><img src="docs/images/deploy-button.png"></a>  | ver 1.0.0 |

---

## Table of Contents

- [1. Collection Types](#1-collection-types)
  - [1.1 SObject Class](#11-sobject-class)
  - [1.2 Custom Class](#12-custom-class)
- [2. Transform Operations](#2-transform-operations)
  - [2.1 Filter](#21-filter)
  - [2.2 Sort](#22-sort)
  - [2.3 Slicing](#23-slicing)
  - [2.4 Rollup](#24-rollup)
- [3. Result Operations](#3-result-operations)
  - [3.1 List](#31-list)
  - [3.2 Map](#32-map)
  - [3.3 Reduce](#33-reduce)
  - [3.4 Diff](#34-diff)
- [4. License](#4-license)

## 1. Collection Types

Apex LINQ supports both sObject lists and custom object lists.

### 1.1 SObject Class

Use `Q.of()` to operate on a list of sObjects. This is the most common use case. The following example simply returns the original list.

```java
List<Account> accounts = [SELECT Name FROM Account];
List<Account> results = (List<Account>) Q.of(accounts).toList();
```

### 1.2 Custom Class

To use the library with custom classes, provide the custom class type as the second parameter to `Q.of()`. The following example returns the original list.

```java
List<Model> models = new List<Model> { m1, m2, m3 };
List<Model> results = (List<Model>) Q.of(models, Model.class).toList();
```

## 2. Transform Operations

### 2.1 Filter

To filter records, implement the `Q.Filter` interface.

1. In the example below, `AnnualRevenue` is cast from `Decimal` to `Double` before comparison.
2. It is recommended to implement `Q.Filter` as an inner class, close to where it is used.

```java
public class AccountFilter implements Q.Filter {
    public Boolean matches(Object record) {
        Account acc = (Account) record;
        return (Double) acc.AnnualRevenue > 10000;
    }
}
```

Apply the filter as shown below. This example returns all accounts with annual revenue greater than 10,000.

```java
List<Account> accounts = [SELECT Name, Industry, AnnualRevenue FROM Account];
Q.Filter filter = new AccountFilter();
List<Account> results = (List<Account>) Q.of(accounts).filter(filter).toList();
```

### 2.2 Sort

To sort records, implement the `Q.Sorter` interface. Sorting is CPU-intensive, so only sort when necessary.

```java
public class AccountSorter implements Q.Sorter {
    public Integer compare(Object arg1, Object arg2) {
        Double revenue1 = ((Account) arg1).AnnualRevenue;
        Double revenue2 = ((Account) arg2).AnnualRevenue;

        if (revenue1 < revenue2) {
            return -1;
        } else if (revenue1 > revenue2) {
            return 1;
        } else {
            return 0;
        }
    }
}
```

Apply the sorter as shown below. This example returns filtered accounts sorted in ascending order by annual revenue.

```java
List<Account> accounts = [SELECT Name, AnnualRevenue FROM Account];
Q.Filter filter = new AccountFilter();
Q.Sorter sorter = new AccountSorter();
List<Account> results = (List<Account>) Q.of(accounts)
    .filter(filter)
    .sortBy(sorter)
    .toList();
```

### 2.3 Slicing

Apex LINQ provides several common slicing operations. When chained, each operation acts on the result of the previous one.

```java
List<Account> accounts = [SELECT Name, Industry, AnnualRevenue FROM Account];
List<Account> results = (List<Account>) Q.of(accounts, SObject.class)
    .skip(5)      // Skip the first 5 elements and return the rest
    .take(4)      // Take the next 4 elements from the current result
    .tail(3)      // Take the last 3 elements from the current result
    .slice(0, 2)  // Select elements at positions 0 and 1 (zero-based, upper bound exclusive)
    .toList();
```

### 2.4 Rollup

To perform rollup operations, implement the `Q.Rollup` interface. Specify which fields to use as rollup summary keys, and define the logic to compute summary values for each group.

```java
public class AccountRollup implements Q.Rollup {
    public List<Object> getKeys(Object record) {
        Account acc = (Account) record;
        return new List<Object>{ acc.Industry };
    }

    public Map<String, Object> summary(List<Object> mapKeys, List<Object> records) {
        Map<String, Object> result = new Map<String, Object>();
        Double sumRevenue = 0;
        Double maxRevenue = 0;
        for (Object record : records) {
            Account acc = (Account) record;
            sumRevenue += (Double) acc.AnnualRevenue;
            if (acc.AnnualRevenue > maxRevenue) {
                maxRevenue = acc.AnnualRevenue;
            }
        }
        result.put('MaxRevenue', maxRevenue);
        result.put('SumRevenue', sumRevenue);
        result.put('AvgRevenue', sumRevenue / records.size());
        return result;
    }
}
```

Apply the rollup as shown below. The result is a list of `Q.Aggregate` objects, which provide convenient access to the summary data.

```java
List<Account> accounts = [SELECT Name, Industry, AnnualRevenue FROM Account];
Q.Filter filter = new AccountFilter();
Q.Rollup rollup = new AccountRollup();

List<Q.Aggregate> results = (List<Q.Aggregate>) Q.of(accounts)
    .filter(filter).rollup(rollup).toList();

Integer INDUSTRY_INDEX = 0;
for (Q.Aggregate aggregate : results) {
    String industry = (String) aggregate.getKeyAt(INDUSTRY_INDEX);
    Double maxRevenue = (Double) aggregate.getValue('MaxRevenue');
    Double sumRevenue = (Double) aggregate.getValue('SumRevenue');
    Double avgRevenue = (Double) aggregate.getValue('AvgRevenue');
}
```

## 3. Result Operations

### 3.1 List

The `toList()` method returns different types of results depending on whether a rollup operation is used:

- If a rollup is applied, `toList()` returns a list of aggregated results. Each entry contains the group keys and their corresponding summary values.
- If no rollup is applied, `toList()` returns a list of the original records, which may be filtered or sorted as specified.

```java
// With rollup
List<Q.Aggregate> results = (List<Q.Aggregate>) Q.of(accounts).rollup(rollup).toList();

// Without rollup
List<Account> results = (List<Account>) Q.of(accounts).filter(filter).toList();
```

### 3.2 Map

To transform each record in a collection, implement the `Q.Mapper` interface.

```java
public class AccountMapper implements Q.Mapper {
    public Object convert(Object record) {
        Account acc = (Account) record;
        return acc.Name;
    }
}
```

Apply the mapper using `toList(Q.Mapper, Type)`, providing the target type as the second parameter. For example, to obtain a list of account names:

```java
Q.Filter filter = new AccountFilter();
Q.Mapper mapper = new AccountMapper();
List<String> results = (List<String>) Q.of(accounts)
    .filter(filter).toList(mapper, String.class);
```

### 3.3 Reduce

To accumulate results, implement the `Q.Reducer` interface.

```java
public class AccountReducer implements Q.Reducer {
    public Object reduce(Object state, Object record) {
        Double currentSum = (Double) state;
        Account acc = (Account) record;
        return currentSum + (Double) acc.AnnualRevenue;
    }
}
```

Apply the reducer as shown below. For example, to calculate the total annual revenue of filtered accounts:

```java
List<Account> accounts = [SELECT Name, Industry, AnnualRevenue FROM Account];
Q.Filter filter = new AccountFilter();
Q.Reducer reducer = new AccountReducer();
Double result = (Double) Q.of(accounts).filter(filter).reduce(reducer, 0.0);
```

### 3.4 Diff

The diff operation is mainly used to compare the `Trigger.new` and `Trigger.old` lists to identify records that have changed. Diff compares two lists of the same size, matching records by their position in the list.

```java
public class AccountDiffer implements Q.Differ {
    public Boolean changed(Object fromRecord, Object toRecord) {
        Account fromAcc = (Account) fromRecord;
        Account toAcc = (Account) toRecord;
        return (Double) fromAcc.AnnualRevenue != (Double) toAcc.AnnualRevenue;
    }
}
```

Apply the differ as shown below. You can compare `Trigger.new` with `Trigger.old` or vice versa, depending on which set of changed records you want to retrieve.

```java
Q.Differ differ = new AccountDiffer();
List<Account> newList = (List<Account>) Q.of(Trigger.new).toDiff(differ, Trigger.old);
List<Account> oldList = (List<Account>) Q.of(Trigger.old).toDiff(differ, Trigger.new);
```

## 4. License

Apache 2.0
