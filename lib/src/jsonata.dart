import 'ast/node.dart';
import 'errors.dart';
import 'evaluator.dart';
import 'lexer.dart';
import 'parser.dart';

/// Main JSONata class for parsing and evaluating JSONata expressions
class Jsonata {
  final String expression;
  late final ASTNode _ast;
  final Evaluator _evaluator = Evaluator();

  /// Creates a new JSONata expression from a string
  ///
  /// Throws [JsonataException] if the expression is invalid
  Jsonata(this.expression) {
    try {
      final lexer = Lexer(expression);
      final tokens = lexer.tokenize();
      final parser = Parser(tokens);
      _ast = parser.parse();
    } catch (e) {
      if (e is JsonataException) {
        rethrow;
      }
      throw JsonataException('Failed to parse expression: $e');
    }
  }

  /// Evaluates the JSONata expression against the provided data
  ///
  /// Returns the result of the evaluation, which can be any JSON-compatible type
  /// Throws [EvaluatorException] if evaluation fails
  dynamic evaluate(dynamic data) {
    try {
      return _evaluator.evaluate(_ast, data);
    } catch (e) {
      if (e is JsonataException) {
        rethrow;
      }
      throw EvaluatorException('Failed to evaluate expression: $e');
    }
  }

  /// Registers a custom function that can be called from JSONata expressions
  ///
  /// The function name should start with $ (if not provided, it will be added automatically)
  ///
  /// Example:
  /// ```dart
  /// final expr = Jsonata('$double(price)');
  /// expr.registerFunction('double', (args) => (args[0] as num) * 2);
  /// final result = expr.evaluate({'price': 10}); // Returns 20
  /// ```
  void registerFunction(String name, Function impl) {
    _evaluator.registerFunction(name, (args) => impl(args));
  }

  @override
  String toString() => 'Jsonata($expression)';
}
