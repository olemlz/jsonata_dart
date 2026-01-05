# Changelog

## 0.1.0 - 2026-01-05

### Initial Release

A pure Dart implementation of JSONata - a JSON query and transformation language.

#### Features

- **Pure Dart Implementation**: No JavaScript dependencies, no WebView
- **Null-safe**: Built with Dart 3.0+ null safety
- **Cross-platform**: Works on all Flutter platforms

#### Supported Features

- **Path Navigation**:
  - Simple property access (`Address.City`)
  - Array indexing (`items[0]`, `items[-1]`)
  - Array slicing (`items[2:5]`)
  - Wildcard selection (`items[*].price`)
  - Recursive descent (`**.price`)
  - Property access on arrays

- **Predicates**:
  - Filter arrays with conditions (`items[price > 10]`)
  - Complex boolean logic (`users[age >= 18 and active = true]`)

- **Operators**:
  - Arithmetic: `+`, `-`, `*`, `/`, `%`
  - Comparison: `=`, `!=`, `<`, `<=`, `>`, `>=`
  - Logical: `and`, `or`, `not`
  - String concatenation: `&`

- **Built-in Functions**:
  - Aggregation: `$sum`, `$count`, `$max`, `$min`, `$average`
  - String: `$substring`, `$uppercase`, `$lowercase`, `$contains`, `$trim`, `$length`, `$split`, `$replace`
  - Array: `$join`, `$append`, `$reverse`, `$sort`, `$distinct`, `$flatten`, `$exists`

- **Custom Functions**: Register your own functions with `registerFunction()`

- **Literals**: Numbers, strings, booleans, null, arrays, objects

#### Known Limitations

- Lambda functions not yet supported
- Variable binding not yet supported
- Parent operator (`%`) not yet supported
- Regular expressions not yet supported
- Some advanced JSONata features not yet implemented

#### Documentation

- Comprehensive README with usage examples
- 72 integration tests covering core functionality
- Example application demonstrating common use cases
