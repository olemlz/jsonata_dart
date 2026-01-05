import '../errors.dart';

class ArrayFunctions {
  static List<dynamic> map(dynamic array, Function mapper) {
    if (array == null) return [];

    final list = _toList(array);
    final result = <dynamic>[];

    for (var i = 0; i < list.length; i++) {
      final item = list[i];
      final mapped = mapper(item, i);
      if (mapped != null) {
        result.add(mapped);
      }
    }

    return result;
  }

  static List<dynamic> filter(dynamic array, Function predicate) {
    if (array == null) return [];

    final list = _toList(array);
    final result = <dynamic>[];

    for (var i = 0; i < list.length; i++) {
      final item = list[i];
      final shouldInclude = predicate(item, i);
      if (shouldInclude == true) {
        result.add(item);
      }
    }

    return result;
  }

  static String join(dynamic array, [String separator = '']) {
    if (array == null) return '';

    final list = _toList(array);
    return list.map((e) => e?.toString() ?? '').join(separator);
  }

  static List<dynamic> append(dynamic array, dynamic value) {
    final list = _toList(array ?? []);
    return [...list, value];
  }

  static bool exists(dynamic value) {
    return value != null;
  }

  static List<dynamic> sort(dynamic array, [Function? comparator]) {
    if (array == null) return [];

    final list = List<dynamic>.from(_toList(array));

    if (comparator != null) {
      list.sort((a, b) {
        final result = comparator(a, b);
        if (result is num) return result.toInt();
        if (result is bool) return result ? 1 : -1;
        return 0;
      });
    } else {
      list.sort((a, b) {
        if (a == null && b == null) return 0;
        if (a == null) return -1;
        if (b == null) return 1;

        if (a is num && b is num) {
          return a.compareTo(b);
        }

        return a.toString().compareTo(b.toString());
      });
    }

    return list;
  }

  static List<dynamic> reverse(dynamic array) {
    if (array == null) return [];

    final list = _toList(array);
    return list.reversed.toList();
  }

  static List<dynamic> distinct(dynamic array) {
    if (array == null) return [];

    final list = _toList(array);
    final seen = <dynamic>{};
    final result = <dynamic>[];

    for (final item in list) {
      if (!seen.contains(item)) {
        seen.add(item);
        result.add(item);
      }
    }

    return result;
  }

  static dynamic reduce(dynamic array, Function reducer, [dynamic initial]) {
    if (array == null) return initial;

    final list = _toList(array);
    if (list.isEmpty) return initial;

    var accumulator = initial ?? list.first;
    final startIndex = initial == null ? 1 : 0;

    for (var i = startIndex; i < list.length; i++) {
      accumulator = reducer(accumulator, list[i], i);
    }

    return accumulator;
  }

  static List<dynamic> flatten(dynamic array, [int depth = 1]) {
    if (array == null) return [];

    final list = _toList(array);
    if (depth <= 0) return list;

    final result = <dynamic>[];

    for (final item in list) {
      if (item is List) {
        result.addAll(flatten(item, depth - 1));
      } else {
        result.add(item);
      }
    }

    return result;
  }

  static List<dynamic> _toList(dynamic value) {
    if (value is List) return value;
    return [value];
  }
}
