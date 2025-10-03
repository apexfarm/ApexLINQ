/**
 * Copyright 2025 Jeff Jin
 * https://github.com/apexfarm/ApexLINQ
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

@isTest
public class QTest {
    // ==================
    // #region Of Methods

    @isTest
    static void testQ_of_null() {
        Assert.areEqual(0, Q.of(null).toList().size());
        Assert.areEqual(0, Q.of(null, Model.class).toList().size());
    }

    @isTest
    static void testQ_of_sobjects() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accounts.add(new Account(Name = 'Account ' + i, AnnualRevenue = 5000 - i));
        }
        List<Account> results = (List<Account>) Q.of(accounts).toList();
        Assert.areEqual(10, results.size());
    }

    @isTest
    static void testQ_of_objects() {
        List<Model> models = new List<Model>();
        for (Integer i = 0; i < 10; i++) {
            models.add(new Model());
        }

        List<Model> results = (List<Model>) Q.of(models, Model.class).toList();

        Assert.areEqual(10, results.size());
    }

    public class Model {
        public String Name { get; set; }
        public String Industry { get; set; }
        public Double AnnualRevenue { get; set; }

        public Model() {
        }

        public Model(String Name, Double AnnualRevenue) {
            this.Name = Name;
            this.AnnualRevenue = AnnualRevenue;
        }

        public Model(String Name, String Industry, Double AnnualRevenue) {
            this.Name = Name;
            this.Industry = Industry;
            this.AnnualRevenue = AnnualRevenue;
        }
    }

    // #endregion
    // ==================

    // ==============
    // #region Filter

    @isTest
    static void testQ_filter_positive() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accounts.add(new Account(Name = 'Account ' + i, AnnualRevenue = 5000 - i));
        }

        Q.Filter filter = new AccountFilter();
        List<Account> results = (List<Account>) Q.of(accounts).filter(filter).toList();

        Assert.areEqual(10, results.size());
    }

    @isTest
    static void testQ_filter_negative() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accounts.add(new Account(Name = 'Account ' + i, AnnualRevenue = i - 5000));
        }

        Q.Filter filter = new AccountFilter();
        List<Account> results = (List<Account>) Q.of(accounts).filter(filter).toList();

        Assert.areEqual(0, results.size());
    }

    public class AccountFilter implements Q.Filter {
        public Boolean matches(Object record) {
            Account acc = (Account) record;
            return acc.Name.startsWith('Account') && (Double) acc.AnnualRevenue > 0;
        }
    }

    @isTest
    static void testQ_filter_model() {
        List<Model> accounts = new List<Model>();
        for (Integer i = 0; i < 10; i++) {
            accounts.add(new Model('Account ' + i, 5000 - i));
        }

        Q.Filter filter = new ModelFilter();
        List<Model> results = (List<Model>) Q.of(accounts, Model.class).filter(filter).toList();

        Assert.areEqual(10, results.size());
    }

    public class ModelFilter implements Q.Filter {
        public Boolean matches(Object record) {
            Model mod = (Model) record;
            return mod.Name.startsWith('Account') && (Double) mod.AnnualRevenue > 0;
        }
    }

    // #endregion
    // ==============

    // ==============
    // #region Sorter

    @isTest
    static void testQ_sorter() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 5000; i++) {
            accounts.add(new Account(Name = 'Account ' + i, AnnualRevenue = 5000 - i));
        }

        Q.Sorter sorter = new AccountSorter();
        List<Account> results = (List<Account>) Q.of(accounts).sortBy(sorter).toList();

        Assert.areEqual(5000, results.size());
        Assert.areEqual(1, results[0].AnnualRevenue);
        Assert.areEqual(5000, results[4999].AnnualRevenue);
    }

    public class AccountSorter implements Q.Sorter {
        public Integer compare(Object arg1, Object arg2) {
            Double arg1Revenue = ((Account) arg1).AnnualRevenue;
            Double arg2Revenue = ((Account) arg2).AnnualRevenue;

            // Treat nulls as less than any number
            if (arg1Revenue == null && arg2Revenue == null) {
                return 0;
            } else if (arg1Revenue == null) {
                return -1;
            } else if (arg2Revenue == null) {
                return 1;
            }

            if (arg1Revenue < arg2Revenue) {
                return -1;
            } else if (arg1Revenue > arg2Revenue) {
                return 1;
            } else {
                return 0;
            }
        }
    }

    // #endregion
    // ==============

    // ===============
    // #region Slicing
    @isTest
    static void testQ_slicing() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 20; i++) {
            accounts.add(new Account(Name = 'Account ' + i, AnnualRevenue = 10000 + i));
        }

        List<Account> results = (List<Account>) Q.of(accounts).skip(5).take(4).tail(3).slice(0, 2).toList();

        System.debug(results);

        Assert.areEqual(2, results.size());
        Assert.areEqual(10006, results[0].AnnualRevenue);
        Assert.areEqual(10007, results[1].AnnualRevenue);
    }

    @isTest
    static void testQ_slicing_skip() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 20; i++) {
            accounts.add(new Account(Name = 'Account ' + i, AnnualRevenue = 10000 + i));
        }

        List<Account> results;

        results = (List<Account>) Q.of(accounts).skip(5).toList();
        Assert.areEqual(15, results.size());
        Assert.areEqual(10005, results[0].AnnualRevenue);
        Assert.areEqual(10019, results[14].AnnualRevenue);

        results = (List<Account>) Q.of(accounts).skip(25).toList();
        Assert.areEqual(0, results.size());

        results = (List<Account>) Q.of(accounts).skip(0).toList();
        Assert.areEqual(20, results.size());

        results = (List<Account>) Q.of(accounts).skip(-5).toList();
        Assert.areEqual(20, results.size());
    }

    @isTest
    static void testQ_slicing_take() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 20; i++) {
            accounts.add(new Account(Name = 'Account ' + i, AnnualRevenue = 10000 + i));
        }

        List<Account> results;

        results = (List<Account>) Q.of(accounts).take(5).toList();
        Assert.areEqual(5, results.size());
        Assert.areEqual(10000, results[0].AnnualRevenue);
        Assert.areEqual(10004, results[4].AnnualRevenue);

        results = (List<Account>) Q.of(accounts).take(25).toList();
        Assert.areEqual(20, results.size());
        Assert.areEqual(10000, results[0].AnnualRevenue);
        Assert.areEqual(10019, results[19].AnnualRevenue);

        results = (List<Account>) Q.of(accounts).take(0).toList();
        Assert.areEqual(0, results.size());

        results = (List<Account>) Q.of(accounts).take(-5).toList();
        Assert.areEqual(0, results.size());
    }

    @isTest
    static void testQ_slicing_tail() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 20; i++) {
            accounts.add(new Account(Name = 'Account ' + i, AnnualRevenue = 10000 + i));
        }

        List<Account> results;

        results = (List<Account>) Q.of(accounts).tail(5).toList();
        Assert.areEqual(5, results.size());
        Assert.areEqual(10015, results[0].AnnualRevenue);
        Assert.areEqual(10019, results[4].AnnualRevenue);

        results = (List<Account>) Q.of(accounts).tail(25).toList();
        Assert.areEqual(20, results.size());
        Assert.areEqual(10000, results[0].AnnualRevenue);
        Assert.areEqual(10019, results[19].AnnualRevenue);

        results = (List<Account>) Q.of(accounts).tail(0).toList();
        Assert.areEqual(0, results.size());

        results = (List<Account>) Q.of(accounts).tail(-5).toList();
        Assert.areEqual(0, results.size());
    }

    @isTest
    static void testQ_slicing_slice() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 20; i++) {
            accounts.add(new Account(Name = 'Account ' + i, AnnualRevenue = 10000 + i));
        }

        List<Account> results;

        results = (List<Account>) Q.of(accounts).slice(0, 20).toList();
        Assert.areEqual(20, results.size());
        Assert.areEqual(10000, results[0].AnnualRevenue);
        Assert.areEqual(10019, results[19].AnnualRevenue);

        results = (List<Account>) Q.of(accounts).slice(5, 10).toList();
        Assert.areEqual(5, results.size());
        Assert.areEqual(10005, results[0].AnnualRevenue);
        Assert.areEqual(10009, results[4].AnnualRevenue);

        results = (List<Account>) Q.of(accounts).slice(-5, 10).toList();
        Assert.areEqual(10, results.size());
        Assert.areEqual(10000, results[0].AnnualRevenue);
        Assert.areEqual(10009, results[9].AnnualRevenue);

        results = (List<Account>) Q.of(accounts).slice(5, 25).toList();
        Assert.areEqual(15, results.size());
        Assert.areEqual(10005, results[0].AnnualRevenue);
        Assert.areEqual(10019, results[14].AnnualRevenue);

        results = (List<Account>) Q.of(accounts).slice(5, 5).toList();
        Assert.areEqual(0, results.size());

        results = (List<Account>) Q.of(accounts).slice(10, 5).toList();
        Assert.areEqual(0, results.size());
    }
    // #endregion
    // ===============

    // ==============
    // #region Rollup

    @isTest
    static void testQ_rollup() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accounts.add(
                new Account(
                    Name = 'Account ' + i,
                    AnnualRevenue = 10000 + i,
                    Industry = (Math.mod(i, 2) == 0) ? 'IT' : 'Finance'
                )
            );
        }

        Q.Filter filter = new AccountFilter();
        Q.Sorter sorter = new AccountSorter();
        Q.Rollup rollup = new AccountRollup();
        List<Q.Aggregate> results = (List<Q.Aggregate>) Q.of(accounts).filter(filter).rollup(rollup).toList();

        Assert.areEqual(2, results.size());

        Integer count = 0;
        Integer IndustryIndex = 0;
        for (Q.Aggregate aggregate : results) {
            // IT = 10000 + 10002 + 10004 + 10006 + 10008 = 50020
            // Finance = 10001 + 10003 + 10005 + 10007 + 10009 = 50025
            if (aggregate.getKeyAt(IndustryIndex) == 'IT') {
                Assert.areEqual(10008, aggregate.getValue('MaxRevenue'));
                Assert.areEqual(50020, aggregate.getValue('SumRevenue'));
                Assert.areEqual(10004, aggregate.getValue('AvgRevenue'));
            } else {
                Assert.areEqual(10009, aggregate.getValue('MaxRevenue'));
                Assert.areEqual(50025, aggregate.getValue('SumRevenue'));
                Assert.areEqual(10005, aggregate.getValue('AvgRevenue'));
            }
            Assert.areEqual(1, aggregate.getKeys().size());
            Assert.areEqual(3, aggregate.getSummary().size());
            Assert.areEqual(5, aggregate.getRecords().size());
            count++;
        }
        Assert.areEqual(2, count);
    }

    public class AccountRollup implements Q.Rollup {
        public List<Object> getKeys(Object record) {
            Account acc = (Account) record;
            return new List<Object>{ acc.Industry };
        }

        public Map<String, Object> summary(List<Object> keys, List<Object> records) {
            Map<String, Object> results = new Map<String, Object>();
            Double sumRevenue = 0;
            Double maxRevenue = 0;
            for (Object record : records) {
                Account acc = (Account) record;
                sumRevenue += (Double) acc.AnnualRevenue;
                if (acc.AnnualRevenue > maxRevenue) {
                    maxRevenue = acc.AnnualRevenue;
                }
            }
            results.put('MaxRevenue', maxRevenue);
            results.put('SumRevenue', sumRevenue);
            results.put('AvgRevenue', sumRevenue / records.size());
            return results;
        }
    }

    // #endregion
    // ==============

    // ==============
    // #region Differ

    @isTest
    static void testQ_differ_triggers() {
        Q.Differ differ = new AccountDiffer();
        Q.Filter filter = new AccountFilter();
        List<Account> results = (List<Account>) Q.of(Trigger.new).diff(differ, Trigger.old).filter(filter).toList();
        Assert.areEqual(0, results.size());
    }

    @isTest
    static void testQ_differ_exception() {
        List<Account> oldAccounts = new List<Account>();
        for (Integer i = 0; i < 1; i++) {
            oldAccounts.add(new Account(Name = 'Account ' + i, AnnualRevenue = 10000 + i));
        }

        List<Account> newAccounts = new List<Account>();
        for (Integer i = 0; i < 2; i++) {
            newAccounts.add(new Account(Name = 'Account ' + i, AnnualRevenue = 20000 + i));
        }

        Q.Differ differ = new AccountDiffer();
        Q.Filter filter = new AccountFilter();
        List<Account> results = (List<Account>) Q.of(oldAccounts).diff(differ, newAccounts).filter(filter).toList();
        Assert.areEqual(1, results.size());
        Assert.areEqual(10000, results[0].AnnualRevenue);
    }

    @isTest
    static void testQ_differ_positive() {
        List<Account> oldAccounts = new List<Account>();
        List<Account> newAccounts = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            oldAccounts.add(new Account(Name = 'Account ' + i, AnnualRevenue = 10000 + i));
            newAccounts.add(new Account(Name = 'Account ' + i, AnnualRevenue = 20000 + i));
        }

        Q.Differ differ = new AccountDiffer();
        Q.Filter filter = new AccountFilter();
        List<Account> results;
        results = (List<Account>) Q.of(newAccounts).diff(differ, oldAccounts).filter(filter).toList();

        Assert.areEqual(10, results.size());
        Assert.areEqual(20000, results[0].AnnualRevenue);

        results = (List<Account>) Q.of(oldAccounts).diff(differ, newAccounts).filter(filter).toList();

        Assert.areEqual(10, results.size());
        Assert.areEqual(10000, results[0].AnnualRevenue);
    }

    @isTest
    static void testQ_differ_negative() {
        List<Account> oldAccounts = new List<Account>();
        List<Account> newAccounts = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            oldAccounts.add(new Account(Name = 'Account ' + i, AnnualRevenue = 10000 + i));
            newAccounts.add(new Account(Name = 'Account ' + i, AnnualRevenue = 10000 + i));
        }

        Q.Differ differ = new AccountDiffer();
        Q.Filter filter = new AccountFilter();
        List<Account> results;
        results = (List<Account>) Q.of(newAccounts).diff(differ, oldAccounts).filter(filter).toList();
        Assert.areEqual(0, results.size());

        results = (List<Account>) Q.of(oldAccounts).diff(differ, newAccounts).filter(filter).toList();
        Assert.areEqual(0, results.size());
    }

    public class AccountDiffer implements Q.Differ {
        public Boolean changed(Object arg1, Object arg2) {
            Account fromAcc = (Account) arg1;
            Account toAcc = (Account) arg2;
            return (Double) fromAcc.AnnualRevenue != (Double) toAcc.AnnualRevenue;
        }
    }
    // #endregion
    // ==============

    // ==============
    // #region Mapper
    @isTest
    static void testQ_mapper() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accounts.add(new Account(Name = 'Account ' + i, AnnualRevenue = 10000 + i));
        }

        Q.Filter filter = new AccountFilter();
        Q.Sorter sorter = new AccountSorter();
        Q.Mapper mapper = new AccountMapper();
        List<Id> results = (List<Id>) Q.of(accounts).filter(filter).sortBy(sorter).toList(mapper, Id.class);

        Assert.areEqual(10, results.size());
    }

    public class AccountMapper implements Q.Mapper {
        public Object convert(Object record) {
            Account acc = (Account) record;
            return acc.Id;
        }
    }

    // #endregion
    // ==============

    // ===============
    // #region Reducer

    @isTest
    static void testQ_reducer() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accounts.add(new Account(Name = 'Account ' + i, AnnualRevenue = 1));
        }

        Q.Filter filter = new AccountFilter();
        Q.Reducer reducer = new AccountReducer();
        Double results = (Double) Q.of(accounts).filter(filter).reduce(reducer, 0.0);

        Assert.areEqual(10, results);
    }

    public class AccountReducer implements Q.Reducer {
        public Object reduce(Object state, Object record) {
            Account acc = (Account) record;
            return (Double) state + (Double) acc.AnnualRevenue;
        }
    }

    // #endregion
    // ===============

    // ==============
    // #region groups

    @isTest
    static void testQ_groups() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 5000; i++) {
            accounts.add(
                new Account(
                    Name = 'Account ' + i,
                    AnnualRevenue = 10000 + i,
                    Industry = (Math.mod(i, 2) == 0) ? 'IT' : 'Finance'
                )
            );
        }

        Integer startCPU = Limits.getCpuTime();

        Q.ByKeys byKeys = new AccountByKeys();
        Q.Groups groups = Q.of(accounts).groups(byKeys);

        Integer endCPU = Limits.getCpuTime();
        System.debug(LoggingLevel.INFO, 'Apex LINQ (CPU): ' + (endCPU - startCPU));

        Assert.areEqual(2, groups.keySet().size());
        Assert.areEqual(2, groups.size());
        Assert.isTrue(groups.containsKey(new List<Object>{ 'IT' }));
        Assert.isFalse(groups.isEmpty());

        List<Object> itAccounts = groups.getRecords(new List<Object>{ 'IT' });
        Assert.areEqual(2500, itAccounts.size());
        List<Object> financeAccounts = groups.getRecords(new List<Object>{ 'Finance' });
        Assert.areEqual(2500, financeAccounts.size());

        Integer count = 0;
        Integer INDUSTRY_INDEX = 0;
        for (Q.GroupInfo groupInfo : groups) {
            String industry = (String) groupInfo.getKeyAt(INDUSTRY_INDEX);
            List<Object> groupRecords = groupInfo.getRecords();
            Assert.areEqual(2500, groupRecords.size());
            count++;
        }
        Assert.areEqual(2, count);
    }

    public class AccountByKeys implements Q.ByKeys {
        public List<Object> getKeys(Object record) {
            Account acc = (Account) record;
            return new List<Object>{ acc.Industry };
        }
    }

    // #endregion
    // ===============

    // ===================
    // #region Performance

    // @isTest
    // static void testQ_performance_nativeLoop() {
    //     String listTypeName = 'List<Account>';
    //     Type listType = Type.forName(listTypeName);
    //     List<Object> accounts = (List<Object>) listType.newInstance();

    //     Integer startCPU = Limits.getCpuTime();
    //     for (Integer i = 0; i < 10000; i++) {
    //         List<Object> accounts2 = accounts.clone();
    //     }

    //     Integer endCPU = Limits.getCpuTime();
    //     System.debug(LoggingLevel.INFO, 'Native Apex (CPU): ' + (endCPU - startCPU));
    // }

    // @isTest
    // static void testQ_performance_nativeLoop2() {
    //     Q.Collection collection = new Q.Collection();

    //     Integer startCPU = Limits.getCpuTime();
    //     for (Integer i = 0; i < 10000; i++) {
    //         collection.newList(SObject.class);
    //     }

    //     Integer endCPU = Limits.getCpuTime();
    //     System.debug(LoggingLevel.INFO, 'Native Apex (CPU): ' + (endCPU - startCPU));
    // }

    // @isTest
    // static void testQ_performance_nativeFilter() {
    //     List<Account> accounts = new List<Account>();
    //     for (Integer i = 0; i < 5000; i++) {
    //         accounts.add(new Account(Name = 'Account ' + i, AnnualRevenue = 5000 - i));
    //     }

    //     Integer startCPU = Limits.getCpuTime();
    //     List<Account> results = new List<Account>();
    //     for (Account acc : accounts) {
    //         if (acc.Name.startsWith('Account') && (Double) acc.AnnualRevenue > 0) {
    //             results.add(acc);
    //         }
    //     }
    //     Integer endCPU = Limits.getCpuTime();
    //     System.debug(LoggingLevel.INFO, 'Native Apex (CPU): ' + (endCPU - startCPU));

    //     Assert.areEqual(5000, results.size());
    //     Assert.areEqual(5000, results[0].AnnualRevenue);
    //     Assert.areEqual(1, results[4999].AnnualRevenue);
    // }

    // @isTest
    // static void testQ_performance_filter() {
    //     List<Account> accounts = new List<Account>();
    //     for (Integer i = 0; i < 5000; i++) {
    //         accounts.add(new Account(Name = 'Account ' + i, AnnualRevenue = 5000 - i));
    //     }

    //     Integer startCPU = Limits.getCpuTime();
    //     Q.Filter filter = new AccountFilter();
    //     List<Account> results = (List<Account>) Q.of(accounts).filter(filter).toList();
    //     Integer endCPU = Limits.getCpuTime();
    //     System.debug(LoggingLevel.INFO, 'Apex LINQ (CPU): ' + (endCPU - startCPU));

    //     Assert.areEqual(5000, results.size());
    //     Assert.areEqual(5000, results[0].AnnualRevenue);
    //     Assert.areEqual(1, results[4999].AnnualRevenue);
    // }

    // @isTest
    // static void testQ_performance_rollup() {
    //     List<Account> accounts = new List<Account>();
    //     for (Integer i = 0; i < 5000; i++) {
    //         accounts.add(
    //             new Account(
    //                 Name = 'Account ' + i,
    //                 AnnualRevenue = 5000 + i,
    //                 Industry = (Math.mod(i, 2) == 0) ? 'IT' : 'Finance'
    //             )
    //         );
    //     }

    //     Integer startCPU = Limits.getCpuTime();
    //     Q.Rollup rollup = new PerformanceAccountRollup();
    //     List<Q.Aggregate> results = (List<Q.Aggregate>) Q.of(accounts).rollup(rollup).toList();

    //     Assert.areEqual(5000, results.size());

    //     Integer count = 0;
    //     Integer NAME_INDEX = 0;
    //     Integer INDUSTRY_INDEX = 1;
    //     for (Q.Aggregate aggregate : results) {
    //         String accountName = (String) aggregate.getKeyAt(NAME_INDEX);
    //         String industry = (String) aggregate.getKeyAt(INDUSTRY_INDEX);
    //         Double maxRevenue = (Double) aggregate.getValue('MaxRevenue');
    //         Double sumRevenue = (Double) aggregate.getValue('SumRevenue');
    //         Double avgRevenue = (Double) aggregate.getValue('AvgRevenue');
    //         count++;
    //     }
    //     Assert.areEqual(5000, count);
    //     Integer endCPU = Limits.getCpuTime();
    //     System.debug(LoggingLevel.INFO, 'Apex LINQ (CPU): ' + (endCPU - startCPU));
    // }

    // public class PerformanceAccountRollup implements Q.Rollup {
    //     public List<Object> getKeys(Object record) {
    //         Account acc = (Account) record;
    //         return new List<Object>{ acc.Name, acc.Industry, acc.AnnualRevenue };
    //     }

    //     public Map<String, Object> summary(List<Object> keys, List<Object> records) {
    //         Map<String, Object> results = new Map<String, Object>();
    //         Double sumRevenue = 0;
    //         Double maxRevenue = 0;
    //         for (Object record : records) {
    //             Account acc = (Account) record;
    //             sumRevenue += (Double) acc.AnnualRevenue;
    //             if (acc.AnnualRevenue > maxRevenue) {
    //                 maxRevenue = acc.AnnualRevenue;
    //             }
    //         }
    //         results.put('MaxRevenue', maxRevenue);
    //         results.put('SumRevenue', sumRevenue);
    //         results.put('AvgRevenue', sumRevenue / records.size());
    //         return results;
    //     }
    // }

    // #endregion
    // ===================
}
