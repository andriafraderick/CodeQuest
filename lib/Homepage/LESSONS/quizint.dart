import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:finalprojects8/Homepage/beginner.dart';

class Quiz2 extends StatefulWidget {
  const Quiz2({super.key});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<Quiz2> {
  int score = 0;
  int currentQuestionIndex = 0;
  int? selectedOptionIndex;
  List<int> wrongAnswers = [];
  List<Question> selectedQuestions = [];
  late User _currentUser;
  List<Question> allQuestions = [
    Question(
      questionText: "What is the main purpose of a function in Python?",
      options: [
        "To store data",
        "To perform a specific task",
        "To define a variable",
        "To create a loop"
      ],
      correctAnswerIndex: 1,
      relatedLesson: "Function and Modules",
    ),
    Question(
      questionText: "Which keyword is used to define a function in Python?",
      options: ["func", "define", "def", "function"],
      correctAnswerIndex: 2,
      relatedLesson: "Function and Modules",
    ),
    Question(
      questionText: "What is an exception in Python?",
      options: [
        "An error that occurs during execution",
        "A function",
        "A loop condition",
        "A variable"
      ],
      correctAnswerIndex: 0,
      relatedLesson: "Error and Exception Handling",
    ),
    Question(
      questionText: "Which keyword is used to handle exceptions in Python?",
      options: ["catch", "handle", "try", "error"],
      correctAnswerIndex: 2,
      relatedLesson: "Error and Exception Handling",
    ),
    Question(
      questionText: "Which of these is a mutable data structure in Python?",
      options: ["Tuple", "String", "List", "Integer"],
      correctAnswerIndex: 2,
      relatedLesson: "Data Structure",
    ),
    Question(
      questionText: "What is the primary use of a dictionary in Python?",
      options: [
        "To store key-value pairs",
        "To store a sequence of numbers",
        "To define a function",
        "To execute a loop"
      ],
      correctAnswerIndex: 0,
      relatedLesson: "Data Structure",
    ),
    Question(
      questionText: "Which keyword is used to define a class in Python?",
      options: ["class", "define", "struct", "type"],
      correctAnswerIndex: 0,
      relatedLesson: "Advanced OOP Concepts",
    ),
    Question(
      questionText:
          "What is the process of creating a child class from a parent class called?",
      options: ["Polymorphism", "Inheritance", "Encapsulation", "Abstraction"],
      correctAnswerIndex: 1,
      relatedLesson: "Python Inheritance",
    ),
    Question(
      questionText: "What is polymorphism in Python?",
      options: [
        "When a function behaves differently based on input",
        "When a class inherits from another",
        "When an object is hidden from users",
        "When variables change dynamically"
      ],
      correctAnswerIndex: 0,
      relatedLesson: "Polymorphism",
    ),
    Question(
      questionText:
          "Which module is used for working with regular expressions in Python?",
      options: ["re", "regex", "regexp", "match"],
      correctAnswerIndex: 0,
      relatedLesson: "Regular Expression",
    ),
    Question(
      questionText:
          "What is the primary function used to find a match in a string using regex?",
      options: ["search()", "find()", "lookup()", "match()"],
      correctAnswerIndex: 3,
      relatedLesson: "Regular Expression",
    ),
    Question(
      questionText:
          "Which data structure does the NumPy library primarily deal with?",
      options: ["List", "Array", "Dictionary", "Set"],
      correctAnswerIndex: 1,
      relatedLesson: "Numpy",
    ),
    Question(
      questionText: "What function is used to create a NumPy array?",
      options: ["array()", "create_array()", "np.array()", "list_to_array()"],
      correctAnswerIndex: 2,
      relatedLesson: "Numpy",
    ),
    Question(
      questionText: "Which library is used for data manipulation in Python?",
      options: ["NumPy", "Pandas", "Matplotlib", "Seaborn"],
      correctAnswerIndex: 1,
      relatedLesson: "Pandas",
    ),
    Question(
      questionText: "Which function is used to read a CSV file in Pandas?",
      options: ["read_csv()", "load_csv()", "import_csv()", "csv_read()"],
      correctAnswerIndex: 0,
      relatedLesson: "Pandas",
    ),
    Question(
      questionText: "What is the default data structure of Pandas?",
      options: ["List", "DataFrame", "Dictionary", "Array"],
      correctAnswerIndex: 1,
      relatedLesson: "Pandas",
    ),
    Question(
      questionText: "What does the 'apply' function in Pandas do?",
      options: [
        "Applies a function to a DataFrame or Series",
        "Deletes a DataFrame column",
        "Merges two DataFrames",
        "Sorts a DataFrame"
      ],
      correctAnswerIndex: 0,
      relatedLesson: "Pandas",
    ),
    Question(
      questionText: "Which keyword is used to import a module in Python?",
      options: ["import", "include", "load", "require"],
      correctAnswerIndex: 0,
      relatedLesson: "Function and Modules",
    ),
    Question(
      questionText: "Which method is used to handle exceptions in Python?",
      options: ["try-except", "catch-throw", "handle-error", "exception-block"],
      correctAnswerIndex: 0,
      relatedLesson: "Error and Exception Handling",
    ),
    Question(
      questionText: "Which data structure uses the LIFO principle?",
      options: ["Queue", "Stack", "Dictionary", "List"],
      correctAnswerIndex: 1,
      relatedLesson: "Data Structure",
    ),
    Question(
      questionText: "Which of the following is an immutable data type?",
      options: ["List", "Dictionary", "Tuple", "Set"],
      correctAnswerIndex: 2,
      relatedLesson: "Data Structure",
    ),
    Question(
      questionText: "Which function is used to find the length of a string?",
      options: ["size()", "count()", "length()", "len()"],
      correctAnswerIndex: 3,
      relatedLesson: "Data Structure",
    ),
    Question(
      questionText: "Which keyword is used to inherit a class in Python?",
      options: ["extends", "inherits", "super", "None of the above"],
      correctAnswerIndex: 3,
      relatedLesson: "Python Inheritance",
    ),
    Question(
      questionText: "Which of these is an example of polymorphism?",
      options: [
        "Overriding a method in a child class",
        "Creating a new variable",
        "Using a list comprehension",
        "Importing a module"
      ],
      correctAnswerIndex: 0,
      relatedLesson: "Polymorphism",
    ),
    Question(
      questionText: "Which symbol is used for regular expressions in Python?",
      options: ["@", "#", "/", "."],
      correctAnswerIndex: 3,
      relatedLesson: "Regular Expression",
    ),
    Question(
      questionText: "What does 're.findall()' return in Python?",
      options: [
        "A list of all matches",
        "Only the first match",
        "A boolean value",
        "None of the above"
      ],
      correctAnswerIndex: 0,
      relatedLesson: "Regular Expression",
    ),
    Question(
      questionText: "What does 'np.zeros((3,3))' create?",
      options: [
        "A list of zeros",
        "A 3x3 matrix of zeros",
        "A 3D array",
        "A dictionary"
      ],
      correctAnswerIndex: 1,
      relatedLesson: "Numpy",
    ),
    Question(
      questionText:
          "Which function is used to concatenate DataFrames in Pandas?",
      options: ["concat()", "merge()", "join()", "append()"],
      correctAnswerIndex: 0,
      relatedLesson: "Pandas",
    ),
  ];
  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    selectRandomQuestions();
  }

