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
      home: const Polymorphism(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Polymorphism extends StatefulWidget {
  const Polymorphism({super.key});

  @override
  _PolymorphismState createState() => _PolymorphismState();
}

class _PolymorphismState extends State<Polymorphism> {
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
        isLessonComplete = data['intlessons']?['Polymorphism'] ?? false;
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
        title: const Text('Python Polymorphism & Runner'),
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
                        'Python Polymorphism Lessons',
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
          completeLesson("Polymorphism");
          Navigator.pop(context, true);
        },
        child: const Text('Complete Lesson'),
      ),
    );
  }

  List<Widget> buildLessonCards() {
    return [
      buildLessonCard(
        title: '1. Polymorphism with Functions',
        code: '''
def add(a, b):
    return a + b

print(add(2, 3))          # Adding integers
print(add("Hello, ", "World!"))  # Concatenating strings
  ''',
        description:
            'Learn how Python functions exhibit polymorphism by working with different data types.',
        lessonKey: 'polymorphism_functions',
      ),
      buildLessonCard(
        title: '2. Polymorphism with Classes',
        code: '''
class Dog:
    def speak(self):
        return "Woof!"

class Cat:
    def speak(self):
        return "Meow!"

animals = [Dog(), Cat()]

for animal in animals:
    print(animal.speak())
  ''',
        description:
            'Understand how polymorphism allows different classes to use the same method name with different behaviors.',
        lessonKey: 'polymorphism_classes',
      ),
      buildLessonCard(
        title: '3. Polymorphism with Inheritance',
        code: '''
class Parent:
    def show_message(self):
        print("This is the parent class.")

class Child(Parent):
    def show_message(self):
        print("This is the child class.")

def display_message(obj):
    obj.show_message()

parent = Parent()
child = Child()

display_message(parent)
display_message(child)
  ''',
        description:
            'Explore how polymorphism works in inheritance, allowing a method to behave differently based on the object.',
        lessonKey: 'polymorphism_inheritance',
      ),
      buildLessonCard(
        title: '4. Polymorphism with Abstract Base Classes',
        code: '''
from abc import ABC, abstractmethod

class Animal(ABC):
    @abstractmethod
    def sound(self):
        pass

class Dog(Animal):
    def sound(self):
        return "Woof!"

class Cat(Animal):
    def sound(self):
        return "Meow!"

animals = [Dog(), Cat()]

for animal in animals:
    print(animal.sound())
  ''',
        description:
            'Learn how abstract base classes enforce method implementation in derived classes to achieve polymorphism.',
        lessonKey: 'polymorphism_abstract_base_classes',
      ),
      buildLessonCard(
        title: '5. Operator Overloading',
        code: '''
class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __add__(self, other):
        return Point(self.x + other.x, self.y + other.y)

    def __str__(self):
        return f"Point({self.x}, {self.y})"

p1 = Point(2, 3)
p2 = Point(4, 5)
result = p1 + p2
print(result)
  ''',
        description:
            'Understand how operator overloading allows using operators like `+` for custom objects.',
        lessonKey: 'polymorphism_operator_overloading',
      ),
      buildLessonCard(
        title: '6. Duck Typing',
        code: '''
class Duck:
    def quack(self):
        return "Quack!"

class Person:
    def quack(self):
        return "I can mimic a duck!"

def make_it_quack(duck_like):
    print(duck_like.quack())

make_it_quack(Duck())
make_it_quack(Person())
  ''',
        description:
            'Discover duck typing, where an object’s behavior is determined by the presence of methods, not its type.',
        lessonKey: 'polymorphism_duck_typing',
      ),
      buildLessonCard(
        title: '7. Method Overloading (Emulated)',
        code: '''
class Calculator:
    def add(self, *args):
        return sum(args)

calc = Calculator()
print(calc.add(2, 3))       # Adding two numbers
print(calc.add(1, 2, 3, 4)) # Adding multiple numbers
  ''',
        description:
            'Learn how to emulate method overloading in Python using variable arguments with `*args`.',
        lessonKey: 'polymorphism_method_overloading',
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
    final Uri url =
        Uri.parse('http://192.168.56.1:5005/run'); // Replace with server URL

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
            TextField(
              controller: _codeController,
              maxLines: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your Python code here...',
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
