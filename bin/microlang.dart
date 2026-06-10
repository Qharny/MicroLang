import 'dart:io';
import 'package:args/args.dart';
import 'package:microlang/microlang.dart';

const String version = '2.0.0';

void main(List<String> arguments) {
  final argParser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage information')
    ..addFlag('version', abbr: 'v', negatable: false, help: 'Show version')
    ..addFlag('tokens', abbr: 't', negatable: false, help: 'Print lexer tokens')
    ..addFlag('ast', abbr: 'a', negatable: false, help: 'Print the AST')
    ..addOption('output', abbr: 'o', help: 'Write generated code to a file');

  ArgResults args;
  try {
    args = argParser.parse(arguments);
  } catch (e) {
    stderr.writeln('Error: $e');
    stderr.writeln();
    _printUsage(argParser);
    exit(1);
  }

  if (args['help'] as bool) {
    _printUsage(argParser);
    return;
  }

  if (args['version'] as bool) {
    print('MicroLang v$version');
    return;
  }

  // Determine source code input
  String sourceCode;
  String? sourceFile;

  if (args.rest.isNotEmpty) {
    // Read from file
    sourceFile = args.rest.first;
    final file = File(sourceFile);
    if (!file.existsSync()) {
      stderr.writeln('Error: File not found: $sourceFile');
      exit(1);
    }
    sourceCode = file.readAsStringSync();
  } else {
    // Interactive mode — read from stdin
    print('MicroLang Compiler v$version');
    print('Enter your code (type "END" on a new line to finish):');
    print('');
    List<String> lines = [];
    while (true) {
      String? line = stdin.readLineSync();
      if (line == 'END') break;
      if (line != null) lines.add(line);
    }
    sourceCode = lines.join('\n');
  }

  if (sourceCode.trim().isEmpty) {
    stderr.writeln('Error: No source code provided.');
    exit(1);
  }

  // Compile
  final compiler = SimpleCompiler();
  try {
    final tokens = compiler.lexer(sourceCode);
    if (args['tokens'] as bool) {
      print('── Tokens ──');
      for (var token in tokens) {
        if (token.type != TokenType.EOF) print('  $token');
      }
      print('');
    }

    final ast = compiler.parser(tokens);
    if (args['ast'] as bool) {
      print('── AST ──');
      for (var node in ast) {
        print('  $node');
      }
      print('');
    }

    final output = compiler.codeGenerator(ast);

    // Output
    final outputPath = args['output'] as String?;
    if (outputPath != null) {
      File(outputPath).writeAsStringSync(output);
      print('✓ Compiled ${sourceFile ?? 'input'} → $outputPath');
    } else {
      if (args['tokens'] as bool || args['ast'] as bool) {
        print('── Generated JavaScript ──');
      }
      print(output);
    }
  } on FormatException catch (e) {
    stderr.writeln('Compilation Error: ${e.message}');
    exit(1);
  } catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  }
}

void _printUsage(ArgParser parser) {
  print('MicroLang Compiler v$version');
  print('A minimalist language that compiles to JavaScript.\n');
  print('Usage:');
  print('  microlang [options] [file.ml]');
  print('  microlang                     Interactive mode (type END to finish)');
  print('  microlang program.ml          Compile a file');
  print('  microlang program.ml -o out.js  Compile to a file');
  print('');
  print('Options:');
  print(parser.usage);
  print('');
  print('Examples:');
  print('  microlang hello.ml                  Print generated JS to stdout');
  print('  microlang hello.ml -o hello.js      Write generated JS to hello.js');
  print('  microlang hello.ml --tokens --ast   Show tokens and AST');
  print('  microlang -v                        Show version');
}