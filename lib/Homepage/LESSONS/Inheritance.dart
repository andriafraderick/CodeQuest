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
      home: const Inheritance(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Inheritance extends StatefulWidget {
  const Inheritance({super.key});

  @override
  _InheritanceState createState() => _InheritanceState();
}

class _InheritanceState extends State<Inheritance> {
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
        isLessonComplete = data['intlessons']?['Inheritance'] ?? false;
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
        title: const Text('Python Inheritance & Runner'),
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
                        'Python Inheritance Lessons',
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
          completeLesson("Inheritance");
          Navigator.pop(context, true);
        },
        child: const Text('Complete Lesson'),
      ),
    );
  }

  List<Widget> buildLessonCards() {
    return [
      buildLessonCard(
        title: '1. Basic Inheritance',
        code: '''
class Parent:
    def show_message(self):
        print("This is the parent class.")

class Child(Parent):
    pass

child = Child()
child.show_message()
  ''',
        description:
            'Learn how a child class can inherit methods and attributes from a parent class.',
        lessonKey: 'inheritance_basic',
      ),
      buildLessonCard(
        title: '2. Overriding Methods',
        code: '''
class Parent:
    def show_message(self):
        print("This is the parent class.")

class Child(Parent):
    def show_message(self):
        print("This is the child class.")

child = Child()
child.show_message()
  ''',
        description:
            'Understand how child classes can override methods from parent classes.',
        lessonKey: 'inheritance_overriding_methods',
      ),
      buildLessonCard(
        title: '3. Calling Parent Methods',
        code: '''
class Parent:
    def show_message(self):
        print("This is the parent class.")

class Child(Parent):
    def show_message(self):
        super().show_message()
        print("This is the child class.")

child = Child()
child.show_message()
  ''',
        description:
            'Learn how to use `super()` to call a method from the parent class.',
        lessonKey: 'inheritance_calling_parent_methods',
      ),
      buildLessonCard(
        title: '4. Multiple Inheritance',
        code: '''
class ClassA:
    def feature_a(self):
        print("Feature A")

class ClassB:
    def feature_b(self):
        print("Feature B")

class CombinedClass(ClassA, ClassB):
    pass

obj = CombinedClass()
obj.feature_a()
obj.feature_b()
  ''',
        description:
            'Understand how multiple inheritance allows a class to inherit from more than one parent class.',
        lessonKey: 'inheritance_multiple',
      ),
      buildLessonCard(
        title: '5. Multi-Level Inheritance',
        code: '''
class GrandParent:
    def feature_gp(self):
        print("Feature from Grandparent")

class Parent(GrandParent):
    def feature_p(self):
        print("Feature from Parent")

class Child(Parent):
    def feature_c(self):
        print("Feature from Child")

child = Child()
child.feature_gp()
child.feature_p()
child.feature_c()
  ''',
        description:
            'Learn about multi-level inheritance where a class can inherit from a derived class.',
        lessonKey: 'inheritance_multilevel',
      ),
      buildLessonCard(
        title: '6. Hierarchical Inheritance',
        code: '''
class Parent:
    def show_message(self):
        print("Message from Parent")

class Child1(Parent):
    pass

class Child2(Parent):
    pass

child1 = Child1()
child2 = Child2()
child1.show_message()
child2.show_message()
  ''',
        description:
            'Explore how multiple child classes can inherit from the same parent class.',
        lessonKey: 'inheritance_hierarchical',
      ),
      buildLessonCard(
        title: '7. Diamond Problem and MRO',
        code: '''
class A:
    def feature(self):
        print("Feature from A")

class B(A):
    def feature(self):
        print("Feature from B")

class C(A):
    def feature(self):
        print("Feature from C")

class D(B, C):
    pass

d = D()
d.feature()
print(D.mro())
  ''',
        description:
            'Understand the diamond problem and how Python resolves method order using MRO.',
        lessonKey: 'inheritance_diamond_problem',
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
