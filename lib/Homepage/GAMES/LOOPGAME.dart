import 'dart:convert';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoopLearningGame extends StatefulWidget {
  const LoopLearningGame({super.key});

  @override
  _LoopLearningGameState createState() => _LoopLearningGameState();
}

class _LoopLearningGameState extends State<LoopLearningGame>
    with SingleTickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  String output = '';
  String error = '';
  bool isLoading = false;
  int currentLevel = 1;
  bool isLevelComplete = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late ConfettiController _confettiController;

  final List<Map<String, String>> levels = [
    {
      'title': 'Level 1: Print Numbers',
      'description': 'Use a `for` loop to print numbers from 1 to 5.',
      'expectedOutput': '1\n2\n3\n4\n5\n',
    },
    {
      'title': 'Level 2: Sum of Numbers',
      'description':
          'Use a `for` loop to calculate the sum of numbers from 1 to 10.',
      'expectedOutput': '55',
    },
    {
      'title': 'Level 3: Print Even Numbers',
      'description': 'Use a `for` loop to print even numbers between 1 and 10.',
      'expectedOutput': '2\n4\n6\n8\n10\n',
    },
    {
      'title': 'Level 4: Reverse a String',
      'description': 'Use a `for` loop to reverse the string "Python".',
      'expectedOutput': 'nohtyP',
    },
    {
      'title': 'Level 5: While Loop',
      'description': 'Use a `while` loop to print numbers from 1 to 5.',
      'expectedOutput': '1\n2\n3\n4\n5\n',
    },
  ];

  @override
  void initState() {
    super.initState();
    getLevelProgress();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  // ---------------- GET LEVEL PROGRESS ----------------
  Future<void> getLevelProgress() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "test_user";
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('levelgame')
        .doc(userId)
        .get();

    if (doc.exists && doc.data() != null) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      setState(() {
        currentLevel = data?['currentLevel'] ?? 1;
      });
    }
  }

  // ---------------- SAVE LEVEL PROGRESS ----------------
  Future<void> saveLevelProgress() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "test_user";
    await FirebaseFirestore.instance.collection('levelgame').doc(userId).set(
      {
        'currentLevel': currentLevel,
      },
      SetOptions(merge: true),
    );
  }

  // ---------------- RUN CODE ----------------
  Future<void> runCode() async {
    final code = _codeController.text;
    final Uri url = Uri.parse(
        'https://codequest-iuxe.onrender.com/run'); // Flask backend URL

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

        if (output.trim() ==
            levels[currentLevel - 1]['expectedOutput']?.trim()) {
          setState(() {
            isLevelComplete = true;
            _confettiController.play(); // Trigger confetti 🎉
          });
          _animationController.forward(from: 0.0);
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

  // ---------------- MOVE TO NEXT LEVEL ----------------
  void nextLevel() async {
    if (currentLevel < levels.length) {
      setState(() {
        currentLevel++;
        isLevelComplete = false;
        _codeController.clear();
        output = '';
        error = '';
      });
      await saveLevelProgress(); // Save progress after level up
    } else {
      await saveLevelProgress();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Congratulations! You completed all levels.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentChallenge = levels[currentLevel - 1];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🎯 Loop Learning Game',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigoAccent,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: currentLevel / levels.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                const SizedBox(height: 20),
                Text(
                  currentChallenge['title']!,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  currentChallenge['description']!,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _codeController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'Write your Python code here...',
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : runCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 248, 249, 251),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                '🚀 Run Code',
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                if (output.isNotEmpty) buildResultCard('✅ Output', output),
                if (error.isNotEmpty) buildResultCard('❌ Error', error),
                if (isLevelComplete)
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Level Complete! 🎉',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: nextLevel,
                        child: const Text('Next Level'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.yellow
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildResultCard(String title, String content) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title:',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 8),
          SelectableText(
            content,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
          ),
        ],
      ),
    );
  }
}
