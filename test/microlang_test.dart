import 'package:microlang/microlang.dart';
import 'package:test/test.dart';

void main() {
  group('SimpleCompiler', () {
    late SimpleCompiler compiler;

    setUp(() {
      compiler = SimpleCompiler();
    });

    test('lexer correctly tokenizes input', () {
      String input = 'x = 5\nprint(x)';
      List<Token> tokens = compiler.lexer(input);
      expect(tokens.length, equals(6));
      expect(tokens[0], isA<Token>().having((t) => t.type, 'type', TokenType.IDENTIFIER).having((t) => t.value, 'value', 'x'));
      expect(tokens[1], isA<Token>().having((t) => t.type, 'type', TokenType.ASSIGN).having((t) => t.value, 'value', '='));
      expect(tokens[2], isA<Token>().having((t) => t.type, 'type', TokenType.NUMBER).having((t) => t.value, 'value', '5'));
      expect(tokens[3], isA<Token>().having((t) => t.type, 'type', TokenType.PRINT).having((t) => t.value, 'value', 'print'));
      expect(tokens[4], isA<Token>().having((t) => t.type, 'type', TokenType.PAREN).having((t) => t.value, 'value', '('));
      expect(tokens[5], isA<Token>().having((t) => t.type, 'type', TokenType.IDENTIFIER).having((t) => t.value, 'value', 'x'));
    });

    test('parser correctly creates AST', () {
      List<Token> tokens = [
        Token(TokenType.IDENTIFIER, 'x'),
        Token(TokenType.ASSIGN, '='),
        Token(TokenType.NUMBER, '5'),
        Token(TokenType.PRINT, 'print'),
        Token(TokenType.PAREN, '('),
        Token(TokenType.IDENTIFIER, 'x'),
        Token(TokenType.PAREN, ')'),
      ];
      List<ASTNode> ast = compiler.parser(tokens);
      expect(ast.length, equals(2));
      expect(ast[0], isA<AssignNode>());
      expect(ast[1], isA<PrintNode>());
    });

    test('codeGenerator produces correct output', () {
      List<ASTNode> ast = [
        AssignNode('x', 5),
        PrintNode('x'),
      ];
      String output = compiler.codeGenerator(ast);
      expect(output, equals('let x = 5;\nconsole.log(x);\n'));
    });
  });
}