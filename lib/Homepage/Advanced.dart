import 'dart:convert';
import 'package:finalprojects8/Homepage/profile.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:finalprojects8/Homepage/login_register.dart';
import 'package:finalprojects8/Homepage/Intermediate.dart';
import 'package:finalprojects8/Homepage/beginner.dart';

class Advanced extends StatefulWidget {
  const Advanced({super.key});

  @override
  _AdvancedState createState() => _AdvancedState();
}

class _AdvancedState extends State<Advanced> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User _currentUser;
  List<bool> levelCompletion = List.generate(20, (index) => false);
  bool isIntermediateUnlocked = false;
  bool isAdvancedUnlocked = false;
  int currentLevel = 1;
  int currentStreak = 0;
  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    fetchUserProgress();
    _loadStreakData();
  }

  Future<void> _loadStreakData() async {
    try {
      DocumentSnapshot streakDoc =
          await _firestore.collection('streaks').doc(_currentUser.uid).get();

      if (streakDoc.exists) {
        setState(() {
          currentStreak = streakDoc['streak'] ?? 0;
        });
      }
    } catch (e) {
      print("Error loading streak data: $e");
    }
  }

  void fetchUserProgress() async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_currentUser.uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        bool intermediateUnlocked = userDoc['IntermediateUnlocked'] ?? false;
        bool advancedUnlocked = userDoc['AdvancedUnlocked'] ?? false;

        setState(() {
          isIntermediateUnlocked = intermediateUnlocked;
          isAdvancedUnlocked = advancedUnlocked;
        });
      }

      DocumentSnapshot advancedLevelsDoc = await _firestore
          .collection('Advancedlevels')
          .doc(_currentUser.uid)
          .get();

      if (advancedLevelsDoc.exists && advancedLevelsDoc.data() != null) {
        Map<String, dynamic>? levels = advancedLevelsDoc['levels'];
        for (int i = 0; i < 20; i++) {
          levelCompletion[i] = levels?['level${i + 1}'] ?? false;
        }
      }

      setState(() {});
    } catch (e) {
      print("Error fetching user progress: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 177, 238, 107),
        title: Row(
          children: [
            Text(
              'Advanced',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department,
                      color: Colors.orange, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '$currentStreak',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 16, 11, 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginRegister()),
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Navigation',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              title: const Text('Beginner'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Beginner()),
                );
              },
            ),
            ListTile(
              title: const Text('Intermediate'),
              enabled: isIntermediateUnlocked,
              onTap: isIntermediateUnlocked
                  ? () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Intermediate()),
                      );
                    }
                  : null,
            ),
            ListTile(
              title: const Text('Advanced'),
              enabled: isAdvancedUnlocked,
              onTap: isAdvancedUnlocked
                  ? () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Advanced()),
                      );
                    }
                  : null,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/images/py_machine.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: LevelSelectionPage(
                  levelCompletion: levelCompletion,
                  onLevelSelected: (level) {
                    setState(() {
                      currentLevel = level;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LevelPage(
                          level: level,
                          question: _getQuestionForLevel(level),
                          expectedOutput: _getExpectedOutputForLevel(level),
                          onLevelComplete: () {
                            setState(() {
                              levelCompletion[level - 1] = true;
                              _updateLevelProgress(level);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getQuestionForLevel(int level) {
    if (level == 1) {
      return """
    Level 1: Basic Arithmetic
    
    Problem statement: 
    Write a function that adds two integers and returns the result.
    
    Example:
    Input: 3, 5
    Output: 8
  """;
    } else if (level == 2) {
      return """
    Level 2: String Reversal
    
    Problem statement: 
    Write a function that takes a string as input and returns the string reversed.
    
    Example:
    Input: "hello"
    Output: "olleh"
  """;
    } else if (level == 3) {
      return """
    Level 3: FizzBuzz
    
    Problem statement:
    Write a function that prints numbers from 1 to n, replacing multiples of 3 with "Fizz", multiples of 5 with "Buzz", and multiples of both with "FizzBuzz".
    
    Example:
    Input: 15
    Output: 1, 2, Fizz, 4, Buzz, Fizz, 7, 8, Fizz, Buzz, 11, Fizz, 13, 14, FizzBuzz,
  """;
    } else if (level == 4) {
      return """
    Level 4: Fibonacci Sequence
    
    Problem statement:
    Write a function that returns the nth Fibonacci number.
    
    Example:
    Input: 6
    Output: 5
  """;
    } else if (level == 5) {
      return """
    Level 5: Palindrome Checker
    
    Problem statement:
    Write a function to check if a string is a palindrome.
    
    Example:
    Input: "madam"
    Output: true
  """;
    } else if (level == 6) {
      return """
    Level 6: Prime Number Checker
    
    Problem statement:
    Write a function to check if a number is prime.
    
    Example:
    Input: 7
    Output: true
  """;
    } else if (level == 7) {
      return """
    Level 7: Sum of Digits
    
    Problem statement:
    Write a function to return the sum of an integer's digits.
    
    Example:
    Input: 123
    Output: 6
  """;
    } else if (level == 8) {
      return """
    Level 8: Merge Two Sorted Lists
    
    Problem statement:
    Write a function to merge two sorted arrays into one sorted array.
    
    Example:
    Input: [1, 3, 5], [2, 4, 6]
    Output: [1, 2, 3, 4, 5, 6]
  """;
    } else if (level == 9) {
      return """
    Level 9: Anagram Checker
    
    Problem statement:
    Write a function to check if two words are anagrams.
    
    Example:
    Input: "listen", "silent"
    Output: true
  """;
    } else if (level == 10) {
      return """
    Level 10: Factorial Calculation
    
    Problem statement:
    Write a function to return the factorial of a number.
    
    Example:
    Input: 5
    Output: 120
  """;
    } else if (level == 11) {
      return """
    Level 11: GCD Calculation
    
    Problem statement:
    Write a function to find the greatest common divisor (GCD) of two numbers.
    
    Example:
    Input: 12, 18
    Output: 6
  """;
    } else if (level == 12) {
      return """
    Level 12: Binary Search
    
    Problem statement:
    Implement binary search to find a target number in a sorted list.
    
    Example:
    Input: [1, 3, 5, 7, 9], target = 5
    Output: 2
  """;
    } else if (level == 13) {
      return """
    Level 13: Two Sum Problem
    
    Problem statement:
    Find two numbers in an array that sum to a given target.
    
    Example:
    Input: [2, 7, 11, 15], target = 9
    Output: [0, 1]
  """;
    } else if (level == 14) {
      return """
    Level 14: Bubble Sort
    
    Problem statement:
    Implement bubble sort to sort an array.
    
    Example:
    Input: [5, 3, 8, 1]
    Output: [1, 3, 5, 8]
  """;
    } else if (level == 15) {
      return """
    Level 15: Matrix Transposition
    
    Problem statement:
    Write a function to transpose a matrix.
    
    Example:
    Input: [[1, 2], [3, 4]]
    Output: [[1, 3], [2, 4]]
  """;
    } else if (level == 16) {
      return """
    Level 16: Valid Parentheses Checker
    
    Problem statement:
    Write a function to check if a string contains valid parentheses.
    
    Example:
    Input: "(())"
    Output: true
  """;
    } else if (level == 17) {
      return """
    Level 17: Reverse a Linked List
    
    Problem statement:
    Write a function to reverse a linked list.
    
    Example:
    Input: 1 -> 2 -> 3 -> 4
    Output: 4 -> 3 -> 2 -> 1
  """;
    } else if (level == 18) {
      return """
    Level 18: Graph Traversal (DFS & BFS)
    
    Problem statement:
    Implement depth-first search (DFS) and breadth-first search (BFS).
  """;
    } else if (level == 19) {
      return """
    Level 19: Dijkstra's Algorithm
    
    Problem statement:
    Implement Dijkstra’s algorithm to find the shortest path.
  """;
    } else if (level == 20) {
      return """
    Level 20: Knapsack Problem (Dynamic Programming)
    
    Problem statement:
    Solve the 0/1 Knapsack problem using dynamic programming.
  """;
    }
    return "";
  }

  String _getExpectedOutputForLevel(int level) {
    if (level == 1) {
      return "8";
    } else if (level == 2)
      return "olleh";
    else if (level == 3)
      return "1, 2, Fizz, 4, Buzz, Fizz, 7, 8, Fizz, Buzz, 11, Fizz, 13, 14, FizzBuzz,";
    else if (level == 4)
      return "5";
    else if (level == 5)
      return "true";
    else if (level == 6)
      return "true";
    else if (level == 7)
      return "6";
    else if (level == 8)
      return "[1, 2, 3, 4, 5, 6]";
    else if (level == 9)
      return "true";
    else if (level == 10)
      return "120";
    else if (level == 11)
      return "6";
    else if (level == 12)
      return "2";
    else if (level == 13)
      return "[0, 1]";
    else if (level == 14)
      return "[1, 3, 5, 8]";
    else if (level == 15)
      return "[[1, 3], [2, 4]]";
    else if (level == 16)
      return "true";
    else if (level == 17)
      return "4 -> 3 -> 2 -> 1";
    else if (level == 18)
      return "Graph traversal order";
    else if (level == 19)
      return "Shortest path";
    else if (level == 20) return "Maximum value that fits in the bag";
    return "";
  }

  void _updateLevelProgress(int level) async {
    try {
      await _firestore.collection('Advancedlevels').doc(_currentUser.uid).set({
        'levels': {
          'level$level': true,
        }
      }, SetOptions(merge: true));

      print("Level $level progress saved successfully.");
    } catch (e) {
      print("Error saving level progress: $e");
    }
  }
}

class LevelPage extends StatefulWidget {
  final int level;
  final String question;
  final String expectedOutput;
  final VoidCallback onLevelComplete;

  const LevelPage({
    super.key,
    required this.level,
    required this.question,
    required this.expectedOutput,
    required this.onLevelComplete,
  });

  @override
  _LevelPageState createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  final TextEditingController _codeController = TextEditingController();
  String output = '';
  String error = '';
  bool isLoading = false;
  bool isLevelCompleted = false;

  Future<void> runCode() async {
    final code = _codeController.text;
    final Uri url = Uri.parse('https://codequest-iuxe.onrender.com/run');
    setState(() {
      isLoading = true;
      output = '';
      error = '';
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code}),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
          output = result['output'] ?? 'No output';
          error = result['error'] ?? 'No error';
        });
        if (output.trim() == widget.expectedOutput.trim()) {
          widget.onLevelComplete();
          setState(() {
            isLevelCompleted = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Congratulations! Level completed.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incorrect. Try again.')),
          );
        }
      } else {
        setState(() {
          error = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Could not connect to server: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void goToNextLevel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Mild background
      appBar: AppBar(
        title: Text('Level ${widget.level}',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey[900],
        centerTitle: true,
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level Title
            Text(
              "📝 Task: ${widget.question}",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[900]),
            ),
            const SizedBox(height: 16),

            // Code Input Box
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 11, 11, 11),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 239, 237, 237)
                          .withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _codeController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 248, 248, 248),
                      fontFamily: 'monospace',
                      fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Write your Python code here...',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Run Code Button
            Center(
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : runCode,
                icon: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.play_arrow, color: Colors.white),
                label: const Text("Run Code",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[800],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Output & Error Display
            if (output.isNotEmpty)
              buildResultCard(
                  "Output", output, Colors.green[50], Colors.green[900]!),
            if (error.isNotEmpty)
              buildResultCard("Error", error, Colors.red[50], Colors.red[900]!),

            // Next Level Button
            if (isLevelCompleted)
              Center(
                child: ElevatedButton(
                  onPressed: goToNextLevel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Next Lesson",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildResultCard(
      String title, String content, Color? bgColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          "$title:",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blueGrey[900]),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            content,
            style: TextStyle(
                fontFamily: 'monospace', fontSize: 14, color: textColor),
          ),
        ),
      ],
    );
  }
}

class LevelSelectionPage extends StatelessWidget {
  final List<bool> levelCompletion;
  final Function(int) onLevelSelected;

  const LevelSelectionPage({
    super.key,
    required this.levelCompletion,
    required this.onLevelSelected,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Level")),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/py1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3, // Wider design
                ),
                itemCount: levelCompletion.length,
                itemBuilder: (context, index) {
                  final level = index + 1;
                  final isCompleted = levelCompletion[index];
                  final isUnlocked = index == 0 || levelCompletion[index - 1];

                  return GestureDetector(
                    onTap: isUnlocked ? () => onLevelSelected(level) : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.white
                            : isUnlocked
                                ? Colors.blue[50]
                                : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(4, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Level $level",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isCompleted
                                      ? Colors.green[700]
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Icon(
                                isCompleted
                                    ? Icons.check_circle
                                    : isUnlocked
                                        ? Icons.play_arrow
                                        : Icons.lock_outline,
                                size: 28,
                                color: isCompleted
                                    ? Colors.green
                                    : isUnlocked
                                        ? Colors.blue[700]
                                        : Colors.grey[600],
                              ),
                            ],
                          ),
                          if (!isUnlocked)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.lock,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
