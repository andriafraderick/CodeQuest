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
      home: const data(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class data extends StatefulWidget {
  const data({super.key});

  @override
  _SetsState createState() => _SetsState();
}

class _SetsState extends State<data> {
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
        isLessonComplete = data['numpylessons']?['datatypes'] ?? false;
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
        title: const Text('Data Types'),
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
                        ' Data Types lessons',
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
          completeLesson("datatypes");
          Navigator.pop(context, true);
        },
        child: const Text('Complete Lesson'),
      ),
    );
  }

  List<Widget> buildLessonCards() {
    return <Widget>[
      buildLessonCard(
        title: '1. Data Types in Python',
        code: '',
        description: 'By default, Python has these data types:\n\n'
            '- **strings** - used to represent text data, given under quote marks, e.g., "ABCD".\n'
            '- **integer** - used to represent whole numbers, e.g., -1, -2, -3.\n'
            '- **float** - used to represent real numbers, e.g., 1.2, 42.42.\n'
            '- **boolean** - used to represent True or False values.\n'
            '- **complex** - used to represent complex numbers, e.g., 1.0 + 2.0j, 1.5 + 2.5j.\n',
        lessonKey: 'datatypes',
      ),
      buildLessonCard(
        title: '2. NumPy Data Types',
        code: '',
        description:
            'NumPy has some extra data types and refers to data types using single-character codes.\n\n'
            'Below is a list of all data types in NumPy and the characters used to represent them:\n'
            '• **i** - integer\n'
            '• **b** - boolean\n'
            '• **u** - unsigned integer\n'
            '• **f** - float\n'
            '• **c** - complex float\n'
            '• **m** - timedelta\n'
            '• **M** - datetime\n'
            '• **O** - object\n'
            '• **S** - string\n'
            '• **U** - Unicode string\n'
            '• **V** - fixed chunk of memory for other types (void)',
        lessonKey: 'datatypes',
      ),
      buildLessonCard(
        title: '3. Checking the Data Type of an Array',
        code:
            'import numpy as np\narr = np.array([1, 2, 3, 4])\nprint(arr.dtype)',
        description:
            'The NumPy array object has a property called **dtype**, which returns the data type of the array.',
        lessonKey: 'datatypes',
      ),
      buildLessonCard(
        title: '4. Checking the Data Type of a String Array',
        code:
            'import numpy as np\narr = np.array(["apple", "banana", "cherry"])\nprint(arr.dtype)',
        description:
            'The **dtype** property can also be used to check the data type of an array that contains string values.',
        lessonKey: 'datatypes',
      ),
      buildLessonCard(
        title: '5. Creating Arrays with a Defined Data Type',
        code:
            'import numpy as np\narr = np.array([1, 2, 3, 4], dtype="S")\nprint(arr)\nprint(arr.dtype)',
        description:
            'The **array()** function in NumPy allows specifying the expected data type of array elements using the **dtype** argument.\n\n'
            'In this example, the array is created with a string data type (**dtype="S"**), which converts all elements into string format.',
        lessonKey: 'datatypes',
      ),
      buildLessonCard(
        title: '6. Defining Array Size with Data Type',
        code:
            'import numpy as np\narr = np.array([1, 2, 3, 4], dtype="i4")\nprint(arr)\nprint(arr.dtype)',
        description:
            'For certain data types like **i (integer), u (unsigned integer), f (float), S (string),** and **U (Unicode string)**, '
            'we can also specify the size (in bytes) while defining the data type.\n\n'
            'In this example, **dtype="i4"** creates an integer array with each element stored in 4 bytes.',
        lessonKey: 'datatypes',
      ),
      buildLessonCard(
        title: '7. Handling Value Conversion Errors',
        code: 'import numpy as np\narr = np.array(["a", "2", "3"], dtype="i")',
        description:
            'If a data type is specified that some elements **cannot be converted into**, NumPy will raise a **ValueError**.\n\n'
            'In Python, **ValueError** occurs when the type of an argument passed to a function is unexpected or incorrect.\n\n'
            'For example, trying to convert a non-numeric string like **"a"** into an integer will raise an error.',
        lessonKey: 'datatypes',
      ),
      buildLessonCard(
        title: '8. Changing Data Type with astype()',
        code:
            'import numpy as np\narr = np.array([1.1, 2.1, 3.1])\nnewarr = arr.astype("i")\nprint(newarr)\nprint(newarr.dtype)',
        description:
            'The **astype()** function is used to **convert** the data type of an existing NumPy array.\n\n'
            'It creates a **copy** of the array with the specified data type.\n\n'
            'Here, we convert a **float** array into an **integer** array using **astype("i")**.',
        lessonKey: 'datatypes',
      ),
      buildLessonCard(
        title: '9. Converting Float to Integer',
        code:
            'import numpy as np\narr = np.array([1.1, 2.1, 3.1])\nnewarr = arr.astype(int)\nprint(newarr)\nprint(newarr.dtype)',
        description:
            'We can change a **float** data type to **integer** in NumPy using **astype()**.\n\n'
            'The conversion removes decimal values, effectively rounding **down** the numbers.',
        lessonKey: 'datatypes',
      ),
      buildLessonCard(
        title: '10. Converting Integer to Boolean',
        code:
            'import numpy as np\narr = np.array([1, 0, 3])\nnewarr = arr.astype(bool)\nprint(newarr)\nprint(newarr.dtype)',
        description:
            'The **astype(bool)** method converts integer values to boolean:\n\n'
            '• **0 is converted to False**\n'
            '• **Non-zero numbers are converted to True**\n\n'
            'In this example, **1 and 3 become True**, while **0 becomes False**.',
        lessonKey: 'datatypes',
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
