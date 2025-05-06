import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalprojects8/Homepage/Advanced.dart';
import 'package:finalprojects8/Homepage/Intermediate.dart';
import 'package:finalprojects8/Homepage/LESSONS/quizint.dart';
import 'package:finalprojects8/Homepage/beginner.dart';
import 'package:finalprojects8/Homepage/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:finalprojects8/Homepage/LESSONS/quizpage.dart';
import 'package:finalprojects8/Homepage/login_register.dart';
import 'LESSONS/Functionmod.dart';
import 'LESSONS/Inheritance.dart';
import 'LESSONS/Numpy.dart';
import 'LESSONS/Pandas.dart';
import 'LESSONS/Polymorphism.dart';
import 'LESSONS/Regularexp.dart';
import 'LESSONS/advoopconc.dart';
import 'LESSONS/datastr.dart';
import 'LESSONS/errorandexcp.dart';
import 'LESSONS/filehand.dart';

class Intermediate extends StatefulWidget {
  const Intermediate({super.key});

  @override
  State<Intermediate> createState() => _HomeState();
}

class _HomeState extends State<Intermediate> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User _currentUser;
  int userScore = 0;
  bool isIntermediateUnlocked = false;
  bool isAdvancedUnlocked = false;
  bool allLessonsCompleted = false;
  int currentStreak = 0;
  List<bool> lessonCompletion = [];
  final buttonNames = [
    'File handling',
    'Function and Modules',
    'Error and Exception Handling',
    'Data Structure',
    'Python Inheritance',
    'Polymorphism',
    'Regular Expression',
    'Numpy',
  ];

  final pages = [
    const Filehand(),
    const Functionandmodules(),
    const Errorandexp(),
    const Datastructure(),
    const Inheritance(),
    const Polymorphism(),
    const Regularexpr(),
    Numpy(),
  ];
  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    updateIntermediateUnlocked();
    checkAdvancedUnlocked();
    fetchLessonProgress();
    _loadStreakData(); // Add this line
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

  void updateIntermediateUnlocked() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'IntermediateUnlocked': true,
      });
    }
  }

  void fetchLessonProgress() async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_currentUser.uid).get();

      List<bool> progress = List.generate(buttonNames.length, (index) => false);

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic>? lessons = userDoc['intlessons'];
        for (int i = 0; i < buttonNames.length; i++) {
          progress[i] = lessons?[buttonNames[i]] ?? false;
        }
      }

      bool completed = progress.every((status) => status);

      setState(() {
        lessonCompletion = progress;
        allLessonsCompleted = completed;
      });

      checkAdvancedUnlocked();
    } catch (e) {
      print("Error fetching lesson progress: $e");
    }
  }

  void checkAdvancedUnlocked() async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_currentUser.uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        bool unlocked = userDoc['AdvancedUnlocked'] ?? false;

        setState(() {
          isAdvancedUnlocked = unlocked; // Update Intermediate button state
        });

        print("Advanced Unlocked: $isAdvancedUnlocked");
      }
    } catch (e) {
      print("Error checking IntermediateUnlocked: $e");
    }
  }

  void _navigateToQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Quiz2()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'Intermediate',
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
                                          .collection('users')
                                          .doc(_currentUser.uid)
                                          .set({
                                        'intlessons': {buttonNames[index]: true}
                                      }, SetOptions(merge: true));
                                      fetchLessonProgress();
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: isCompleted
                                  ? const Color.fromARGB(255, 132, 236, 101)
                                  : isUnlocked
                                      ? const Color.fromARGB(255, 232, 229, 229)
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
                                      ? const Color.fromARGB(255, 16, 15, 15)
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
              if (allLessonsCompleted && !isAdvancedUnlocked)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _navigateToQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Take Quiz",
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
