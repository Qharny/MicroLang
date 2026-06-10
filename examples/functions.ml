// MicroLang Example: Functions
// Demonstrates function declarations, calls, and recursion

// Simple function
fn greet(name) {
  print("Hello")
  print(name)
}

greet("World")

// Function with return value
fn add(a, b) {
  return a + b
}

result = add(10, 20)
print(result)

// Function with conditional logic
fn max(a, b) {
  if (a > b) {
    return a
  } else {
    return b
  }
}

bigger = max(42, 17)
print(bigger)

// Recursive function — factorial
fn factorial(n) {
  if (n <= 1) {
    return 1
  } else {
    return n * factorial(n - 1)
  }
}

fact5 = factorial(5)
print(fact5)

// Recursive function — fibonacci
fn fib(n) {
  if (n <= 0) {
    return 0
  }
  if (n == 1) {
    return 1
  }
  return fib(n - 1) + fib(n - 2)
}

fib10 = fib(10)
print(fib10)
