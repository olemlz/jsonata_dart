import 'ast/node.dart';
import 'ast/path_node.dart';
import 'ast/operator_node.dart';
import 'ast/function_node.dart';
import 'errors.dart';
import 'lexer.dart';

// Internal node used during parsing to distinguish identifiers from strings
class _IdentifierNode extends ASTNode {
  final String name;
  const _IdentifierNode(this.name);
}

class Parser {
  final List<Token> tokens;
  int _current = 0;

  Parser(this.tokens);

  ASTNode parse() {
    if (_isAtEnd()) {
      throw ParserException('Empty expression');
    }
    return _expression();
  }

  ASTNode _expression() {
    return _logicalOr();
  }

  ASTNode _logicalOr() {
    ASTNode left = _logicalAnd();

    while (_match(TokenType.or)) {
      final right = _logicalAnd();
      left = BinaryOpNode('or', left, right);
    }

    return left;
  }

  ASTNode _logicalAnd() {
    ASTNode left = _equality();

    while (_match(TokenType.and)) {
      final right = _equality();
      left = BinaryOpNode('and', left, right);
    }

    return left;
  }

  ASTNode _equality() {
    ASTNode left = _comparison();

    while (_matchAny([TokenType.equal, TokenType.notEqual])) {
      final operator = _previous().value.toString();
      final right = _comparison();
      left = BinaryOpNode(operator, left, right);
    }

    return left;
  }

  ASTNode _comparison() {
    ASTNode left = _stringConcat();

    while (_matchAny([
      TokenType.lessThan,
      TokenType.lessOrEqual,
      TokenType.greaterThan,
      TokenType.greaterOrEqual,
    ])) {
      final operator = _previous().value.toString();
      final right = _stringConcat();
      left = BinaryOpNode(operator, left, right);
    }

    return left;
  }

  ASTNode _stringConcat() {
    ASTNode left = _addition();

    while (_match(TokenType.ampersand)) {
      final right = _addition();
      left = BinaryOpNode('&', left, right);
    }

    return left;
  }

  ASTNode _addition() {
    ASTNode left = _multiplication();

    while (_matchAny([TokenType.plus, TokenType.minus])) {
      final operator = _previous().value.toString();
      final right = _multiplication();
      left = BinaryOpNode(operator, left, right);
    }

    return left;
  }

  ASTNode _multiplication() {
    ASTNode left = _unary();

    while (_matchAny([TokenType.multiply, TokenType.divide, TokenType.modulo])) {
      final operator = _previous().value.toString();
      final right = _unary();
      left = BinaryOpNode(operator, left, right);
    }

    return left;
  }

  ASTNode _unary() {
    if (_match(TokenType.not)) {
      final operand = _unary();
      return UnaryOpNode('not', operand);
    }

    if (_match(TokenType.minus)) {
      final operand = _unary();
      return UnaryOpNode('-', operand);
    }

    return _path();
  }

  ASTNode _path() {
    if (_match(TokenType.variable)) {
      return _variable();
    }

    ASTNode node = _primary();

    // Check for path steps
    final steps = <PathStep>[];
    var hasPathSteps = false;

    while (true) {
      if (_match(TokenType.dot)) {
        hasPathSteps = true;
        if (_match(TokenType.dot)) {
          // Range operator (..)
          throw ParserException('Range operator not yet supported');
        } else if (_match(TokenType.multiply)) {
          // Wildcard after dot: .*
          steps.add(const WildcardStep());
        } else if (_match(TokenType.identifier)) {
          steps.add(PropertyStep(_previous().value.toString()));
        } else {
          throw ParserException('Expected property name after dot');
        }
      } else if (_match(TokenType.descendant)) {
        hasPathSteps = true;
        if (_match(TokenType.identifier)) {
          steps.add(DescendantStep(_previous().value.toString()));
        } else {
          steps.add(const DescendantStep());
        }
      } else if (_match(TokenType.leftBracket)) {
        hasPathSteps = true;
        steps.add(_arrayAccess());
      } else {
        break;
      }
    }

    // If we have path steps and the node is an identifier, convert to path
    if (hasPathSteps) {
      if (node is _IdentifierNode) {
        // Identifier with path steps
        return PathNode([PropertyStep(node.name), ...steps]);
      } else if (node is PathNode) {
        // Already a path (e.g., from ** or *), append steps
        return PathNode([...node.steps, ...steps]);
      } else if (node is LiteralNode && node.value is String) {
        // This shouldn't happen for normal strings from primary
        return PathNode([PropertyStep(node.value.toString()), ...steps]);
      } else {
        throw ParserException('Cannot apply path steps to ${node.runtimeType}');
      }
    }

    // If it's an identifier without steps, treat it as a path
    if (node is _IdentifierNode) {
      return PathNode([PropertyStep(node.name)]);
    }

    return node;
  }

  bool _isIdentifier(String value) {
    // Check if the string looks like an identifier
    if (value.isEmpty) return false;
    final firstChar = value[0];
    return (firstChar.contains(RegExp(r'[a-zA-Z_]')));
  }

