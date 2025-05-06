import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'coderunner.dart';

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
      home: const Dateandmath(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Dateandmath extends StatefulWidget {
  const Dateandmath({super.key});

  @override
  _DateandmathState createState() => _DateandmathState();
}

class _DateandmathState extends State<Dateandmath> {
  bool isLessonComplete = false;

  @override
  void initState() {
    super.initState();
    getLessonProgress();
  }

  Future<void> getLessonProgress() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "test_user";
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      setState(() {
        isLessonComplete = data['lessons']?['Date and Math'] ?? false;
      });
    }
  }

  void completeLesson(String lessonName) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "test_user";

    FirebaseFirestore.instance.collection('users').doc(userId).set({
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
        title: const Text('Python Date and math & Runner'),
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
                        'Python Dateandmath Lessons',
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
          completeLesson("Date and Math");
          Navigator.pop(context, true);
        },
        child: const Text('Complete Lesson'),
      ),
    );
  }

  List<Widget> buildLessonCards() {
    return [
      buildLessonCard(
        title: '1. Getting the Current Date and Time',
        code: '''
import datetime
now = datetime.datetime.now()
print("Current date and time:", now)
  ''',
        description:
            'Use the `datetime` module to get the current date and time.',
        lessonKey: 'date',
      ),
      buildLessonCard(
        title: '2. Creating a Specific Date',
        code: '''
import datetime
my_date = datetime.date(2023, 5, 17)
print("Specific date:", my_date)
  ''',
        description: 'Use the `date()` method to create a specific date.',
        lessonKey: 'date',
      ),
      buildLessonCard(
        title: '3. Formatting Dates',
        code: '''
import datetime
now = datetime.datetime.now()
formatted = now.strftime("%Y-%m-%d %H:%M:%S")
print("Formatted date:", formatted)
  ''',
        description: 'Use the `strftime()` method to format dates.',
        lessonKey: 'date',
      ),
      buildLessonCard(
        title: '4. Calculating Date Differences',
        code: '''
import datetime
date1 = datetime.date(2025, 2, 10)
date2 = datetime.date(2025, 2, 20)
difference = date2 - date1
print("Difference in days:", difference.days)
  ''',
        description: 'Subtract two dates to calculate the difference in days.',
        lessonKey: 'date',
      ),
      buildLessonCard(
        title: '5. Adding or Subtracting Days',
        code: '''
import datetime
today = datetime.date.today()
new_date = today + datetime.timedelta(days=7)
print("Date after 7 days:", new_date)
  ''',
        description: 'Use `timedelta` to add or subtract days from a date.',
        lessonKey: 'date',
      ),
      buildLessonCard(
        title: '1. Basic Math Operations',
        code: '''
# Addition
print(5 + 3)

# Subtraction
print(10 - 2)

# Multiplication
print(4 * 3)

# Division
print(15 / 3)
  ''',
        description:
            'Python supports basic math operations like addition, subtraction, multiplication, and division.',
        lessonKey: 'math',
      ),
      buildLessonCard(
        title: '2. Using the Math Module',
        code: '''
import math
result = math.sqrt(16)
print("Square root of 16:", result)
  ''',
        description:
            'Use the `math` module for advanced math operations like square roots.',
        lessonKey: 'math',
      ),
      buildLessonCard(
        title: '3. Calculating Power',
        code: '''
import math
result = math.pow(2, 3)
print("2 to the power of 3:", result)
  ''',
        description: 'Use `math.pow()` to calculate the power of a number.',
        lessonKey: 'math',
      ),
      buildLessonCard(
        title: '4. Rounding Numbers',
        code: '''
number = 3.14159
rounded = round(number, 2)
print("Rounded to 2 decimal places:", rounded)
  ''',
        description:
            'Use the `round()` function to round numbers to a specified number of decimal places.',
        lessonKey: 'math',
      ),
      buildLessonCard(
        title: '5. Finding the Greatest Common Divisor (GCD)',
        code: '''
import math
result = math.gcd(48, 18)
print("GCD of 48 and 18:", result)
  ''',
        description:
            'Use `math.gcd()` to find the greatest common divisor of two numbers.',
        lessonKey: 'math',
      ),
      buildLessonCard(
        title: '6. Working with Constants',
        code: '''
import math
print("Value of Pi:", math.pi)
print("Value of e:", math.e)
  ''',
        description: 'The `math` module provides constants like Pi and e.',
        lessonKey: 'math',
      ),
      buildLessonCard(
        title: '7. Trigonometric Functions',
        code: '''
import math
angle = math.radians(45)
print("Sin of 45 degrees:", math.sin(angle))
print("Cos of 45 degrees:", math.cos(angle))
  ''',
        description:
            'Use trigonometric functions from the `math` module for sine, cosine, etc.',
        lessonKey: 'math',
      ),
      buildLessonCard(
        title: '8. Absolute Values',
        code: '''
number = -15
absolute = abs(number)
print("Absolute value:", absolute)
  ''',
        description:
            'Use the `abs()` function to find the absolute value of a number.',
        lessonKey: 'math',
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
