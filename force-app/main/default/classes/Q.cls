/**
 * Copyright 2025 Jeff Jin
 * https://github.com/apexfarm/ApexDI
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

public virtual class Q implements IQ {
    private interface IQ {
        List<Object> toList();
        List<Object> toList(Mapper mapper, Type mapToType);
        Groups groups(ByKeys byKeys);
        Object reduce(Reducer reducer, Object initialState);

        Q diff(Differ differ, List<Object> toRecords);
        Q filter(Filter filter);
        Q sortBy(Sorter sorter);
        Q rollup(Rollup rollup);
        Q take(Integer count);
        Q skip(Integer count);
        Q tail(Integer count);
        Q slice(Integer startIndex, Integer endIndex);
    }

    public interface Reducer {
        Object reduce(Object state, Object record);
    }

    public interface Mapper {
        Object convert(Object record);
    }

    public interface Joiner {
        Boolean canJoin(Object record, Object innerRecord);
    }

    public interface Filter {
        Boolean matches(Object record);
    }

    public interface Sorter extends Comparator<Object> {
        Integer compare(Object arg1, Object arg2);
    }

    public interface ByKeys {
        List<Object> getKeys(Object record);
    }

    public interface Rollup extends ByKeys {
        Map<String, Object> summary(List<Object> keys, List<Object> records);
    }

    public interface Differ {
        Boolean changed(Object arg1, Object arg2);
    }

    public interface Aggregate extends GroupInfo {
        Map<String, Object> getSummary();
        Object getValue(String fieldName);
    }

    public interface GroupInfo {
        List<Object> getKeys();
        Object getKeyAt(Integer position);
        List<Object> getRecords();
    }

    public interface Groups extends Iterable<GroupInfo> {
        Integer size();
        Boolean isEmpty();

        Set<List<Object>> keySet();
        List<Object> getRecords(List<Object> keys);
        Boolean containsKey(List<Object> keys);
    }

    // ======================
    // #region Static Factory

    private static Collection COLLECTION = new Collection();

    public static Q of(List<SObject> records) {
        Q q = new Q();
        q.init(records, SObject.class);
        return q;
    }

    public static Q of(List<Object> records, Type listItemType) {
        Q q = new Q();
        q.init(records, listItemType);
        return q;
    }

    // #endregion
    // ======================

    // =================
    // #region Transform

    private List<Object> records { get; set; }
    private Type listItemType { get; set; }

    private void init(List<Object> records, Type ListItemType) {
        this.listItemType = ListItemType;
        this.records = new List<Object>(records);
    }

    public Q filter(Filter filter) {
        if (filter != null) {
            List<Object> filteredRecords = new List<Object>();
            for (Object record : this.records) {
                if (filter.matches(record)) {
                    filteredRecords.add(record);
                }
            }
            this.records = filteredRecords;
        }
        return this;
    }

    public Q sortBy(Sorter sorter) {
        if (sorter != null) {
            records.sort(sorter);
        }
        return this;
    }

    public Q rollup(Rollup rollup) {
        if (rollup != null) {
            Map<List<Object>, List<Object>> groups = new Map<List<Object>, List<Object>>();
            for (Object record : this.records) {
                List<Object> keys = rollup.getKeys(record);
                List<Object> records = groups.get(keys);
                if (records == null) {
                    groups.put(keys, new List<Object>{ record });
                } else {
                    records.add(record);
                }
            }

            List<Aggregate> rolledUpRecords = new List<Aggregate>();
            for (List<Object> keys : groups.keySet()) {
                List<Object> records = groups.get(keys);
                Map<String, Object> summary = rollup.summary(keys, records);
                rolledUpRecords.add(new AggregateImpl(records, keys, summary));
            }
            this.listItemType = Aggregate.class;
            this.records = rolledUpRecords;
        }
        return this;
    }

    public Q skip(Integer count) {
        if (count != null && count > 0) {
            List<Object> result = new List<Object>();
            for (Integer i = count; i < records.size(); i++) {
                result.add(records[i]);
            }
            records = result;
        }
        return this;
    }

    public Q take(Integer count) {
        List<Object> result = new List<Object>();
        if (count != null && count > 0) {
            Integer upper = Math.min(count, records.size());
            for (Integer i = 0; i < upper; i++) {
                result.add(records[i]);
            }
        }
        records = result;
        return this;
    }

    public Q tail(Integer count) {
        List<Object> result = new List<Object>();
        if (count != null && count > 0) {
            Integer upper = records.size();
            for (Integer i = Math.max(0, records.size() - count); i < upper; i++) {
                result.add(records[i]);
            }
        }
        records = result;
        return this;
    }

    public Q slice(Integer startIndex, Integer endIndex) {
        Integer size = records.size();
        Integer fromIndex = (startIndex == null || startIndex < 0) ? 0 : startIndex;
        Integer toIndex = (endIndex == null || endIndex > size) ? size : endIndex;
        List<Object> result = new List<Object>();
        if (fromIndex < toIndex) {
            for (Integer i = fromIndex; i < toIndex; i++) {
                result.add(records[i]);
            }
        }
        records = result;
        return this;
    }

    public Q diff(Differ differ, List<Object> toRecords) {
        List<Object> diffRecords = new List<Object>();
        if (differ == null || toRecords == null) {
            this.records = diffRecords;
            return this;
        }

        Integer minSize = Math.min(this.records.size(), toRecords.size());
        for (Integer i = 0; i < minSize; i++) {
            Object arg1 = this.records[i];
            Object arg2 = toRecords[i];
            if (differ.changed(arg1, arg2)) {
                diffRecords.add(arg1);
            }
        }

        this.records = diffRecords;
        return this;
    }

    // #endregion
    // =================

    // =================
    // #region Resulting

    public Groups groups(ByKeys byKeys) {
        Map<List<Object>, List<Object>> groups = new Map<List<Object>, List<Object>>();
        for (Object record : this.records) {
            List<Object> keys = byKeys.getKeys(record);
            List<Object> records = groups.get(keys);
            if (records == null) {
                groups.put(keys, new List<Object>{ record });
            } else {
                records.add(record);
            }
        }
        return new GroupsImpl(groups);
    }

    public List<Object> toList() {
        List<Object> records = COLLECTION.newList(this.listItemType);
        records.addAll(this.records);
        return records;
    }

    public List<Object> toList(Mapper mapper, Type mapToType) {
        List<Object> records = COLLECTION.newList(mapToType);

        for (Object record : this.records) {
            records.add(mapper.convert(record));
        }

        return records;
    }

    public Object reduce(Reducer reducer, Object initialState) {
        Object state = initialState;
        for (Object record : this.records) {
            state = reducer.reduce(state, record);
        }
        return state;
    }

    // #endregion
    // =================

    // ==========================
    // #region Supproting Classes

    private class GroupsImpl implements Groups {
        private Map<List<Object>, List<Object>> groups { get; set; }

        private GroupsImpl(Map<List<Object>, List<Object>> groups) {
            this.groups = groups;
        }

        public Integer size() {
            return groups.size();
        }

        public Boolean isEmpty() {
            return groups.isEmpty();
        }

        public Set<List<Object>> keySet() {
            return groups.keySet();
        }

        public Boolean containsKey(List<Object> keys) {
            return groups.containsKey(keys);
        }

        public List<Object> getRecords(List<Object> keys) {
            return groups.get(keys);
        }

        public Iterator<GroupInfo> iterator() {
            return new GroupsIterator(this.groups);
        }
    }

    private class GroupsIterator implements Iterator<GroupInfo> {
        private Iterator<List<Object>> keyIterator { get; set; }
        private Map<List<Object>, List<Object>> groups { get; set; }

        private GroupsIterator(Map<List<Object>, List<Object>> groups) {
            this.groups = groups;
            this.keyIterator = groups.keySet().iterator();
        }

        public Boolean hasNext() {
            return keyIterator.hasNext();
        }

        public GroupInfo next() {
            List<Object> keys = keyIterator.next();
            return new GroupInfoImpl(keys, groups.get(keys));
        }
    }

    private virtual class GroupInfoImpl implements GroupInfo {
        protected List<Object> keys { get; set; }
        protected List<Object> records { get; set; }

        private GroupInfoImpl(List<Object> keys, List<Object> records) {
            this.keys = keys;
            this.records = records;
        }

        public List<Object> getKeys() {
            return keys;
        }

        public Object getKeyAt(Integer position) {
            return keys[position];
        }

        public List<Object> getRecords() {
            return records;
        }
    }

    private class AggregateImpl extends GroupInfoImpl implements Aggregate {
        private Map<String, Object> summary { get; set; }

        private AggregateImpl(List<Object> records, List<Object> keys, Map<String, Object> summary) {
            super(keys, records);
            this.summary = summary;
        }

        public Map<String, Object> getSummary() {
            return summary;
        }

        public Object getValue(String fieldName) {
            return summary.get(fieldName);
        }
    }

    @TestVisible
    private class Collection {
        private Map<Type, List<Object>> listCache = new Map<Type, List<Object>>();

        public List<Object> newList(Type listItemType) {
            List<Object> defaultList = listCache.get(listItemType);
            if (defaultList == null) {
                String listTypeName = 'List<' + listItemType.getName() + '>';
                Type listType = Type.forName(listTypeName);
                defaultList = (List<Object>) listType.newInstance();
                listCache.put(listItemType, defaultList);
            }
            return defaultList.clone();
        }
    }

    // #endregion
    // =================
}
