import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class RegexGameScreen extends StatefulWidget {
  @override
  _RegexGameScreenState createState() => _RegexGameScreenState();
}

class _RegexGameScreenState extends State<RegexGameScreen> {
  int currentLevel = 0;
  int score = 0;
  List<bool> wordSelected = [];
  List<bool> wordCorrect = [];
  late ConfettiController _confettiController;
  bool showConfetti = false;

  final List<RegexLevel> levels = [
    RegexLevel(
      title: "Match 4-letter Words",
      description: "Tap words with exactly 4 letters using \\b\\w{4}\\b",
      sentence: "The quick brown fox jumps over the lazy dog",
      regex: r"\b\w{4}\b",
      matches: ["quick", "brown", "jumps", "over", "lazy"],
      color: Colors.blue,
    ),
    RegexLevel(
      title: "Find All Numbers",
      description: "Tap all numbers in the text using \\d+",
      sentence: "I have 3 apples, 15 oranges, and 100 bananas for my 2 kids",
      regex: r"\d+",
      matches: ["3", "15", "100", "2"],
      color: Colors.green,
    ),
    RegexLevel(
      title: "Email Hunter",
      description: "Find valid email addresses",
      sentence: "Contact me@example.com, support@company.co or invalid@email",
      regex: r"\b[\w.-]+@[\w.-]+\.\w+\b",
      matches: ["me@example.com", "support@company.co"],
      color: Colors.orange,
    ),
    RegexLevel(
      title: "Capital Word Search",
      description: "Find words starting with capital letters",
      sentence: "The Quick Brown Fox jumps Over The Lazy Dog in Paris",
      regex: r"\b[A-Z][a-z]*\b",
      matches: [
        "The",
        "Quick",
        "Brown",
        "Fox",
        "Over",
        "The",
        "Lazy",
        "Dog",
        "Paris"
      ],
      color: Colors.purple,
    ),
    RegexLevel(
      title: "Hex Color Finder",
      description: "Match hex color codes like #FF0000",
      sentence:
          "Colors: #FF0000 red, #00FF00 green, #0000FF blue and #ZZZZZZ invalid",
      regex: r"#[0-9A-Fa-f]{6}\b",
      matches: ["#FF0000", "#00FF00", "#0000FF"],
      color: Colors.red,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _loadLevel();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _loadLevel() {
    setState(() {
      wordSelected =
          List.filled(levels[currentLevel].sentence.split(' ').length, false);
      wordCorrect =
          List.filled(levels[currentLevel].sentence.split(' ').length, false);
      showConfetti = false;
    });
  }

  void _checkWord(int index) {
    final word = levels[currentLevel].sentence.split(' ')[index];
    final isMatch = RegExp(levels[currentLevel].regex).hasMatch(word);

    setState(() {
      wordSelected[index] = true;
      wordCorrect[index] = isMatch;
      if (isMatch) score += 10;
    });

    if (_allMatchesFound()) {
      if (currentLevel < levels.length - 1) {
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            currentLevel++;
            _loadLevel();
          });
        });
      } else {
        setState(() {
          showConfetti = true;
          _confettiController.play();
        });
      }
    }
  }

  bool _allMatchesFound() {
    final words = levels[currentLevel].sentence.split(' ');
    for (int i = 0; i < words.length; i++) {
      if (RegExp(levels[currentLevel].regex).hasMatch(words[i]) &&
          !wordSelected[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (showConfetti) {
      // 🎉 Show only the completion screen when all levels are done
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "🎉 Congratulations! 🎉",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "You've completed all levels with $score points!",
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      );
    }

    final words = levels[currentLevel].sentence.split(' ');
    final levelColor = levels[currentLevel].color;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: levelColor.withOpacity(0.1),
          appBar: AppBar(
            title: Text("Level ${currentLevel + 1}/${levels.length}"),
            backgroundColor: levelColor,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        "$score",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: Colors.white,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          levels[currentLevel].title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: levelColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          levels[currentLevel].description,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Regex Pattern:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SelectableText(
                            levels[currentLevel].regex,
                            style: const TextStyle(
                                fontFamily: 'monospace', fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tap matching words:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: List.generate(words.length, (index) {
                                  return GestureDetector(
                                    onTap: () => _checkWord(index),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: wordSelected[index]
                                            ? (wordCorrect[index]
                                                ? Colors.green[400]
                                                : Colors.red[400])
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 2,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        words[index],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: wordSelected[index]
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_allMatchesFound() && currentLevel < levels.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        "Level Complete! Loading next level...",
                        style: TextStyle(
                            color: levelColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (showConfetti)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
          ),
      ],
    );
  }
}

class RegexLevel {
  final String title;
  final String description;
  final String sentence;
  final String regex;
  final List<String> matches;
  final Color color;

  RegexLevel({
    required this.title,
    required this.description,
    required this.sentence,
    required this.regex,
    required this.matches,
    required this.color,
  });
}
