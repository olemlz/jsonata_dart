import 'ast/node.dart';
import 'ast/path_node.dart';
import 'ast/operator_node.dart';
import 'ast/function_node.dart';
import 'errors.dart';
import 'functions/aggregation.dart';
import 'functions/string.dart';
import 'functions/array.dart';

typedef JsonataFunction = dynamic Function(List<dynamic> args);

class Evaluator {
  final Map<String, JsonataFunction> _functions = {};
  final Map<String, dynamic> _variables = {};

  Evaluator() {
    _registerBuiltInFunctions();
  }

  void _registerBuiltInFunctions() {
    // Aggregation functions
    _functions['\$sum'] = (args) => AggregationFunctions.sum(args.isNotEmpty ? args[0] : null);
    _functions['\$count'] = (args) => AggregationFunctions.count(args.isNotEmpty ? args[0] : null);
    _functions['\$max'] = (args) => AggregationFunctions.max(args.isNotEmpty ? args[0] : null);
    _functions['\$min'] = (args) => AggregationFunctions.min(args.isNotEmpty ? args[0] : null);
    _functions['\$average'] = (args) => AggregationFunctions.average(args.isNotEmpty ? args[0] : null);

    // String functions
    _functions['\$substring'] = (args) {
      if (args.isEmpty) return null;
      if (args.length == 1) return StringFunctions.substring(args[0], 0);
      if (args.length == 2) return StringFunctions.substring(args[0], args[1]);
      return StringFunctions.substring(args[0], args[1], args[2]);
    };
    _functions['\$uppercase'] = (args) => StringFunctions.uppercase(args.isNotEmpty ? args[0] : null);
    _functions['\$lowercase'] = (args) => StringFunctions.lowercase(args.isNotEmpty ? args[0] : null);
    _functions['\$contains'] = (args) {
      if (args.length < 2) return false;
      return StringFunctions.contains(args[0], args[1]);
    };
    _functions['\$trim'] = (args) => StringFunctions.trim(args.isNotEmpty ? args[0] : null);
    _functions['\$length'] = (args) => StringFunctions.length(args.isNotEmpty ? args[0] : null);
    _functions['\$split'] = (args) {
      if (args.isEmpty) return [];
      if (args.length == 1) return StringFunctions.split(args[0], '');
      if (args.length == 2) return StringFunctions.split(args[0], args[1]);
      return StringFunctions.split(args[0], args[1], args[2] as int?);
    };
    _functions['\$replace'] = (args) {
      if (args.length < 3) throw EvaluatorException('replace requires 3 arguments');
      if (args.length == 3) return StringFunctions.replace(args[0], args[1], args[2]);
      return StringFunctions.replace(args[0], args[1], args[2], args[3] as int?);
    };

    // Array functions
    _functions['\$join'] = (args) {
      if (args.isEmpty) return '';
      if (args.length == 1) return ArrayFunctions.join(args[0]);
      return ArrayFunctions.join(args[0], args[1]?.toString() ?? '');
    };
    _functions['\$append'] = (args) {
      if (args.length < 2) throw EvaluatorException('append requires 2 arguments');
      return ArrayFunctions.append(args[0], args[1]);
    };
    _functions['\$exists'] = (args) => ArrayFunctions.exists(args.isNotEmpty ? args[0] : null);
    _functions['\$sort'] = (args) => ArrayFunctions.sort(args.isNotEmpty ? args[0] : null);
    _functions['\$reverse'] = (args) => ArrayFunctions.reverse(args.isNotEmpty ? args[0] : null);
    _functions['\$distinct'] = (args) => ArrayFunctions.distinct(args.isNotEmpty ? args[0] : null);
    _functions['\$flatten'] = (args) {
      if (args.isEmpty) return [];
      if (args.length == 1) return ArrayFunctions.flatten(args[0]);
      return ArrayFunctions.flatten(args[0], (args[1] as num).toInt());
    };

    // Map and filter need special handling due to lambda support
    _functions['\$map'] = (args) {
      if (args.length < 2) throw EvaluatorException('map requires 2 arguments');
      if (args[1] is! Function) throw EvaluatorException('map second argument must be a function');
      return ArrayFunctions.map(args[0], args[1] as Function);
    };
    _functions['\$filter'] = (args) {
      if (args.length < 2) throw EvaluatorException('filter requires 2 arguments');
      if (args[1] is! Function) throw EvaluatorException('filter second argument must be a function');
      return ArrayFunctions.filter(args[0], args[1] as Function);
    };
    _functions['\$reduce'] = (args) {
      if (args.length < 2) throw EvaluatorException('reduce requires 2 arguments');
      if (args[1] is! Function) throw EvaluatorException('reduce second argument must be a function');
      if (args.length == 2) return ArrayFunctions.reduce(args[0], args[1] as Function);
      return ArrayFunctions.reduce(args[0], args[1] as Function, args[2]);
    };
  }

