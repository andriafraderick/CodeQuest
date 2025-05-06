import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
      home: const copy(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class copy extends StatefulWidget {
  const copy({super.key});

  @override
  _SetsState createState() => _SetsState();
}

class _SetsState extends State<copy> {
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
        isLessonComplete = data['numpylessons']?['copy'] ?? false;
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
        title: const Text('Array Copy vs View'),
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
                        'NumPArray Copy vs View lessons',
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
          completeLesson("copy");
          Navigator.pop(context, true);
        },
        child: const Text('Complete Lesson'),
      ),
    );
  }

  List<Widget> buildLessonCards() {
    return <Widget>[
      buildLessonCard(
        title: '1. Copy vs. View in NumPy',
        code: '',
        description: '**The Difference Between Copy and View**\n\n'
            '- A **copy** creates a new array, independent of the original.\n'
            '- A **view** is just a reference to the original array.\n\n'
            '**Key Differences:**\n'
            '- Copy: Changes in the original do **not** affect the copy.\n'
            '- View: Changes in the original **do** affect the view, and vice versa.\n',
        lessonKey: 'copy',
      ),
      buildLessonCard(
        title: '2. Copy Example in NumPy',
        code: '',
        description: '**Make a Copy and Modify the Original:**\n\n'
            '```python\n'
            'import numpy as np\n\n'
            'arr = np.array([1, 2, 3, 4, 5])\n'
            'x = arr.copy()\n'
            'arr[0] = 42\n\n'
            'print(arr)  # [42, 2, 3, 4, 5]\n'
            'print(x)    # [1, 2, 3, 4, 5] (Copy remains unchanged)\n'
            '```\n'
            '**The copy remains unaffected by changes in the original array.**\n',
        lessonKey: 'copy',
      ),
      buildLessonCard(
        title: '3. View Example in NumPy',
        code: '',
        description: '**Make a View and Modify the Original:**\n\n'
            '```python\n'
            'import numpy as np\n\n'
            'arr = np.array([1, 2, 3, 4, 5])\n'
            'x = arr.view()\n'
            'arr[0] = 42\n\n'
            'print(arr)  # [42, 2, 3, 4, 5]\n'
            'print(x)    # [42, 2, 3, 4, 5] (View reflects the change)\n'
            '```\n'
            '**The view is affected by changes in the original array.**\n',
        lessonKey: 'copy',
      ),
      buildLessonCard(
        title: '4. Modifying a View',
        code: '',
        description:
            '**Modify the View and See Its Effect on the Original:**\n\n'
            '```python\n'
            'import numpy as np\n\n'
            'arr = np.array([1, 2, 3, 4, 5])\n'
            'x = arr.view()\n'
            'x[0] = 31\n\n'
            'print(arr)  # [31, 2, 3, 4, 5]\n'
            'print(x)    # [31, 2, 3, 4, 5] (Both changed)\n'
            '```\n'
            '**Since `x` is a view, modifying it affects the original array.**\n',
        lessonKey: 'copy',
      ),
      buildLessonCard(
        title: '5. Checking Ownership in NumPy',
        code: '',
        description: '**How to Check if an Array Owns Its Data?**\n\n'
            'The `.base` attribute tells us whether an array owns its data:\n\n'
            '```python\n'
            'import numpy as np\n\n'
            'arr = np.array([1, 2, 3, 4, 5])\n\n'
            'x = arr.copy()\n'
            'y = arr.view()\n\n'
            'print(x.base)  # None (Copy owns data)\n'
            'print(y.base)  # [1, 2, 3, 4, 5] (View does not own data)\n'
            '```\n'
            '**If `.base` is `None`, the array is a copy. If it points to another array, it is a view.**\n',
        lessonKey: 'copy',
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
                  const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
            const SizedBox(height: 8),
            MarkdownBody(
              data: description,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 12),
            if (code.isNotEmpty)
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
