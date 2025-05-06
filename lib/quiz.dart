import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Homepage/Advanced.dart';
import 'Homepage/Intermediate.dart';
import 'Homepage/beginner.dart';

class QuizIntro extends StatelessWidget {
  const QuizIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Welcome to CodeQuest Quiz",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(20),
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.quiz_rounded,
                    size: 100,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 20),

                  // ✅ Welcome Message
                  const Text(
                    "Let's do a quick quiz to assess your knowledge!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // ✅ Quiz Instructions
                  const Text(
                    "You'll be presented with 10 questions. "
                    "Choose the correct answer for each question. "
                    "Based on your score, you'll be assigned a learning level: "
                    "\n- Beginner (0-49%)"
                    "\n- Intermediate (50-79%)"
                    "\n- Advanced (80-100%)",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ✅ Start Quiz Button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QuizPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text(
                      "Start Quiz",
                      style: TextStyle(fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  final int questionsCount; // ✅ Dynamic question count support

  const QuizPage({super.key, this.questionsCount = 10}); // Default to 10

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final List<Question> allQuestions = [
    Question('What does `len([1, 2, 3])` return?', ['3', '2', '1'], '3'),
    Question(
        'What is the output of `print(type([]))`?',
        ["<class 'list'>", "<class 'tuple'>", "<class 'dict'>"],
        "<class 'list'>"),
    Question('Which keyword is used to define a function in Python?',
        ['def', 'func', 'define'], 'def'),
    Question('What will `3 * 2 ** 3` evaluate to?', ['24', '18', '48'], '24'),
    Question('Which of the following is a mutable data type in Python?',
        ['List', 'Tuple', 'String'], 'List'),
    Question(
        'What does `bool([])` return?', ['False', 'True', 'None'], 'False'),
    Question('How do you get the last element of a list `lst`?',
        ['lst[-1]', 'lst[len(lst)]', 'lst[last]'], 'lst[-1]'),
    Question(
        'What is the result of `5 // 2` in Python?', ['2', '2.5', '2.0'], '2'),
    Question('What does `print("Python"[::-1])` output?',
        ['Python', 'nohtyP', 'Error'], 'nohtyP'),
    Question('Which method is used to add an element to a set?',
        ['add()', 'append()', 'insert()'], 'add()'),
    Question('What does `set([1, 2, 2, 3])` return?',
        ['{1, 2, 3}', '[1, 2, 2, 3]', '{1, 2, 2, 3}'], '{1, 2, 3}'),
    Question('Which symbol is used for single-line comments in Python?',
        ['#', '//', '--'], '#'),
    Question('What will `print(2 == "2")` return?', ['True', 'False', 'Error'],
        'False'),
    Question('Which function is used to get user input in Python?',
        ['input()', 'scan()', 'get_input()'], 'input()'),
    Question('What is the output of `print(5 % 2)`?', ['1', '2', '0'], '1'),
    Question('Which module is used to work with random numbers in Python?',
        ['random', 'math', 'numbers'], 'random'),
    Question('What does `range(5)` return?',
        ['A list', 'An iterator', 'A tuple'], 'An iterator'),
    Question('What will `print(bool(" "))` return?', ['True', 'False', 'None'],
        'True'),
    Question('How do you check the length of a dictionary `d`?',
        ['len(d)', 'size(d)', 'count(d)'], 'len(d)'),
    Question('Which operator is used for exponentiation in Python?',
        ['**', '^', 'pow'], '**'),
    Question('What does `sorted([3, 1, 2])` return?',
        ['[1, 2, 3]', '[3, 1, 2]', 'None'], '[1, 2, 3]'),
    Question('What will `print(10 / 5)` return?', ['2', '2.0', '10'], '2.0'),
    Question('Which of the following can be used as a dictionary key?',
        ['List', 'Tuple', 'Set'], 'Tuple'),
    Question('Which of the following methods removes an item from a list?',
        ['pop()', 'remove()', 'delete()'], 'pop()'),
    Question('What is the output of `print("hello".upper())`?',
        ['HELLO', 'hello', 'Error'], 'HELLO'),
    Question(
        'What is the default return value of a function that does not return anything?',
        ['None', '0', 'False'],
        'None'),
    Question(
        'How do you check if a key exists in a dictionary `d`?',
        ['"key" in d', 'd.has_key("key")', 'key_exists(d, "key")'],
        '"key" in d'),
    Question(
        'What will `print(type(None))` return?',
        ["<class 'NoneType'>", "<class 'int'>", "<class 'str'>"],
        "<class 'NoneType'>"),
    Question(
        'What is the result of `min([3, 2, 8, 5])`?', ['2', '3', '8'], '2'),
    Question('What is the output of `print("python".capitalize())`?',
        ['Python', 'PYTHON', 'python'], 'Python'),
    Question(
        'Which of the following methods can be used to read a file in Python?',
        ['read()', 'fetch()', 'scan()'],
        'read()'),
    Question('What does `print("abc" * 3)` output?',
        ['abcabcabc', 'abc3', 'Error'], 'abcabcabc'),
    Question('Which loop is used when the number of iterations is not known?',
        ['while', 'for', 'do-while'], 'while'),
    Question(
        'What will `print(type({}))` return?',
        ["<class 'dict'>", "<class 'set'>", "<class 'list'>"],
        "<class 'dict'>"),
    Question('What does `print([1, 2, 3] + [4, 5])` return?',
        ['[1, 2, 3, 4, 5]', '[5, 7, 8]', 'Error'], '[1, 2, 3, 4, 5]'),
    Question(
        'Which method is used to remove whitespace from the beginning and end of a string?',
        ['strip()', 'trim()', 'clean()'],
        'strip()'),
    Question('How do you check if a list `lst` is empty?',
        ['if not lst', 'if lst == None', 'if len(lst) == -1'], 'if not lst'),
    Question('What will `print(3 in [1, 2, 3])` return?',
        ['True', 'False', 'None'], 'True'),
    Question(
        'What is the correct syntax for a class definition?',
        ['class ClassName:', 'define ClassName:', 'new ClassName:'],
        'class ClassName:'),
    Question('Which keyword is used to inherit a class in Python?',
        ['extends', 'inherits', 'class ParentClass'], 'class ParentClass'),
    Question('What will `print(2**3**2)` return?', ['512', '64', '256'], '512'),
    Question('What is the output of `print(10 > 5 and 5 < 3)`?',
        ['True', 'False', 'None'], 'False'),
    Question('Which function is used to convert a string to an integer?',
        ['int()', 'str()', 'float()'], 'int()'),
    Question('What does `print(10 // 3)` return?', ['3', '3.33', '4'], '3'),
    Question('What will `print(bool(0))` return?', ['True', 'False', 'None'],
        'False'),
    Question('Which of the following is NOT a valid variable name in Python?',
        ['1variable', '_variable', 'var_name'], '1variable'),
    Question('Which of the following is an immutable type in Python?',
        ['String', 'List', 'Dictionary'], 'String'),
  ];
  late List<Question> selectedQuestions;
  int currentQuestionIndex = 0;
  int score = 0;
  String? selectedAnswer;
  bool isAnswerCorrect = false;

  @override
  void initState() {
    super.initState();
    _selectRandomQuestions();
  }

  /// ✅ Selects N random questions without duplicates
  void _selectRandomQuestions() {
    final random = Random();
    final Set<int> randomIndexes = {};

    while (randomIndexes.length < widget.questionsCount) {
      randomIndexes.add(random.nextInt(allQuestions.length));
    }

    selectedQuestions =
        randomIndexes.map((index) => allQuestions[index]).toList();
  }

  /// ✅ Handle the answer selection and score
  void answerQuestion(String answer) {
    setState(() {
      selectedAnswer = answer;
      isAnswerCorrect =
          (answer == selectedQuestions[currentQuestionIndex].correctAnswer);
      if (isAnswerCorrect) {
        score++;
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (currentQuestionIndex + 1 >= selectedQuestions.length) {
        _navigateToResultPage();
      } else {
        setState(() {
          currentQuestionIndex++;
          selectedAnswer = null; // Reset for the next question
        });
      }
    });
  }

  /// ✅ Navigate to result page and save the result in Firestore
  void _navigateToResultPage() async {
    double percentage = (score / selectedQuestions.length) * 100;
    String level = percentage < 50
        ? "beginner"
        : (percentage < 80 ? "intermediate" : "advanced");

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // ✅ Unlock logic: advanced unlocks both levels
        bool intermediateUnlocked =
            (level == "intermediate" || level == "advanced");
        bool advancedUnlocked = (level == "advanced");

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'level': level,
          'score': score,
          'percentage': percentage,
          'IntermediateUnlocked': intermediateUnlocked,
          'AdvancedUnlocked': advancedUnlocked,
        }, SetOptions(merge: true));
      } catch (e) {
        print("Error saving data to Firestore: $e");
      }
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            score: score,
            totalQuestions: selectedQuestions.length,
            percentage: percentage,
            level: level,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Question currentQuestion = selectedQuestions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CodeQuest Quiz',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(20),
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ✅ Progress Bar
                  LinearProgressIndicator(
                    value:
                        (currentQuestionIndex + 1) / selectedQuestions.length,
                    backgroundColor: Colors.grey[300],
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 20),

                  // ✅ Score Display
                  Text(
                    'Score: $score / ${selectedQuestions.length}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ✅ Question Number
                  Text(
                    'Question ${currentQuestionIndex + 1} of ${selectedQuestions.length}',
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                  const SizedBox(height: 30),

                  // ✅ Question Text
                  Text(
                    currentQuestion.questionText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ✅ Answer Options
                  ...currentQuestion.options.map((option) {
                    bool isSelected = option == selectedAnswer;
                    bool isCorrect = option == currentQuestion.correctAnswer;

                    return GestureDetector(
                      onTap: selectedAnswer == null
                          ? () => answerQuestion(option)
                          : null,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: selectedAnswer != null
                              ? (isSelected
                                  ? (isCorrect
                                      ? const LinearGradient(
                                          colors: [Colors.green, Colors.teal])
                                      : const LinearGradient(
                                          colors: [Colors.red, Colors.orange]))
                                  : (isCorrect
                                      ? const LinearGradient(
                                          colors: [Colors.green, Colors.teal])
                                      : const LinearGradient(
                                          colors: [Colors.grey, Colors.white])))
                              : const LinearGradient(
                                  colors: [Colors.blueAccent, Colors.cyan]),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Text(
                          option,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final double percentage;
  final String level;

  const ResultPage({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    Widget nextPage = (level == "beginner")
        ? const Beginner()
        : (level == "intermediate")
            ? const Intermediate()
            : const Advanced();

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Result')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You are at $level level!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => nextPage),
                );
              },
              child: const Text('Go to Learning Path'),
            ),
          ],
        ),
      ),
    );
  }
}

/// ✅ Question Model
class Question {
  final String questionText;
  final List<String> options;
  final String correctAnswer;

  Question(this.questionText, this.options, this.correctAnswer);
}
