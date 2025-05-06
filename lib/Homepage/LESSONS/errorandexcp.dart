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
      home: const Errorandexp(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Errorandexp extends StatefulWidget {
  const Errorandexp({super.key});

  @override
  _ErrorandexpState createState() => _ErrorandexpState();
}

class _ErrorandexpState extends State<Errorandexp> {
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
        isLessonComplete =
            data['intlessons']?['Error and Exception Handling'] ?? false;
      });
    }
  }

  void completeLesson(String lessonName) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "test_user";

    FirebaseFirestore.instance.collection('users').doc(userId).set({
      'intlessons': {lessonName: true}
    }, SetOptions(merge: true));

    setState(() {
      isLessonComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Python Error and  & Exception Handling Runner'),
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
                        'Python Error and Exception Handling Lessons',
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
          completeLesson("Error and Exception Handling");
          Navigator.pop(context, true);
        },
        child: const Text('Complete Lesson'),
      ),
    );
  }

  List<Widget> buildLessonCards() {
    return [
      buildLessonCard(
        title: '1. Introduction to Errors',
        code: '''
# This code will raise a ZeroDivisionError
result = 10 / 0
  ''',
        description: 'Understand what errors are and how they occur in Python.',
        lessonKey: 'errors_intro',
      ),
      buildLessonCard(
        title: '2. Using Try-Except',
        code: '''
try:
    result = 10 / 0
except ZeroDivisionError:
    print("You cannot divide by zero!")
  ''',
        description:
            'Learn to handle exceptions using `try` and `except` blocks.',
        lessonKey: 'try_except',
      ),
      buildLessonCard(
        title: '3. Catching Multiple Exceptions',
        code: '''
try:
    num = int("not_a_number")
    result = 10 / 0
except ValueError:
    print("Invalid input!")
except ZeroDivisionError:
    print("You cannot divide by zero!")
  ''',
        description:
            'Handle multiple types of exceptions with specific handlers.',
        lessonKey: 'multiple_exceptions',
      ),
      buildLessonCard(
        title: '4. Finally Block',
        code: '''
try:
    file = open("example.txt", "r")
    content = file.read()
except FileNotFoundError:
    print("File not found!")
finally:
    print("Execution completed.")
  ''',
        description: 'Use the `finally` block to execute cleanup code.',
        lessonKey: 'finally_block',
      ),
      buildLessonCard(
        title: '5. Raising Exceptions',
        code: '''
def check_age(age):
    if age < 18:
        raise ValueError("Age must be 18 or above.")
    return "Access granted!"

try:
    print(check_age(16))
except ValueError as e:
    print(e)
  ''',
        description:
            'Learn how to raise custom exceptions with the `raise` keyword.',
        lessonKey: 'raise_exceptions',
      ),
      buildLessonCard(
        title: '6. Custom Exceptions',
        code: '''
class CustomError(Exception):
    pass

try:
    raise CustomError("This is a custom error!")
except CustomError as e:
    print(e)
  ''',
        description:
            'Create your own exception classes for better error handling.',
        lessonKey: 'custom_exceptions',
      ),
      buildLessonCard(
        title: '7. Else Clause with Try-Except',
        code: '''
try:
    result = 10 / 2
except ZeroDivisionError:
    print("You cannot divide by zero!")
else:
    print("The result is:", result)
  ''',
        description:
            'Learn to use the `else` clause for code that runs if no errors occur.',
        lessonKey: 'else_in_try',
      ),
      buildLessonCard(
        title: '8. Assertions',
        code: '''
def divide(a, b):
    assert b != 0, "Denominator cannot be zero!"
    return a / b

print(divide(10, 2))
print(divide(10, 0))  # This will trigger the assertion
  ''',
        description: 'Use `assert` to validate conditions in your code.',
        lessonKey: 'assertions',
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
