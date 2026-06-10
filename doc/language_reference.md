# MicroLang Language Reference

This document is the complete reference for the MicroLang programming language.

## Table of Contents

- [Types](#types)
- [Variables](#variables)
- [Operators](#operators)
- [Expressions](#expressions)
- [Statements](#statements)
- [Control Flow](#control-flow)
- [Functions](#functions)
- [Comments](#comments)
- [Grammar](#grammar)

---

## Types

MicroLang supports four value types:

| Type | Examples | Description |
|------|----------|-------------|
| Integer | `0`, `42`, `1000` | Whole numbers |
| Float | `3.14`, `0.5`, `100.0` | Decimal numbers |
| String | `"hello"`, `"MicroLang"` | Text in double quotes |
| Boolean | `true`, `false` | Logical values |

### String Escape Sequences

| Escape | Character |
|--------|-----------|
| `\n` | Newline |
| `\t` | Tab |
| `\\` | Backslash |
| `\"` | Double quote |

---

## Variables

Variables are created by assignment. No declaration keyword is needed — variables are created on first assignment.

```
x = 5
name = "Alice"
pi = 3.14
active = true
```

Variables are dynamically typed — you can reassign a variable to a different type:

```
x = 5
x = "now a string"
```

---

## Operators

### Arithmetic Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `+` | Addition | `x + 5` |
| `-` | Subtraction | `x - 3` |
| `*` | Multiplication | `x * 2` |
| `/` | Division | `x / 4` |
| `-` (unary) | Negation | `-x` |

### Comparison Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `==` | Equal | `x == 5` |
| `!=` | Not equal | `x != 0` |
| `<` | Less than | `x < 10` |
| `>` | Greater than | `x > 0` |
| `<=` | Less or equal | `x <= 100` |
| `>=` | Greater or equal | `x >= 1` |

### Logical Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `&&` | Logical AND | `a && b` |
| `\|\|` | Logical OR | `a \|\| b` |
| `!` | Logical NOT | `!flag` |

### Operator Precedence (highest to lowest)

| Precedence | Operators | Associativity |
|------------|-----------|---------------|
| 1 (highest) | `!`, `-` (unary) | Right |
| 2 | `*`, `/` | Left |
| 3 | `+`, `-` | Left |
| 4 | `<`, `>`, `<=`, `>=` | Left |
| 5 | `==`, `!=` | Left |
| 6 | `&&` | Left |
| 7 (lowest) | `\|\|` | Left |

---

## Expressions

Expressions can be combined and grouped with parentheses:

```
result = (x + y) * 2
check = (a > 0) && (b < 100)
value = -x + 1
```

Function calls are also expressions:

```
result = add(x, y) * 2
```

---

## Statements

### Assignment

```
variable = expression
```

### Print

Outputs the value of any expression:

```
print(42)
print("hello")
print(x + y)
print(myFunction(5))
```

### Expression Statement

Any expression can be used as a statement (useful for function calls):

```
doSomething()
```

---

## Control Flow

### If / Else

```
if (condition) {
  // then branch
}
```

```
if (condition) {
  // then branch
} else {
  // else branch
}
```

Nested if/else for multi-way decisions:

```
if (score >= 90) {
  print("A")
} else {
  if (score >= 80) {
    print("B")
  } else {
    print("C")
  }
}
```

### While Loop

```
while (condition) {
  // body
}
```

Example:

```
i = 0
while (i < 10) {
  print(i)
  i = i + 1
}
```

---

## Functions

### Declaration

```
fn functionName(param1, param2) {
  // body
}
```

### Return Values

```
fn add(a, b) {
  return a + b
}
```

Functions without a `return` statement return `undefined` in the generated JavaScript.

### Calling Functions

```
result = add(2, 3)
print(result)
```

Functions can be called inside expressions:

```
total = add(x, y) + add(a, b)
```

### Recursion

Functions can call themselves:

```
fn factorial(n) {
  if (n <= 1) {
    return 1
  } else {
    return n * factorial(n - 1)
  }
}
```

---

## Comments

Single-line comments start with `//`:

```
// This is a comment
x = 5 // This is an inline comment
```

---

## Grammar

Formal grammar for the MicroLang language in BNF-like notation:

```
program       → statement*

statement     → assignStmt
              | printStmt
              | ifStmt
              | whileStmt
              | fnDecl
              | returnStmt
              | exprStmt

assignStmt    → IDENTIFIER '=' expression
printStmt     → 'print' '(' expression ')'
ifStmt        → 'if' '(' expression ')' block ( 'else' block )?
whileStmt     → 'while' '(' expression ')' block
fnDecl        → 'fn' IDENTIFIER '(' params? ')' block
returnStmt    → 'return' expression?
exprStmt      → expression
block         → '{' statement* '}'
params        → IDENTIFIER ( ',' IDENTIFIER )*

expression    → logicOr
logicOr       → logicAnd ( '||' logicAnd )*
logicAnd      → equality ( '&&' equality )*
equality      → comparison ( ( '==' | '!=' ) comparison )*
comparison    → addition ( ( '<' | '>' | '<=' | '>=' ) addition )*
addition      → multiplication ( ( '+' | '-' ) multiplication )*
multiplication → unary ( ( '*' | '/' ) unary )*
unary         → ( '!' | '-' ) unary | primary
primary       → NUMBER | FLOAT | STRING | BOOLEAN
              | IDENTIFIER ( '(' args? ')' )?
              | '(' expression ')'
args          → expression ( ',' expression )*

NUMBER        → [0-9]+
FLOAT         → [0-9]+ '.' [0-9]+
STRING        → '"' [^"]* '"'
BOOLEAN       → 'true' | 'false'
IDENTIFIER    → [a-zA-Z_][a-zA-Z0-9_]*
```
