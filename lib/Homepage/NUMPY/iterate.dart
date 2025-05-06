import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      home: const iterateArrays(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class iterateArrays extends StatefulWidget {
  const iterateArrays({super.key});

  @override
  _SetsState createState() => _SetsState();
}

class _SetsState extends State<iterateArrays> {
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
        isLessonComplete = data['numpylessons']?['iterateArrays'] ?? false;
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
        title: const Text('Array iterating'),
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
                        ' Arrays iterating lessons',
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
          completeLesson("iterateArrays");
          Navigator.pop(context, true);
        },
        child: const Text('Complete Lesson'),
      ),
    );
  }

  List<Widget> buildLessonCards() {
    return <Widget>[
      buildLessonCard(
        title: '1. Iterating 1-D Arrays',
        code:
            'import numpy as np\n\narr = np.array([1, 2, 3])\n\nfor x in arr:\n  print(x)',
        description:
            'Iterate on each element of a 1-D array using a basic for loop.',
        lessonKey: 'iterate',
      ),
      buildLessonCard(
        title: '2. Iterating 2-D Arrays',
        code:
            'import numpy as np\n\narr = np.array([[1, 2, 3], [4, 5, 6]])\n\nfor x in arr:\n  print(x)',
        description: 'Iterate through all rows in a 2-D array.',
        lessonKey: 'iterate',
      ),
      buildLessonCard(
        title: '3. Iterating 2-D Arrays (Scalars)',
        code:
            'import numpy as np\n\narr = np.array([[1, 2, 3], [4, 5, 6]])\n\nfor x in arr:\n  for y in x:\n    print(y)',
        description:
            'Access individual scalar elements by iterating through each dimension.',
        lessonKey: 'iterate',
      ),
      buildLessonCard(
        title: '4. Iterating 3-D Arrays',
        code:
            'import numpy as np\n\narr = np.array([[[1, 2, 3], [4, 5, 6]], [[7, 8, 9], [10, 11, 12]]])\n\nfor x in arr:\n  print(x)',
        description: 'Iterate through all 2-D arrays in a 3-D array.',
        lessonKey: 'iterate',
      ),
      buildLessonCard(
        title: '5. Iterating 3-D Arrays (Scalars)',
        code:
            'import numpy as np\n\narr = np.array([[[1, 2, 3], [4, 5, 6]], [[7, 8, 9], [10, 11, 12]]])\n\nfor x in arr:\n  for y in x:\n    for z in y:\n      print(z)',
        description:
            'Iterate through a 3-D array to access each scalar element.',
        lessonKey: 'iterate',
      ),
      buildLessonCard(
        title: '6. Iterating Arrays Using nditer()',
        code:
            'import numpy as np\n\narr = np.array([[[1, 2], [3, 4]], [[5, 6], [7, 8]]])\n\nfor x in np.nditer(arr):\n  print(x)',
        description:
            'Use nditer() to simplify iterating through high-dimensional arrays.',
        lessonKey: 'iterate',
      ),
      buildLessonCard(
        title: '7. Iterating With Different Data Types',
        code:
            'import numpy as np\n\narr = np.array([1, 2, 3])\n\nfor x in np.nditer(arr, flags=[\'buffered\'], op_dtypes=[\'S\']):\n  print(x)',
        description:
            'Change data types while iterating using op_dtypes and buffered flag.',
        lessonKey: 'iterate',
      ),
      buildLessonCard(
        title: '8. Iterating With Different Step Size',
        code:
            'import numpy as np\n\narr = np.array([[1, 2, 3, 4], [5, 6, 7, 8]])\n\nfor x in np.nditer(arr[:, ::2]):\n  print(x)',
        description: 'Skip elements while iterating using slicing.',
        lessonKey: 'iterate',
      ),
      buildLessonCard(
        title: '9. Enumerated Iteration Using ndenumerate()',
        code:
            'import numpy as np\n\narr = np.array([1, 2, 3])\n\nfor idx, x in np.ndenumerate(arr):\n  print(idx, x)',
        description:
            'Use ndenumerate() to access both element values and their indexes.',
        lessonKey: 'iterate',
      ),
      buildLessonCard(
        title: '10. Enumerate 2-D Arrays Using ndenumerate()',
        code:
            'import numpy as np\n\narr = np.array([[1, 2, 3, 4], [5, 6, 7, 8]])\n\nfor idx, x in np.ndenumerate(arr):\n  print(idx, x)',
        description:
            'Enumerate over 2-D arrays to get index and value of each element.',
        lessonKey: 'iterate',
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

class CodeRunner extends StatefulWidget {
  const CodeRunner({super.key});

  @override
  _CodeRunnerState createState() => _CodeRunnerState();
}

class _CodeRunnerState extends State<CodeRunner> {
  final TextEditingController _codeController = TextEditingController();
  String output = '';
  String error = '';
  bool isLoading = false;

  Future<void> runCode() async {
    final code = _codeController.text;
    final Uri url = Uri.parse(
        'https://codequest-iuxe.onrender.com/run'); // Replace with server URL

    setState(() {
      isLoading = true;
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

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Run Your Code',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Line numbers column
                  Container(
                    width: 40,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _codeController.text.split('\n').length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            '${index + 1}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontFamily: 'monospace',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Code input area
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(8),
                        hintText: 'Enter your Python code here...',
                      ),
                      onChanged: (text) {
                        setState(() {}); // Refresh the line numbers
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: isLoading ? null : runCode,
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text('Run'),
            ),
            const SizedBox(height: 10),
            if (output.isNotEmpty) buildResultCard('Output', output),
            if (error.isNotEmpty) buildResultCard('Error', error),
          ],
        ),
      ),
    );
  }

  Widget buildResultCard(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title:',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            content,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }
}
