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
      home: const Functionandmodules(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Functionandmodules extends StatefulWidget {
  const Functionandmodules({super.key});

  @override
  _FunctionandmodulesState createState() => _FunctionandmodulesState();
}

class _FunctionandmodulesState extends State<Functionandmodules> {
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
        isLessonComplete = data['intlessons']?['Function and Modules'] ?? false;
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
        title: const Text('Python Functionandmodules & Runner'),
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
                        'Python Functionandmodules Lessons',
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
          completeLesson("Function and Modules");
          Navigator.pop(context, true);
        },
        child: const Text('Complete Lesson'),
      ),
    );
  }

  List<Widget> buildLessonCards() {
    return [
      buildLessonCard(
        title: '1. Introduction to Functions',
        code: '''
def greet():
    print("Hello, World!")
greet()
  ''',
        description:
            'Learn the basics of defining and calling functions in Python.',
        lessonKey: 'functions_intro',
      ),
      buildLessonCard(
        title: '2. Parameters and Arguments',
        code: '''
def greet(name):
    print(f"Hello, {name}!")
greet("Alice")
  ''',
        description:
            'Understand how to use parameters and arguments in functions.',
        lessonKey: 'functions_parameters',
      ),
      buildLessonCard(
        title: '3. Default Arguments',
        code: '''
def greet(name="User"):
    print(f"Hello, {name}!")
greet()
greet("Alice")
  ''',
        description: 'Learn how to set default values for function parameters.',
        lessonKey: 'functions_default_arguments',
      ),
      buildLessonCard(
        title: '4. Variable-Length Arguments',
        code: '''
def add_numbers(*args):
    return sum(args)
print(add_numbers(1, 2, 3, 4))
  ''',
        description: 'Use `*args` to handle multiple positional arguments.',
        lessonKey: 'functions_variable_args',
      ),
      buildLessonCard(
        title: '5. Keyword Arguments',
        code: '''
def print_details(**kwargs):
    for key, value in kwargs.items():
        print(f"{key}: {value}")
print_details(name="Alice", age=25, city="Paris")
  ''',
        description:
            'Learn to work with `**kwargs` for flexible keyword arguments.',
        lessonKey: 'functions_keyword_args',
      ),
      buildLessonCard(
        title: '6. Function Scope',
        code: '''
x = 10

def modify_global():
    global x
    x = 20
modify_global()
print(x)
  ''',
        description:
            'Explore local and global variables, and the `global` keyword.',
        lessonKey: 'functions_scope',
      ),
      buildLessonCard(
        title: '7. Anonymous Functions',
        code: '''
square = lambda x: x * x
print(square(5))
  ''',
        description: 'Create concise, inline functions using `lambda`.',
        lessonKey: 'functions_lambda',
      ),
      buildLessonCard(
        title: '8. Creating Modules',
        code: '''
# In a file called mymodule.py
def greet(name):
    return f"Hello, {name}!"

# In the main script
import mymodule
print(mymodule.greet("Alice"))
  ''',
        description: 'Organize reusable code into modules and import them.',
        lessonKey: 'modules_intro',
      ),
      buildLessonCard(
        title: '9. Using Built-in Functions',
        code: '''
nums = [1, 2, 3, 4]
squared = map(lambda x: x**2, nums)
print(list(squared))
  ''',
        description:
            'Explore built-in functions like `map()`, `filter()`, and more.',
        lessonKey: 'functions_builtin',
      ),
      buildLessonCard(
        title: '10. Importing Libraries',
        code: '''
import math
print(math.sqrt(16))
  ''',
        description:
            'Learn to use Python’s standard and third-party libraries.',
        lessonKey: 'modules_import',
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
