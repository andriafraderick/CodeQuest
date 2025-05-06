import 'dart:convert';
import 'package:finalprojects8/Homepage/LESSONS/coderunner.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      home: const Classobj(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Classobj extends StatefulWidget {
  const Classobj({super.key});

  @override
  _ClassobjState createState() => _ClassobjState();
}

class _ClassobjState extends State<Classobj> {
  bool isLessonComplete = false;

  @override
  void initState() {
    super.initState();
    getLessonProgress();
  }

  Future<void> getLessonProgress() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "test_user";
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('user_progress')
        .doc(userId)
        .get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      setState(() {
        isLessonComplete = data['lessons']?['Classobj'] ?? false;
      });
    }
  }

  void completeLesson(String lessonName) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "test_user";

    FirebaseFirestore.instance.collection('user_progress').doc(userId).set({
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
        title: const Text('Python Classobj & Runner'),
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
                        'Classobj Lessons',
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
              Expanded(
                flex: 1,
                child: CodeRunner(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          completeLesson("Classobj");
          Navigator.pop(context, true);
        },
        child: const Text('Complete Lesson'),
      ),
    );
  }

  List<Widget> buildLessonCards() {
    return [
      buildLessonCard(
        title: '1. Introduction to Classes & Objects',
        code: 'class MyClass:\n    x = 5\np1 = MyClass()\nprint(p1.x)',
        description:
            'Python is an object-oriented programming language. A class is like a blueprint for creating objects. An object is an instance of a class.',
        lessonKey: 'ClassIntro',
      ),
      buildLessonCard(
        title: '2. Creating an Object',
        code: 'class MyClass:\n    x = 5\np1 = MyClass()\nprint(p1.x)',
        description:
            'Classes define properties and behavior, while objects store actual values and methods. We create an object by calling the class.',
        lessonKey: 'CreateObject',
      ),
      buildLessonCard(
        title: '3. The __init__() Function',
        code:
            'class Person:\n    def __init__(self, name, age):\n        self.name = name\n        self.age = age\np1 = Person("John", 36)\nprint(p1.name, p1.age)',
        description:
            'The __init__() function is a special method that is automatically called when an object is created. It initializes object attributes.',
        lessonKey: 'InitFunction',
      ),
      buildLessonCard(
        title: '4. The __str__() Function',
        code:
            'class Person:\n    def __init__(self, name, age):\n        self.name = name\n        self.age = age\n    def __str__(self):\n        return f"{self.name} ({self.age})"\np1 = Person("John", 36)\nprint(p1)',
        description:
            'The __str__() function defines the string representation of an object. Without it, Python prints the memory address of the object.',
        lessonKey: 'StrFunction',
      ),
      buildLessonCard(
        title: '5. Object Methods',
        code:
            'class Person:\n    def __init__(self, name, age):\n        self.name = name\n        self.age = age\n    def greet(self):\n        return f"Hello, my name is {self.name}."\np1 = Person("John", 36)\nprint(p1.greet())',
        description:
            'Methods are functions that belong to an object. They allow objects to perform actions based on their data.',
        lessonKey: 'ObjectMethods',
      ),
      buildLessonCard(
        title: '6. The self Parameter',
        code:
            'class Person:\n    def __init__(mysillyobject, name, age):\n        mysillyobject.name = name\n        mysillyobject.age = age\n    def myfunc(abc):\n        print("Hello my name is " + abc.name)\np1 = Person("John", 36)\np1.myfunc()',
        description:
            'The self parameter refers to the current instance of the class. It is always the first parameter in a method.',
        lessonKey: 'SelfParameter',
      ),
      buildLessonCard(
        title: '7. Modify Object Properties',
        code: 'p1.age = 40\nprint(p1.age)',
        description:
            'You can modify an object’s properties by assigning new values to them.',
        lessonKey: 'ModifyProperties',
      ),
      buildLessonCard(
        title: '8. Delete Object Properties',
        code: 'del p1.age',
        description:
            'Use the del keyword to delete an attribute from an object.',
        lessonKey: 'DeleteProperties',
      ),
      buildLessonCard(
        title: '9. Delete Objects',
        code: 'del p1',
        description:
            'You can delete an entire object using the del keyword. This removes the object from memory.',
        lessonKey: 'DeleteObjects',
      ),
      buildLessonCard(
        title: '10. The pass Statement',
        code: 'class Person:\n    pass',
        description:
            'The pass statement is used when you need a class definition but don’t want to implement it yet.',
        lessonKey: 'PassStatement',
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
