import '../errors.dart';

class StringFunctions {
  static String? substring(dynamic str, dynamic start, [dynamic? length]) {
    if (str == null) return null;

    final string = str.toString();
    final startIndex = _toInt(start);

    if (startIndex < 0 || startIndex >= string.length) {
      return '';
    }

    if (length == null) {
      return string.substring(startIndex);
    }

    final len = _toInt(length);
    final endIndex = (startIndex + len).clamp(0, string.length);

    return string.substring(startIndex, endIndex);
  }

  static String? uppercase(dynamic str) {
    if (str == null) return null;
    return str.toString().toUpperCase();
  }

  static String? lowercase(dynamic str) {
    if (str == null) return null;
    return str.toString().toLowerCase();
  }

  static bool contains(dynamic str, dynamic pattern) {
    if (str == null || pattern == null) return false;
    return str.toString().contains(pattern.toString());
  }

  static String? trim(dynamic str) {
    if (str == null) return null;
    return str.toString().trim();
  }

  static int? length(dynamic str) {
    if (str == null) return null;
    return str.toString().length;
  }

  static List<String> split(dynamic str, dynamic separator, [int? limit]) {
    if (str == null) return [];

    final string = str.toString();
    final sep = separator?.toString() ?? '';

    if (sep.isEmpty) {
      return string.split('');
    }

    if (limit != null) {
      final parts = <String>[];
      var remaining = string;

      for (var i = 0; i < limit - 1; i++) {
        final index = remaining.indexOf(sep);
        if (index == -1) {
          parts.add(remaining);
          return parts;
        }
        parts.add(remaining.substring(0, index));
        remaining = remaining.substring(index + sep.length);
      }

      parts.add(remaining);
      return parts;
    }

    return string.split(sep);
  }

  static String? replace(dynamic str, dynamic pattern, dynamic replacement, [int? limit]) {
    if (str == null) return null;

    final string = str.toString();
    final pat = pattern?.toString() ?? '';
    final repl = replacement?.toString() ?? '';

    if (pat.isEmpty) return string;

    if (limit != null && limit > 0) {
      var result = string;
      for (var i = 0; i < limit; i++) {
        if (!result.contains(pat)) break;
        result = result.replaceFirst(pat, repl);
      }
      return result;
    }

    return string.replaceAll(pat, repl);
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    throw EvaluatorException('Cannot convert $value to int');
  }
}
