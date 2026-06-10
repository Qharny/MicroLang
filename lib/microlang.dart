/// MicroLang Compiler Library
///
/// A minimalist language compiler written in Dart that compiles MicroLang
/// source code to JavaScript.
///
/// ## Features
/// - Multiple types: `int`, `float`, `string`, `boolean`
/// - Arithmetic, comparison, and logical expressions with precedence
/// - Control structures: `if`/`else`, `while`
/// - Functions with parameters and return values
/// - JavaScript code generation
///
/// ## Usage
/// ```dart
/// import 'package:microlang/microlang.dart';
///
/// final compiler = SimpleCompiler();
/// final tokens = compiler.lexer('x = 5\nprint(x)');
/// final ast = compiler.parser(tokens);
/// final js = compiler.codeGenerator(ast);
/// print(js);
/// ```
library microlang;

// ── Token Types ──────────────────────────────────────────────

enum TokenType {
  // Literals
  NUMBER,
  FLOAT,
  STRING,
  BOOLEAN,

  // Identifiers & keywords
  IDENTIFIER,
  PRINT,
  IF,
  ELSE,
  WHILE,
  FN,
  RETURN,

  // Operators
  OPERATOR, // + - * /
  ASSIGN, // =
  COMPARISON, // == != < > <= >=
  AND, // &&
  OR, // ||
  NOT, // !

  // Delimiters
  LPAREN, // (
  RPAREN, // )
  LBRACE, // {
  RBRACE, // }
  COMMA, // ,

  // End of file
  EOF,
}

class Token {
  final TokenType type;
  final String value;

  Token(this.type, this.value);

  @override
  String toString() => 'Token($type, $value)';
}

// ── AST Nodes ────────────────────────────────────────────────

abstract class ASTNode {}

/// Integer literal: 42
class NumberLiteral extends ASTNode {
  final int value;
  NumberLiteral(this.value);

  @override
  String toString() => 'NumberLiteral($value)';
}

/// Floating-point literal: 3.14
class FloatLiteral extends ASTNode {
  final double value;
  FloatLiteral(this.value);

  @override
  String toString() => 'FloatLiteral($value)';
}

/// String literal: "hello"
class StringLiteral extends ASTNode {
  final String value;
  StringLiteral(this.value);

  @override
  String toString() => 'StringLiteral("$value")';
}

/// Boolean literal: true / false
class BoolLiteral extends ASTNode {
  final bool value;
  BoolLiteral(this.value);

  @override
  String toString() => 'BoolLiteral($value)';
}

/// Variable reference: x
class IdentifierNode extends ASTNode {
  final String name;
  IdentifierNode(this.name);

  @override
  String toString() => 'IdentifierNode($name)';
}

/// Binary expression: left op right
class BinaryExpr extends ASTNode {
  final ASTNode left;
  final String op;
  final ASTNode right;
  BinaryExpr(this.left, this.op, this.right);

  @override
  String toString() => 'BinaryExpr($left $op $right)';
}

/// Unary expression: !flag, -x
class UnaryExpr extends ASTNode {
  final String op;
  final ASTNode operand;
  UnaryExpr(this.op, this.operand);

  @override
  String toString() => 'UnaryExpr($op $operand)';
}

/// Variable assignment: x = expr
class AssignNode extends ASTNode {
  final String identifier;
  final ASTNode value;
  AssignNode(this.identifier, this.value);

  @override
  String toString() => 'AssignNode($identifier, $value)';
}

/// Print statement: print(expr)
class PrintNode extends ASTNode {
  final ASTNode expression;
  PrintNode(this.expression);

  @override
  String toString() => 'PrintNode($expression)';
}

/// If / else: if (cond) { ... } else { ... }
class IfNode extends ASTNode {
  final ASTNode condition;
  final List<ASTNode> thenBranch;
  final List<ASTNode>? elseBranch;
  IfNode(this.condition, this.thenBranch, [this.elseBranch]);

  @override
  String toString() =>
      'IfNode($condition, then: $thenBranch, else: $elseBranch)';
}