  void registerFunction(String name, JsonataFunction function) {
    if (!name.startsWith('\$')) {
      name = '\$$name';
    }
    _functions[name] = function;
  }

  dynamic evaluate(ASTNode node, dynamic context) {
    if (node is LiteralNode) {
      return node.value;
    }

    if (node is ArrayNode) {
      return node.elements.map((e) => evaluate(e, context)).toList();
    }

    if (node is ObjectNode) {
      final result = <String, dynamic>{};
      for (final entry in node.properties.entries) {
        result[entry.key] = evaluate(entry.value, context);
      }
      return result;
    }

    if (node is PathNode) {
      return _evaluatePath(node, context);
    }

    if (node is VariableNode) {
      return _variables[node.name];
    }

    if (node is BinaryOpNode) {
      return _evaluateBinaryOp(node, context);
    }

    if (node is UnaryOpNode) {
      return _evaluateUnaryOp(node, context);
    }

    if (node is FunctionNode) {
      return _evaluateFunction(node, context);
    }

    throw EvaluatorException('Unknown node type: ${node.runtimeType}');
  }

  dynamic _evaluatePath(PathNode node, dynamic context) {
    var current = context;

    for (final step in node.steps) {
      if (current == null) return null;

      if (step is PropertyStep) {
        current = _getProperty(current, step.name);
      } else if (step is WildcardStep) {
        current = _getWildcard(current);
      } else if (step is DescendantStep) {
        current = _getDescendant(current, step.property);
      } else if (step is IndexStep) {
        current = _getIndex(current, step.index);
      } else if (step is SliceStep) {
        current = _getSlice(current, step.start, step.end);
      } else if (step is PredicateStep) {
        current = _getPredicate(current, step.condition);
      } else {
        throw EvaluatorException('Unknown path step: ${step.runtimeType}');
      }
    }

    return current;
  }

  dynamic _getProperty(dynamic obj, String name) {
    if (obj == null) return null;

    if (obj is Map) {
      return obj[name];
    }

    if (obj is List) {
      return obj.map((item) => _getProperty(item, name)).where((e) => e != null).toList();
    }

    return null;
  }

  dynamic _getWildcard(dynamic obj) {
    if (obj == null) return null;

    if (obj is Map) {
      return obj.values.toList();
    }

    if (obj is List) {
      return obj;
    }

    return [obj];
  }

  dynamic _getDescendant(dynamic obj, String? property) {
    final results = <dynamic>[];

    void collect(dynamic current) {
      if (current == null) return;

      if (property != null) {
        if (current is Map && current.containsKey(property)) {
          results.add(current[property]);
        }

        if (current is Map) {
          for (final value in current.values) {
            collect(value);
          }
        } else if (current is List) {
          for (final item in current) {
            collect(item);
          }
        }
      } else {
        results.add(current);

        if (current is Map) {
          for (final value in current.values) {
            collect(value);
          }
        } else if (current is List) {
          for (final item in current) {
            collect(item);
          }
        }
      }
    }

    collect(obj);
    return results.isEmpty ? null : results;
  }

