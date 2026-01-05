import 'package:jsonata_dart/jsonata_dart.dart';

void main() {
  print('Testing visibility rule - exact user scenario\n');

  // Original data structure from user
  final data = {
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
  };

  // Test with exact user expression
  print('Test 1: Exact user expression (with value set to "Issue 1")');
  final expr1 = Jsonata("fields[jira_field_name = 'Topic Field A'].value = 'Issue 1'");
  print("Expression: fields[jira_field_name = 'Topic Field A'].value = 'Issue 1'");
  final result1 = expr1.evaluate(data);
  print('Result: $result1');
  print('Expected: true\n');

  // Test what .value returns
  print('Test 2: What does .value return?');
  final expr2 = Jsonata("fields[jira_field_name = 'Topic Field A'].value");
  print("Expression: fields[jira_field_name = 'Topic Field A'].value");
  final result2 = expr2.evaluate(data);
  print('Result: $result2');
  print('Type: ${result2.runtimeType}\n');

  // Test without value property
  print('Test 3: WITHOUT value property (field has no current value)');
  final dataNoValue = {
    "fields": [
      {
        "id": "field-004",
        "label": "Topic",
        "type": "option",
        "jira_field_name": "Topic Field A",
        "options": ["Issue 1", "Issue 2"],
        "required": false
        // NO value property!
      }
    ]
  };

  final expr3a = Jsonata("fields[jira_field_name = 'Topic Field A'].value");
  print("Expression: fields[jira_field_name = 'Topic Field A'].value");
  final result3a = expr3a.evaluate(dataNoValue);
  print('Result (no value property): $result3a');
  print('Type: ${result3a.runtimeType}\n');

  final expr3b = Jsonata("fields[jira_field_name = 'Topic Field A'].value = 'Issue 1'");
  print("Expression: fields[jira_field_name = 'Topic Field A'].value = 'Issue 1'");
  final result3b = expr3b.evaluate(dataNoValue);
  print('Result: $result3b (should be false or null)\n');

  // Test with different value
  print('Test 4: Value is "Issue 2" (not "Issue 1")');
  final dataDifferentValue = {
    "fields": [
      {
        "id": "field-004",
        "label": "Topic",
        "jira_field_name": "Topic Field A",
        "value": "Issue 2"
      }
    ]
  };

  final expr4 = Jsonata("fields[jira_field_name = 'Topic Field A'].value = 'Issue 1'");
  print("Expression: fields[jira_field_name = 'Topic Field A'].value = 'Issue 1'");
  final result4 = expr4.evaluate(dataDifferentValue);
  print('Result: $result4 (should be false)\n');

  // Test with null value
  print('Test 5: Value is null');
  final dataNullValue = {
    "fields": [
      {
        "id": "field-004",
        "label": "Topic",
        "jira_field_name": "Topic Field A",
        "value": null
      }
    ]
  };

  final expr5 = Jsonata("fields[jira_field_name = 'Topic Field A'].value = 'Issue 1'");
  print("Expression: fields[jira_field_name = 'Topic Field A'].value = 'Issue 1'");
  final result5 = expr5.evaluate(dataNullValue);
  print('Result: $result5 (should be false)\n');

  // Recommended solution
  print('Test 6: Recommended solution using \$exists');
  final expr6 = Jsonata("\$exists(fields[jira_field_name = 'Topic Field A' and value = 'Issue 1'])");
  print("Expression: \$exists(fields[jira_field_name = 'Topic Field A' and value = 'Issue 1'])");
  print('With value = "Issue 1": ${expr6.evaluate(data)}');
  print('Without value property: ${expr6.evaluate(dataNoValue)}');
  print('With value = "Issue 2": ${expr6.evaluate(dataDifferentValue)}');
  print('With value = null: ${expr6.evaluate(dataNullValue)}');
}
