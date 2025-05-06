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
      home: const Variables(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Variables extends StatefulWidget {
  const Variables({super.key});

  @override
  _VariablesState createState() => _VariablesState();
}

class _VariablesState extends State<Variables> {
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
        isLessonComplete = data['lessons']?['Variables'] ?? false;
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
        title: const Text('Python Variables & Runner'),
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
                        'Python Variables Lessons',
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
          completeLesson("Variables");
          Navigator.pop(context, true);
        },
        child: const Text('Complete Lesson'),
      ),
    );
  }

  List<Widget> buildLessonCards() {
    return [
      buildLessonCard(
        title: '1. Introduction to Variables',
        code: 'x = 10\ny = "Python"\nz = 3.14\nprint(x, y, z)',
        description:
            'Variables store data in Python. You can assign numbers, strings, or other types of values to variables.',
        lessonKey: 'variables',
      ),
      buildLessonCard(
        title: '2. Variable Naming Rules',
        code: '''
# Valid variable names:
my_var = 10
_myVar = "Python"
var123 = 3.14

# Invalid variable names:
# 123var = 10 (Cannot start with a number)
# my-var = 5 (Cannot use special characters)
print(my_var, _myVar, var123)
''',
        description:
            'Variable names must start with a letter or an underscore (_). They cannot start with a number or contain special characters like `-`.',
        lessonKey: 'variables',
      ),
      buildLessonCard(
        title: '3. Dynamic Typing',
        code: '''
x = 10       # Integer
x = "Hello"  # Now a String
x = 3.14     # Now a Float
print(x)
  ''',
        description:
            'In Python, variables can change type during execution. This is called dynamic typing.',
        lessonKey: 'variables',
      ),
      buildLessonCard(
        title: '4. Assigning Multiple Variables',
        code: '''
x, y, z = 10, "Python", 3.14
print(x, y, z)
  ''',
        description:
            'Assign multiple values to multiple variables in a single line using commas.',
        lessonKey: 'variables',
      ),
      buildLessonCard(
        title: '5. Assigning the Same Value',
        code: '''
x = y = z = 100
print(x, y, z)
  ''',
        description: 'Assign the same value to multiple variables in one line.',
        lessonKey: 'variables',
      ),
      buildLessonCard(
        title: '7. Constants',
        code: '''
PI = 3.14
GRAVITY = 9.8
print("PI:", PI)
print("Gravity:", GRAVITY)
  ''',
        description:
            'Constants are variables whose values should not change. By convention, their names are in uppercase.',
        lessonKey: 'variables',
      ),
      buildLessonCard(
        title: '8. Deleting Variables',
        code: '''
x = 10
print(x)

del x  # Delete the variable
# print(x)  # This will throw an error because x is deleted
''',
        description: 'You can delete variables using the `del` keyword.',
        lessonKey: 'variables',
      ),
      buildLessonCard(
        title: '9. Global vs Local Variables',
        code: '''
x = "global"  # Global variable

def my_function():
    x = "local"  # Local variable
    print("Inside function:", x)

my_function()
print("Outside function:", x)
  ''',
        description:
            'Variables declared inside functions are local, while variables outside are global.',
        lessonKey: 'variables',
      ),
      buildLessonCard(
        title: '10. Deleting Variables',
        code: '''
x = 10
print(x)
del x  # Deletes the variable
# print(x)  # This will raise an error
  ''',
        description:
            'Use `del` to delete variables when they are no longer needed.',
        lessonKey: 'variables',
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
