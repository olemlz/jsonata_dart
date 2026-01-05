import 'errors.dart';

enum TokenType {
  // Literals
  number,
  string,
  boolean,
  nil,

  // Identifiers and operators
  identifier,

  // Symbols
  dot, // .
  comma, // ,
  colon, // :
  leftParen, // (
  rightParen, // )
  leftBracket, // [
  rightBracket, // ]
  leftBrace, // {
  rightBrace, // }

  // Operators
  plus, // +
  minus, // -
  multiply, // *
  divide, // /
  modulo, // %

  // Comparison
  equal, // =
  notEqual, // !=
  lessThan, // <
  lessOrEqual, // <=
  greaterThan, // >
  greaterOrEqual, // >=

  // Logical
  and,
  or,
  not,

  // String concatenation
  ampersand, // &

  // Special
  variable, // $
  descendant, // **
  wildcard, // *
  range, // ..

  eof,
}

class Token {
  final TokenType type;
  final dynamic value;
  final int position;

  Token(this.type, this.value, this.position);

  @override
  String toString() => 'Token($type, $value, pos: $position)';
}

class Lexer {
  final String input;
  int _position = 0;
  int _current = 0;

  Lexer(this.input);

  List<Token> tokenize() {
    final tokens = <Token>[];

    while (!_isAtEnd()) {
      _skipWhitespace();
      if (_isAtEnd()) break;

      _current = _position;
      tokens.add(_nextToken());
    }

    tokens.add(Token(TokenType.eof, null, _position));
    return tokens;
  }

  Token _nextToken() {
    final char = _advance();

    switch (char) {
      case '.':
        if (_match('.')) {
          return Token(TokenType.range, '..', _current);
        }
        return Token(TokenType.dot, '.', _current);

      case ',':
        return Token(TokenType.comma, ',', _current);

      case ':':
        return Token(TokenType.colon, ':', _current);

      case '(':
        return Token(TokenType.leftParen, '(', _current);

      case ')':
        return Token(TokenType.rightParen, ')', _current);

      case '[':
        return Token(TokenType.leftBracket, '[', _current);

      case ']':
        return Token(TokenType.rightBracket, ']', _current);

      case '{':
        return Token(TokenType.leftBrace, '{', _current);

      case '}':
        return Token(TokenType.rightBrace, '}', _current);

      case '+':
        return Token(TokenType.plus, '+', _current);

      case '-':
        return _isDigit(_peek()) ? _number(negative: true) : Token(TokenType.minus, '-', _current);

      case '/':
        return Token(TokenType.divide, '/', _current);

      case '%':
        return Token(TokenType.modulo, '%', _current);

      case '&':
        return Token(TokenType.ampersand, '&', _current);

      case '=':
        return Token(TokenType.equal, '=', _current);

      case '!':
        if (_match('=')) {
          return Token(TokenType.notEqual, '!=', _current);
        }
        throw LexerException('Unexpected character: !', position: _current);

      case '<':
        if (_match('=')) {
          return Token(TokenType.lessOrEqual, '<=', _current);
        }
        return Token(TokenType.lessThan, '<', _current);

      case '>':
        if (_match('=')) {
          return Token(TokenType.greaterOrEqual, '>=', _current);
        }
        return Token(TokenType.greaterThan, '>', _current);

      case '*':
        if (_match('*')) {
          return Token(TokenType.descendant, '**', _current);
        }
        return Token(TokenType.multiply, '*', _current);

      case '\$':
        return _variable();

      case '"':
      case "'":
        return _string(char);

      default:
        if (_isDigit(char)) {
          _position--; // Back up to re-read the digit
          return _number();
        }

        if (_isAlpha(char) || char == '_') {
          _position--; // Back up to re-read the character
          return _identifier();
        }

        throw LexerException('Unexpected character: $char', position: _current);
    }
  }

  Token _number({bool negative = false}) {
    final start = _position - (negative ? 1 : 0);

    while (_isDigit(_peek())) {
      _advance();
    }

    if (_peek() == '.' && _isDigit(_peekNext())) {
      _advance(); // consume '.'

      while (_isDigit(_peek())) {
        _advance();
      }
    }

    // Handle scientific notation
    if (_peek() == 'e' || _peek() == 'E') {
      _advance();
      if (_peek() == '+' || _peek() == '-') {
        _advance();
      }
      while (_isDigit(_peek())) {
        _advance();
      }
    }

    final value = num.parse(input.substring(start, _position));
    return Token(TokenType.number, value, _current);
  }

  Token _string(String quote) {
    final buffer = StringBuffer();

    while (_peek() != quote && !_isAtEnd()) {
      if (_peek() == '\\') {
        _advance();
        final escaped = _advance();
        switch (escaped) {
          case 'n':
            buffer.write('\n');
            break;
          case 't':
            buffer.write('\t');
            break;
          case 'r':
            buffer.write('\r');
            break;
          case '\\':
            buffer.write('\\');
            break;
          case '"':
            buffer.write('"');
            break;
          case "'":
            buffer.write("'");
            break;
          default:
            buffer.write(escaped);
        }
      } else {
        buffer.write(_advance());
      }
    }

    if (_isAtEnd()) {
      throw LexerException('Unterminated string', position: _current);
    }

    _advance(); // closing quote

    return Token(TokenType.string, buffer.toString(), _current);
  }

  Token _identifier() {
    final start = _position;

    while (_isAlphaNumeric(_peek())) {
      _advance();
    }

    final text = input.substring(start, _position);

    // Check for keywords
    switch (text) {
      case 'true':
        return Token(TokenType.boolean, true, _current);
      case 'false':
        return Token(TokenType.boolean, false, _current);
      case 'null':
        return Token(TokenType.nil, null, _current);
      case 'and':
        return Token(TokenType.and, 'and', _current);
      case 'or':
        return Token(TokenType.or, 'or', _current);
      case 'not':
        return Token(TokenType.not, 'not', _current);
      default:
        return Token(TokenType.identifier, text, _current);
    }
  }

  Token _variable() {
    final start = _position;

    while (_isAlphaNumeric(_peek())) {
      _advance();
    }

    final text = input.substring(start, _position);
    return Token(TokenType.variable, text, _current);
  }

  bool _match(String expected) {
    if (_isAtEnd()) return false;
    if (input[_position] != expected) return false;

    _position++;
    return true;
  }

  String _advance() {
    return input[_position++];
  }

  String _peek() {
    if (_isAtEnd()) return '\x00';
    return input[_position];
  }

  String _peekNext() {
    if (_position + 1 >= input.length) return '\x00';
    return input[_position + 1];
  }

  bool _isAtEnd() => _position >= input.length;

  void _skipWhitespace() {
    while (!_isAtEnd()) {
      final char = _peek();
      if (char == ' ' || char == '\t' || char == '\n' || char == '\r') {
        _advance();
      } else {
        break;
      }
    }
  }

  bool _isDigit(String char) {
    return char.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
           char.codeUnitAt(0) <= '9'.codeUnitAt(0);
  }

  bool _isAlpha(String char) {
    final code = char.codeUnitAt(0);
    return (code >= 'a'.codeUnitAt(0) && code <= 'z'.codeUnitAt(0)) ||
           (code >= 'A'.codeUnitAt(0) && code <= 'Z'.codeUnitAt(0)) ||
           char == '_';
  }

  bool _isAlphaNumeric(String char) {
    return _isAlpha(char) || _isDigit(char);
  }
}