/// While loop: while (cond) { ... }
class WhileNode extends ASTNode {
  final ASTNode condition;
  final List<ASTNode> body;
  WhileNode(this.condition, this.body);

  @override
  String toString() => 'WhileNode($condition, $body)';
}

/// Function declaration: fn name(params) { body }
class FnDeclNode extends ASTNode {
  final String name;
  final List<String> params;
  final List<ASTNode> body;
  FnDeclNode(this.name, this.params, this.body);

  @override
  String toString() => 'FnDeclNode($name, $params, $body)';
}

/// Return statement: return expr
class ReturnNode extends ASTNode {
  final ASTNode? value;
  ReturnNode([this.value]);

  @override
  String toString() => 'ReturnNode($value)';
}

/// Function call: name(args)
class FnCallNode extends ASTNode {
  final String name;
  final List<ASTNode> args;
  FnCallNode(this.name, this.args);

  @override
  String toString() => 'FnCallNode($name, $args)';
}

// ── Compiler ─────────────────────────────────────────────────

/// The MicroLang compiler.
///
/// Provides a three-stage compilation pipeline:
/// 1. **Lexer** ([lexer]) — tokenizes source code
/// 2. **Parser** ([parser]) — builds an abstract syntax tree
/// 3. **Code Generator** ([codeGenerator]) — emits JavaScript
///
/// ```dart
/// final compiler = SimpleCompiler();
/// final tokens = compiler.lexer(source);
/// final ast = compiler.parser(tokens);
/// final js = compiler.codeGenerator(ast);
/// ```
class SimpleCompiler {
  // ── Lexer ────────────────────────────────────────────────

