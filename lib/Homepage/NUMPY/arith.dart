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
      home: const arith(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class arith extends StatefulWidget {
  const arith({super.key});

  @override
  _SetsState createState() => _SetsState();
}

class _SetsState extends State<arith> {
  bool isLessonComplete = false;

  @override
  void initState() {
    super.initState();
    getLessonProgress();
  }

  Future<void> getLessonProgress() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "test_user";
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('levelgamed')
        .doc(userId)
        .get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      setState(() {
        isLessonComplete = data['numpylessons']?['arith'] ?? false;
      });
    }
  }

  void completeLesson(String lessonName) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "test_user";

    FirebaseFirestore.instance.collection('levelgame').doc(userId).set({
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
        title: const Text('Simple Arithmetic'),
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
                        ' Simple Arithmetic lessons',
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
          completeLesson("arith");
          Navigator.pop(context, true);
        },
        child: const Text('Complete Lesson'),
      ),
    );
  }

  List<Widget> buildLessonCards() {
    return <Widget>[
      buildLessonCard(
        title: '1. Simple Arithmetic',
        code: '',
        description:
            'You could use arithmetic operators + - * / directly between NumPy arrays, but this section discusses an extension where we have functions that can take any array-like objects (e.g., lists, tuples) and perform arithmetic conditionally. Arithmetic Conditionally means that we can define conditions where the arithmetic operation should happen. All discussed arithmetic functions take a where parameter to specify that condition.',
        lessonKey: 'arith',
      ),
      buildLessonCard(
        title: '2. Addition',
        code:
            'import numpy as np\n\narr1 = np.array([10, 11, 12, 13, 14, 15])\narr2 = np.array([20, 21, 22, 23, 24, 25])\n\nnewarr = np.add(arr1, arr2)\n\nprint(newarr)',
        description:
            'The add() function sums the content of two arrays and returns the results in a new array.',
        lessonKey: 'arith',
      ),
      buildLessonCard(
        title: '3. Subtraction',
        code:
            'import numpy as np\n\narr1 = np.array([10, 20, 30, 40, 50, 60])\narr2 = np.array([20, 21, 22, 23, 24, 25])\n\nnewarr = np.subtract(arr1, arr2)\n\nprint(newarr)',
        description:
            'The subtract() function subtracts the values from one array with the values from another array and returns the results in a new array.',
        lessonKey: 'arith',
      ),
      buildLessonCard(
        title: '4. Multiplication',
        code:
            'import numpy as np\n\narr1 = np.array([10, 20, 30, 40, 50, 60])\narr2 = np.array([20, 21, 22, 23, 24, 25])\n\nnewarr = np.multiply(arr1, arr2)\n\nprint(newarr)',
        description:
            'The multiply() function multiplies the values from one array with the values from another array and returns the results in a new array.',
        lessonKey: 'arith',
      ),
      buildLessonCard(
        title: '5. Division',
        code:
            'import numpy as np\n\narr1 = np.array([10, 20, 30, 40, 50, 60])\narr2 = np.array([3, 5, 10, 8, 2, 33])\n\nnewarr = np.divide(arr1, arr2)\n\nprint(newarr)',
        description:
            'The divide() function divides the values from one array with the values from another array and returns the results in a new array.',
        lessonKey: 'arith',
      ),
      buildLessonCard(
        title: '6. Power',
        code:
            'import numpy as np\n\narr1 = np.array([10, 20, 30, 40, 50, 60])\narr2 = np.array([3, 5, 6, 8, 2, 33])\n\nnewarr = np.power(arr1, arr2)\n\nprint(newarr)',
        description:
            'The power() function raises the values from the first array to the power of the values of the second array and returns the results in a new array.',
        lessonKey: 'arith',
      ),
      buildLessonCard(
        title: '7. Remainder',
        code:
            'import numpy as np\n\narr1 = np.array([10, 20, 30, 40, 50, 60])\narr2 = np.array([3, 7, 9, 8, 2, 33])\n\nnewarr = np.mod(arr1, arr2)\n\nprint(newarr)',
        description:
            'Both the mod() and remainder() functions return the remainder of the values in the first array corresponding to the values in the second array and return the results in a new array.',
        lessonKey: 'arith',
      ),
      buildLessonCard(
        title: '8. Quotient and Mod',
        code:
            'import numpy as np\n\narr1 = np.array([10, 20, 30, 40, 50, 60])\narr2 = np.array([3, 7, 9, 8, 2, 33])\n\nnewarr = np.divmod(arr1, arr2)\n\nprint(newarr)',
        description:
            'The divmod() function returns both the quotient and the mod. The return value is two arrays: the first array contains the quotient, and the second array contains the mod.',
        lessonKey: 'arith',
      ),
      buildLessonCard(
        title: '9. Absolute Values',
        code:
            'import numpy as np\n\narr = np.array([-1, -2, 1, 2, 3, -4])\n\nnewarr = np.absolute(arr)\n\nprint(newarr)',
        description:
            'Both the absolute() and the abs() functions perform the same absolute operation element-wise. However, absolute() is preferred to avoid confusion with Python’s built-in math.abs().',
        lessonKey: 'arith',
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
