# MicroLang Compiler

MicroLang is a minimalist language compiler written in Dart. It demonstrates the basic concepts of lexical analysis, parsing, and code generation.

## Features

- Simple syntax for variable assignment and printing
- Lexical analysis (tokenization)
- Abstract Syntax Tree (AST) generation
- Basic code generation
- Error handling for common syntax errors

## Getting Started

### Prerequisites

- Dart SDK (latest version recommended)
- Visual Studio Code with Dart extension (optional, but recommended)

### Installation

1. Clone this repository or download the source code.
2. Open the project folder in Visual Studio Code.
3. Ensure that the Dart SDK is properly set up in your environment.

### Running the Compiler

1. Open a terminal in the project directory.
2. Run the following command:

   ```
   dart run
   ```

3. Enter your MicroLang code when prompted. Type "END" on a new line when you're finished entering code.

## MicroLang Syntax

MicroLang currently supports two types of statements:

1. Variable assignment:
   ```
   variable_name = number
   ```

2. Printing a variable:
   ```
   print(variable_name)
   ```

### Example

```
x = 5
print(x)
```

## Project Structure

- `main.dart`: Contains the main compiler implementation, including:
  - `SimpleCompiler` class with lexer, parser, and code generator
  - Token and AST node definitions
  - Main function for user interaction

## Limitations

- Only supports integer variables
- No support for expressions or operations
- Limited to assignment and print statements
- No support for control structures or functions

## Future Enhancements

- Add support for arithmetic expressions
- Implement control structures (if/else, loops)
- Add function definitions and calls
- Extend type system to include strings and floating-point numbers
- Implement a proper symbol table for variable management

## Contributing

Contributions to MicroLang are welcome! Please feel free to submit pull requests, report bugs, or suggest new features.

## License

This project is open-source and available under the MIT License.