  /// Tokenizes [sourceCode] into a list of [Token]s.
  ///
  /// The lexer handles integers, floats, strings (with escape sequences),
  /// booleans, identifiers, keywords, operators, and single-line comments.
  ///
  /// Throws [FormatException] on unexpected characters or unterminated strings.
  List<Token> lexer(String sourceCode) {
    List<Token> tokens = [];
    int i = 0;
    int len = sourceCode.length;

    while (i < len) {
      // Skip whitespace
      if (_isWhitespace(sourceCode[i])) {
        i++;
        continue;
      }

      // Skip single-line comments: // ...
      if (i + 1 < len && sourceCode[i] == '/' && sourceCode[i + 1] == '/') {
        while (i < len && sourceCode[i] != '\n') {
          i++;
        }
        continue;
      }

      // String literals
      if (sourceCode[i] == '"') {
        i++; // skip opening "
        StringBuffer sb = StringBuffer();
        while (i < len && sourceCode[i] != '"') {
          if (sourceCode[i] == '\\' && i + 1 < len) {
            i++;
            switch (sourceCode[i]) {
              case 'n':
                sb.write('\n');
                break;
              case 't':
                sb.write('\t');
                break;
              case '\\':
                sb.write('\\');
                break;
              case '"':
                sb.write('"');
                break;
              default:
                sb.write('\\');
                sb.write(sourceCode[i]);
            }
          } else {
            sb.write(sourceCode[i]);
          }
          i++;
        }
        if (i >= len) {
          throw FormatException('Unterminated string literal');
        }
        i++; // skip closing "
        tokens.add(Token(TokenType.STRING, sb.toString()));
        continue;
      }

      // Numbers (int and float)
      if (_isDigit(sourceCode[i])) {
        StringBuffer sb = StringBuffer();
        bool isFloat = false;
        while (i < len && _isDigit(sourceCode[i])) {
          sb.write(sourceCode[i]);
          i++;
        }
        if (i < len && sourceCode[i] == '.' && i + 1 < len && _isDigit(sourceCode[i + 1])) {
          isFloat = true;
          sb.write('.');
          i++;
          while (i < len && _isDigit(sourceCode[i])) {
            sb.write(sourceCode[i]);
            i++;
          }
        }
        tokens.add(Token(
          isFloat ? TokenType.FLOAT : TokenType.NUMBER,
          sb.toString(),
        ));
        continue;
      }

      // Identifiers and keywords
      if (_isAlpha(sourceCode[i])) {
        StringBuffer sb = StringBuffer();
        while (i < len && _isAlphaNumeric(sourceCode[i])) {
          sb.write(sourceCode[i]);
          i++;
        }
        String word = sb.toString();
        TokenType type;
        switch (word) {
          case 'if':
            type = TokenType.IF;
            break;
          case 'else':
            type = TokenType.ELSE;
            break;
          case 'while':
            type = TokenType.WHILE;
            break;
          case 'print':
            type = TokenType.PRINT;
            break;
          case 'fn':
            type = TokenType.FN;
            break;
          case 'return':
            type = TokenType.RETURN;
            break;
          case 'true':
          case 'false':
            type = TokenType.BOOLEAN;
            break;
          default:
            type = TokenType.IDENTIFIER;
        }
        tokens.add(Token(type, word));
        continue;
      }

      // Multi-character and single-character operators / delimiters
      String c = sourceCode[i];
      String? next = (i + 1 < len) ? sourceCode[i + 1] : null;

      switch (c) {
        case '&':
          if (next == '&') {
            tokens.add(Token(TokenType.AND, '&&'));
            i += 2;
          } else {
            throw FormatException('Unexpected character: $c');
          }
          break;
        case '|':
          if (next == '|') {
            tokens.add(Token(TokenType.OR, '||'));
            i += 2;
          } else {
            throw FormatException('Unexpected character: $c');
          }
          break;
        case '!':
          if (next == '=') {
            tokens.add(Token(TokenType.COMPARISON, '!='));
            i += 2;
          } else {
            tokens.add(Token(TokenType.NOT, '!'));
            i++;
          }
          break;
        case '=':
          if (next == '=') {
            tokens.add(Token(TokenType.COMPARISON, '=='));
            i += 2;
          } else {
            tokens.add(Token(TokenType.ASSIGN, '='));
            i++;
          }
          break;
        case '<':
          if (next == '=') {
            tokens.add(Token(TokenType.COMPARISON, '<='));
            i += 2;
          } else {
            tokens.add(Token(TokenType.COMPARISON, '<'));
            i++;
          }
          break;
        case '>':
          if (next == '=') {
            tokens.add(Token(TokenType.COMPARISON, '>='));
            i += 2;
          } else {
            tokens.add(Token(TokenType.COMPARISON, '>'));
            i++;
          }
          break;
        case '+':
        case '-':
        case '*':
        case '/':
          tokens.add(Token(TokenType.OPERATOR, c));
          i++;
          break;
        case '(':
          tokens.add(Token(TokenType.LPAREN, '('));
          i++;
          break;
        case ')':
          tokens.add(Token(TokenType.RPAREN, ')'));
          i++;
          break;
        case '{':
          tokens.add(Token(TokenType.LBRACE, '{'));
          i++;
          break;
        case '}':
          tokens.add(Token(TokenType.RBRACE, '}'));
          i++;
          break;
        case ',':
          tokens.add(Token(TokenType.COMMA, ','));
          i++;
          break;
        default:
          throw FormatException('Unexpected character: $c');
      }
    }

    tokens.add(Token(TokenType.EOF, ''));
    return tokens;
  }

  bool _isWhitespace(String c) => c == ' ' || c == '\t' || c == '\n' || c == '\r';
  bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
  bool _isAlpha(String c) {
    int code = c.codeUnitAt(0);
    return (code >= 65 && code <= 90) ||
        (code >= 97 && code <= 122) ||
        c == '_';
  }
  bool _isAlphaNumeric(String c) => _isAlpha(c) || _isDigit(c);

  // ── Parser (Recursive Descent) ──────────────────────────

  late List<Token> _tokens;
  late int _pos;

  Token _peek() => _tokens[_pos];
  Token _advance() => _tokens[_pos++];

  Token _expect(TokenType type, [String? message]) {
    if (_peek().type != type) {
      throw FormatException(
          message ?? 'Expected $type but got ${_peek().type} (${_peek().value})');
    }
    return _advance();
  }

  bool _match(TokenType type, [String? value]) {
    if (_peek().type == type && (value == null || _peek().value == value)) {
      return true;
    }
    return false;
  }

