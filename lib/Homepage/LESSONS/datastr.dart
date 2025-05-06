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
      home: const Datastructure(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Datastructure extends StatefulWidget {
  const Datastructure({super.key});

  @override
  _DatastructureState createState() => _DatastructureState();
}

class _DatastructureState extends State<Datastructure> {
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
        isLessonComplete = data['intlessons']?['Data Structure'] ?? false;
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
        title: const Text('Python Datastructure & Runner'),
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
                        'Python Datastructure Lessons',
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
          completeLesson("Data Structure");
          Navigator.pop(context, true);
        },
        child: const Text('Complete Lesson'),
      ),
    );
  }

  List<Widget> buildLessonCards() {
    return [
      buildLessonCard(
        title: '1. Lists',
        code: '''
fruits = ["apple", "banana", "cherry"]
fruits.append("orange")
print(fruits)
  ''',
        description: 'Learn how to create, access, and modify lists in Python.',
        lessonKey: 'data_structures_lists',
      ),
      buildLessonCard(
        title: '2. Tuples',
        code: '''
coordinates = (10, 20, 30)
print(coordinates[1])
  ''',
        description: 'Explore tuples, immutable sequences used to store data.',
        lessonKey: 'data_structures_tuples',
      ),
      buildLessonCard(
        title: '3. Sets',
        code: '''
unique_numbers = {1, 2, 3, 4, 4}
unique_numbers.add(5)
print(unique_numbers)
  ''',
        description:
            'Understand sets, unordered collections of unique elements.',
        lessonKey: 'data_structures_sets',
      ),
      buildLessonCard(
        title: '4. Dictionaries',
        code: '''
person = {"name": "Alice", "age": 25, "city": "Paris"}
print(person["name"])
  ''',
        description:
            'Learn about dictionaries, key-value pairs for fast lookups.',
        lessonKey: 'data_structures_dictionaries',
      ),
      buildLessonCard(
        title: '5. Nested Data Structures',
        code: '''
data = {
    "name": "Alice",
    "scores": [95, 88, 92],
    "address": {"city": "Paris", "zip": "75001"}
}
print(data["address"]["city"])
  ''',
        description: 'Combine data structures to represent complex data.',
        lessonKey: 'data_structures_nested',
      ),
      buildLessonCard(
        title: '6. Stack (Using List)',
        code: '''
stack = []
stack.append(1)
stack.append(2)
print(stack.pop())
  ''',
        description: 'Implement a stack (LIFO) using Python lists.',
        lessonKey: 'data_structures_stack',
      ),
      buildLessonCard(
        title: '7. Queue (Using Collections)',
        code: '''
from collections import deque
queue = deque([1, 2, 3])
queue.append(4)
print(queue.popleft())
  ''',
        description: 'Learn how to create and use queues (FIFO) with `deque`.',
        lessonKey: 'data_structures_queue',
      ),
      buildLessonCard(
        title: '8. Linked List (Custom Implementation)',
        code: '''
class Node:
    def __init__(self, data):
        self.data = data
        self.next = None

node1 = Node(1)
node2 = Node(2)
node1.next = node2
print(node1.data, "->", node2.data)
  ''',
        description: 'Create a simple linked list in Python.',
        lessonKey: 'data_structures_linked_list',
      ),
      buildLessonCard(
        title: '9. Priority Queue',
        code: '''
import heapq
pq = []
heapq.heappush(pq, (2, "Task A"))
heapq.heappush(pq, (1, "Task B"))
print(heapq.heappop(pq))
  ''',
        description: 'Implement a priority queue using `heapq`.',
        lessonKey: 'data_structures_priority_queue',
      ),
      buildLessonCard(
        title: '10. Graph (Adjacency List)',
        code: '''
graph = {
    "A": ["B", "C"],
    "B": ["A", "D", "E"],
    "C": ["A", "F"],
    "D": ["B"],
    "E": ["B", "F"],
    "F": ["C", "E"]
}
print(graph["A"])
  ''',
        description: 'Represent graphs using adjacency lists.',
        lessonKey: 'data_structures_graph',
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