  PathStep _arrayAccess() {
    if (_match(TokenType.multiply)) {
      // Wildcard in array brackets: [*]
      _consume(TokenType.rightBracket, 'Expected ] after *');
      return const WildcardStep();
    }

    if (_check(TokenType.number)) {
      final start = _advance().value as num;

      if (_match(TokenType.colon)) {
        // Slice
        final end = _check(TokenType.number) ? (_advance().value as num).toInt() : null;
        _consume(TokenType.rightBracket, 'Expected ] after slice');
        return SliceStep(start.toInt(), end);
      } else {
        // Index
        _consume(TokenType.rightBracket, 'Expected ] after index');
        return IndexStep(start.toInt());
      }
    }

    // Predicate
    final condition = _expression();
    _consume(TokenType.rightBracket, 'Expected ] after predicate');
    return PredicateStep(condition);
  }

  ASTNode _variable() {
    final name = _previous().value.toString();

    if (_match(TokenType.leftParen)) {
      // Function call - add $ prefix to name
      final args = <ASTNode>[];

      if (!_check(TokenType.rightParen)) {
        do {
          args.add(_expression());
        } while (_match(TokenType.comma));
      }

      _consume(TokenType.rightParen, 'Expected ) after function arguments');
      return FunctionNode('\$$name', args);
    }

    return VariableNode('\$$name');
  }

  ASTNode _primary() {
    if (_match(TokenType.number)) {
      return LiteralNode(_previous().value);
    }

    if (_match(TokenType.string)) {
      return LiteralNode(_previous().value);
    }

    if (_match(TokenType.boolean)) {
      return LiteralNode(_previous().value);
    }

    if (_match(TokenType.nil)) {
      return const LiteralNode(null);
    }

    if (_match(TokenType.leftParen)) {
      final expr = _expression();
      _consume(TokenType.rightParen, 'Expected ) after expression');
      return expr;
    }

    if (_match(TokenType.leftBracket)) {
      return _arrayLiteral();
    }

    if (_match(TokenType.leftBrace)) {
      return _objectLiteral();
    }

    if (_match(TokenType.identifier)) {
      final name = _previous().value.toString();

      // Check if this is a function call without $ prefix
      if (_match(TokenType.leftParen)) {
        final args = <ASTNode>[];

        if (!_check(TokenType.rightParen)) {
          do {
            args.add(_expression());
          } while (_match(TokenType.comma));
        }

        _consume(TokenType.rightParen, 'Expected ) after function arguments');
        return FunctionNode('\$$name', args);
      }

      // Otherwise, it's a property reference - return as internal identifier node
      // This will be converted to a path in the _path() method
      return _IdentifierNode(name);
    }

    if (_match(TokenType.descendant)) {
      // Recursive descent operator at start of expression
      // Check if followed by .property or just **
      if (_match(TokenType.dot)) {
        if (_match(TokenType.identifier)) {
          return PathNode([DescendantStep(_previous().value.toString())]);
        } else {
          throw ParserException('Expected property name after **.');
        }
      } else if (_match(TokenType.identifier)) {
        return PathNode([DescendantStep(_previous().value.toString())]);
      } else {
        return PathNode(const [DescendantStep()]);
      }
    }

    throw ParserException('Unexpected token: ${_peek().type}', position: _peek().position);
  }

  ASTNode _arrayLiteral() {
    final elements = <ASTNode>[];

    if (!_check(TokenType.rightBracket)) {
      do {
        elements.add(_expression());
      } while (_match(TokenType.comma));
    }

    _consume(TokenType.rightBracket, 'Expected ] after array elements');
    return ArrayNode(elements);
  }

  ASTNode _objectLiteral() {
    final properties = <String, ASTNode>{};

    if (!_check(TokenType.rightBrace)) {
      do {
        String key;

        if (_match(TokenType.string)) {
          key = _previous().value.toString();
        } else if (_match(TokenType.identifier)) {
          key = _previous().value.toString();
        } else {
          throw ParserException('Expected property name');
        }

        _consume(TokenType.colon, 'Expected : after property name');
        final value = _expression();
        properties[key] = value;
      } while (_match(TokenType.comma));
    }

    _consume(TokenType.rightBrace, 'Expected } after object properties');
    return ObjectNode(properties);
  }

  bool _match(TokenType type) {
    if (_check(type)) {
      _advance();
      return true;
    }
    return false;
  }

  bool _matchAny(List<TokenType> types) {
    for (final type in types) {
      if (_check(type)) {
        _advance();
        return true;
      }
    }
    return false;
  }

  bool _check(TokenType type) {
    if (_isAtEnd()) return false;
    return _peek().type == type;
  }

  Token _advance() {
    if (!_isAtEnd()) _current++;
    return _previous();
  }

  Token _peek() {
    return tokens[_current];
  }

  Token _previous() {
    return tokens[_current - 1];
  }

  bool _isAtEnd() {
    return _peek().type == TokenType.eof;
  }

  void _consume(TokenType type, String message) {
    if (_check(type)) {
      _advance();
      return;
    }

    throw ParserException(message, position: _peek().position);
  }
}
