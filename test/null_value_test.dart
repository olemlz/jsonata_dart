import 'package:jsonata_dart/jsonata_dart.dart';

void main() {
  print('Testing NULL value handling\n');

  // Test case 1: value is null (should be preserved)
  final dataWithNull = {
    "fields": [
      {
        "id": "field-004",
        "jira_field_name": "Topic Field A",
        "value": null  // NULL value exists!
      }
    ]
  };

  print('Test 1: Field with value = null');
  final expr1 = Jsonata("fields[jira_field_name = 'Topic Field A'].value");
  final result1 = expr1.evaluate(dataWithNull);
  print('Expression: fields[jira_field_name = \'Topic Field A\'].value');
  print('Result: $result1');
  print('Type: ${result1.runtimeType}');
  print('Expected: [null] (list with null value)');
  print('Actual behavior: $result1\n');

  print('Test 2: Comparison with null value');
  final expr2 = Jsonata("fields[jira_field_name = 'Topic Field A'].value = null");
  final result2 = expr2.evaluate(dataWithNull);
  print('Expression: fields[jira_field_name = \'Topic Field A\'].value = null');
  print('Result: $result2');
  print('Expected: true (because value IS null)\n');

  // Test case 3: value property doesn't exist
  final dataWithoutValue = {
    "fields": [
      {
        "id": "field-004",
        "jira_field_name": "Topic Field A"
        // NO value property!
      }
    ]
  };

  print('Test 3: Field WITHOUT value property');
  final expr3 = Jsonata("fields[jira_field_name = 'Topic Field A'].value");
  final result3 = expr3.evaluate(dataWithoutValue);
  print('Expression: fields[jira_field_name = \'Topic Field A\'].value');
  print('Result: $result3');
  print('Type: ${result3.runtimeType}');
  print('Expected: [] (empty list)\n');

  // Test case 4: multiple fields, some with null
  final dataMultiple = {
    "fields": [
      {
        "id": "field-001",
        "jira_field_name": "Field 1",
        "value": "Value 1"
      },
      {
        "id": "field-002",
        "jira_field_name": "Field 2",
        "value": null
      },
      {
        "id": "field-003",
        "jira_field_name": "Field 3"
        // no value
      }
    ]
  };

  print('Test 4: Multiple fields - accessing .value on all');
  final expr4 = Jsonata("fields.value");
  final result4 = expr4.evaluate(dataMultiple);
  print('Expression: fields.value');
  print('Result: $result4');
  print('Expected: ["Value 1", null] (should include null, but NOT undefined)\n');
}
