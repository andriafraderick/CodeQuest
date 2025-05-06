import 'dart:convert';
import 'package:finalprojects8/Homepage/GAMES/regx.dart';
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
      home: const Regularexpr(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Regularexpr extends StatefulWidget {
  const Regularexpr({super.key});

  @override
  _RegularexprState createState() => _RegularexprState();
}

class _RegularexprState extends State<Regularexpr>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLessonComplete = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    getLessonProgress();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> getLessonProgress() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "test_user";
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      setState(() {
        isLessonComplete = data['intlessons']?['Regular Expression'] ?? false;
      });
    }
  }

  void completeLesson(String lessonName) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "test_user";

    FirebaseFirestore.instance.collection('users').doc(userId).set({
      'intlessons': {lessonName: true}
    }, SetOptions(merge: true));

    setState(() {
      isLessonComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Python Regular Expression & Runner'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Lesson'),
            Tab(text: 'Regex Game'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 182, 190, 233), Colors.lightBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            // First tab - Lesson content
            Padding(
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
                            'Python Regular expressions',
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
            // Second tab - Regex Game
            RegexGameScreen(),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? ElevatedButton(
              onPressed: () {
                completeLesson("Regular Expression");
                Navigator.pop(context, true);
              },
              child: const Text('Complete Lesson'),
            )
          : null,
    );
  }

  List<Widget> buildLessonCards() {
    return [
      buildLessonCard(
        title: '1. Introduction to Regular Expressions',
        code:
            'import re\npattern = "abc"\ntext = "abcdef"\nmatch = re.search(pattern, text)\nprint(match)',
        description: 'Use `re.search()` to find a pattern in text.',
        lessonKey: 'Regularexpr_intro',
      ),
      buildLessonCard(
        title: '2. Using Metacharacters',
        code:
            'import re\npattern = "^Hello"\ntext = "Hello, World!"\nmatch = re.search(pattern, text)\nprint(match)',
        description: 'Use `^` to match the beginning of a string.',
        lessonKey: 'Regularexpr_metacharacters',
      ),
      buildLessonCard(
        title: '3. Finding Multiple Matches',
        code:
            'import re\npattern = "a.c"\ntext = "abc, adc, aec, afc"\nmatches = re.findall(pattern, text)\nprint(matches)',
        description: 'Use `.` to match any character except a newline.',
        lessonKey: 'Regularexpr_multiple_matches',
      ),
      buildLessonCard(
        title: '4. Matching Digits and Alphabets',
        code:
            'import re\npattern = "\\d+"\ntext = "Order 123 is ready."\nmatch = re.findall(pattern, text)\nprint(match)',
        description: 'Use `\\d` to match digits and `\\w` to match words.',
        lessonKey: 'Regularexpr_digits',
      ),
      buildLessonCard(
        title: '5. Using Quantifiers',
        code:
            'import re\npattern = "a{2,3}"\ntext = "aaaa abc aabb aaaa"\nmatches = re.findall(pattern, text)\nprint(matches)',
        description: 'Use `{n,m}` to match repetitions.',
        lessonKey: 'Regularexpr_quantifiers',
      ),
      buildLessonCard(
        title: '6. Extracting Emails',
        code:
            'import re\npattern = "\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}\\b"\ntext = "Contact me at test@example.com"\nmatch = re.search(pattern, text)\nprint(match.group())',
        description: 'Extract valid email addresses using regex.',
        lessonKey: 'Regularexpr_emails',
      ),
      buildLessonCard(
        title: '7. Removing Special Characters',
        code:
            'import re\npattern = "[^a-zA-Z0-9 ]"\ntext = "Hello! How are you? #regex123"\ncleaned_text = re.sub(pattern, "", text)\nprint(cleaned_text)',
        description: 'Use `re.sub()` to replace unwanted characters.',
        lessonKey: 'Regularexpr_cleaning_text',
      ),
      buildLessonCard(
        title: '8. Extracting URLs from Text',
        code:
            'import re\npattern = "https?://\\S+"\ntext = "Visit https://example.com for details."\nmatches = re.findall(pattern, text)\nprint(matches)',
        description: 'Extract all URLs from a given text.',
        lessonKey: 'Regularexpr_urls',
      ),
      buildLessonCard(
        title: '9. Grouping and Capturing',
        code:
            'import re\npattern = "(\\d{3})-(\\d{3})-(\\d{4})"\ntext = "My number is 123-456-7890"\nmatch = re.search(pattern, text)\nprint(match.groups())',
        description:
            'Use parentheses `()` to create groups and capture parts of a match.',
        lessonKey: 'Regularexpr_grouping',
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
