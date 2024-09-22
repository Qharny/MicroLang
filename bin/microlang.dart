import 'dart:io';

void main() {
  final compiler = SimpleCompiler();
  print('Enter your code (type "END" on a new line to finish):');
  
  List<String> lines = [];
  while (true) {
    String? line = stdin.readLineSync();
    if (line == 'END') break;
    if (line != null) lines.add(line);
  }
  
  String sourceCode = lines.join('\n');
  try {
    List<Token> tokens = compiler.lexer(sourceCode);
    print('Tokens: $tokens');
    
    List<ASTNode> ast = compiler.parser(tokens);
    print('AST: $ast');
    
    String output = compiler.codeGenerator(ast);
    print('Generated code:\n$output');
  } catch (e) {
    print('Error: $e');
  }
}

class SimpleCompiler {
  List<Token> lexer(String sourceCode) {
    List<Token> tokens = [];
    RegExp tokenRegex = RegExp(r'\b(if|else|print)\b|\d+|[a-zA-Z_]\w*|[+\-*/()=]');
    
    for (Match match in tokenRegex.allMatches(sourceCode)) {
      String value = match.group(0)!;
      TokenType type = _getTokenType(value);
      tokens.add(Token(type, value));
    }
    
    return tokens;
  }
  
  TokenType _getTokenType(String value) {
    switch (value) {
      case 'if': return TokenType.IF;
      case 'else': return TokenType.ELSE;
      case 'print': return TokenType.PRINT;
      case '+': case '-': case '*': case '/': return TokenType.OPERATOR;
      case '(': case ')': return TokenType.PAREN;
      case '=': return TokenType.ASSIGN;
      default:
        if (RegExp(r'^\d+$').hasMatch(value)) return TokenType.NUMBER;
        if (RegExp(r'^[a-zA-Z_]\w*$').hasMatch(value)) return TokenType.IDENTIFIER;
        throw FormatException('Unknown token: $value');
    }
  }
  
  List<ASTNode> parser(List<Token> tokens) {
    List<ASTNode> ast = [];
    int i = 0;
    
    while (i < tokens.length) {
      if (tokens[i].type == TokenType.PRINT) {
        i++;
        if (i >= tokens.length || tokens[i].type != TokenType.PAREN || tokens[i].value != '(') {
          throw FormatException('Expected "(" after print');
        }
        i++;
        if (i >= tokens.length || tokens[i].type != TokenType.IDENTIFIER) {
          throw FormatException('Expected identifier after print(');
        }
        String identifier = tokens[i].value;
        i++;
        if (i >= tokens.length || tokens[i].type != TokenType.PAREN || tokens[i].value != ')') {
          throw FormatException('Expected ")" after print(identifier');
        }
        ast.add(PrintNode(identifier));
        i++;
      } else if (tokens[i].type == TokenType.IDENTIFIER) {
        String identifier = tokens[i].value;
        i++;
        if (i >= tokens.length || tokens[i].type != TokenType.ASSIGN) {
          throw FormatException('Expected "=" after identifier');
        }
        i++;
        if (i >= tokens.length || tokens[i].type != TokenType.NUMBER) {
          throw FormatException('Expected number after identifier =');
        }
        int value = int.parse(tokens[i].value);
        ast.add(AssignNode(identifier, value));
        i++;
      } else {
        throw FormatException('Unexpected token: ${tokens[i].value}');
      }
    }
    
    return ast;
  }
  
  String codeGenerator(List<ASTNode> ast) {
    StringBuffer output = StringBuffer();
    
    for (var node in ast) {
      if (node is PrintNode) {
        output.writeln('console.log(${node.identifier});');
      } else if (node is AssignNode) {
        output.writeln('let ${node.identifier} = ${node.value};');
      }
    }
    
    return output.toString();
  }
}

enum TokenType { IF, ELSE, PRINT, NUMBER, IDENTIFIER, OPERATOR, PAREN, ASSIGN }

class Token {
  final TokenType type;
  final String value;
  
  Token(this.type, this.value);
  
  @override
  String toString() => 'Token($type, $value)';
}

abstract class ASTNode {}

class PrintNode extends ASTNode {
  final String identifier;
  PrintNode(this.identifier);
  
  @override
  String toString() => 'PrintNode($identifier)';
}

class AssignNode extends ASTNode {
  final String identifier;
  final int value;
  AssignNode(this.identifier, this.value);
  
  @override
  String toString() => 'AssignNode($identifier, $value)';
}