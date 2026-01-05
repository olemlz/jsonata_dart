import 'package:test/test.dart';
import 'package:jsonata_dart/src/lexer.dart';
import 'package:jsonata_dart/src/parser.dart';
import 'package:jsonata_dart/src/ast/node.dart';
import 'package:jsonata_dart/src/ast/path_node.dart';
import 'package:jsonata_dart/src/ast/operator_node.dart';
import 'package:jsonata_dart/src/ast/function_node.dart';

void main() {
  group('Parser', () {
    test('parses literals', () {
      expect(_parse('42'), isA<LiteralNode>());
      expect(_parse('"hello"'), isA<LiteralNode>());
      expect(_parse('true'), isA<LiteralNode>());
      expect(_parse('null'), isA<LiteralNode>());
    });

    test('parses simple path', () {
      final ast = _parse('Address.City');
      expect(ast, isA<PathNode>());
      final path = ast as PathNode;
      expect(path.steps.length, 2);
      expect(path.steps[0], isA<PropertyStep>());
      expect(path.steps[1], isA<PropertyStep>());
    });

    test('parses array index', () {
      final ast = _parse('items[0]');
      expect(ast, isA<PathNode>());
      final path = ast as PathNode;
      expect(path.steps.length, 2);
      expect(path.steps[1], isA<IndexStep>());
    });

    test('parses array wildcard', () {
      final ast = _parse('items[*]');
      expect(ast, isA<PathNode>());
      final path = ast as PathNode;
      expect(path.steps.length, 2);
      expect(path.steps[1], isA<WildcardStep>());
    });

    test('parses array slice', () {
      final ast = _parse('items[2:5]');
      expect(ast, isA<PathNode>());
      final path = ast as PathNode;
      expect(path.steps.length, 2);
      expect(path.steps[1], isA<SliceStep>());
    });

    test('parses wildcard in array', () {
      final ast = _parse('items[*]');
      expect(ast, isA<PathNode>());
      final path = ast as PathNode;
      expect(path.steps.length, 2);
      expect(path.steps[1], isA<WildcardStep>());
    });

    test('parses descendant', () {
      final ast = _parse('**.price');
      expect(ast, isA<PathNode>());
      final path = ast as PathNode;
      expect(path.steps.length, 1);
      expect(path.steps[0], isA<DescendantStep>());
    });

    test('parses binary operations', () {
      expect(_parse('1 + 2'), isA<BinaryOpNode>());
      expect(_parse('a = b'), isA<BinaryOpNode>());
      expect(_parse('x < 10'), isA<BinaryOpNode>());
    });

    test('parses unary operations', () {
      // Note: -5 is lexed as a number token directly, not as unary operation
      // This is consistent with JSON and most parsers
      expect(_parse('not x'), isA<UnaryOpNode>());
      expect(_parse('- x'), isA<UnaryOpNode>());
    });

    test('parses function calls', () {
      final ast = _parse(r'$sum(items)');
      expect(ast, isA<FunctionNode>());
      final func = ast as FunctionNode;
      expect(func.name, r'$sum');
      expect(func.arguments.length, 1);
    });

    test('parses array literals', () {
      final ast = _parse('[1, 2, 3]');
      expect(ast, isA<ArrayNode>());
      final array = ast as ArrayNode;
      expect(array.elements.length, 3);
    });

    test('parses object literals', () {
      final ast = _parse('{"name": "John", "age": 30}');
      expect(ast, isA<ObjectNode>());
      final obj = ast as ObjectNode;
      expect(obj.properties.length, 2);
      expect(obj.properties.containsKey('name'), true);
      expect(obj.properties.containsKey('age'), true);
    });

    test('parses predicate', () {
      final ast = _parse('items[price > 10]');
      expect(ast, isA<PathNode>());
      final path = ast as PathNode;
      expect(path.steps.length, 2);
      expect(path.steps[1], isA<PredicateStep>());
    });

    test('respects operator precedence', () {
      final ast = _parse('1 + 2 * 3');
      expect(ast, isA<BinaryOpNode>());
      final op = ast as BinaryOpNode;
      expect(op.operator, '+');
      expect(op.left, isA<LiteralNode>());
      expect(op.right, isA<BinaryOpNode>());
    });

    test('handles parentheses', () {
      final ast = _parse('(1 + 2) * 3');
      expect(ast, isA<BinaryOpNode>());
      final op = ast as BinaryOpNode;
      expect(op.operator, '*');
      expect(op.left, isA<BinaryOpNode>());
      expect(op.right, isA<LiteralNode>());
    });
  });
}

ASTNode _parse(String expression) {
  final lexer = Lexer(expression);
  final tokens = lexer.tokenize();
  final parser = Parser(tokens);
  return parser.parse();
}
