import 'package:microlang/microlang.dart';
import 'package:test/test.dart';

void main() {
  late SimpleCompiler compiler;

  setUp(() {
    compiler = SimpleCompiler();
  });

  // ── Helper ──────────────────────────────────────────────

  /// Lex → Parse → Generate in one step.
  String compile(String source) {
    final tokens = compiler.lexer(source);
    final ast = compiler.parser(tokens);
    return compiler.codeGenerator(ast);
  }

  // ── Lexer Tests ─────────────────────────────────────────

  group('Lexer', () {
    test('tokenizes integers', () {
      final tokens = compiler.lexer('42');
      expect(tokens[0].type, TokenType.NUMBER);
      expect(tokens[0].value, '42');
    });

    test('tokenizes floats', () {
      final tokens = compiler.lexer('3.14');
      expect(tokens[0].type, TokenType.FLOAT);
      expect(tokens[0].value, '3.14');
    });

    test('tokenizes strings', () {
      final tokens = compiler.lexer('"hello world"');
      expect(tokens[0].type, TokenType.STRING);
      expect(tokens[0].value, 'hello world');
    });

    test('tokenizes booleans', () {
      final tokens = compiler.lexer('true false');
      expect(tokens[0].type, TokenType.BOOLEAN);
      expect(tokens[0].value, 'true');
      expect(tokens[1].type, TokenType.BOOLEAN);
      expect(tokens[1].value, 'false');
    });

    test('tokenizes comparison operators', () {
      final tokens = compiler.lexer('== != < > <= >=');
      expect(tokens.where((t) => t.type == TokenType.COMPARISON).length, 6);
      expect(tokens[0].value, '==');
      expect(tokens[1].value, '!=');
      expect(tokens[2].value, '<');
      expect(tokens[3].value, '>');
      expect(tokens[4].value, '<=');
      expect(tokens[5].value, '>=');
    });

    test('tokenizes logical operators', () {
      final tokens = compiler.lexer('&& || !');
      expect(tokens[0].type, TokenType.AND);
      expect(tokens[1].type, TokenType.OR);
      expect(tokens[2].type, TokenType.NOT);
    });

    test('tokenizes keywords', () {
      final tokens = compiler.lexer('if else while fn return print');
      expect(tokens[0].type, TokenType.IF);
      expect(tokens[1].type, TokenType.ELSE);
      expect(tokens[2].type, TokenType.WHILE);
      expect(tokens[3].type, TokenType.FN);
      expect(tokens[4].type, TokenType.RETURN);
      expect(tokens[5].type, TokenType.PRINT);
    });

    test('tokenizes braces and comma', () {
      final tokens = compiler.lexer('{ } ,');
      expect(tokens[0].type, TokenType.LBRACE);
      expect(tokens[1].type, TokenType.RBRACE);
      expect(tokens[2].type, TokenType.COMMA);
    });

    test('skips comments', () {
      final tokens = compiler.lexer('x = 5 // this is a comment\ny = 10');
      // Should have: x = 5 y = 10 EOF
      final nonEof = tokens.where((t) => t.type != TokenType.EOF).toList();
      expect(nonEof.length, 6); // x = 5 y = 10
    });

    test('handles unterminated string', () {
      expect(
        () => compiler.lexer('"hello'),
        throwsA(isA<FormatException>()),
      );
    });

    test('simple assignment and print', () {
      final tokens = compiler.lexer('x = 5\nprint(x)');
      final nonEof = tokens.where((t) => t.type != TokenType.EOF).toList();
      expect(nonEof.length, 7);
      expect(nonEof[0].type, TokenType.IDENTIFIER);
      expect(nonEof[1].type, TokenType.ASSIGN);
      expect(nonEof[2].type, TokenType.NUMBER);
      expect(nonEof[3].type, TokenType.PRINT);
      expect(nonEof[4].type, TokenType.LPAREN);
      expect(nonEof[5].type, TokenType.IDENTIFIER);
      expect(nonEof[6].type, TokenType.RPAREN);
    });
  });

  // ── Parser Tests ────────────────────────────────────────

  group('Parser', () {
    test('parses assignment with expression', () {
      final tokens = compiler.lexer('x = 2 + 3');
      final ast = compiler.parser(tokens);
      expect(ast.length, 1);
      expect(ast[0], isA<AssignNode>());
      final assign = ast[0] as AssignNode;
      expect(assign.identifier, 'x');
      expect(assign.value, isA<BinaryExpr>());
    });

    test('parses operator precedence (* before +)', () {
      final tokens = compiler.lexer('x = 2 + 3 * 4');
      final ast = compiler.parser(tokens);
      final assign = ast[0] as AssignNode;
      final expr = assign.value as BinaryExpr;
      // Should be: 2 + (3 * 4)
      expect(expr.op, '+');
      expect(expr.left, isA<NumberLiteral>());
      expect(expr.right, isA<BinaryExpr>());
      final mult = expr.right as BinaryExpr;
      expect(mult.op, '*');
    });

    test('parses parenthesized expressions', () {
      final tokens = compiler.lexer('x = (2 + 3) * 4');
      final ast = compiler.parser(tokens);
      final assign = ast[0] as AssignNode;
      final expr = assign.value as BinaryExpr;
      // Should be: (2 + 3) * 4
      expect(expr.op, '*');
      expect(expr.left, isA<BinaryExpr>());
      expect(expr.right, isA<NumberLiteral>());
    });

    test('parses if/else', () {
      final tokens = compiler.lexer('if (x > 3) { print(x) } else { print(0) }');
      final ast = compiler.parser(tokens);
      expect(ast.length, 1);
      expect(ast[0], isA<IfNode>());
      final ifNode = ast[0] as IfNode;
      expect(ifNode.condition, isA<BinaryExpr>());
      expect(ifNode.thenBranch.length, 1);
      expect(ifNode.elseBranch, isNotNull);
      expect(ifNode.elseBranch!.length, 1);
    });

    test('parses while', () {
      final tokens = compiler.lexer('while (x > 0) { x = x - 1 }');
      final ast = compiler.parser(tokens);
      expect(ast.length, 1);
      expect(ast[0], isA<WhileNode>());
      final whileNode = ast[0] as WhileNode;
      expect(whileNode.condition, isA<BinaryExpr>());
      expect(whileNode.body.length, 1);
    });

    test('parses function declaration', () {
      final tokens = compiler.lexer('fn add(a, b) { return a + b }');
      final ast = compiler.parser(tokens);
      expect(ast.length, 1);
      expect(ast[0], isA<FnDeclNode>());
      final fn = ast[0] as FnDeclNode;
      expect(fn.name, 'add');
      expect(fn.params, ['a', 'b']);
      expect(fn.body.length, 1);
      expect(fn.body[0], isA<ReturnNode>());
    });

    test('parses function call in expression', () {
      final tokens = compiler.lexer('x = add(2, 3)');
      final ast = compiler.parser(tokens);
      final assign = ast[0] as AssignNode;
      expect(assign.value, isA<FnCallNode>());
      final call = assign.value as FnCallNode;
      expect(call.name, 'add');
      expect(call.args.length, 2);
    });

    test('parses unary negation', () {
      final tokens = compiler.lexer('x = -5');
      final ast = compiler.parser(tokens);
      final assign = ast[0] as AssignNode;
      expect(assign.value, isA<UnaryExpr>());
    });

    test('parses unary not', () {
      final tokens = compiler.lexer('x = !true');
      final ast = compiler.parser(tokens);
      final assign = ast[0] as AssignNode;
      expect(assign.value, isA<UnaryExpr>());
      final unary = assign.value as UnaryExpr;
      expect(unary.op, '!');
    });

    test('parses logical operators', () {
      final tokens = compiler.lexer('x = a && b || c');
      final ast = compiler.parser(tokens);
      final assign = ast[0] as AssignNode;
      // || has lower precedence than &&, so: (a && b) || c
      final orExpr = assign.value as BinaryExpr;
      expect(orExpr.op, '||');
      expect(orExpr.left, isA<BinaryExpr>());
      final andExpr = orExpr.left as BinaryExpr;
      expect(andExpr.op, '&&');
    });

    test('parses string assignment', () {
      final tokens = compiler.lexer('name = "hello"');
      final ast = compiler.parser(tokens);
      final assign = ast[0] as AssignNode;
      expect(assign.value, isA<StringLiteral>());
      expect((assign.value as StringLiteral).value, 'hello');
    });

    test('parses float assignment', () {
      final tokens = compiler.lexer('pi = 3.14');
      final ast = compiler.parser(tokens);
      final assign = ast[0] as AssignNode;
      expect(assign.value, isA<FloatLiteral>());
      expect((assign.value as FloatLiteral).value, 3.14);
    });

    test('parses boolean assignment', () {
      final tokens = compiler.lexer('flag = true');
      final ast = compiler.parser(tokens);
      final assign = ast[0] as AssignNode;
      expect(assign.value, isA<BoolLiteral>());
      expect((assign.value as BoolLiteral).value, true);
    });
  });

  // ── Code Generator Tests ────────────────────────────────

  group('Code Generator', () {
    test('generates integer assignment', () {
      final output = compile('x = 5');
      expect(output.trim(), 'let x = 5;');
    });

    test('generates float assignment', () {
      final output = compile('pi = 3.14');
      expect(output.trim(), 'let pi = 3.14;');
    });

    test('generates string assignment', () {
      final output = compile('name = "hello"');
      expect(output.trim(), 'let name = "hello";');
    });

    test('generates boolean assignment', () {
      final output = compile('flag = true');
      expect(output.trim(), 'let flag = true;');
    });

    test('generates print with expression', () {
      final output = compile('print(5 + 3)');
      expect(output.trim(), 'console.log((5 + 3));');
    });

    test('generates print with string', () {
      final output = compile('print("hello")');
      expect(output.trim(), 'console.log("hello");');
    });

    test('generates arithmetic expression', () {
      final output = compile('x = 2 + 3 * 4');
      expect(output.trim(), 'let x = (2 + (3 * 4));');
    });

    test('generates comparison expression', () {
      final output = compile('x = a > 3');
      expect(output.trim(), 'let x = (a > 3);');
    });

    test('generates logical expression', () {
      final output = compile('x = a && b');
      expect(output.trim(), 'let x = (a && b);');
    });

    test('generates unary expression', () {
      final output = compile('x = !true');
      expect(output.trim(), 'let x = (!true);');
    });

    test('generates if/else', () {
      final output = compile('if (x > 3) { print(x) } else { print(0) }');
      expect(output, contains('if ((x > 3)) {'));
      expect(output, contains('console.log(x);'));
      expect(output, contains('} else {'));
      expect(output, contains('console.log(0);'));
    });

    test('generates while loop', () {
      final output = compile('while (x > 0) { x = x - 1 }');
      expect(output, contains('while ((x > 0)) {'));
      expect(output, contains('x = (x - 1);'));
    });

    test('generates function declaration', () {
      final output = compile('fn add(a, b) { return a + b }');
      expect(output, contains('function add(a, b) {'));
      expect(output, contains('return (a + b);'));
    });

    test('generates function call', () {
      final output = compile('x = add(2, 3)');
      expect(output.trim(), 'let x = add(2, 3);');
    });

    test('uses let only on first assignment', () {
      final output = compile('x = 5\nx = 10');
      final lines = output.trim().split('\n');
      expect(lines[0], 'let x = 5;');
      expect(lines[1], 'x = 10;');
    });

    test('generates complex program', () {
      final source = '''
fn factorial(n) {
  if (n <= 1) {
    return 1
  } else {
    return n * factorial(n - 1)
  }
}
result = factorial(5)
print(result)
''';
      final output = compile(source);
      expect(output, contains('function factorial(n) {'));
      expect(output, contains('if ((n <= 1)) {'));
      expect(output, contains('return 1;'));
      expect(output, contains('return (n * factorial((n - 1)));'));
      expect(output, contains('let result = factorial(5);'));
      expect(output, contains('console.log(result);'));
    });
  });

  // ── Error Handling Tests ────────────────────────────────

  group('Error Handling', () {
    test('throws on unexpected character', () {
      expect(() => compiler.lexer('@'), throwsA(isA<FormatException>()));
    });

    test('throws on missing paren after print', () {
      expect(() => compile('print x'), throwsA(isA<FormatException>()));
    });

    test('throws on missing closing brace', () {
      expect(
        () => compile('if (x > 3) { print(x)'),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws on missing closing paren in expression', () {
      expect(() => compile('x = (2 + 3'), throwsA(isA<FormatException>()));
    });
  });
}