// MicroLang Example: Control Flow
// Demonstrates if/else and while loops

// If / else
score = 85

if (score >= 90) {
  print("Grade: A")
} else {
  if (score >= 80) {
    print("Grade: B")
  } else {
    if (score >= 70) {
      print("Grade: C")
    } else {
      print("Grade: F")
    }
  }
}

// While loop — countdown
count = 5
while (count > 0) {
  print(count)
  count = count - 1
}
print("Liftoff!")

// While loop with logical operators
x = 1
while (x < 10 && x != 7) {
  print(x)
  x = x + 1
}
