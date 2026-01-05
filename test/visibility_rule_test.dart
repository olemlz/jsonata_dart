import 'package:jsonata_dart/jsonata_dart.dart';

void main() {
  print('Testing visibility rule expressions\n');

  final data = {
    "data": {
      "fields": [
        {
          "id": "field-001",
          "label": "Request Title",
          "type": "text",
          "required": true
        },
        {
          "id": "field-002",
          "label": "Product Serial Number",
          "type": "text",
          "required": false
        },
        {
          "id": "field-003",
          "label": "Product Type",
          "type": "option",
          "jira_field_name": "Product Type Field",
          "options": ["Type A", "Type B", "Type C", "Type D", "Other"],
          "required": true,
          "value": "Type A"  // Current value
        },
        {
          "id": "field-004",
          "label": "Topic",
          "type": "option",
          "jira_field_name": "Topic Field A",
          "options": ["Issue 1", "Issue 2", "Issue 3", "Issue 4", "Issue 5", "Issue 6", "Other", "Service Request", "General Consultation"],
          "required": false,
          "value": "Issue 1"  // Current value
        },
        {
          "id": "field-005",
          "label": "Subcategory 1",
          "type": "option",
          "jira_field_name": "Subcategory 1 Field",
          "options": ["Problem A", "Problem B", "Problem C", "Problem D", "Problem E", "Problem F"],
          "required": false
        },
        {
          "id": "field-006",
          "label": "Request Description",
          "type": "text",
          "required": true
        }
      ]
    }
  };

  // Test 1: Original expression (problematic)
  print('Test 1: Original expression');
  final expr1 = Jsonata("data.fields[jira_field_name = 'Topic Field A'].value = 'Issue 1'");
  print("Expression: data.fields[jira_field_name = 'Topic Field A'].value = 'Issue 1'");
  final result1 = expr1.evaluate(data);
  print('Result: $result1');
  print('Type: ${result1.runtimeType}\n');

  // Test 2: Check what the predicate returns
  print('Test 2: What does the predicate return?');
  final expr2 = Jsonata("data.fields[jira_field_name = 'Topic Field A']");
  print("Expression: data.fields[jira_field_name = 'Topic Field A']");
  final result2 = expr2.evaluate(data);
  print('Result: $result2');
  print('Type: ${result2.runtimeType}\n');

  // Test 3: Check what .value returns
  print('Test 3: What does .value return?');
  final expr3 = Jsonata("data.fields[jira_field_name = 'Topic Field A'].value");
  print("Expression: data.fields[jira_field_name = 'Topic Field A'].value");
  final result3 = expr3.evaluate(data);
  print('Result: $result3');
  print('Type: ${result3.runtimeType}\n');

  // Test 4: Using $exists with combined predicate
  print('Test 4: Using \$exists with combined predicate');
  final expr4 = Jsonata("\$exists(data.fields[jira_field_name = 'Topic Field A' and value = 'Issue 1'])");
  print("Expression: \$exists(data.fields[jira_field_name = 'Topic Field A' and value = 'Issue 1'])");
  final result4 = expr4.evaluate(data);
  print('Result: $result4');
  print('Type: ${result4.runtimeType}\n');

  // Test 5: Using $count
  print('Test 5: Using \$count');
  final expr5 = Jsonata("\$count(data.fields[jira_field_name = 'Topic Field A' and value = 'Issue 1']) > 0");
  print("Expression: \$count(data.fields[jira_field_name = 'Topic Field A' and value = 'Issue 1']) > 0");
  final result5 = expr5.evaluate(data);
  print('Result: $result5');
  print('Type: ${result5.runtimeType}\n');

  // Test 6: Using array index [0]
  print('Test 6: Using array index [0]');
  final expr6 = Jsonata("data.fields[jira_field_name = 'Topic Field A'][0].value = 'Issue 1'");
  print("Expression: data.fields[jira_field_name = 'Topic Field A'][0].value = 'Issue 1'");
  try {
    final result6 = expr6.evaluate(data);
    print('Result: $result6');
    print('Type: ${result6.runtimeType}\n');
  } catch (e) {
    print('Error: $e\n');
  }

  // Test 7: Using 'in' operator
  print('Test 7: Check if value is in array');
  final expr7 = Jsonata("'Issue 1' in data.fields[jira_field_name = 'Topic Field A'].value");
  print("Expression: 'Issue 1' in data.fields[jira_field_name = 'Topic Field A'].value");
  try {
    final result7 = expr7.evaluate(data);
    print('Result: $result7');
    print('Type: ${result7.runtimeType}\n');
  } catch (e) {
    print('Error: $e\n');
  }

  // Test 8: Testing with false case
  print('Test 8: Testing with false case (Issue 2 instead of Issue 1)');
  final expr8 = Jsonata("\$exists(data.fields[jira_field_name = 'Topic Field A' and value = 'Issue 2'])");
  print("Expression: \$exists(data.fields[jira_field_name = 'Topic Field A' and value = 'Issue 2'])");
  final result8 = expr8.evaluate(data);
  print('Result: $result8');
  print('Type: ${result8.runtimeType}\n');
}
