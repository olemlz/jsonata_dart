import 'package:test/test.dart';
import 'package:jsonata_dart/jsonata_dart.dart';

void main() {
  group('Integration Tests', () {
    group('Path Navigation', () {
      test('simple property access', () {
        final data = {'Address': {'City': 'London'}};
        final expr = Jsonata('Address.City');
        expect(expr.evaluate(data), 'London');
      });

      test('nested property access', () {
        final data = {
          'user': {
            'profile': {
              'name': 'John'
            }
          }
        };
        final expr = Jsonata('user.profile.name');
        expect(expr.evaluate(data), 'John');
      });

      test('array index access', () {
        final data = {
          'items': [10, 20, 30]
        };
        final expr = Jsonata('items[0]');
        expect(expr.evaluate(data), 10);
      });

      test('negative array index', () {
        final data = {
          'items': [10, 20, 30]
        };
        final expr = Jsonata('items[-1]');
        expect(expr.evaluate(data), 30);
      });

      test('array slice', () {
        final data = {
          'items': [10, 20, 30, 40, 50]
        };
        final expr = Jsonata('items[1:3]');
        expect(expr.evaluate(data), [20, 30]);
      });

      test('array wildcard', () {
        final data = {
          'items': [
            {'price': 10},
            {'price': 20},
            {'price': 30}
          ]
        };
        final expr = Jsonata('items[*].price');
        expect(expr.evaluate(data), [10, 20, 30]);
      });

      test('wildcard on object', () {
        final data = {
          'products': {
            'a': {'name': 'Apple'},
            'b': {'name': 'Banana'}
          }
        };
        final expr = Jsonata('products.*');
        final result = expr.evaluate(data) as List;
        expect(result.length, 2);
      });

      test('recursive descent', () {
        final data = {
          'store': {
            'book': [
              {'price': 8.95},
              {'price': 12.99}
            ],
            'bicycle': {'price': 19.95}
          }
        };
        final expr = Jsonata('**.price');
        final result = expr.evaluate(data) as List;
        expect(result.length, 3);
        expect(result, containsAll([8.95, 12.99, 19.95]));
      });

      test('property access on array', () {
        final data = {
          'users': [
            {'name': 'John'},
            {'name': 'Jane'}
          ]
        };
        final expr = Jsonata('users.name');
        expect(expr.evaluate(data), ['John', 'Jane']);
      });
    });

    group('Predicates', () {
      test('simple predicate', () {
        final data = {
          'items': [
            {'price': 5},
            {'price': 15},
            {'price': 25}
          ]
        };
        final expr = Jsonata('items[price > 10]');
        final result = expr.evaluate(data) as List;
        expect(result.length, 2);
      });

      test('complex predicate', () {
        final data = {
          'users': [
            {'age': 25, 'active': true},
            {'age': 17, 'active': true},
            {'age': 30, 'active': false}
          ]
        };
        final expr = Jsonata('users[age >= 18 and active = true]');
        final result = expr.evaluate(data) as List;
        expect(result.length, 1);
        expect((result[0] as Map)['age'], 25);
      });
    });

    group('Operators', () {
      test('arithmetic operations', () {
        expect(Jsonata('5 + 3').evaluate(null), 8);
        expect(Jsonata('10 - 4').evaluate(null), 6);
        expect(Jsonata('6 * 7').evaluate(null), 42);
        expect(Jsonata('15 / 3').evaluate(null), 5);
        expect(Jsonata('10 % 3').evaluate(null), 1);
      });

      test('comparison operations', () {
        expect(Jsonata('5 = 5').evaluate(null), true);
        expect(Jsonata('5 != 3').evaluate(null), true);
        expect(Jsonata('5 < 10').evaluate(null), true);
        expect(Jsonata('5 <= 5').evaluate(null), true);
        expect(Jsonata('10 > 5').evaluate(null), true);
        expect(Jsonata('10 >= 10').evaluate(null), true);
      });

      test('logical operations', () {
        expect(Jsonata('true and true').evaluate(null), true);
        expect(Jsonata('true and false').evaluate(null), false);
        expect(Jsonata('true or false').evaluate(null), true);
        expect(Jsonata('not false').evaluate(null), true);
      });

      test('string concatenation', () {
        final data = {'first': 'Hello', 'last': 'World'};
        final expr = Jsonata('first & " " & last');
        expect(expr.evaluate(data), 'Hello World');
      });

      test('operator precedence', () {
        expect(Jsonata('2 + 3 * 4').evaluate(null), 14);
        expect(Jsonata('(2 + 3) * 4').evaluate(null), 20);
      });
    });

    group('Functions - Aggregation', () {
      test('sum', () {
        final data = {'items': [1, 2, 3, 4, 5]};
        final expr = Jsonata(r'$sum(items)');
        expect(expr.evaluate(data), 15);
      });

      test('count', () {
        final data = {'items': [1, 2, 3, 4, 5]};
        final expr = Jsonata(r'$count(items)');
        expect(expr.evaluate(data), 5);
      });

      test('max', () {
        final data = {'items': [5, 2, 8, 1, 9]};
        final expr = Jsonata(r'$max(items)');
        expect(expr.evaluate(data), 9);
      });

      test('min', () {
        final data = {'items': [5, 2, 8, 1, 9]};
        final expr = Jsonata(r'$min(items)');
        expect(expr.evaluate(data), 1);
      });

      test('average', () {
        final data = {'items': [10, 20, 30]};
        final expr = Jsonata(r'$average(items)');
        expect(expr.evaluate(data), 20);
      });
    });

    group('Functions - String', () {
      test('substring', () {
        final expr = Jsonata(r'$substring("Hello World", 0, 5)');
        expect(expr.evaluate(null), 'Hello');
      });

      test('uppercase', () {
        final expr = Jsonata(r'$uppercase("hello")');
        expect(expr.evaluate(null), 'HELLO');
      });

      test('lowercase', () {
        final expr = Jsonata(r'$lowercase("HELLO")');
        expect(expr.evaluate(null), 'hello');
      });

      test('contains', () {
        final expr = Jsonata(r'$contains("Hello World", "World")');
        expect(expr.evaluate(null), true);
      });

      test('trim', () {
        final expr = Jsonata(r'$trim("  hello  ")');
        expect(expr.evaluate(null), 'hello');
      });

      test('length', () {
        final expr = Jsonata(r'$length("Hello")');
        expect(expr.evaluate(null), 5);
      });

      test('split', () {
        final expr = Jsonata(r'$split("a,b,c", ",")');
        expect(expr.evaluate(null), ['a', 'b', 'c']);
      });

      test('replace', () {
        final expr = Jsonata(r'$replace("Hello World", "World", "Universe")');
        expect(expr.evaluate(null), 'Hello Universe');
      });
    });

    group('Functions - Array', () {
      test('join', () {
        final data = {'items': ['a', 'b', 'c']};
        final expr = Jsonata(r'$join(items, ",")');
        expect(expr.evaluate(data), 'a,b,c');
      });

      test('append', () {
        final data = {'items': [1, 2, 3]};
        final expr = Jsonata(r'$append(items, 4)');
        expect(expr.evaluate(data), [1, 2, 3, 4]);
      });

      test('reverse', () {
        final data = {'items': [1, 2, 3]};
        final expr = Jsonata(r'$reverse(items)');
        expect(expr.evaluate(data), [3, 2, 1]);
      });

      test('sort', () {
        final data = {'items': [3, 1, 4, 1, 5]};
        final expr = Jsonata(r'$sort(items)');
        expect(expr.evaluate(data), [1, 1, 3, 4, 5]);
      });

      test('distinct', () {
        final data = {'items': [1, 2, 2, 3, 3, 3]};
        final expr = Jsonata(r'$distinct(items)');
        expect(expr.evaluate(data), [1, 2, 3]);
      });

      test('flatten', () {
        final data = {
          'items': [
            [1, 2],
            [3, 4]
          ]
        };
        final expr = Jsonata(r'$flatten(items)');
        expect(expr.evaluate(data), [1, 2, 3, 4]);
      });

      test('exists', () {
        expect(Jsonata(r'$exists(null)').evaluate(null), false);
        expect(Jsonata(r'$exists(5)').evaluate(null), true);
      });
    });

    group('Complex Queries', () {
      test('sum with path and predicate', () {
        final data = {
          'items': [
            {'price': 5, 'active': true},
            {'price': 15, 'active': false},
            {'price': 25, 'active': true}
          ]
        };
        final expr = Jsonata(r'$sum(items[active = true].price)');
        expect(expr.evaluate(data), 30);
      });

      test('nested paths with functions', () {
        final data = {
          'store': {
            'books': [
              {'title': 'Book A', 'price': 10},
              {'title': 'Book B', 'price': 15}
            ]
          }
        };
        final expr = Jsonata(r'$count(store.books)');
        expect(expr.evaluate(data), 2);
      });

      test('multiple operations', () {
        final data = {
          'items': [
            {'name': 'apple', 'price': 1.5},
            {'name': 'banana', 'price': 0.8},
            {'name': 'orange', 'price': 2.0}
          ]
        };
        final expr = Jsonata(r'$average(items.price) > 1');
        expect(expr.evaluate(data), true);
      });

      test('string concatenation with functions', () {
        final data = {
          'firstName': 'john',
          'lastName': 'doe'
        };
        final expr = Jsonata(r'$uppercase(firstName) & " " & $uppercase(lastName)');
        expect(expr.evaluate(data), 'JOHN DOE');
      });
    });

    group('Custom Functions', () {
      test('register and use custom function', () {
        final expr = Jsonata(r'$double(5)');
        expr.registerFunction('double', (List args) => (args[0] as num) * 2);
        expect(expr.evaluate(null), 10);
      });

      test('custom function with context', () {
        final data = {'value': 10};
        final expr = Jsonata(r'$triple(value)');
        expr.registerFunction('triple', (List args) => (args[0] as num) * 3);
        expect(expr.evaluate(data), 30);
      });
    });

    group('Edge Cases', () {
      test('null handling', () {
        expect(Jsonata('missing.property').evaluate({}), null);
        expect(Jsonata('items[10]').evaluate({'items': [1, 2, 3]}), null);
      });

      test('empty arrays', () {
        expect(Jsonata(r'$sum(items)').evaluate({'items': []}), 0);
        expect(Jsonata(r'$count(items)').evaluate({'items': []}), 0);
      });

      test('array literals', () {
        expect(Jsonata('[1, 2, 3]').evaluate(null), [1, 2, 3]);
      });

      test('object literals', () {
        final result = Jsonata('{"name": "John", "age": 30}').evaluate(null);
        expect(result, {'name': 'John', 'age': 30});
      });
    });
  });
}
