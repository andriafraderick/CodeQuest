import 'dart:convert';
import 'package:finalprojects8/Homepage/beginner.dart';
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
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Python List and Tuples'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Lessons & Compiler'),
              Tab(text: 'Drag-and-Drop Game'),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 182, 190, 233), Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const TabBarView(
            children: [
              Listandtuples(), // First tab content
              DragAndDropGame(), // Second tab content
            ],
          ),
        ),
      ),
    );
  }
}

// Lessons and Compiler Section
class Listandtuples extends StatefulWidget {
  const Listandtuples({super.key});

  @override
  _ListandtuplesState createState() => _ListandtuplesState();
}

class _ListandtuplesState extends State<Listandtuples> {
  bool isLessonComplete = false;
  bool isGameComplete = false;
  @override
  void initState() {
    super.initState();
    getLessonProgress();
    _checkGameCompletion();
  }

  Future<void> _checkGameCompletion() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("❌ No user signed in.");
      return;
    }

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('gameProgress')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> progressData = doc.data() as Map<String, dynamic>;

        // Check if all levels are marked as true
        bool allLevelsCompleted =
            progressData.values.every((completed) => completed == true);

        setState(() {
          isGameComplete = allLevelsCompleted;
        });

        print("✅ Game completion status: $isGameComplete");
      } else {
        print("❌ No progress found. Game is not complete.");
        setState(() {
          isGameComplete = false;
        });
      }
    } catch (e) {
      print("❌ Error checking game progress: $e");
    }
  }

  Future<void> getLessonProgress() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "test_user";
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      setState(() {
        isLessonComplete = data['lessons']?['List and Tuples'] ?? false;
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
        title: const Text('Python Listandtuples & Runner'),
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
                        'Python Listandtuples Lessons',
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
        onPressed: isGameComplete
            ? () {
                completeLesson("List and Tuples"); // Mark lesson complete
                Navigator.pop(context, true);
              }
            : null, // Disable button when game is incomplete
        style: ElevatedButton.styleFrom(
          backgroundColor: isGameComplete
              ? Colors.indigo
              : Colors.grey, // Change button color
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: Text(
          isGameComplete ? 'Complete Lesson' : 'Complete Levels to Unlock',
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  List<Widget> buildLessonCards() {
    return [
      buildLessonCard(
        title: '1. Introduction to Lists',
        code: '''
# Creating a list
fruits = ["apple", "banana", "cherry"]
print(fruits)
  ''',
        description:
            'Lists in Python are ordered, mutable, and can contain duplicate elements.',
        lessonKey: 'lists',
      ),
      buildLessonCard(
        title: '2. Accessing Elements in a List',
        code: '''
fruits = ["apple", "banana", "cherry"]
print(fruits[0])  # Output: apple
print(fruits[-1])  # Output: cherry
  ''',
        description:
            'Use indexing to access elements in a list. Negative indices start from the end.',
        lessonKey: 'lists',
      ),
      buildLessonCard(
        title: '3. Modifying Elements in a List',
        code: '''
fruits = ["apple", "banana", "cherry"]
fruits[1] = "orange"
print(fruits)
  ''',
        description:
            'Lists are mutable, so you can change their elements using indices.',
        lessonKey: 'lists',
      ),
      buildLessonCard(
        title: '4. Adding Elements to a List',
        code: '''
fruits = ["apple", "banana"]
fruits.append("cherry")
print(fruits)
  ''',
        description:
            'Use the `append()` method to add an element to the end of a list.',
        lessonKey: 'lists',
      ),
      buildLessonCard(
        title: '5. Removing Elements from a List',
        code: '''
fruits = ["apple", "banana", "cherry"]
fruits.remove("banana")
print(fruits)
  ''',
        description:
            'Use the `remove()` method to delete a specific element from a list.',
        lessonKey: 'lists',
      ),
      buildLessonCard(
        title: '6. List Slicing',
        code: '''
fruits = ["apple", "banana", "cherry", "date"]
print(fruits[1:3])  # Output: ['banana', 'cherry']
  ''',
        description:
            'Use slicing to extract a portion of a list. The syntax is `list[start:end]`.',
        lessonKey: 'lists',
      ),
      buildLessonCard(
        title: '7. Looping Through a List',
        code: '''
fruits = ["apple", "banana", "cherry"]
for fruit in fruits:
    print(fruit)
  ''',
        description: 'Use a `for` loop to iterate through elements in a list.',
        lessonKey: 'lists',
      ),
      buildLessonCard(
        title: '8. Sorting a List',
        code: '''
fruits = ["banana", "cherry", "apple"]
fruits.sort()
print(fruits)
  ''',
        description:
            'Use the `sort()` method to sort a list in ascending order.',
        lessonKey: 'lists',
      ),
      buildLessonCard(
        title: '9. List Comprehensions',
        code: '''
numbers = [x for x in range(5)]
print(numbers)
  ''',
        description:
            'List comprehensions provide a concise way to create lists.',
        lessonKey: 'lists',
      ),
      buildLessonCard(
        title: '10. Copying a List',
        code: '''
original = ["apple", "banana", "cherry"]
copy = original.copy()
print(copy)
  ''',
        description: 'Use the `copy()` method to make a duplicate of a list.',
        lessonKey: 'lists',
      ),
      buildLessonCard(
        title: '1. Introduction to Tuples',
        code: '''
# Creating a tuple
fruits = ("apple", "banana", "cherry")
print(fruits)
  ''',
        description:
            'Tuples in Python are ordered and immutable. They cannot be modified after creation.',
        lessonKey: 'tuples',
      ),
      buildLessonCard(
        title: '2. Accessing Elements in a Tuple',
        code: '''
fruits = ("apple", "banana", "cherry")
print(fruits[0])  # Output: apple
print(fruits[-1])  # Output: cherry
  ''',
        description:
            'Access elements in a tuple using indexing. Negative indices start from the end.',
        lessonKey: 'tuples',
      ),
      buildLessonCard(
        title: '3. Unpacking Tuples',
        code: '''
fruits = ("apple", "banana", "cherry")
a, b, c = fruits
print(a, b, c)
  ''',
        description:
            'Unpacking allows you to assign tuple elements to variables directly.',
        lessonKey: 'tuples',
      ),
      buildLessonCard(
        title: '4. Looping Through a Tuple',
        code: '''
fruits = ("apple", "banana", "cherry")
for fruit in fruits:
    print(fruit)
  ''',
        description: 'Use a `for` loop to iterate through elements in a tuple.',
        lessonKey: 'tuples',
      ),
      buildLessonCard(
        title: '5. Tuple Concatenation',
        code: '''
tuple1 = ("apple", "banana")
tuple2 = ("cherry", "date")
result = tuple1 + tuple2
print(result)
  ''',
        description: 'Use the `+` operator to concatenate tuples.',
        lessonKey: 'tuples',
      ),
      buildLessonCard(
        title: '6. Tuple Length',
        code: '''
fruits = ("apple", "banana", "cherry")
print(len(fruits))
  ''',
        description:
            'Use the `len()` function to find the number of elements in a tuple.',
        lessonKey: 'tuples',
      ),
      buildLessonCard(
        title: '7. Tuple Membership',
        code: '''
fruits = ("apple", "banana", "cherry")
print("banana" in fruits)  # True
  ''',
        description:
            'Use the `in` keyword to check if an element exists in a tuple.',
        lessonKey: 'tuples',
      ),
      buildLessonCard(
        title: '8. Immutable Nature of Tuples',
        code: '''
fruits = ("apple", "banana", "cherry")
# fruits[1] = "orange"  # This will raise an error
print(fruits)
  ''',
        description:
            'Tuples are immutable, meaning their elements cannot be changed after creation.',
        lessonKey: 'tuples',
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

class DragAndDropGame extends StatefulWidget {
  const DragAndDropGame({super.key});

  @override
  _DragAndDropGameState createState() => _DragAndDropGameState();
}

class _DragAndDropGameState extends State<DragAndDropGame> {
  int currentLevel = 1;
  bool isLevelComplete = false;
  List<String> codeBlocks = [];
  List<String> correctOrder = [];
  List<String> userOrder = [];

  // ✅ Track progress
  Map<String, dynamic> levelProgress = {
    'level1': false,
    'level2': false,
    'level3': false,
    'level4': false,
    'level5': false,
  };

  // ✅ List of levels
  final List<Map<String, dynamic>> levels = [
    {
      'title': 'Level 1: Create and Print a List',
      'description':
          'Drag the code blocks to create a list named `fruits` and print it.',
      'codeBlocks': [
        'fruits = [',
        '"apple"',
        ', "banana"',
        ', "cherry"',
        ']',
        'print(',
        'fruits',
        ')',
      ],
      'correctOrder': [
        'fruits = [',
        '"apple"',
        ', "banana"',
        ', "cherry"',
        ']',
        'print(',
        'fruits',
        ')',
      ],
    },
    {
      'title': 'Level 2: Add an Item to a List',
      'description': 'Drag the code blocks to add "orange" to the list.',
      'codeBlocks': [
        'fruits.append(',
        '"orange"',
        ')',
      ],
      'correctOrder': [
        'fruits.append(',
        '"orange"',
        ')',
      ],
    },
    {
      'title': 'Level 3: Remove an Item from a List',
      'description': 'Drag the code blocks to remove "banana" from the list.',
      'codeBlocks': [
        'fruits.remove(',
        '"banana"',
        ')',
      ],
      'correctOrder': [
        'fruits.remove(',
        '"banana"',
        ')',
      ],
    },
    {
      'title': 'Level 4: Create and Print a Tuple',
      'description':
          'Drag the code blocks to create a tuple named `colors` and print it.',
      'codeBlocks': [
        'colors = (',
        '"red"',
        ', "green"',
        ', "blue"',
        ')',
        'print(',
        'colors',
        ')',
      ],
      'correctOrder': [
        'colors = (',
        '"red"',
        ', "green"',
        ', "blue"',
        ')',
        'print(',
        'colors',
        ')',
      ],
    },
    {
      'title': 'Level 5: Access an Element in a Tuple',
      'description':
          'Drag the code blocks to access and print the first element of the tuple `colors`.',
      'codeBlocks': [
        'print(colors[',
        '0',
        '])',
      ],
      'correctOrder': [
        'print(colors[',
        '0',
        '])',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadGameProgress();
  }

  // ✅ Load progress from Firebase
  Future<void> _loadGameProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("❌ No user signed in.");
      return;
    }

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('gameProgress')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        print("✅ Game progress loaded: ${doc.data()}");
        setState(() {
          levelProgress = Map<String, dynamic>.from(doc.data() as Map);
          _setLastCompletedLevel();
        });
      } else {
        print("❌ No progress found. Initializing...");
        await _initializeGameProgress(user.uid);
      }
    } catch (e) {
      print("❌ Error loading game progress: $e");
    }
  }

  // ✅ Initialize progress for new user
  Future<void> _initializeGameProgress(String userId) async {
    levelProgress = {
      'level1': false,
      'level2': false,
      'level3': false,
      'level4': false,
      'level5': false,
    };
    await FirebaseFirestore.instance
        .collection('gameProgress')
        .doc(userId)
        .set(levelProgress);
    print("✅ Game progress initialized for new user.");
    _setLastCompletedLevel();
  }

  void _setLastCompletedLevel() {
    if (_checkAllLevelsCompleted()) {
      setState(() {
        currentLevel = 0; // No levels left
      });
    } else {
      for (int i = 1; i <= levels.length; i++) {
        if (levelProgress['level$i'] != true) {
          currentLevel = i;
          break;
        }
      }
    }
    _loadLevel();
  }

  // ✅ Check if all levels are completed
  bool _checkAllLevelsCompleted() {
    return levelProgress.values.every((completed) => completed == true);
  }

  Future<void> _updateGameProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String levelKey = 'level$currentLevel';
    levelProgress[levelKey] = true;

    try {
      await FirebaseFirestore.instance
          .collection('gameProgress')
          .doc(user.uid)
          .set(levelProgress, SetOptions(merge: true));

      print("✅ Level progress updated successfully!");

      // ✅ Step 6: Check if all levels are done
      if (_checkAllLevelsCompleted()) {
        await FirebaseFirestore.instance
            .collection('gameProgress')
            .doc(user.uid)
            .set({'allLevelsCompleted': true}, SetOptions(merge: true));

        print("🏆 All levels completed. Unlocking lesson.");
      }
    } catch (e) {
      print("❌ Error updating game progress: $e");
    }
  }

  // ✅ Load the current level
  void _loadLevel() {
    if (currentLevel > 0 && currentLevel <= levels.length) {
      final level = levels[currentLevel - 1];
      setState(() {
        codeBlocks = List.from(level['codeBlocks']);
        correctOrder = List.from(level['correctOrder']);
        userOrder = [];
        isLevelComplete = false;
      });
      _shuffleCodeBlocks();
    }
  }

  // ✅ Shuffle code blocks
  void _shuffleCodeBlocks() {
    if (codeBlocks.isNotEmpty) {
      setState(() {
        codeBlocks.shuffle();
      });
    }
  }

  // ✅ Check if user solution is correct
  void _checkSolution() {
    if (userOrder.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🚫 Drag and arrange code blocks first!')),
      );
      return;
    }

    if (_areListsEqual(userOrder, correctOrder)) {
      setState(() {
        isLevelComplete = true;
      });
      _updateGameProgress();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Correct! Moving to the next level. 🎉'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Try again!')),
      );
    }
  }

  // ✅ Compare two lists to check correctness
  bool _areListsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].trim() != list2[i].trim()) {
        return false;
      }
    }
    return true;
  }

  // ✅ Move to the next level or show completion message
  void _nextLevel() {
    if (_checkAllLevelsCompleted()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              '🎉 All levels are complete! You can proceed to the next module. 🏆'),
        ),
      );
      return;
    }

    if (currentLevel < levels.length) {
      setState(() {
        currentLevel++;
      });
      _loadLevel();
    }
  }

  // ✅ Remove a block from user order
  void _removeBlock(int index) {
    setState(() {
      codeBlocks.add(userOrder[index]); // Return block to original area
      userOrder.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Show completion message if all levels are complete
    if (_checkAllLevelsCompleted()) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🎉 Congratulations! You have completed all the levels. 🏆',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Listandtuples()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Now you can move to next lesson',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final level = levels[currentLevel - 1];
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              level['title'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: codeBlocks.map((block) {
                return Draggable<String>(
                  data: block,
                  feedback: Material(
                    elevation: 3,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.blue[300],
                      child: Text(
                        block,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  childWhenDragging: Container(),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      block,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 25),
            DragTarget<String>(
              onAcceptWithDetails: (details) {
                final String data = details.data; // Extract data correctly
                if (data.isNotEmpty) {
                  setState(() {
                    userOrder.add(data);
                    codeBlocks.remove(data);
                  });
                } else {
                  print("⚠️ Data is empty or invalid!");
                }
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  height: 75,
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(userOrder.length, (index) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                userOrder[index],
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 5),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                color: Colors.red,
                                onPressed: () => _removeBlock(index),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _checkSolution,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Check Solution',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            if (isLevelComplete)
              ElevatedButton(
                onPressed: _nextLevel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Next Level',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