  dynamic _getIndex(dynamic obj, int index) {
    if (obj == null) return null;

    if (obj is List) {
      if (index < 0) {
        index = obj.length + index;
      }
      if (index >= 0 && index < obj.length) {
        return obj[index];
      }
      return null;
    }

    return null;
  }

  dynamic _getSlice(dynamic obj, int? start, int? end) {
    if (obj == null) return null;

    if (obj is List) {
      final actualStart = start ?? 0;
      final actualEnd = end ?? obj.length;
      return obj.sublist(
        actualStart.clamp(0, obj.length),
        actualEnd.clamp(0, obj.length),
      );
    }

    return null;
  }

  dynamic _getPredicate(dynamic obj, ASTNode condition) {
    if (obj == null) return null;

    if (obj is List) {
      final results = <dynamic>[];
      for (final item in obj) {
        final result = evaluate(condition, item);
        if (_isTruthy(result)) {
          results.add(item);
        }
      }
      return results.isEmpty ? null : results;
    }

    final result = evaluate(condition, obj);
    return _isTruthy(result) ? obj : null;
  }

  dynamic _evaluateBinaryOp(BinaryOpNode node, dynamic context) {
    final left = evaluate(node.left, context);
    final right = evaluate(node.right, context);

    switch (node.operator) {
      case '+':
        return (left as num) + (right as num);
      case '-':
        return (left as num) - (right as num);
      case '*':
        return (left as num) * (right as num);
      case '/':
        return (left as num) / (right as num);
      case '%':
        return (left as num) % (right as num);
      case '&':
        return '${left ?? ''}${right ?? ''}';
      case '=':
        return _compareEqual(left, right);
      case '!=':
        return !_compareEqual(left, right);
      case '<':
        return (left as num) < (right as num);
      case '<=':
        return (left as num) <= (right as num);
      case '>':
        return (left as num) > (right as num);
      case '>=':
        return (left as num) >= (right as num);
      case 'and':
        return _isTruthy(left) && _isTruthy(right);
      case 'or':
        return _isTruthy(left) || _isTruthy(right);
      default:
        throw EvaluatorException('Unknown operator: ${node.operator}');
    }
  }

  dynamic _evaluateUnaryOp(UnaryOpNode node, dynamic context) {
    final operand = evaluate(node.operand, context);

    switch (node.operator) {
      case '-':
        return -(operand as num);
      case 'not':
        return !_isTruthy(operand);
      default:
        throw EvaluatorException('Unknown unary operator: ${node.operator}');
    }
  }

  dynamic _evaluateFunction(FunctionNode node, dynamic context) {
    final function = _functions[node.name];
    if (function == null) {
      throw EvaluatorException('Unknown function: ${node.name}');
    }

    final args = node.arguments.map((arg) => evaluate(arg, context)).toList();
    return function(args);
  }

  bool _isTruthy(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.isNotEmpty;
    if (value is List) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    return true;
  }

  bool _compareEqual(dynamic left, dynamic right) {
    // If either is null, use simple equality
    if (left == null || right == null) {
      return left == right;
    }

    // If left is an array and right is not
    if (left is List && right is! List) {
      // Check if any element in left equals right
      return left.any((item) => _compareEqual(item, right));
    }

    // If right is an array and left is not
    if (right is List && left is! List) {
      // Check if any element in right equals left
      return right.any((item) => _compareEqual(left, item));
    }

    // If both are arrays
    if (left is List && right is List) {
      // Check if any element from left equals any element from right
      for (final leftItem in left) {
        for (final rightItem in right) {
          if (_compareEqual(leftItem, rightItem)) {
            return true;
          }
        }
      }
      return false;
    }

    // For non-array values, use standard equality
    return left == right;
  }
}
