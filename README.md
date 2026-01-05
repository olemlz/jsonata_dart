# JSONata Dart

A pure Dart implementation of [JSONata](https://jsonata.org/) - a lightweight JSON query and transformation language.

## Features

- **Pure Dart**: No WebView, no JavaScript dependencies
- **Null-safe**: Built with Dart 3.0+ null safety
- **Cross-platform**: Works on all Flutter platforms (iOS, Android, Web, Desktop)
- **Comprehensive**: Supports path navigation, predicates, operators, and built-in functions
- **Extensible**: Register custom functions for domain-specific operations

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  jsonata_dart: ^0.1.0
```

## Quick Start

```dart
import 'package:jsonata_dart/jsonata_dart.dart';

void main() {
  final data = {
    'products': [
      {'name': 'Laptop', 'price': 1200, 'inStock': true},
      {'name': 'Mouse', 'price': 25, 'inStock': true},
      {'name': 'Keyboard', 'price': 80, 'inStock': false},
    ]
  };

  // Simple query
  final expr = Jsonata(r'$sum(products[inStock = true].price)');
  final result = expr.evaluate(data);
  print(result); // 1225
}
```

## Core Features

### Path Navigation

```dart
// Simple property access
Jsonata('Address.City').evaluate(data);

// Array indexing
Jsonata('items[0]').evaluate(data);

// Negative indexing
Jsonata('items[-1]').evaluate(data);

// Array slicing
Jsonata('items[2:5]').evaluate(data);

// Wildcard
Jsonata('items[*].price').evaluate(data);

// Recursive descent
Jsonata('**.price').evaluate(data);

// Property access on arrays (maps over elements)
Jsonata('users.name').evaluate(data);
```

### Predicates

Filter arrays based on conditions:

```dart
// Simple predicate
Jsonata('items[price > 10]').evaluate(data);

// Complex predicates with logical operators
Jsonata('users[age >= 18 and active = true]').evaluate(data);
```

### Operators

#### Arithmetic
- `+` Addition
- `-` Subtraction
- `*` Multiplication
- `/` Division
- `%` Modulo

#### Comparison
- `=` Equal
- `!=` Not equal
- `<` Less than
- `<=` Less than or equal
- `>` Greater than
- `>=` Greater than or equal

#### Logical
- `and` Logical AND
- `or` Logical OR
- `not` Logical NOT

#### String
- `&` String concatenation

### Built-in Functions

#### Aggregation Functions

```dart
$sum(array)          // Sum of numeric values
$count(array)        // Count of elements
$max(array)          // Maximum value
$min(array)          // Minimum value
$average(array)      // Average of numeric values
```

#### String Functions

```dart
$substring(str, start, length)     // Extract substring
$uppercase(str)                     // Convert to uppercase
$lowercase(str)                     // Convert to lowercase
$contains(str, pattern)             // Check if string contains pattern
$trim(str)                          // Remove leading/trailing whitespace
$length(str)                        // String length
$split(str, separator, limit?)     // Split string into array
$replace(str, pattern, repl, limit?) // Replace occurrences
```

#### Array Functions

```dart
$join(array, separator?)      // Join array elements into string
$append(array, value)         // Append value to array
$reverse(array)               // Reverse array order
$sort(array)                  // Sort array
$distinct(array)              // Remove duplicates
$flatten(array, depth?)       // Flatten nested arrays
$exists(value)                // Check if value exists (not null)
```

## Examples

### Example 1: E-commerce Query

```dart
final data = {
  'orders': [
    {'id': 1, 'total': 150, 'status': 'completed'},
    {'id': 2, 'total': 200, 'status': 'completed'},
    {'id': 3, 'total': 75, 'status': 'pending'},
  ]
};

// Calculate average of completed orders
final expr = Jsonata(r'$average(orders[status = "completed"].total)');
print(expr.evaluate(data)); // 175
```

### Example 2: Data Transformation

```dart
final data = {
  'firstName': 'john',
  'lastName': 'doe'
};

// Transform to full name in uppercase
final expr = Jsonata(r'$uppercase(firstName) & " " & $uppercase(lastName)');
print(expr.evaluate(data)); // "JOHN DOE"
```

### Example 3: Recursive Search

```dart
final data = {
  'store': {
    'book': [
      {'price': 8.95},
      {'price': 12.99}
    ],
    'bicycle': {'price': 19.95}
  }
};

// Find all prices in nested structure
final expr = Jsonata(r'$sum(**.price)');
print(expr.evaluate(data)); // 41.89
```

### Example 4: Custom Functions

```dart
final expr = Jsonata(r'$double(price)');

// Register custom function
expr.registerFunction('double', (args) => (args[0] as num) * 2);

final result = expr.evaluate({'price': 10});
print(result); // 20
```

## API Reference

### `Jsonata(String expression)`

Creates a new JSONata expression. Throws `JsonataException` if the expression is invalid.

```dart
final expr = Jsonata('user.name');
```

### `evaluate(dynamic data)`

Evaluates the expression against the provided data. Returns the result which can be any JSON-compatible type.

```dart
final result = expr.evaluate({'user': {'name': 'John'}});
```

### `registerFunction(String name, Function impl)`

Registers a custom function that can be called from JSONata expressions.

```dart
expr.registerFunction('triple', (args) => (args[0] as num) * 3);
```

## Error Handling

The library throws specific exceptions for different error types:

- `LexerException`: Tokenization errors
- `ParserException`: Syntax errors in expressions
- `EvaluatorException`: Runtime evaluation errors

```dart
try {
  final expr = Jsonata('invalid expression [[[');
  expr.evaluate(data);
} on ParserException catch (e) {
  print('Parse error: ${e.message}');
} on EvaluatorException catch (e) {
  print('Evaluation error: ${e.message}');
}
```

## Limitations

This is an initial implementation focusing on core JSONata features. The following are not yet supported:

- Lambda functions in expressions (syntax like `function($v){$v * 2}`)
- Variable binding
- Parent operator (`%`)
- Context variables beyond `$` functions
- Regular expressions
- Some advanced JSONata features

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

## Acknowledgments

This implementation is inspired by the [JSONata specification](https://docs.jsonata.org/).