  /// Parses [tokens] into an abstract syntax tree (list of statement nodes).
  ///
  /// Uses recursive descent with operator precedence climbing.
  /// Supports assignment, print, if/else, while, function declarations,
  /// return statements, and expression statements.
  ///
  /// Throws [FormatException] on syntax errors.
  List<ASTNode> parser(List<Token> tokens) {
    _tokens = tokens;
    _pos = 0;
    List<ASTNode> statements = [];

    while (!_match(TokenType.EOF)) {
      statements.add(_parseStatement());
    }

    return statements;
  }

  ASTNode _parseStatement() {
    // print(...)
    if (_match(TokenType.PRINT)) {
      return _parsePrint();
    }

    // if (...)
    if (_match(TokenType.IF)) {
      return _parseIf();
    }

    // while (...)
    if (_match(TokenType.WHILE)) {
      return _parseWhile();
    }

    // fn name(...)
    if (_match(TokenType.FN)) {
      return _parseFnDecl();
    }

    // return ...
    if (_match(TokenType.RETURN)) {
      return _parseReturn();
    }

    // identifier = expr  (assignment) OR expression statement
    if (_match(TokenType.IDENTIFIER)) {
      // Look ahead: if next token is '=', it's an assignment
      if (_pos + 1 < _tokens.length && _tokens[_pos + 1].type == TokenType.ASSIGN) {
        return _parseAssign();
      }
      // Otherwise fall through to expression statement (e.g., function call)
    }

    // Expression statement (e.g., standalone function call)
    ASTNode expr = _parseExpression();
    return expr;
  }

  ASTNode _parsePrint() {
    _advance(); // consume 'print'
    _expect(TokenType.LPAREN, 'Expected "(" after print');
    ASTNode expr = _parseExpression();
    _expect(TokenType.RPAREN, 'Expected ")" after print expression');
    return PrintNode(expr);
  }

  ASTNode _parseAssign() {
    String name = _advance().value; // consume identifier
    _advance(); // consume '='
    ASTNode value = _parseExpression();
    return AssignNode(name, value);
  }

  ASTNode _parseIf() {
    _advance(); // consume 'if'
    _expect(TokenType.LPAREN, 'Expected "(" after if');
    ASTNode condition = _parseExpression();
    _expect(TokenType.RPAREN, 'Expected ")" after if condition');
    List<ASTNode> thenBranch = _parseBlock();

    List<ASTNode>? elseBranch;
    if (_match(TokenType.ELSE)) {
      _advance(); // consume 'else'
      elseBranch = _parseBlock();
    }

    return IfNode(condition, thenBranch, elseBranch);
  }

  ASTNode _parseWhile() {
    _advance(); // consume 'while'
    _expect(TokenType.LPAREN, 'Expected "(" after while');
    ASTNode condition = _parseExpression();
    _expect(TokenType.RPAREN, 'Expected ")" after while condition');
    List<ASTNode> body = _parseBlock();
    return WhileNode(condition, body);
  }

  ASTNode _parseFnDecl() {
    _advance(); // consume 'fn'
    String name = _expect(TokenType.IDENTIFIER, 'Expected function name').value;
    _expect(TokenType.LPAREN, 'Expected "(" after function name');

    List<String> params = [];
    if (!_match(TokenType.RPAREN)) {
      params.add(_expect(TokenType.IDENTIFIER, 'Expected parameter name').value);
      while (_match(TokenType.COMMA)) {
        _advance(); // consume ','
        params.add(_expect(TokenType.IDENTIFIER, 'Expected parameter name').value);
      }
    }
    _expect(TokenType.RPAREN, 'Expected ")" after parameters');

    List<ASTNode> body = _parseBlock();
    return FnDeclNode(name, params, body);
  }

  ASTNode _parseReturn() {
    _advance(); // consume 'return'
    // If the next token starts a new statement or is '}', return void
    if (_match(TokenType.RBRACE) ||
        _match(TokenType.EOF) ||
        _match(TokenType.PRINT) ||
        _match(TokenType.IF) ||
        _match(TokenType.WHILE) ||
        _match(TokenType.FN) ||
        _match(TokenType.RETURN)) {
      return ReturnNode();
    }
    ASTNode value = _parseExpression();
    return ReturnNode(value);
  }

