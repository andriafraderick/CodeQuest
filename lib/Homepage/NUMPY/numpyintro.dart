import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../LESSONS/coderunner.dart';

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
      home: const numintro(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class numintro extends StatefulWidget {
  const numintro({super.key});

  @override
  _SetsState createState() => _SetsState();
}

class _SetsState extends State<numintro> {
  bool isLessonComplete = false;

  @override
  void initState() {
    super.initState();
    getLessonProgress();
  }

  Future<void> getLessonProgress() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "test_user";
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('levelgame')
        .doc(userId)
        .get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      setState(() {
        isLessonComplete = data['numpylessons']?['numintro'] ?? false;
      });
    }
  }

  void completeLesson(String lessonName) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "test_user";

    // Save lesson completion to Firestore
    await FirebaseFirestore.instance.collection('levelgame').doc(userId).set({
      'numpylessons': {lessonName: true}
    }, SetOptions(merge: true));

    // Refresh the lesson completion status
    await getLessonProgress(); // ✅ Refresh progress
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Numpy intro'),
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
                        'Numpy intro Lessons',
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
          completeLesson("numintro");
          Navigator.pop(context, true);
        },
        child: const Text('Complete Lesson'),
      ),
    );
  }

  List<Widget> buildLessonCards() {
    return <Widget>[
      buildLessonCard(
        title: '1. What is NumPy?',
        code: '',
        description:
            'NumPy is a Python library used for working with arrays.\nIt also has functions for working in domain of linear algebra, fourier transform, and matrices.\nNumPy was created in 2005 by Travis Oliphant. It is an open source project and you can use it freely.\nNumPy stands for Numerical Python.',
        lessonKey: 'numintro',
      ),
      buildLessonCard(
        title: '2. Why Use NumPy?',
        code: '',
        description:
            'In Python we have lists that serve the purpose of arrays, but they are slow to process.\nNumPy aims to provide an array object that is up to 50x faster than traditional Python lists.\n The array object in NumPy is called ndarray, it provides a lot of supporting functions that make working with ndarray very easy.\n Arrays are very frequently used in data science, where speed and resources are very important.\n\n Data Science\: is a branch of computer science where we study how to store, use and analyze data for deriving information from it.',
        lessonKey: 'numintro',
      ),
      buildLessonCard(
        title: '3. Why is NumPy Faster Than Lists?',
        code: '',
        description:
            'NumPy arrays are stored at one continuous place in memory, unlike lists, so processes can access and manipulate them very efficiently.\nThis behavior is called locality of reference in computer science.\n This is the main reason why NumPy is faster than lists. Also, it is optimized to work with the latest CPU architectures.',
        lessonKey: 'numintro',
      ),
      buildLessonCard(
        title: '4. Which Language is NumPy Written In?',
        code: '',
        description:
            'NumPy is a Python library and is written partially in Python, but most of the parts that require fast computation are written in C or C++.',
        lessonKey: 'numintro',
      ),
      buildLessonCard(
        title: '5. Installation of NumPy',
        code: 'C:\Users\Your Name>pip install numpy',
        description:
            'If you have Python and PIP already installed on a system, then installation of NumPy is very easy.\nInstall it using this command:',
        lessonKey: 'numintro',
      ),
      buildLessonCard(
        title: '6. Import NumPy',
        code: 'import numpy',
        description:
            'Once NumPy is installed, import it in your applications by adding the import keyword:',
        lessonKey: 'numintro',
      ),
      buildLessonCard(
        title: '7. Example:',
        code: 'import numpy\n arr = numpy.array([1, 2, 3, 4, 5])\nprint(arr)',
        description: '',
        lessonKey: 'numintro',
      ),
      buildLessonCard(
        title: '8. NumPy as np',
        code:
            'import numpy as np\n arr = numpy.array([1, 2, 3, 4, 5])\nprint(arr)',
        description:
            'NumPy is usually imported under the np alias.\nalias: In Python alias are an alternate name for referring to the same thing.\nCreate an alias with the as keyword while importing:',
        lessonKey: 'numintro',
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
            if (code
                .isNotEmpty) // Check if code is not empty before showing the white box
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
