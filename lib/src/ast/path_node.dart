import 'node.dart';

/// Represents a path expression (e.g., Address.City, items[0])
class PathNode extends ASTNode {
  final List<PathStep> steps;

  const PathNode(this.steps);

  @override
  String toString() => 'PathNode($steps)';
}

/// Base class for path steps
abstract class PathStep {
  const PathStep();
}

/// Simple property access (e.g., City in Address.City)
class PropertyStep extends PathStep {
  final String name;

  const PropertyStep(this.name);

  @override
  String toString() => 'PropertyStep($name)';
}

/// Wildcard selector (*)
class WildcardStep extends PathStep {
  const WildcardStep();

  @override
  String toString() => 'WildcardStep()';
}

/// Recursive descent (**)
class DescendantStep extends PathStep {
  final String? property;

  const DescendantStep([this.property]);

  @override
  String toString() => 'DescendantStep($property)';
}

/// Array index access (e.g., [0])
class IndexStep extends PathStep {
  final int index;

  const IndexStep(this.index);

  @override
  String toString() => 'IndexStep($index)';
}

/// Array slice (e.g., [2:5])
class SliceStep extends PathStep {
  final int? start;
  final int? end;

  const SliceStep(this.start, this.end);

  @override
  String toString() => 'SliceStep($start:$end)';
}

/// Array predicate (e.g., [price > 10])
class PredicateStep extends PathStep {
  final ASTNode condition;

  const PredicateStep(this.condition);

  @override
  String toString() => 'PredicateStep($condition)';
}

/// Represents a variable reference (e.g., $var)
class VariableNode extends ASTNode {
  final String name;

  const VariableNode(this.name);

  @override
  String toString() => 'VariableNode($name)';
}
