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
      home: const typecast(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class typecast extends StatefulWidget {
  const typecast({super.key});

  @override
  _typecastState createState() => _typecastState();
}

class _typecastState extends State<typecast> {
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
        isLessonComplete = data['lessons']?['Type Casting'] ?? false;
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
        title: const Text('Python typecast & Runner'),
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
                        'Python typecast Lessons',
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
          completeLesson("Type Casting");
          Navigator.pop(context, true);
        },
        child: const Text('Complete Lesson'),
      ),
    );
  }

  List<Widget> buildLessonCards() {
    return [
      buildLessonCard(
        title: '1. Introduction to Typecasting',
        code: '''
x = "100"  # String
y = int(x)  # Convert to integer
print(type(y))  # <class 'int'>
  ''',
        description:
            'Typecasting is the process of converting one data type into another, such as converting a string to an integer.',
        lessonKey: 'typecasting',
      ),
      buildLessonCard(
        title: '2. String to Integer',
        code: '''
x = "42"
y = int(x)
print(y, type(y))
  ''',
        description:
            'Use `int()` to convert a numeric string to an integer. The string must contain valid digits.',
        lessonKey: 'typecasting',
      ),
      buildLessonCard(
        title: '3. String to Float',
        code: '''
x = "3.14"
y = float(x)
print(y, type(y))
  ''',
        description:
            'Use `float()` to convert a numeric string to a floating-point number.',
        lessonKey: 'typecasting',
      ),
      buildLessonCard(
        title: '4. Integer to String',
        code: '''
x = 50
y = str(x)
print(y, type(y))
  ''',
        description: 'Use `str()` to convert an integer to a string.',
        lessonKey: 'typecasting',
      ),
      buildLessonCard(
        title: '5. Float to Integer',
        code: '''
x = 5.99
y = int(x)
print(y, type(y))
  ''',
        description:
            'Use `int()` to convert a float to an integer. This will truncate the decimal part.',
        lessonKey: 'typecasting',
      ),
      buildLessonCard(
        title: '6. Integer to Float',
        code: '''
x = 10
y = float(x)
print(y, type(y))
  ''',
        description:
            'Use `float()` to convert an integer to a floating-point number.',
        lessonKey: 'typecasting',
      ),
      buildLessonCard(
        title: '7. Boolean to Integer',
        code: '''
x = True
y = int(x)
print(y, type(y))  # Outputs: 1 <class 'int'>
  ''',
        description:
            'Booleans can be converted to integers, where `True` is `1` and `False` is `0`.',
        lessonKey: 'typecasting',
      ),
      buildLessonCard(
        title: '8. Integer to Boolean',
        code: '''
x = 0
y = bool(x)
print(y, type(y))  # Outputs: False <class 'bool'>
  ''',
        description:
            'Use `bool()` to convert integers to booleans. `0` is `False`, and any non-zero value is `True`.',
        lessonKey: 'typecasting',
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