  List<ASTNode> _parseBlock() {
    _expect(TokenType.LBRACE, 'Expected "{"');
    List<ASTNode> statements = [];
    while (!_match(TokenType.RBRACE) && !_match(TokenType.EOF)) {
      statements.add(_parseStatement());
    }
    _expect(TokenType.RBRACE, 'Expected "}"');
    return statements;
  }

  // ── Expression parsing (precedence climbing) ────────────

  ASTNode _parseExpression() {
    return _parseOr();
  }

  ASTNode _parseOr() {
    ASTNode left = _parseAnd();
    while (_match(TokenType.OR)) {
      String op = _advance().value;
      ASTNode right = _parseAnd();
      left = BinaryExpr(left, op, right);
    }
    return left;
  }

  ASTNode _parseAnd() {
    ASTNode left = _parseEquality();
    while (_match(TokenType.AND)) {
      String op = _advance().value;
      ASTNode right = _parseEquality();
      left = BinaryExpr(left, op, right);
    }
    return left;
  }

  ASTNode _parseEquality() {
    ASTNode left = _parseComparison();
    while (_match(TokenType.COMPARISON) &&
        (_peek().value == '==' || _peek().value == '!=')) {
      String op = _advance().value;
      ASTNode right = _parseComparison();
      left = BinaryExpr(left, op, right);
    }
    return left;
  }

  ASTNode _parseComparison() {
    ASTNode left = _parseAddition();
    while (_match(TokenType.COMPARISON) &&
        (_peek().value == '<' ||
            _peek().value == '>' ||
            _peek().value == '<=' ||
            _peek().value == '>=')) {
      String op = _advance().value;
      ASTNode right = _parseAddition();
      left = BinaryExpr(left, op, right);
    }
    return left;
  }

  ASTNode _parseAddition() {
    ASTNode left = _parseMultiplication();
    while (_match(TokenType.OPERATOR) &&
        (_peek().value == '+' || _peek().value == '-')) {
      String op = _advance().value;
      ASTNode right = _parseMultiplication();
      left = BinaryExpr(left, op, right);
    }
    return left;
  }

  ASTNode _parseMultiplication() {
    ASTNode left = _parseUnary();
    while (_match(TokenType.OPERATOR) &&
        (_peek().value == '*' || _peek().value == '/')) {
      String op = _advance().value;
      ASTNode right = _parseUnary();
      left = BinaryExpr(left, op, right);
    }
    return left;
  }

  ASTNode _parseUnary() {
    if (_match(TokenType.NOT)) {
      String op = _advance().value;
      ASTNode operand = _parseUnary();
      return UnaryExpr(op, operand);
    }
    if (_match(TokenType.OPERATOR) && _peek().value == '-') {
      String op = _advance().value;
      ASTNode operand = _parseUnary();
      return UnaryExpr(op, operand);
    }
    return _parsePrimary();
  }

  ASTNode _parsePrimary() {
    Token token = _peek();

    switch (token.type) {
      case TokenType.NUMBER:
        _advance();
        return NumberLiteral(int.parse(token.value));

      case TokenType.FLOAT:
        _advance();
        return FloatLiteral(double.parse(token.value));

      case TokenType.STRING:
        _advance();
        return StringLiteral(token.value);

      case TokenType.BOOLEAN:
        _advance();
        return BoolLiteral(token.value == 'true');

      case TokenType.IDENTIFIER:
        _advance();
        // Check if this is a function call: identifier(
        if (_match(TokenType.LPAREN)) {
          _advance(); // consume '('
          List<ASTNode> args = [];
          if (!_match(TokenType.RPAREN)) {
            args.add(_parseExpression());
            while (_match(TokenType.COMMA)) {
              _advance(); // consume ','
              args.add(_parseExpression());
            }
          }
          _expect(TokenType.RPAREN, 'Expected ")" after function arguments');
          return FnCallNode(token.value, args);
        }
        return IdentifierNode(token.value);

      case TokenType.LPAREN:
        _advance(); // consume '('
        ASTNode expr = _parseExpression();
        _expect(TokenType.RPAREN, 'Expected ")"');
        return expr;

      default:
        throw FormatException(
            'Unexpected token in expression: ${token.type} (${token.value})');
    }
  }

