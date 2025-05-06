import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../GAMES/hangman.dart';
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
      home: const Dictionaries(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Dictionaries extends StatefulWidget {
  const Dictionaries({super.key});

  @override
  _DictionariesState createState() => _DictionariesState();
}

class _DictionariesState extends State<Dictionaries>
    with SingleTickerProviderStateMixin {
  bool isLessonComplete = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    getLessonProgress();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> getLessonProgress() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "test_user";
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      setState(() {
        isLessonComplete = data['lessons']?['Dictionaries'] ?? false;
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
        title: const Text('Python Dictionaries & Runner'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Dictionaries"),
            Tab(text: "Hangman Game"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildDictionariesLesson(),
          HangmanGame(onCompleteLesson: () {
            completeLesson("Dictionaries");
          }),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? ElevatedButton(
              onPressed: () {
                completeLesson("Dictionaries");
                Navigator.pop(context, true);
              },
              child: const Text('Complete Lesson'),
            )
          : null,
    );
  }

  Widget buildDictionariesLesson() {
    return Container(
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
                      'Python Dictionaries Lessons',
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
    );
  }

  List<Widget> buildLessonCards() {
    return [
      buildLessonCard(
        title: '1. Introduction to Dictionaries',
        code: '''
# Creating a dictionary
person = {"name": "John", "age": 30, "city": "New York"}
print(person)
  ''',
        description:
            'Dictionaries in Python are used to store data in key-value pairs. Keys must be unique and immutable.',
      ),
      buildLessonCard(
        title: '2. Accessing Dictionary Values',
        code: '''
person = {"name": "John", "age": 30}
print(person["name"])  # Access by key
  ''',
        description:
            'Use the key in square brackets to access its corresponding value.',
      ),
      buildLessonCard(
        title: '3. Adding or Updating a Key-Value Pair',
        code: '''
person = {"name": "John", "age": 30}
person["city"] = "New York"  # Add new key-value pair
person["age"] = 31  # Update value
print(person)
  ''',
        description:
            'You can add or update key-value pairs by assigning values to a key.',
      ),
      buildLessonCard(
        title: '4. Removing a Key-Value Pair',
        code: '''
person = {"name": "John", "age": 30, "city": "New York"}
person.pop("age")  # Remove by key
print(person)
  ''',
        description:
            'Use the `pop()` method to remove a key-value pair by key.',
      ),
      buildLessonCard(
        title: '5. Iterating Through a Dictionary',
        code: '''
person = {"name": "John", "age": 30}
for key, value in person.items():
    print(key, ":", value)
  ''',
        description:
            'Use the `items()` method to loop through both keys and values in a dictionary.',
      ),
      buildLessonCard(
        title: '6. Checking for a Key in a Dictionary',
        code: '''
person = {"name": "John", "age": 30}
if "name" in person:
    print("Name exists!")
  ''',
        description:
            'Use the `in` keyword to check if a key exists in the dictionary.',
      ),
      buildLessonCard(
        title: '7. Getting All Keys',
        code: '''
person = {"name": "John", "age": 30}
keys = person.keys()
print(keys)
  ''',
        description:
            'Use the `keys()` method to get a list-like view of all keys in the dictionary.',
      ),
      buildLessonCard(
        title: '8. Getting All Values',
        code: '''
person = {"name": "John", "age": 30}
values = person.values()
print(values)
  ''',
        description:
            'Use the `values()` method to get a list-like view of all values in the dictionary.',
      ),
      buildLessonCard(
        title: '9. Using `get()` to Access Values',
        code: '''
person = {"name": "John", "age": 30}
print(person.get("city", "Not Found"))  # Output: Not Found
  ''',
        description:
            'The `get()` method retrieves a value by key and allows you to set a default return value if the key is not found.',
      ),
      buildLessonCard(
        title: '10. Merging Two Dictionaries',
        code: '''
person = {"name": "John", "age": 30}
address = {"city": "New York", "zip": "10001"}
person.update(address)
print(person)
  ''',
        description:
            'Use the `update()` method to merge another dictionary into an existing one.',
      ),
      buildLessonCard(
        title: '11. Clearing a Dictionary',
        code: '''
person = {"name": "John", "age": 30}
person.clear()
print(person)  # Output: {}
  ''',
        description:
            'The `clear()` method removes all key-value pairs from a dictionary.',
      ),
      buildLessonCard(
        title: '12. Dictionary with Nested Data',
        code: '''
family = {
    "parent": {"name": "John", "age": 40},
    "child": {"name": "Alice", "age": 10}
}
print(family["child"]["name"])  # Output: Alice
  ''',
        description:
            'Dictionaries can contain nested dictionaries, enabling you to represent hierarchical data.',
      ),
      buildLessonCard(
        title: '13. Using Default Values with `setdefault()`',
        code: '''
person = {"name": "John"}
person.setdefault("age", 30)
print(person)
  ''',
        description:
            'The `setdefault()` method inserts a key with a default value if the key does not already exist.',
      ),
    ];
  }

  Widget buildLessonCard({
    required String title,
    required String code,
    required String description,
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
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
