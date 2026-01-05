import 'package:jsonata_dart/jsonata_dart.dart';

void main() {
  print('JSONata Dart Examples\n');

  // Example 1: Simple path navigation
  print('Example 1: Simple path navigation');
  final data1 = {
    'user': {
      'name': 'John Doe',
      'email': 'john@example.com'
    }
  };
  final expr1 = Jsonata('user.name');
  print('Expression: user.name');
  print('Result: ${expr1.evaluate(data1)}\n');

  // Example 2: Array access and filtering
  print('Example 2: Array access and filtering');
  final data2 = {
    'products': [
      {'name': 'Laptop', 'price': 1200, 'inStock': true},
      {'name': 'Mouse', 'price': 25, 'inStock': true},
      {'name': 'Keyboard', 'price': 80, 'inStock': false},
      {'name': 'Monitor', 'price': 350, 'inStock': true},
    ]
  };
  final expr2 = Jsonata('products[inStock = true].name');
  print('Expression: products[inStock = true].name');
  print('Result: ${expr2.evaluate(data2)}\n');

  // Example 3: Aggregation functions
  print('Example 3: Aggregation functions');
  final expr3 = Jsonata(r'$sum(products[inStock = true].price)');
  print(r'Expression: $sum(products[inStock = true].price)');
  print('Result: \$${expr3.evaluate(data2)}\n');

  // Example 4: String manipulation
  print('Example 4: String manipulation');
  final data4 = {
    'firstName': 'john',
    'lastName': 'doe'
  };
  final expr4 = Jsonata(r'$uppercase(firstName) & " " & $uppercase(lastName)');
  print(r'Expression: $uppercase(firstName) & " " & $uppercase(lastName)');
  print('Result: ${expr4.evaluate(data4)}\n');

  // Example 5: Complex query with multiple functions
  print('Example 5: Complex query with multiple functions');
  final data5 = {
    'orders': [
      {'id': 1, 'total': 150, 'status': 'completed'},
      {'id': 2, 'total': 200, 'status': 'completed'},
      {'id': 3, 'total': 75, 'status': 'pending'},
      {'id': 4, 'total': 300, 'status': 'completed'},
    ]
  };
  final expr5 = Jsonata(r'$average(orders[status = "completed"].total)');
  print(r'Expression: $average(orders[status = "completed"].total)');
  print('Result: \$${expr5.evaluate(data5)}\n');

  // Example 6: Recursive descent
  print('Example 6: Recursive descent');
  final data6 = {
    'store': {
      'book': [
        {'title': 'Book 1', 'price': 8.95},
        {'title': 'Book 2', 'price': 12.99}
      ],
      'bicycle': {'price': 19.95}
    }
  };
  final expr6 = Jsonata(r'$sum(**.price)');
  print(r'Expression: $sum(**.price)');
  print('Result: \$${expr6.evaluate(data6)}\n');

  // Example 7: Array functions
  print('Example 7: Array functions');
  final data7 = {
    'numbers': [5, 2, 8, 1, 9, 3]
  };
  final expr7 = Jsonata(r'$reverse($sort(numbers))');
  print(r'Expression: $reverse($sort(numbers))');
  print('Result: ${expr7.evaluate(data7)}\n');

  // Example 8: Custom function
  print('Example 8: Custom function');
  final data8 = {
    'items': [
      {'quantity': 2, 'price': 10},
      {'quantity': 3, 'price': 15},
      {'quantity': 1, 'price': 20}
    ]
  };
  final expr8 = Jsonata(r'$calculateTotal(items)');
  expr8.registerFunction('calculateTotal', (args) {
    final items = args[0] as List;
    num total = 0;
    for (final item in items) {
      final map = item as Map;
      total += (map['quantity'] as num) * (map['price'] as num);
    }
    return total;
  });
  print(r'Expression: $calculateTotal(items) (custom function)');
  print('Result: \$${expr8.evaluate(data8)}\n');

  // Example 9: Predicates with complex conditions
  print('Example 9: Predicates with complex conditions');
  final data9 = {
    'employees': [
      {'name': 'Alice', 'age': 30, 'salary': 75000, 'active': true},
      {'name': 'Bob', 'age': 25, 'salary': 55000, 'active': true},
      {'name': 'Charlie', 'age': 35, 'salary': 85000, 'active': false},
      {'name': 'Diana', 'age': 28, 'salary': 65000, 'active': true},
    ]
  };
  final expr9 = Jsonata(r'$count(employees[age >= 28 and salary > 60000 and active = true])');
  print(r'Expression: $count(employees[age >= 28 and salary > 60000 and active = true])');
  print('Result: ${expr9.evaluate(data9)}\n');

  // Example 10: String functions
  print('Example 10: String functions');
  final data10 = {
    'text': 'Hello, World! Welcome to JSONata.'
  };
  final expr10 = Jsonata(r'$join($split(text, " "), "-")');
  print(r'Expression: $join($split(text, " "), "-")');
  print('Result: ${expr10.evaluate(data10)}\n');

  print('All examples completed successfully!');
}
