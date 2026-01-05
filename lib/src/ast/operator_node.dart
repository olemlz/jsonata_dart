import 'node.dart';

/// Represents a binary operation (e.g., a + b, x = y)
class BinaryOpNode extends ASTNode {
  final String operator;
  final ASTNode left;
  final ASTNode right;

  const BinaryOpNode(this.operator, this.left, this.right);

  @override
  String toString() => 'BinaryOpNode($operator, $left, $right)';
}

/// Represents a unary operation (e.g., -x, not x)
class UnaryOpNode extends ASTNode {
  final String operator;
  final ASTNode operand;

  const UnaryOpNode(this.operator, this.operand);

  @override
  String toString() => 'UnaryOpNode($operator, $operand)';
}
