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
      home: const creatingArrays(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class creatingArrays extends StatefulWidget {
  const creatingArrays({super.key});

  @override
  _SetsState createState() => _SetsState();
}

class _SetsState extends State<creatingArrays> {
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
        isLessonComplete = data['numpylessons']?['creatingArrays'] ?? false;
      });
    }
  }

  void completeLesson(String lessonName) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "test_user";

    FirebaseFirestore.instance.collection('levelgame').doc(userId).set({
      'numpylessons': {lessonName: true}
    }, SetOptions(merge: true));

    setState(() {
      isLessonComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Creating Arrays'),
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
                        'Creating Arrays lessons',
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
          completeLesson("creatingArrays");
          Navigator.pop(context, true);
        },
        child: const Text('Complete Lesson'),
      ),
    );
  }

  List<Widget> buildLessonCards() {
    return <Widget>[
      buildLessonCard(
        title: '1. Create a NumPy ndarray Object',
        code:
            'import numpy as np\n\narr = np.array([1, 2, 3, 4, 5])\n\nprint(arr)\n\nprint(type(arr))',
        description:
            'NumPy is used to work with arrays. The array object in NumPy is called ndarray.\n\nWe can create a NumPy ndarray object by using the array() function.',
        lessonKey: 'creatingArrays',
      ),
      buildLessonCard(
        title: '2. Dimensions in Arrays',
        code: '',
        description:
            'A dimension in arrays is one level of array depth (nested arrays).\n\nNested arrays are arrays that have arrays as their elements.',
        lessonKey: 'creatingArrays',
      ),
      buildLessonCard(
        title: '3. 0-D Arrays',
        code: 'import numpy as np\n\narr = np.array(42)\n\nprint(arr)',
        description:
            '0-D arrays, or Scalars, are the elements in an array. Each value in an array is a 0-D array.',
        lessonKey: 'creatingArrays',
      ),
      buildLessonCard(
        title: '4. 1-D Arrays',
        code:
            'import numpy as np\n\narr = np.array([1, 2, 3, 4, 5])\n\nprint(arr)',
        description:
            'An array that has 0-D arrays as its elements is called a uni-dimensional or 1-D array. These are the most common and basic arrays.',
        lessonKey: 'creatingArrays',
      ),
      buildLessonCard(
        title: '5. 2-D Arrays',
        code:
            'import numpy as np\n\narr = np.array([[1, 2, 3], [4, 5, 6]])\n\nprint(arr)',
        description:
            'An array that has 1-D arrays as its elements is called a 2-D array. These are often used to represent matrices or 2nd order tensors.',
        lessonKey: 'creatingArrays',
      ),
      buildLessonCard(
        title: '6. 3-D Arrays',
        code:
            'import numpy as np\n\narr = np.array([[[1, 2, 3], [4, 5, 6]], [[1, 2, 3], [4, 5, 6]]])\n\nprint(arr)',
        description:
            'An array that has 2-D arrays (matrices) as its elements is called a 3-D array. These are often used to represent a 3rd order tensor.',
        lessonKey: 'creatingArrays',
      ),
      buildLessonCard(
        title: '7. Check Number of Dimensions',
        code:
            'import numpy as np\n\na = np.array(42)\nb = np.array([1, 2, 3, 4, 5])\nc = np.array([[1, 2, 3], [4, 5, 6]])\nd = np.array([[[1, 2, 3], [4, 5, 6]], [[1, 2, 3], [4, 5, 6]]])\n\nprint(a.ndim)\nprint(b.ndim)\nprint(c.ndim)\nprint(d.ndim)',
        description:
            'NumPy provides the ndim attribute that returns an integer indicating the number of dimensions in an array.',
        lessonKey: 'creatingArrays',
      ),
      buildLessonCard(
        title: '8. Higher Dimensional Arrays',
        code:
            'import numpy as np\n\narr = np.array([1, 2, 3, 4], ndmin=5)\n\nprint(arr)\nprint(\'number of dimensions :\', arr.ndim)',
        description:
            'An array can have any number of dimensions. The number of dimensions can be defined using the ndmin argument.',
        lessonKey: 'creatingArrays',
      )
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