  // ── Code Generator (JavaScript) ─────────────────────────

  /// Generates JavaScript source code from [ast].
  ///
  /// Tracks variable declarations to emit `let` only on the first assignment
  /// of each variable. Subsequent assignments use plain reassignment.
  ///
  /// Returns the generated JavaScript as a [String].
  String codeGenerator(List<ASTNode> ast) {
    Set<String> declaredVars = {};
    StringBuffer output = StringBuffer();
    _generateStatements(ast, output, declaredVars, '');
    return output.toString();
  }

  void _generateStatements(
    List<ASTNode> statements,
    StringBuffer output,
    Set<String> declaredVars,
    String indent,
  ) {
    for (var node in statements) {
      _generateStatement(node, output, declaredVars, indent);
    }
  }

  void _generateStatement(
    ASTNode node,
    StringBuffer output,
    Set<String> declaredVars,
    String indent,
  ) {
    if (node is AssignNode) {
      String keyword = declaredVars.contains(node.identifier) ? '' : 'let ';
      declaredVars.add(node.identifier);
      output.writeln('$indent$keyword${node.identifier} = ${_generateExpr(node.value)};');
    } else if (node is PrintNode) {
      output.writeln('${indent}console.log(${_generateExpr(node.expression)});');
    } else if (node is IfNode) {
      output.writeln('${indent}if (${_generateExpr(node.condition)}) {');
      _generateStatements(node.thenBranch, output, declaredVars, '$indent  ');
      if (node.elseBranch != null) {
        output.writeln('$indent} else {');
        _generateStatements(node.elseBranch!, output, declaredVars, '$indent  ');
      }
      output.writeln('$indent}');
    } else if (node is WhileNode) {
      output.writeln('${indent}while (${_generateExpr(node.condition)}) {');
      _generateStatements(node.body, output, declaredVars, '$indent  ');
      output.writeln('$indent}');
    } else if (node is FnDeclNode) {
      output.writeln('${indent}function ${node.name}(${node.params.join(', ')}) {');
      _generateStatements(node.body, output, declaredVars, '$indent  ');
      output.writeln('$indent}');
    } else if (node is ReturnNode) {
      if (node.value != null) {
        output.writeln('${indent}return ${_generateExpr(node.value!)};');
      } else {
        output.writeln('${indent}return;');
      }
    } else if (node is FnCallNode) {
      // Expression statement (standalone function call)
      output.writeln('$indent${_generateExpr(node)};');
    } else {
      // Generic expression statement
      output.writeln('$indent${_generateExpr(node)};');
    }
  }

  String _generateExpr(ASTNode node) {
    if (node is NumberLiteral) {
      return '${node.value}';
    } else if (node is FloatLiteral) {
      return '${node.value}';
    } else if (node is StringLiteral) {
      // Escape special characters for JS output
      String escaped = node.value
          .replaceAll('\\', '\\\\')
          .replaceAll('"', '\\"')
          .replaceAll('\n', '\\n')
          .replaceAll('\t', '\\t');
      return '"$escaped"';
    } else if (node is BoolLiteral) {
      return '${node.value}';
    } else if (node is IdentifierNode) {
      return node.name;
    } else if (node is BinaryExpr) {
      return '(${_generateExpr(node.left)} ${node.op} ${_generateExpr(node.right)})';
    } else if (node is UnaryExpr) {
      return '(${node.op}${_generateExpr(node.operand)})';
    } else if (node is FnCallNode) {
      List<String> argStrs = node.args.map(_generateExpr).toList();
      return '${node.name}(${argStrs.join(', ')})';
    } else {
      throw FormatException('Unknown AST node type: ${node.runtimeType}');
    }
  }
}