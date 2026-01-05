import '../errors.dart';

class AggregationFunctions {
  static num sum(dynamic array) {
    if (array == null) return 0;

    final list = _toList(array);
    if (list.isEmpty) return 0;

    num total = 0;
    for (final item in list) {
      if (item is num) {
        total += item;
      } else if (item != null) {
        throw EvaluatorException('Cannot sum non-numeric value: $item');
      }
    }

    return total;
  }

  static int count(dynamic array) {
    if (array == null) return 0;
    final list = _toList(array);
    return list.length;
  }

  static num? max(dynamic array) {
    if (array == null) return null;

    final list = _toList(array);
    if (list.isEmpty) return null;

    num? maxVal;
    for (final item in list) {
      if (item is num) {
        if (maxVal == null || item > maxVal) {
          maxVal = item;
        }
      } else if (item != null) {
        throw EvaluatorException('Cannot find max of non-numeric value: $item');
      }
    }

    return maxVal;
  }

  static num? min(dynamic array) {
    if (array == null) return null;

    final list = _toList(array);
    if (list.isEmpty) return null;

    num? minVal;
    for (final item in list) {
      if (item is num) {
        if (minVal == null || item < minVal) {
          minVal = item;
        }
      } else if (item != null) {
        throw EvaluatorException('Cannot find min of non-numeric value: $item');
      }
    }

    return minVal;
  }

  static num? average(dynamic array) {
    if (array == null) return null;

    final list = _toList(array);
    if (list.isEmpty) return null;

    final total = sum(list);
    return total / list.length;
  }

  static List<dynamic> _toList(dynamic value) {
    if (value is List) return value;
    return [value];
  }
}
