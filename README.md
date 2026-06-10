# MicroLang

[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](CHANGELOG.md)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](licence)

A minimalist programming language that compiles to JavaScript. Written in Dart.

MicroLang supports **multiple types**, **arithmetic/comparison/logical expressions**, **if/else conditionals**, **while loops**, and **functions with recursion** — all compiled to clean, readable JavaScript.

## Quick Start

### Option 1: Download the binary

Download the latest release from the [Releases](https://github.com/Qharny/MicroLang/releases) page. No Dart SDK required.

```bash
# Compile a file
microlang hello.ml

# Compile and save output
microlang hello.ml -o hello.js

# Interactive mode
microlang
```

### Option 2: Run with Dart

```bash
git clone https://github.com/Qharny/MicroLang.git
cd MicroLang
dart pub get
dart run
```

## Language Overview

```
// Variables — integers, floats, strings, booleans
x = 42
pi = 3.14
name = "MicroLang"
active = true

// Expressions with operator precedence
result = (x + 8) * 2 - pi

// Comparisons and logic
valid = x > 0 && active

// Print any expression
print(result)
print("Hello, World!")

// If / else
if (x > 50) {
  print("big")
} else {
  print("small")
}

// While loops
i = 0
while (i < 5) {
  print(i)
  i = i + 1
}

// Functions
fn factorial(n) {
  if (n <= 1) {
    return 1
  } else {
    return n * factorial(n - 1)
  }
}

print(factorial(5))
```

This compiles to:

```js
let x = 42;
let pi = 3.14;
let name = "MicroLang";
let active = true;
let result = ((x + 8) * 2) - pi);
let valid = ((x > 0) && active);
console.log(result);
console.log("Hello, World!");
if ((x > 50)) {
  console.log("big");
} else {
  console.log("small");
}
let i = 0;
while ((i < 5)) {
  console.log(i);
  i = (i + 1);
}
function factorial(n) {
  if ((n <= 1)) {
    return 1;
  } else {
    return (n * factorial((n - 1)));
  }
}
console.log(factorial(5));
```

## CLI Usage

```
MicroLang Compiler v2.0.0

Usage:
  microlang [options] [file.ml]
  microlang                     Interactive mode (type END to finish)
  microlang program.ml          Compile a file
  microlang program.ml -o out.js  Compile to a file

Options:
  -h, --help       Show usage information
  -v, --version    Show version
  -t, --tokens     Print lexer tokens
  -a, --ast        Print the AST
  -o, --output     Write generated code to a file
```

### Examples

```bash
# Print generated JavaScript to stdout
microlang examples/hello.ml

# Save to a file and run with Node.js
microlang examples/functions.ml -o output.js
node output.js

# Debug: see tokens and AST
microlang examples/hello.ml --tokens --ast
```

## Using as a Library

Add MicroLang to your Dart project:

```yaml
dependencies:
  microlang:
    git:
      url: https://github.com/Qharny/MicroLang.git
```

```dart
import 'package:microlang/microlang.dart';

void main() {
  final compiler = SimpleCompiler();

  final source = 'x = 5\nprint(x + 1)';
  final tokens = compiler.lexer(source);
  final ast = compiler.parser(tokens);
  final js = compiler.codeGenerator(ast);

  print(js);
  // Output:
  // let x = 5;
  // console.log((x + 1));
}
```

## Documentation

- **[Language Reference](doc/language_reference.md)** — complete syntax, types, operators, precedence, grammar
- **[Changelog](CHANGELOG.md)** — version history
- **[Examples](examples/)** — example programs:
  - [`hello.ml`](examples/hello.ml) — Hello World
  - [`variables.ml`](examples/variables.ml) — types and expressions
  - [`control_flow.ml`](examples/control_flow.ml) — if/else and while loops
  - [`functions.ml`](examples/functions.ml) — functions and recursion

## Building from Source

### Run tests

```bash
dart test
```

### Build standalone executable

```bash
dart compile exe bin/microlang.dart -o build/microlang.exe
```

This produces a self-contained binary that can be distributed without the Dart SDK.

### Generate API documentation

```bash
dart doc
```

## Project Structure

```
MicroLang/
├── bin/
│   └── microlang.dart       # CLI entry point
├── lib/
│   └── microlang.dart       # Compiler library (lexer, parser, codegen)
├── test/
│   └── microlang_test.dart  # Test suite (44 tests)
├── examples/
│   ├── hello.ml             # Hello World
│   ├── variables.ml         # Types and expressions
│   ├── control_flow.ml      # If/else and while
│   └── functions.ml         # Functions and recursion
├── doc/
│   └── language_reference.md # Complete language reference
├── pubspec.yaml
├── CHANGELOG.md
├── README.md
└── licence
```

## Contributing

Contributions to MicroLang are welcome! Please feel free to submit pull requests, report bugs, or suggest new features.

## License

This project is open-source and available under the [MIT License](licence).