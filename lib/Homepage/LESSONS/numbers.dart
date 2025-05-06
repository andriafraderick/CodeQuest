import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'coderunner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const CodeQuestApp());
}

class CodeQuestApp extends StatelessWidget {
  const CodeQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Python Code Runner',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Roboto', fontSize: 16),
        ),
      ),
      home: const Numbers(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Numbers extends StatefulWidget {
  const Numbers({super.key});

  @override
  _NumbersState createState() => _NumbersState();
}

class _NumbersState extends State<Numbers> {
  bool isLessonComplete = false;

  @override
  void initState() {
    super.initState();
    getLessonProgress();
  }

  Future<void> getLessonProgress() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "test_user";
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      setState(() {
        isLessonComplete = data['lessons']?['Numbers and operations'] ?? false;
      });
    }
  }

  void completeLesson(String lessonName) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "test_user";

    FirebaseFirestore.instance.collection('users').doc(userId).set({
      'lessons': {lessonName: true}
    }, SetOptions(merge: true));

    setState(() {
      isLessonComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Python Numbers & Runner'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 182, 190, 233), Colors.lightBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Python Numbers Lessons',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 106, 130, 204),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...buildLessonCards(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                flex: 1,
                child: CodeRunner(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          completeLesson("Numbers and operations");
          Navigator.pop(context, true);
        },
        child: const Text('Complete Lesson'),
      ),
    );
  }

  List<Widget> buildLessonCards() {
    return [
      buildLessonCard(
        title: '1. Introduction to Numbers',
        code: '''
x = 10       # Integer
y = 3.14     # Float
z = 1 + 2j   # Complex Number
print(type(x), type(y), type(z))
  ''',
        description:
            'Python supports integers, floating-point numbers, and complex numbers as numeric types.',
        lessonKey: 'numbers',
      ),
      buildLessonCard(
        title: '2. Arithmetic Operations',
        code: '''
x = 10
y = 3
print(x + y)  # Addition
print(x - y)  # Subtraction
print(x * y)  # Multiplication
print(x / y)  # Division
  ''',
        description:
            'You can perform basic arithmetic operations such as addition, subtraction, multiplication, and division with numbers.',
        lessonKey: 'numbers',
      ),
      buildLessonCard(
        title: '3. Floor Division and Modulus',
        code: '''
x = 10
y = 3
print(x // y)  # Floor Division
print(x % y)   # Modulus (Remainder)
  ''',
        description:
            'Floor division `//` returns the largest integer less than or equal to the division. Modulus `%` gives the remainder.',
        lessonKey: 'numbers',
      ),
      buildLessonCard(
        title: '4. Exponents and Roots',
        code: '''
x = 2
print(x ** 3)  # Exponentiation (2^3 = 8)
print(x ** 0.5)  # Square Root (√2)
  ''',
        description:
            'Use `**` for exponentiation. To calculate roots, use fractional exponents like `** 0.5` for square root.',
        lessonKey: 'numbers',
      ),
      buildLessonCard(
        title: '5. Rounding Numbers',
        code: '''
x = 3.14159
print(round(x, 2))  # Round to 2 decimal places
  ''',
        description:
            'Use `round()` to round numbers to the nearest integer or a specified number of decimal places.',
        lessonKey: 'numbers',
      ),
      buildLessonCard(
        title: '6. Absolute Value',
        code: '''
x = -5
print(abs(x))
  ''',
        description:
            'The `abs()` function returns the absolute value of a number, which is always positive.',
        lessonKey: 'numbers',
      ),
      buildLessonCard(
        title: '7. Converting Numbers',
        code: '''
x = 10.5
y = int(x)  # Convert to integer
z = float(y)  # Convert to float
print(y, z)
  ''',
        description:
            'Use `int()` to convert a float to an integer and `float()` to convert an integer to a float.',
        lessonKey: 'numbers',
      ),
      buildLessonCard(
        title: '8. Working with Large Numbers',
        code: '''
x = 1_000_000
print(x)
  ''',
        description:
            'You can use underscores `_` in numbers for better readability. It doesn’t affect the value.',
        lessonKey: 'numbers',
      ),
      buildLessonCard(
        title: '9. Random Numbers',
        code: '''
import random
print(random.randint(1, 10))  # Random integer between 1 and 10
  ''',
        description:
            'Use the `random` module to generate random numbers. `randint(a, b)` generates a random integer between `a` and `b`.',
        lessonKey: 'numbers',
      ),
    ];
  }

  Widget buildLessonCard({
    required String title,
    required String code,
    required String description,
    required String lessonKey,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      color: isLessonComplete ? Colors.green[100] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (isLessonComplete)
                  const Icon(Icons.check_circle,
                      color: Colors.green), // ✅ Show checkmark
              ],
            ),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                code,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