  void selectRandomQuestions() {
    final random = Random();
    selectedQuestions = List.from(allQuestions)..shuffle(random);
    selectedQuestions = selectedQuestions.take(10).toList();
  }

  void submitQuiz() async {
    double percentage = (score / selectedQuestions.length) * 100;
    bool passed = score >= 8;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser.uid)
        .set({'AdvancedUnlocked': passed}, SetOptions(merge: true));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Quiz Feedback", textAlign: TextAlign.center),
        content: Text(
          "You scored $score out of ${selectedQuestions.length} (${percentage.toInt()}%).\n${passed ? "🎉 Congratulations! Advanced level is now unlocked!" : "⚠️ Try again. Revise the lesson and retry."}",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Beginner()));
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void answerQuestion(int selectedIndex) {
    setState(() {
      selectedOptionIndex = selectedIndex;
      if (selectedIndex ==
          selectedQuestions[currentQuestionIndex].correctAnswerIndex) {
        score++;
      } else {
        wrongAnswers.add(currentQuestionIndex);
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        if (currentQuestionIndex < selectedQuestions.length - 1) {
          currentQuestionIndex++;
          selectedOptionIndex = null;
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
        title: const Text('Python Quiz', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Question ${currentQuestionIndex + 1} of ${selectedQuestions.length}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                currentQuestion.questionText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            ...currentQuestion.options.asMap().entries.map((entry) {
              int index = entry.key;
              String option = entry.value;
              bool isSelected = selectedOptionIndex == index;
              bool isCorrect = index == currentQuestion.correctAnswerIndex;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 200),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? (isCorrect ? Colors.green : Colors.red)
                          : Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                    ),
                    onPressed: selectedOptionIndex == null
                        ? () => answerQuestion(index)
                        : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            isCorrect ? Icons.check : Icons.close,
                            color: Colors.white,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
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
