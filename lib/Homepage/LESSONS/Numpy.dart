import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalprojects8/Homepage/Intermediate.dart';
import 'package:finalprojects8/Homepage/NUMPY/arrays.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:finalprojects8/Homepage/LESSONS/intro.dart';
import 'package:finalprojects8/Homepage/LESSONS/quizint.dart';

import '../NUMPY/arith.dart';
import '../NUMPY/arrayindex.dart';
import '../NUMPY/arrayslicing.dart';
import '../NUMPY/copy.dart';
import '../NUMPY/createfun.dart';
import '../NUMPY/datatypes.dart';
import '../NUMPY/iterate.dart';
import '../NUMPY/numpyintro.dart';
import '../NUMPY/search.dart';
import '../NUMPY/sort.dart';
import '../NUMPY/tri.dart';
import '../NUMPY/unfunc.dart';

class Numpy extends StatefulWidget {
  Numpy({super.key});

  @override
  State<Numpy> createState() => _NewLessonsPageState();
}

class _NewLessonsPageState extends State<Numpy> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User _currentUser;
  bool allLessonsCompleted = false;

  List<bool> lessonCompletion = [];
  final buttonNames = [
    'Numpy intro',
    'Creating Arrays',
    'Array indexing',
    'Array Slicing',
    'Data Types',
    'Copy vs View',
    'Array Iterating',
    'Array Search',
    'Array Sort',
    'Universal Functions',
    'unfunc create',
    'Simple Arithmetic',
    'Trigonometric',
  ];

  final pages = [
    const numintro(),
    const creatingArrays(),
    const indexArrays(),
    const sliceArrays(),
    const data(),
    const copy(),
    const iterateArrays(),
    const searchArrays(),
    const sortArrays(),
    const unfunc(),
    const createfun(),
    const arith(),
    const tri(),
  ];

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    fetchLessonProgress();
  }

  void fetchLessonProgress() async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('levelgame').doc(_currentUser.uid).get();

      List<bool> progress = List.generate(buttonNames.length, (index) => false);

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic>? lessons = userDoc['numpylessons'];
        if (lessons != null) {
          for (int i = 0; i < buttonNames.length; i++) {
            progress[i] = lessons[buttonNames[i]] ?? false;
          }
        }
      }

      bool completed = progress.every((status) => status);

      setState(() {
        lessonCompletion = progress;
        allLessonsCompleted = completed;
      });
    } catch (e) {
      print("Error fetching lesson progress: $e");
    }
  }

  void _navigateTohome() async {
    String userId = _currentUser.uid;

    try {
      // ✅ Mark Numpy as completed directly in users -> userId -> intlessons
      await _firestore.collection('users').doc(userId).set({
        'intlessons': {
          'Numpy': true, // ✅ Set Numpy lesson as completed
        }
      }, SetOptions(merge: true));

      print("✅ Numpy marked as completed in users -> intlessons");

      // ✅ Navigate to the Intermediate page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Intermediate()),
      );
    } catch (e) {
      print("❌ Error marking Numpy as completed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Numpy Lessons',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/images/py1.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: buttonNames.length,
                  itemBuilder: (context, index) {
                    final lessonName = buttonNames[index];
                    final isCompleted =
                        lessonCompletion.isNotEmpty && lessonCompletion[index];
                    final isUnlocked = index == 0 ||
                        (lessonCompletion.isNotEmpty &&
                            lessonCompletion[index - 1]);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(
                        child: SizedBox(
                          width: 250,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: isUnlocked
                                ? () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => pages[index]),
                                    );

                                    if (result == true) {
                                      await _firestore
                                          .collection('levelgame')
                                          .doc(_currentUser.uid)
                                          .set({
                                        'numpylessons': {
                                          buttonNames[index]: true
                                        }
                                      }, SetOptions(merge: true));
                                      fetchLessonProgress();
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: isCompleted
                                  ? Colors.green
                                  : isUnlocked
                                      ? Colors.white
                                      : Colors.grey.shade400,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                lessonName,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: isCompleted
                                      ? Colors.black
                                      : Colors.grey.shade800,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (allLessonsCompleted)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed:
                        _navigateTohome, // ✅ Trigger lesson completion and navigation
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 79, 173, 250),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Completed",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
