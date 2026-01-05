import 'package:jsonata_dart/jsonata_dart.dart';

void main() {
  print('Testing with user\'s exact data structure\n');

  // Scenario 1: field-004 has NO value property (initial state)
  final dataNoValue = {
    "fields": [
      {
        "id": "field-003",
        "label": "Product Type",
        "type": "option",
        "jira_field_name": "Product Type Field",
        "value": "Type A",
        "required": true
      },
      {
        "id": "field-004",
        "label": "Topic",
        "type": "option",
        "jira_field_name": "Topic Field A",
        "required": false
        // NO value property
      },
      {
        "id": "field-005",
        "label": "Subcategory 1",
        "jira_field_name": "Subcategory 1 Field",
        "required": false
      }
    ]
  };

  print('=== Scenario 1: Field has NO value property ===');
  final expr1 = Jsonata("fields[jira_field_name = 'Topic Field A'].value = 'Issue 1'");
  final result1 = expr1.evaluate(dataNoValue);
  print('Expression: fields[jira_field_name = \'Topic Field A\'].value = \'Issue 1\'');
  print('Result: $result1');
  print('Expected: false (no value set yet)\n');

  // Scenario 2: field-004 HAS value = "Issue 1" (user selected it)
  final dataWithValue = {
    "fields": [
      {
        "id": "field-003",
        "label": "Product Type",
        "jira_field_name": "Product Type Field",
        "value": "Type A"
      },
      {
        "id": "field-004",
        "label": "Topic",
        "jira_field_name": "Topic Field A",
        "value": "Issue 1"  // User selected this value
      }
    ]
  };

  print('=== Scenario 2: Field HAS value = "Issue 1" ===');
  final expr2 = Jsonata("fields[jira_field_name = 'Topic Field A'].value = 'Issue 1'");
  final result2 = expr2.evaluate(dataWithValue);
  print('Expression: fields[jira_field_name = \'Topic Field A\'].value = \'Issue 1\'');
  print('Result: $result2');
  print('Expected: true (value matches!)\n');

  // Scenario 3: field-004 HAS value = null (explicitly null)
  final dataWithNull = {
    "fields": [
      {
        "id": "field-004",
        "jira_field_name": "Topic Field A",
        "value": null  // Explicitly set to null
      }
    ]
  };

  print('=== Scenario 3: Field HAS value = null ===');
  final expr3 = Jsonata("fields[jira_field_name = 'Topic Field A'].value = 'Issue 1'");
  final result3 = expr3.evaluate(dataWithNull);
  print('Expression: fields[jira_field_name = \'Topic Field A\'].value = \'Issue 1\'');
  print('Result: $result3');
  print('Expected: false (null != "Issue 1")\n');

  // Let's also check what .value returns in each case
  print('=== Debug: What does .value return? ===');

  final exprDebug = Jsonata("fields[jira_field_name = 'Topic Field A'].value");

  print('No value property:');
  final debugResult1 = exprDebug.evaluate(dataNoValue);
  print('  Result: $debugResult1 (type: ${debugResult1.runtimeType})');

  print('With value = "Issue 1":');
  final debugResult2 = exprDebug.evaluate(dataWithValue);
  print('  Result: $debugResult2 (type: ${debugResult2.runtimeType})');

  print('With value = null:');
  final debugResult3 = exprDebug.evaluate(dataWithNull);
  print('  Result: $debugResult3 (type: ${debugResult3.runtimeType})');
}
