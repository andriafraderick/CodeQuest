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
      home: const Sets(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Sets extends StatefulWidget {
  const Sets({super.key});

  @override
  _SetsState createState() => _SetsState();
}

class _SetsState extends State<Sets> {
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
        isLessonComplete = data['lessons']?['Sets'] ?? false;
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
        title: const Text('Python Sets & Runner'),
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
                        'Python Sets Lessons',
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
          completeLesson("Sets");
          Navigator.pop(context, true);
        },
        child: const Text('Complete Lesson'),
      ),
    );
  }

  List<Widget> buildLessonCards() {
    return [
      buildLessonCard(
        title: '1. Introduction to Sets',
        code: '''
# Creating a set
fruits = {"apple", "banana", "cherry"}
print(fruits)
  ''',
        description:
            'Sets in Python are unordered, mutable, and do not allow duplicate elements.',
        lessonKey: 'sets',
      ),
      buildLessonCard(
        title: '2. Adding an Element to a Set',
        code: '''
fruits = {"apple", "banana", "cherry"}
fruits.add("orange")
print(fruits)
  ''',
        description: 'Use the `add()` method to add an element to a set.',
        lessonKey: 'sets',
      ),
      buildLessonCard(
        title: '3. Removing an Element from a Set',
        code: '''
fruits = {"apple", "banana", "cherry"}
fruits.remove("banana")
print(fruits)
  ''',
        description:
            'Use the `remove()` method to remove a specific element. It raises an error if the element does not exist.',
        lessonKey: 'sets',
      ),
      buildLessonCard(
        title: '4. Discarding an Element',
        code: '''
fruits = {"apple", "banana", "cherry"}
fruits.discard("banana")
fruits.discard("grape")  # No error if element doesn't exist
print(fruits)
  ''',
        description:
            'The `discard()` method removes an element if it exists, but does not raise an error if it does not.',
        lessonKey: 'sets',
      ),
      buildLessonCard(
        title: '5. Checking Membership in a Set',
        code: '''
fruits = {"apple", "banana", "cherry"}
print("apple" in fruits)  # True
print("grape" in fruits)  # False
  ''',
        description:
            'Use the `in` keyword to check if an element exists in a set.',
        lessonKey: 'sets',
      ),
      buildLessonCard(
        title: '6. Set Union',
        code: '''
set1 = {"apple", "banana"}
set2 = {"cherry", "banana"}
union_set = set1.union(set2)
print(union_set)
  ''',
        description:
            'The `union()` method returns a set containing all unique elements from both sets.',
        lessonKey: 'sets',
      ),
      buildLessonCard(
        title: '7. Set Intersection',
        code: '''
set1 = {"apple", "banana"}
set2 = {"cherry", "banana"}
intersection_set = set1.intersection(set2)
print(intersection_set)
  ''',
        description:
            'The `intersection()` method returns a set containing only elements common to both sets.',
        lessonKey: 'sets',
      ),
      buildLessonCard(
        title: '8. Set Difference',
        code: '''
set1 = {"apple", "banana", "cherry"}
set2 = {"banana", "cherry"}
difference_set = set1.difference(set2)
print(difference_set)
  ''',
        description:
            'The `difference()` method returns a set containing elements in the first set but not in the second.',
        lessonKey: 'sets',
      ),
      buildLessonCard(
        title: '9. Symmetric Difference',
        code: '''
set1 = {"apple", "banana"}
set2 = {"banana", "cherry"}
symmetric_difference_set = set1.symmetric_difference(set2)
print(symmetric_difference_set)
  ''',
        description:
            'The `symmetric_difference()` method returns a set containing elements that are in either set but not in both.',
        lessonKey: 'sets',
      ),
      buildLessonCard(
        title: '10. Checking if a Set is a Subset',
        code: '''
set1 = {"apple", "banana"}
set2 = {"apple", "banana", "cherry"}
print(set1.issubset(set2))  # True
  ''',
        description:
            'The `issubset()` method checks if all elements of a set are present in another set.',
        lessonKey: 'sets',
      ),
      buildLessonCard(
        title: '11. Checking if a Set is a Superset',
        code: '''
set1 = {"apple", "banana", "cherry"}
set2 = {"apple", "banana"}
print(set1.issuperset(set2))  # True
  ''',
        description:
            'The `issuperset()` method checks if a set contains all elements of another set.',
        lessonKey: 'sets',
      ),
      buildLessonCard(
        title: '12. Clearing a Set',
        code: '''
fruits = {"apple", "banana", "cherry"}
fruits.clear()
print(fruits)  # Output: set()
  ''',
        description: 'The `clear()` method removes all elements from the set.',
        lessonKey: 'sets',
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
