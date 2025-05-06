import 'dart:math';
import 'package:flutter/material.dart';

class HangmanGame extends StatefulWidget {
  final VoidCallback onCompleteLesson;

  const HangmanGame({super.key, required this.onCompleteLesson});

  @override
  _HangmanGameState createState() => _HangmanGameState();
}

class _HangmanGameState extends State<HangmanGame> {
  final List<String> words = [
    "dictionary",
    "key",
    "value",
    "items",
    "update",
    "pop",
    "clear",
    "get",
    "keys",
    "values",
    "KeyError",
    "copy",
    "in",
    "len",
    "empty"
  ];

  final List<String> questions = [
    "What is the built-in data type in Python that stores key-value pairs?\n\nHint: This data type uses curly braces `{}` and allows fast retrieval of data using unique keys.",
    "What do you call the unique identifier used to access a value in a dictionary?\n\nHint: Each value in a dictionary is associated with a unique label that identifies it.",
    "What term describes the data associated with a key in a dictionary?\n\nHint: When you access a key, this is the information that is returned.",
    "Which method returns all key-value pairs from a dictionary in the form of tuples?\n\nHint: It provides a list of `(key, value)` pairs that you can iterate through.",
    "Which method is used to add a new key-value pair or update an existing key in a dictionary?\n\nHint: If the key already exists, it modifies the value; if the key is new, it adds a new pair.",
    "Which method is used to remove a key and return its value from a dictionary?\n\nHint: It takes a key as an argument and deletes the key-value pair while returning the value.",
    "Which method is used to empty all elements from a dictionary?\n\nHint: It wipes the dictionary completely, leaving it empty.",
    "Which method is used to retrieve the value of a specified key without causing an error if the key does not exist?\n\nHint: Unlike accessing a key directly, this method returns `None` if the key is not found.",
    "Which method returns a list of all the keys in a dictionary?\n\nHint: It allows you to view all the unique identifiers in the dictionary.",
    "Which method returns a list of all the values in a dictionary?\n\nHint: It provides access to all the data stored in the dictionary without the keys.",
    "What happens if you try to access a key that does not exist using square brackets?\n\nHint: A direct lookup with square brackets throws an error if the key is missing.",
    "What method can be used to copy a dictionary?\n\nHint: This creates a shallow copy of the dictionary, not modifying the original.",
    "How do you check if a key exists in a dictionary?\n\nHint: Use the `in` keyword to check for the presence of a key before accessing it.",
    "What is the result of `len(my_dict)` where `my_dict` is a dictionary?\n\nHint: `len()` counts how many pairs are stored in the dictionary.",
    "How can you create an empty dictionary in Python?\n\nHint: Use curly braces or the `dict()` function to define an empty dictionary."
  ];

  late String wordToGuess;
  late String currentQuestion;
  late List<String> guessedLetters;
  late int attemptsLeft;
  final int maxAttempts = 6;
  int correctAnswers = 0;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    int randomIndex = Random().nextInt(words.length);
    wordToGuess = words[randomIndex].toUpperCase();
    currentQuestion = questions[randomIndex];
    guessedLetters = [];
    attemptsLeft = maxAttempts;
    isGameOver = false;
  }

  void _guessLetter(String letter) {
    setState(() {
      if (!guessedLetters.contains(letter)) {
        guessedLetters.add(letter);
        if (!wordToGuess.contains(letter)) {
          attemptsLeft--;
        } else {
          if (_getDisplayWord().replaceAll(' ', '') == wordToGuess) {
            correctAnswers++;
            if (correctAnswers >= 5) {
              isGameOver = true;
              widget
                  .onCompleteLesson(); // Mark lesson as complete after 5 correct answers
            } else {
              _initializeGame(); // Continue to next question
            }
          }
        }
      }
    });
  }

  String _getDisplayWord() {
    return wordToGuess
        .split('')
        .map((letter) => guessedLetters.contains(letter) ? letter : '_')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          currentQuestion,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text("Attempts Left: $attemptsLeft",
            style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 16),
        Text(_getDisplayWord(),
            style: const TextStyle(fontSize: 32, letterSpacing: 4)),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split('').map((letter) {
            return ElevatedButton(
              onPressed: guessedLetters.contains(letter) ||
                      attemptsLeft == 0 ||
                      isGameOver
                  ? null
                  : () => _guessLetter(letter),
              child: Text(letter),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        if (_getDisplayWord().replaceAll(' ', '') == wordToGuess)
          Text("You Win! The word was $wordToGuess",
              style: const TextStyle(fontSize: 20, color: Colors.green)),
        if (attemptsLeft == 0)
          Text("Game Over! The word was $wordToGuess",
              style: const TextStyle(fontSize: 20, color: Colors.red)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _initializeGame();
            });
          },
          child: const Text('Play Again'),
        ),
        const SizedBox(height: 20),
        if (correctAnswers >= 5)
          Text("You have answered 5 questions correctly! Lesson Complete.",
              style: const TextStyle(fontSize: 20, color: Colors.green)),
      ],
    );
  }
}
