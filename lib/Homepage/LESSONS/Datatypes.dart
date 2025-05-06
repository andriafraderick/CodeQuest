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
      home: const Datatypes(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Datatypes extends StatefulWidget {
  const Datatypes({super.key});

  @override
  _DatatypesState createState() => _DatatypesState();
}

class _DatatypesState extends State<Datatypes> {
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
        isLessonComplete = data['lessons']?['Datatypes'] ?? false;
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
        title: const Text('Python Datatypes & Runner'),
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
                        'Python Datatypes Lessons',
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
          completeLesson("Datatypes");
          Navigator.pop(context, true);
        },
        child: const Text('Complete Lesson'),
      ),
    );
  }

  List<Widget> buildLessonCards() {
    return [
      buildLessonCard(
        title: '1. Introduction to Data Types',
        code: '''
x = 10        # Integer
y = 3.14      # Float
z = "Python"  # String
print(type(x), type(y), type(z))
  ''',
        description:
            'Data types define the type of data a variable can hold. Common types include integers, floats, and strings.',
        lessonKey: 'datatypes',
      ),
      buildLessonCard(
        title: '2. Numeric Data Types',
        code: '''
x = 42        # Integer
y = 3.14      # Float
z = 1 + 2j    # Complex Number
print(type(x), type(y), type(z))
  ''',
        description:
            'Python supports integers, floating-point numbers, and complex numbers as numeric data types.',
        lessonKey: 'datatypes',
      ),
      buildLessonCard(
        title: '3. Strings',
        code: '''
x = "Hello, World!"
print(x.upper())
print(x.lower())
print(x[0:5])  # Slice
  ''',
        description:
            'Strings are sequences of characters enclosed in quotes. You can manipulate them using various methods.',
        lessonKey: 'datatypes',
      ),
      buildLessonCard(
        title: '4. Boolean Data Type',
        code: '''
x = True
y = False
print(x and y)
print(x or y)
  ''',
        description:
            'The Boolean data type represents `True` or `False`, often used in conditional statements.',
        lessonKey: 'datatypes',
      ),
      buildLessonCard(
        title: '9. Type Conversion',
        code: '''
x = "10"
y = int(x)  # Convert string to integer
z = float(y)  # Convert integer to float
print(type(x), type(y), type(z))
  ''',
        description:
            'Use built-in functions like `int()`, `float()`, and `str()` to convert data types.',
        lessonKey: 'datatypes',
      ),
      buildLessonCard(
        title: '10. NoneType',
        code: '''
x = None
print(x is None)
  ''',
        description:
            '`None` represents the absence of a value or a null value. It is often used as a default return type.',
        lessonKey: 'datatypes',
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
