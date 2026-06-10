## 2.0.0

Major release — MicroLang is now a full-featured language.

### Added
- **Multiple types**: float (`3.14`), string (`"hello"`), boolean (`true`/`false`) literals
- **Arithmetic expressions**: `+`, `-`, `*`, `/` with proper operator precedence
- **Comparison operators**: `==`, `!=`, `<`, `>`, `<=`, `>=`
- **Logical operators**: `&&`, `||`, `!`
- **Control structures**: `if`/`else` conditionals, `while` loops
- **Functions**: `fn` declarations with parameters, `return` statements, function calls
- **Unary operators**: negation (`-x`), logical not (`!flag`)
- **Parenthesized expressions**: `(2 + 3) * 4`
- **Single-line comments**: `// comment`
- **String escape sequences**: `\n`, `\t`, `\\`, `\"`
- **CLI file input**: `microlang program.ml` to compile from file
- **CLI flags**: `--help`, `--tokens`, `--ast`, `--output`
- **Comprehensive test suite**: 44 tests covering lexer, parser, code generator, and error handling

### Changed
- Rewrote lexer from regex-based to character-by-character scanner
- Rewrote parser from index-based to recursive descent with precedence climbing
- `AssignNode` now holds an expression tree (not just an `int`)
- `PrintNode` now holds an expression tree (not just a `String`)
- Code generator tracks declared variables (`let` on first use only)
- `bin/microlang.dart` now imports from `lib/` (no duplicated classes)

### Fixed
- Library and binary were completely independent copies — now properly separated

## 1.0.0

- Initial version.
