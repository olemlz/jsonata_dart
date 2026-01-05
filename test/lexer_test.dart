import 'package:test/test.dart';
import 'package:jsonata_dart/src/lexer.dart';

void main() {
  group('Lexer', () {
    test('tokenizes identifiers', () {
      final lexer = Lexer('Address');
      final tokens = lexer.tokenize();
      expect(tokens.length, 2); // identifier + EOF
      expect(tokens[0].type, TokenType.identifier);
      expect(tokens[0].value, 'Address');
    });

    test('tokenizes numbers', () {
      final lexer = Lexer('42 3.14 -5 1.5e10');
      final tokens = lexer.tokenize();
      expect(tokens[0].type, TokenType.number);
      expect(tokens[0].value, 42);
      expect(tokens[1].type, TokenType.number);
      expect(tokens[1].value, 3.14);
      expect(tokens[2].type, TokenType.number);
      expect(tokens[2].value, -5);
      expect(tokens[3].type, TokenType.number);
      expect(tokens[3].value, 1.5e10);
    });

    test('tokenizes strings', () {
      final lexer = Lexer('"hello" \'world\'');
      final tokens = lexer.tokenize();
      expect(tokens[0].type, TokenType.string);
      expect(tokens[0].value, 'hello');
      expect(tokens[1].type, TokenType.string);
      expect(tokens[1].value, 'world');
    });

    test('tokenizes escape sequences', () {
      final lexer = Lexer(r'"hello\nworld"');
      final tokens = lexer.tokenize();
      expect(tokens[0].value, 'hello\nworld');
    });

    test('tokenizes booleans', () {
      final lexer = Lexer('true false');
      final tokens = lexer.tokenize();
      expect(tokens[0].type, TokenType.boolean);
      expect(tokens[0].value, true);
      expect(tokens[1].type, TokenType.boolean);
      expect(tokens[1].value, false);
    });

    test('tokenizes null', () {
      final lexer = Lexer('null');
      final tokens = lexer.tokenize();
      expect(tokens[0].type, TokenType.nil);
      expect(tokens[0].value, null);
    });

    test('tokenizes operators', () {
      final lexer = Lexer('+ - * / % = != < <= > >= and or not &');
      final tokens = lexer.tokenize();
      expect(tokens[0].type, TokenType.plus);
      expect(tokens[1].type, TokenType.minus);
      expect(tokens[2].type, TokenType.multiply);
      expect(tokens[3].type, TokenType.divide);
      expect(tokens[4].type, TokenType.modulo);
      expect(tokens[5].type, TokenType.equal);
      expect(tokens[6].type, TokenType.notEqual);
      expect(tokens[7].type, TokenType.lessThan);
      expect(tokens[8].type, TokenType.lessOrEqual);
      expect(tokens[9].type, TokenType.greaterThan);
      expect(tokens[10].type, TokenType.greaterOrEqual);
      expect(tokens[11].type, TokenType.and);
      expect(tokens[12].type, TokenType.or);
      expect(tokens[13].type, TokenType.not);
      expect(tokens[14].type, TokenType.ampersand);
    });

    test('tokenizes symbols', () {
      final lexer = Lexer('. , : ( ) [ ] { }');
      final tokens = lexer.tokenize();
      expect(tokens[0].type, TokenType.dot);
      expect(tokens[1].type, TokenType.comma);
      expect(tokens[2].type, TokenType.colon);
      expect(tokens[3].type, TokenType.leftParen);
      expect(tokens[4].type, TokenType.rightParen);
      expect(tokens[5].type, TokenType.leftBracket);
      expect(tokens[6].type, TokenType.rightBracket);
      expect(tokens[7].type, TokenType.leftBrace);
      expect(tokens[8].type, TokenType.rightBrace);
    });

    test('tokenizes special operators', () {
      final lexer = Lexer('** ..');
      final tokens = lexer.tokenize();
      expect(tokens[0].type, TokenType.descendant);
      expect(tokens[1].type, TokenType.range);
    });

    test('tokenizes variables', () {
      final lexer = Lexer(r'$sum $myVar');
      final tokens = lexer.tokenize();
      expect(tokens[0].type, TokenType.variable);
      expect(tokens[0].value, 'sum');
      expect(tokens[1].type, TokenType.variable);
      expect(tokens[1].value, 'myVar');
    });

    test('tokenizes complex expression', () {
      final lexer = Lexer(r'Address.City = "London"');
      final tokens = lexer.tokenize();
      expect(tokens.length, 6); // identifier, dot, identifier, equal, string, EOF
    });
  });
}
