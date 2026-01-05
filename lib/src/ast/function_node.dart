import 'node.dart';

/// Represents a function call (e.g., $sum(items))
class FunctionNode extends ASTNode {
  final String name;
  final List<ASTNode> arguments;

  const FunctionNode(this.name, this.arguments);

  @override
  String toString() => 'FunctionNode($name, $arguments)';
}

/// Represents a lambda function
class LambdaNode extends ASTNode {
  final List<String> parameters;
  final ASTNode body;

  const LambdaNode(this.parameters, this.body);

  @override
  String toString() => 'LambdaNode($parameters, $body)';
}
