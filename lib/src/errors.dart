/// Base exception for JSONata errors
class JsonataException implements Exception {
  final String message;
  final int? position;
  final String? token;

  JsonataException(this.message, {this.position, this.token});

  @override
  String toString() {
    if (position != null) {
      return 'JsonataException at position $position: $message';
    }
    return 'JsonataException: $message';
  }
}

/// Lexer-specific exception
class LexerException extends JsonataException {
  LexerException(super.message, {super.position, super.token});
}

/// Parser-specific exception
class ParserException extends JsonataException {
  ParserException(super.message, {super.position, super.token});
}

/// Evaluator-specific exception
class EvaluatorException extends JsonataException {
  EvaluatorException(super.message, {super.position, super.token});
}
