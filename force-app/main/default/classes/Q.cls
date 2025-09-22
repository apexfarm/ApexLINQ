public virtual class Q {
    public interface Filter {
        Boolean matches(SObject record);
    }

    public interface LogicalFilter extends Filter {
        LogicalFilter add(Filter filter);
    }

    public class AndFilter implements LogicalFilter {
        private List<Filter> filters = new List<Filter>();

        public LogicalFilter add(Filter filter) {
            filters.add(filter);
            return this;
        }

        public Boolean matches(SObject record) {
            for (Filter filter : filters) {
                if (!filter.matches(record)) {
                    return false;
                }
            }
            return true;
        }
    }

    public static LogicalFilter andx() {
        return new AndFilter();
    }

    private interface DataType {
        void forField(String fieldName);
    }

    private List<SObject> records { get; set; }
    private Filter filter { get; set; }

    public Q() {
        this.records = new List<SObject>();
    }

    private Q(List<SObject> records) {
        this.records = records;
    }

    public static Q Q(List<SObject> records) {
        return new Q(records);
    }

    public Q whereBy(Filter filter) {
        this.filter = filter;
        return this;
    }

    public List<SObject> toList() {
        List<SObject> filteredRecords = new List<SObject>();
        for (SObject record : records) {
            if (filter.matches(record)) {
                filteredRecords.add(record);
            }
        }
        return filteredRecords;
    }

    // ==============
    // #region Double

    private static DoubleDataType doubleDataType {
        get {
            if (doubleDataType == null) {
                doubleDataType = new DoubleDataTypeImpl();
            }
            return doubleDataType;
        }
        set;
    }

    public static DoubleDataType forDouble(String fieldName) {
        DoubleDataType dt = doubleDataType;
        dt.forField(fieldName);
        return dt;
    }

    public interface DoubleDataType extends DataType {
        Filter gt(Double value);
        Filter gte(Double value);
        Filter lt(Double value);
        Filter lte(Double value);
        Filter eq(Double value);
        Filter ne(Double value);
        Filter inx(List<Double> values);
        Filter nin(List<Double> values);
        Filter between(Double startValue, Double endValue);
    }

    private class DoubleGreaterThanFilter implements Filter {
        private String fieldName;
        private Double value;

        public DoubleGreaterThanFilter(String fieldName, Double value) {
            this.fieldName = fieldName;
            this.value = value;
        }

        public Boolean matches(SObject record) {
            return (Double) record.get(fieldName) > value;
        }
    }

    private class DoubleLessThanFilter implements Filter {
        private String fieldName;
        private Double value;

        public DoubleLessThanFilter(String fieldName, Double value) {
            this.fieldName = fieldName;
            this.value = value;
        }

        public Boolean matches(SObject record) {
            return (Double) record.get(fieldName) < value;
        }
    }

    private class DoubleEqualToFilter implements Filter {
        private String fieldName;
        private Double value;

        public DoubleEqualToFilter(String fieldName, Double value) {
            this.fieldName = fieldName;
            this.value = value;
        }

        public Boolean matches(SObject record) {
            return ((Double) record.get(fieldName)) == value;
        }
    }

    private class DoubleGreaterThanOrEqualToFilter implements Filter {
        private String fieldName;
        private Double value;

        public DoubleGreaterThanOrEqualToFilter(String fieldName, Double value) {
            this.fieldName = fieldName;
            this.value = value;
        }

        public Boolean matches(SObject record) {
            return (Double) record.get(fieldName) >= value;
        }
    }

    private class DoubleLessThanOrEqualToFilter implements Filter {
        private String fieldName;
        private Double value;

        public DoubleLessThanOrEqualToFilter(String fieldName, Double value) {
            this.fieldName = fieldName;
            this.value = value;
        }

        public Boolean matches(SObject record) {
            return (Double) record.get(fieldName) <= value;
        }
    }

    private class DoubleNotEqualToFilter implements Filter {
        private String fieldName;
        private Double value;

        public DoubleNotEqualToFilter(String fieldName, Double value) {
            this.fieldName = fieldName;
            this.value = value;
        }

        public Boolean matches(SObject record) {
            return ((Double) record.get(fieldName)) != value;
        }
    }

    private class DoubleInFilter implements Filter {
        private String fieldName;
        private List<Double> values;

        public DoubleInFilter(String fieldName, List<Double> values) {
            this.fieldName = fieldName;
            this.values = values;
        }

        public Boolean matches(SObject record) {
            return values.contains((Double) record.get(fieldName));
        }
    }

    private class DoubleNotInFilter implements Filter {
        private String fieldName;
        private List<Double> values;

        public DoubleNotInFilter(String fieldName, List<Double> values) {
            this.fieldName = fieldName;
            this.values = values;
        }

        public Boolean matches(SObject record) {
            return !values.contains((Double) record.get(fieldName));
        }
    }

    private class DoubleBetweenFilter implements Filter {
        private String fieldName;
        private Double startValue;
        private Double endValue;

        public DoubleBetweenFilter(String fieldName, Double startValue, Double endValue) {
            this.fieldName = fieldName;
            this.startValue = startValue;
            this.endValue = endValue;
        }

        public Boolean matches(SObject record) {
            Double value = (Double) record.get(fieldName);
            return value >= startValue && value <= endValue;
        }
    }

    private class DoubleDataTypeImpl implements DoubleDataType {
        private String fieldName;

        public void forField(String fieldName) {
            this.fieldName = fieldName;
        }

        public Filter gt(Double value) {
            return new DoubleGreaterThanFilter(fieldName, value);
        }

        public Filter gte(Double value) {
            return new DoubleGreaterThanOrEqualToFilter(fieldName, value);
        }

        public Filter lt(Double value) {
            return new DoubleLessThanFilter(fieldName, value);
        }

        public Filter lte(Double value) {
            return new DoubleLessThanOrEqualToFilter(fieldName, value);
        }

        public Filter eq(Double value) {
            return new DoubleEqualToFilter(fieldName, value);
        }

        public Filter ne(Double value) {
            return new DoubleNotEqualToFilter(fieldName, value);
        }

        public Filter inx(List<Double> values) {
            return new DoubleInFilter(fieldName, values);
        }

        public Filter nin(List<Double> values) {
            return new DoubleNotInFilter(fieldName, values);
        }

        public Filter between(Double startValue, Double endValue) {
            return new DoubleBetweenFilter(fieldName, startValue, endValue);
        }
    }

    // ==============
    // #region Integer

    private static IntegerDataType integerDataType {
        get {
            if (integerDataType == null) {
                integerDataType = new IntegerDataTypeImpl();
            }
            return integerDataType;
        }
        set;
    }

    public static IntegerDataType forInteger(String fieldName) {
        IntegerDataType dt = integerDataType;
        dt.forField(fieldName);
        return dt;
    }

    public interface IntegerDataType extends DataType {
        Filter gt(Integer value);
        Filter gte(Integer value);
        Filter lt(Integer value);
        Filter lte(Integer value);
        Filter eq(Integer value);
        Filter ne(Integer value);
        Filter inx(List<Integer> values);
        Filter nin(List<Integer> values);
        Filter between(Integer startValue, Integer endValue);
    }

    private class IntegerGreaterThanFilter implements Filter {
        private String fieldName;
        private Integer value;

        public IntegerGreaterThanFilter(String fieldName, Integer value) {
            this.fieldName = fieldName;
            this.value = value;
        }

        public Boolean matches(SObject record) {
            return (Integer) record.get(fieldName) > value;
        }
    }

    private class IntegerLessThanFilter implements Filter {
        private String fieldName;
        private Integer value;

        public IntegerLessThanFilter(String fieldName, Integer value) {
            this.fieldName = fieldName;
            this.value = value;
        }

        public Boolean matches(SObject record) {
            return (Integer) record.get(fieldName) < value;
        }
    }

    private class IntegerEqualToFilter implements Filter {
        private String fieldName;
        private Integer value;

        public IntegerEqualToFilter(String fieldName, Integer value) {
            this.fieldName = fieldName;
            this.value = value;
        }

        public Boolean matches(SObject record) {
            return ((Integer) record.get(fieldName)) == value;
        }
    }

    private class IntegerGreaterThanOrEqualToFilter implements Filter {
        private String fieldName;
        private Integer value;

        public IntegerGreaterThanOrEqualToFilter(String fieldName, Integer value) {
            this.fieldName = fieldName;
            this.value = value;
        }

        public Boolean matches(SObject record) {
            return (Integer) record.get(fieldName) >= value;
        }
    }

    private class IntegerLessThanOrEqualToFilter implements Filter {
        private String fieldName;
        private Integer value;

        public IntegerLessThanOrEqualToFilter(String fieldName, Integer value) {
            this.fieldName = fieldName;
            this.value = value;
        }

        public Boolean matches(SObject record) {
            return (Integer) record.get(fieldName) <= value;
        }
    }

    private class IntegerNotEqualToFilter implements Filter {
        private String fieldName;
        private Integer value;

        public IntegerNotEqualToFilter(String fieldName, Integer value) {
            this.fieldName = fieldName;
            this.value = value;
        }

        public Boolean matches(SObject record) {
            return ((Integer) record.get(fieldName)) != value;
        }
    }

    private class IntegerInFilter implements Filter {
        private String fieldName;
        private List<Integer> values;

        public IntegerInFilter(String fieldName, List<Integer> values) {
            this.fieldName = fieldName;
            this.values = values;
        }

        public Boolean matches(SObject record) {
            return values.contains((Integer) record.get(fieldName));
        }
    }

    private class IntegerNotInFilter implements Filter {
        private String fieldName;
        private List<Integer> values;

        public IntegerNotInFilter(String fieldName, List<Integer> values) {
            this.fieldName = fieldName;
            this.values = values;
        }

        public Boolean matches(SObject record) {
            return !values.contains((Integer) record.get(fieldName));
        }
    }

    private class IntegerBetweenFilter implements Filter {
        private String fieldName;
        private Integer startValue;
        private Integer endValue;

        public IntegerBetweenFilter(String fieldName, Integer startValue, Integer endValue) {
            this.fieldName = fieldName;
            this.startValue = startValue;
            this.endValue = endValue;
        }

        public Boolean matches(SObject record) {
            Integer value = (Integer) record.get(fieldName);
            return value >= startValue && value <= endValue;
        }
    }

    private class IntegerDataTypeImpl implements IntegerDataType {
        private String fieldName;

        public void forField(String fieldName) {
            this.fieldName = fieldName;
        }

        public Filter gt(Integer value) {
            return new IntegerGreaterThanFilter(fieldName, value);
        }

        public Filter gte(Integer value) {
            return new IntegerGreaterThanOrEqualToFilter(fieldName, value);
        }

        public Filter lt(Integer value) {
            return new IntegerLessThanFilter(fieldName, value);
        }

        public Filter lte(Integer value) {
            return new IntegerLessThanOrEqualToFilter(fieldName, value);
        }

        public Filter eq(Integer value) {
            return new IntegerEqualToFilter(fieldName, value);
        }

        public Filter ne(Integer value) {
            return new IntegerNotEqualToFilter(fieldName, value);
        }

        public Filter inx(List<Integer> values) {
            return new IntegerInFilter(fieldName, values);
        }

        public Filter nin(List<Integer> values) {
            return new IntegerNotInFilter(fieldName, values);
        }

        public Filter between(Integer startValue, Integer endValue) {
            return new IntegerBetweenFilter(fieldName, startValue, endValue);
        }
    }

    // #endregion
    // ==============

    // ==============
    // #region String

    private static StringDataType stringDataType {
        get {
            if (stringDataType == null) {
                stringDataType = new StringDataTypeImpl();
            }
            return stringDataType;
        }
        set;
    }

    public static StringDataType forString(String fieldName) {
        StringDataType dt = stringDataType;
        dt.forField(fieldName);
        return dt;
    }

    public interface StringDataType extends DataType {
        Filter eq(String value);
        Filter ne(String value);
        Filter contains(String value);
        Filter startsWith(String value);
        Filter endsWith(String value);
        Filter inx(List<String> values);
        Filter nin(List<String> values);
        // Rarely used, but available:
        Filter gt(String value);
        Filter gte(String value);
        Filter lt(String value);
        Filter lte(String value);
    }

    private class StringEqualToFilter implements Filter {
        private String fieldName;
        private String value;

        public StringEqualToFilter(String fieldName, String value) {
            this.fieldName = fieldName;
            this.value = value;
        }

        public Boolean matches(SObject record) {
            return ((String) record.get(fieldName)) == value;
        }
    }

    private class StringNotEqualToFilter implements Filter {
        private String fieldName;
        private String value;

        public StringNotEqualToFilter(String fieldName, String value) {
            this.fieldName = fieldName;
            this.value = value;
        }

        public Boolean matches(SObject record) {
            return ((String) record.get(fieldName)) != value;
        }
    }

    private class StringContainsFilter implements Filter {
        private String fieldName;
        private String value;

        public StringContainsFilter(String fieldName, String value) {
            this.fieldName = fieldName;
            this.value = value;
        }

        public Boolean matches(SObject record) {
            String fieldValue = (String) record.get(fieldName);
            return fieldValue != null && fieldValue.contains(value);
        }
    }

    private class StringStartsWithFilter implements Filter {
        private String fieldName;
        private String value;

        public StringStartsWithFilter(String fieldName, String value) {
            this.fieldName = fieldName;
            this.value = value;
        }

        public Boolean matches(SObject record) {
            String fieldValue = (String) record.get(fieldName);
            return fieldValue != null && fieldValue.startsWith(value);
        }
    }

    private class StringEndsWithFilter implements Filter {
        private String fieldName;
        private String value;

        public StringEndsWithFilter(String fieldName, String value) {
            this.fieldName = fieldName;
            this.value = value;
        }

        public Boolean matches(SObject record) {
            String fieldValue = (String) record.get(fieldName);
            return fieldValue != null && fieldValue.endsWith(value);
        }
    }

    private class StringInFilter implements Filter {
        private String fieldName;
        private List<String> values;

        public StringInFilter(String fieldName, List<String> values) {
            this.fieldName = fieldName;
            this.values = values;
        }

        public Boolean matches(SObject record) {
            return values.contains((String) record.get(fieldName));
        }
    }

    private class StringNotInFilter implements Filter {
        private String fieldName;
        private List<String> values;

        public StringNotInFilter(String fieldName, List<String> values) {
            this.fieldName = fieldName;
            this.values = values;
        }

        public Boolean matches(SObject record) {
            return !values.contains((String) record.get(fieldName));
        }
    }

    // Lexicographical comparison filters
    private class StringGreaterThanFilter implements Filter {
        private String fieldName;
        private String value;

        public StringGreaterThanFilter(String fieldName, String value) {
            this.fieldName = fieldName;
            this.value = value;
        }

        public Boolean matches(SObject record) {
            String fieldValue = (String) record.get(fieldName);
            return fieldValue != null && fieldValue > value;
        }
    }

    private class StringGreaterThanOrEqualToFilter implements Filter {
        private String fieldName;
        private String value;

        public StringGreaterThanOrEqualToFilter(String fieldName, String value) {
            this.fieldName = fieldName;
            this.value = value;
        }

        public Boolean matches(SObject record) {
            String fieldValue = (String) record.get(fieldName);
            return fieldValue != null && fieldValue >= value;
        }
    }

    private class StringLessThanFilter implements Filter {
        private String fieldName;
        private String value;

        public StringLessThanFilter(String fieldName, String value) {
            this.fieldName = fieldName;
            this.value = value;
        }

        public Boolean matches(SObject record) {
            String fieldValue = (String) record.get(fieldName);
            return fieldValue != null && fieldValue < value;
        }
    }

    private class StringLessThanOrEqualToFilter implements Filter {
        private String fieldName;
        private String value;

        public StringLessThanOrEqualToFilter(String fieldName, String value) {
            this.fieldName = fieldName;
            this.value = value;
        }

        public Boolean matches(SObject record) {
            String fieldValue = (String) record.get(fieldName);
            return fieldValue != null && fieldValue <= value;
        }
    }

    private class StringDataTypeImpl implements StringDataType {
        private String fieldName;

        public void forField(String fieldName) {
            this.fieldName = fieldName;
        }

        public Filter eq(String value) {
            return new StringEqualToFilter(fieldName, value);
        }

        public Filter ne(String value) {
            return new StringNotEqualToFilter(fieldName, value);
        }

        public Filter contains(String value) {
            return new StringContainsFilter(fieldName, value);
        }

        public Filter startsWith(String value) {
            return new StringStartsWithFilter(fieldName, value);
        }

        public Filter endsWith(String value) {
            return new StringEndsWithFilter(fieldName, value);
        }

        public Filter inx(List<String> values) {
            return new StringInFilter(fieldName, values);
        }

        public Filter nin(List<String> values) {
            return new StringNotInFilter(fieldName, values);
        }

        public Filter gt(String value) {
            return new StringGreaterThanFilter(fieldName, value);
        }

        public Filter gte(String value) {
            return new StringGreaterThanOrEqualToFilter(fieldName, value);
        }

        public Filter lt(String value) {
            return new StringLessThanFilter(fieldName, value);
        }

        public Filter lte(String value) {
            return new StringLessThanOrEqualToFilter(fieldName, value);
        }
    }

    // #endregion
    // ==============
}
