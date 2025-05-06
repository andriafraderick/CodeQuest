import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalprojects8/Homepage/beginner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class Quiz1 extends StatefulWidget {
  const Quiz1({super.key});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<Quiz1> {
  int score = 0;
  int currentQuestionIndex = 0;
  List<int> wrongAnswers = [];
  List<Question> selectedQuestions = [];
  late User _currentUser;
  int? selectedOptionIndex;

  final List<Question> allQuestions = [
    Question(
      questionText: "What does the 'self' keyword refer to in Python?",
      options: [
        "The current object instance",
        "The function arguments",
        "A Python built-in function",
        "The class name"
      ],
      correctAnswerIndex: 0,
      relatedLesson: "Classes and Objects",
    ),
    Question(
      questionText: "What is the output of print(2 ** 3 ** 2)?",
      options: ["64", "512", "256", "128"],
      correctAnswerIndex: 2,
      relatedLesson: "Order of Operations",
    ),
    Question(
        questionText: "What is the output of print(type([]))?",
        options: ["list", "tuple", "dictionary", "set"],
        correctAnswerIndex: 0,
        relatedLesson: "Datatypes"),
    Question(
        questionText:
            "Which of the following is used to define a function in Python?",
        options: ["function", "def", "define", "func"],
        correctAnswerIndex: 1,
        relatedLesson: "Syntax"),
    Question(
        questionText: "Which keyword is used to create a class in Python?",
        options: ["class", "Class", "struct", "define"],
        correctAnswerIndex: 0,
        relatedLesson: "Classes and Objects"),
    Question(
        questionText: "What is the correct syntax for a for loop in Python?",
        options: [
          "for i in range(5):",
          "for (i = 0; i < 5; i++)",
          "foreach i in range(5):",
          "loop i from 0 to 5"
        ],
        correctAnswerIndex: 0,
        relatedLesson: "Loop Lessons"),
    Question(
        questionText: "Which data structure uses key-value pairs?",
        options: ["List", "Tuple", "Dictionary", "Set"],
        correctAnswerIndex: 2,
        relatedLesson: "Dictionaries"),
    Question(
        questionText: "What is the output of print(2**3)?",
        options: ["5", "6", "8", "9"],
        correctAnswerIndex: 2,
        relatedLesson: "Numbers and Operations"),
    Question(
        questionText: "Which function is used to read input from the user?",
        options: ["input()", "read()", "scan()", "get()"],
        correctAnswerIndex: 0,
        relatedLesson: "User Input"),
    Question(
        questionText: "What does 'len()' do in Python?",
        options: [
          "Returns the length of an object",
          "Adds an item to a list",
          "Removes an item from a dictionary",
          "Prints an object"
        ],
        correctAnswerIndex: 0,
        relatedLesson: "Datatypes"),
    Question(
        questionText: "How do you declare a variable in Python?",
        options: ["var x = 5", "x = 5", "int x = 5", "declare x = 5"],
        correctAnswerIndex: 1,
        relatedLesson: "Variables"),
    Question(
        questionText: "What will print(type({1, 2, 3})) output?",
        options: [
          "<class 'set'>",
          "<class 'list'>",
          "<class 'dict'>",
          "<class 'tuple'>"
        ],
        correctAnswerIndex: 0,
        relatedLesson: "Sets"),
    Question(
        questionText: "Which method is used to add an item to a list?",
        options: ["append()", "add()", "insert()", "push()"],
        correctAnswerIndex: 0,
        relatedLesson: "Lists and Tuples"),
    Question(
        questionText: "Which of the following is NOT a valid variable name?",
        options: ["my_var", "2var", "_var", "varName"],
        correctAnswerIndex: 1,
        relatedLesson: "Syntax"),
    Question(
        questionText: "Which keyword is used to exit a loop prematurely?",
        options: ["break", "exit", "continue", "stop"],
        correctAnswerIndex: 0,
        relatedLesson: "Loop Lessons"),
    Question(
        questionText: "What does the open() function return?",
        options: ["A string", "A file object", "A list", "A dictionary"],
        correctAnswerIndex: 1,
        relatedLesson: "File Handling"),
    Question(
        questionText: "How do you create an infinite loop in Python?",
        options: [
          "while True:",
          "while (true)",
          "for i in range(0, ∞):",
          "loop forever"
        ],
        correctAnswerIndex: 0,
        relatedLesson: "Loop Lessons"),
    Question(
        questionText:
            "What is the default return value of a function that does not return anything?",
        options: ["None", "0", "False", "Empty String"],
        correctAnswerIndex: 0,
        relatedLesson: "Functions"),
    Question(
        questionText: "What does 'isinstance(x, int)' do?",
        options: [
          "Checks if x is an integer",
          "Converts x to an integer",
          "Declares x as an integer",
          "Checks if x is defined"
        ],
        correctAnswerIndex: 0,
        relatedLesson: "Type Casting"),
    Question(
        questionText: "Which operator is used for floor division?",
        options: ["/", "//", "%", "**"],
        correctAnswerIndex: 1,
        relatedLesson: "Numbers and Operations"),
    Question(
        questionText: "How do you open a file for reading?",
        options: [
          "open('file.txt', 'r')",
          "open('file.txt', 'read')",
          "open('file.txt', 'w')",
          "read('file.txt')"
        ],
        correctAnswerIndex: 0,
        relatedLesson: "File Handling"),
    Question(
        questionText: "How do you check if a key exists in a dictionary?",
        options: [
          "if key in dict:",
          "if dict.contains(key):",
          "if key in dict.keys():",
          "if dict.hasKey(key):"
        ],
        correctAnswerIndex: 0,
        relatedLesson: "Dictionaries"),
    Question(
        questionText: "Which keyword is used to define a class method?",
        options: ["def", "class", "method", "func"],
        correctAnswerIndex: 0,
        relatedLesson: "Classes and Objects"),
    Question(
        questionText: "How do you convert a string to lowercase?",
        options: [
          "string.toLower()",
          "string.lower()",
          "string.lowercase()",
          "string.toLowerCase()"
        ],
        correctAnswerIndex: 1,
        relatedLesson: "Strings"),
    Question(
        questionText: "What does 'import math' do?",
        options: [
          "Imports all functions from the math module",
          "Imports a single function from math",
          "Creates a new math object",
          "Defines a math class"
        ],
        correctAnswerIndex: 0,
        relatedLesson: "Date and Math"),
    Question(
        questionText: "Which function returns the absolute value of a number?",
        options: ["abs()", "ceil()", "floor()", "round()"],
        correctAnswerIndex: 0,
        relatedLesson: "Numbers and Operations"),
    Question(
        questionText: "What does 'return' do in a function?",
        options: [
          "Ends the function and returns a value",
          "Prints a value",
          "Stores a value in memory",
          "Loops through a value"
        ],
        correctAnswerIndex: 0,
        relatedLesson: "Functions")
  ];
  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    selectRandomQuestions();
  }

  void selectRandomQuestions() {
    final random = Random();
    selectedQuestions = allQuestions..shuffle(random);
    selectedQuestions = selectedQuestions.take(10).toList();
  }

  void submitQuiz() async {
    double percentage = (score / selectedQuestions.length) * 100;
    bool passed = score >= 8;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser.uid)
        .set({'IntermediateUnlocked': passed}, SetOptions(merge: true));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Quiz Feedback", textAlign: TextAlign.center),
        content: Text(
          "You scored $score out of ${selectedQuestions.length} (${percentage.toInt()}%).\n${passed ? "🎉 Congratulations! Intermediate level is now unlocked in the Beginner page!" : "⚠️ Try again. Revise the lesson and retry."}",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Beginner()),
              );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void answerQuestion(int selectedOptionIndex) {
    setState(() {
      this.selectedOptionIndex = selectedOptionIndex;
      if (selectedOptionIndex ==
          selectedQuestions[currentQuestionIndex].correctAnswerIndex) {
        score++;
      } else {
        wrongAnswers.add(currentQuestionIndex);
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        this.selectedOptionIndex = null;
        if (currentQuestionIndex < selectedQuestions.length - 1) {
          currentQuestionIndex++;
        } else {
          submitQuiz();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Question currentQuestion = selectedQuestions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Python Quiz',
            style: TextStyle(color: Color.fromARGB(255, 43, 3, 3))),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: FadeIn(
        duration: const Duration(milliseconds: 500),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElasticIn(
                duration: const Duration(milliseconds: 600),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 67, 46, 107),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Answer at least 8/10 correctly to unlock Intermediate Level!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              BounceInDown(
                duration: const Duration(milliseconds: 600),
                child: Text(
                  currentQuestion.questionText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 27, 5, 5)),
                ),
              ),
              const SizedBox(height: 20),
              ...currentQuestion.options.asMap().entries.map(
                    (entry) => FadeInLeft(
                      duration: const Duration(milliseconds: 300),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedOptionIndex == null
                                ? Colors.deepPurple
                                : (entry.key ==
                                        currentQuestion.correctAnswerIndex
                                    ? Colors.green
                                    : (selectedOptionIndex == entry.key
                                        ? Colors.red
                                        : Colors.deepPurple)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                          ),
                          onPressed: selectedOptionIndex == null
                              ? () => answerQuestion(entry.key)
                              : null,
                          child: Center(
                            child: Text(
                              entry.value,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class Question {
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String relatedLesson;

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.relatedLesson,
  });
}
