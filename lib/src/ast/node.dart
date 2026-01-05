/// Base class for all AST nodes
abstract class ASTNode {
  const ASTNode();
}

/// Represents a literal value (number, string, boolean, null)
class LiteralNode extends ASTNode {
  final dynamic value;

  const LiteralNode(this.value);

  @override
  String toString() => 'LiteralNode($value)';
}

/// Represents an array literal
class ArrayNode extends ASTNode {
  final List<ASTNode> elements;

  const ArrayNode(this.elements);

  @override
  String toString() => 'ArrayNode($elements)';
}

/// Represents an object literal
class ObjectNode extends ASTNode {
  final Map<String, ASTNode> properties;

  const ObjectNode(this.properties);

  @override
  String toString() => 'ObjectNode($properties)';
}
