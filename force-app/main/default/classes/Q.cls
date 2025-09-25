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

    public interface Differ {
        Boolean changed(Object arg1, Object arg2);
    }

    public interface Joiner {
        Boolean canJoin(Object record, Object innerRecord);
    }

    public interface Filter {
        Boolean matches(Object record);
    }

    public interface Sorter {
        Integer compare(Object arg1, Object arg2);
    }

    public interface Rollup {
        List<Object> getKeys(Object record);
        Map<String, Object> summary(List<Object> mapKeys, List<Object> records);
    }

    public interface Aggregate {
        List<Object> getKeys();
        Map<String, Object> getSummary();
        Object getKeyAt(Integer position);
        Object getValue(String fieldName);
    }

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
            records.sort(new SObjectComparator(sorter));
        }
        return this;
    }

    public Q rollup(Rollup rollup) {
        if (rollup != null) {
            Map<List<Object>, List<Object>> groups = new Map<List<Object>, List<Object>>();
            for (Object record : this.records) {
                List<Object> keys = rollup.getKeys(record);
                if (!groups.containsKey(keys)) {
                    groups.put(keys, new List<Object>());
                }
                groups.get(keys).add(record);
            }
            List<Aggregate> rolledUpRecords = new List<Aggregate>();
            for (List<Object> key : groups.keySet()) {
                Map<String, Object> summary = rollup.summary(key, groups.get(key));
                rolledUpRecords.add(new AggregateImpl(key, summary));
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

    private List<Object> newList(Type listItemType) {
        String listTypeName = 'List<' + listItemType.getName() + '>';
        System.debug('listTypeName: ' + listTypeName);
        Type listType = Type.forName(listTypeName);
        return (List<Object>) listType.newInstance();
    }

    public List<Object> toList() {
        List<Object> records = newList(this.listItemType);
        records.addAll(this.records);
        return records;
    }

    public List<Object> toList(Mapper mapper, Type mapToType) {
        List<Object> records = newList(mapToType);

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

    private class AggregateImpl implements Aggregate {
        private List<Object> keys { get; set; }
        private Map<String, Object> summary { get; set; }

        private AggregateImpl(List<Object> keys, Map<String, Object> summary) {
            this.keys = keys;
            this.summary = summary;
        }

        public List<Object> getKeys() {
            return keys;
        }

        public Map<String, Object> getSummary() {
            return summary;
        }

        public Object getKeyAt(Integer position) {
            return keys[position];
        }

        public Object getValue(String fieldName) {
            return summary.get(fieldName);
        }
    }

    @TestVisible
    private class SObjectComparator implements Comparator<Object> {
        private Sorter sorter { get; set; }

        @TestVisible
        private SObjectComparator(Sorter sorter) {
            this.sorter = sorter;
        }

        public Integer compare(Object arg1, Object arg2) {
            return sorter.compare(arg1, arg2);
        }
    }

    // #endregion
    // =================
}
