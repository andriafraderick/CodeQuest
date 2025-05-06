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
      home: const Advancedoop(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Advancedoop extends StatefulWidget {
  const Advancedoop({super.key});

  @override
  _AdvancedoopState createState() => _AdvancedoopState();
}

class _AdvancedoopState extends State<Advancedoop> {
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
        isLessonComplete =
            data['intlessons']?['Advanced oop Concepts'] ?? false;
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
        title: const Text('Python Advanced oop consepts & Runner'),
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
                        'Python Advanced oop Lessons',
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
          completeLesson("Advanced oop Concepts");
          Navigator.pop(context, true);
        },
        child: const Text('Complete Lesson'),
      ),
    );
  }

  List<Widget> buildLessonCards() {
    return [
      buildLessonCard(
        title: '1. Class Methods',
        code: '''
class MyClass:
    count = 0

    @classmethod
    def increment_count(cls):
        cls.count += 1

MyClass.increment_count()
print(MyClass.count)
  ''',
        description:
            'Learn how to use `@classmethod` to modify class-level attributes.',
        lessonKey: 'advanced_oop_class_methods',
      ),
      buildLessonCard(
        title: '2. Static Methods',
        code: '''
class MyClass:
    @staticmethod
    def greet():
        return "Hello, this is a static method!"

print(MyClass.greet())
  ''',
        description:
            'Understand `@staticmethod` for utility methods without accessing class data.',
        lessonKey: 'advanced_oop_static_methods',
      ),
      buildLessonCard(
        title: '3. Property Decorators',
        code: '''
class Circle:
    def __init__(self, radius):
        self._radius = radius

    @property
    def radius(self):
        return self._radius

    @radius.setter
    def radius(self, value):
        if value < 0:
            raise ValueError("Radius cannot be negative!")
        self._radius = value

c = Circle(5)
print(c.radius)
c.radius = 10
print(c.radius)
  ''',
        description:
            'Use `@property` for getter and setter methods in a Pythonic way.',
        lessonKey: 'advanced_oop_property_decorators',
      ),
      buildLessonCard(
        title: '4. Inheritance',
        code: '''
class Animal:
    def speak(self):
        print("Animal speaks")

class Dog(Animal):
    def speak(self):
        print("Dog barks")

d = Dog()
d.speak()
  ''',
        description:
            'Learn how to use inheritance to reuse and extend classes.',
        lessonKey: 'advanced_oop_inheritance',
      ),
      buildLessonCard(
        title: '5. Abstract Classes',
        code: '''
from abc import ABC, abstractmethod

class Shape(ABC):
    @abstractmethod
    def area(self):
        pass

class Rectangle(Shape):
    def __init__(self, width, height):
        self.width = width
        self.height = height

    def area(self):
        return self.width * self.height

r = Rectangle(5, 10)
print(r.area())
  ''',
        description:
            'Understand how to use `abc` to define abstract base classes.',
        lessonKey: 'advanced_oop_abstract_classes',
      ),
      buildLessonCard(
        title: '6. Polymorphism',
        code: '''
class Cat:
    def speak(self):
        return "Meow"

class Dog:
    def speak(self):
        return "Bark"

def animal_speak(animal):
    print(animal.speak())

animal_speak(Cat())
animal_speak(Dog())
  ''',
        description:
            'Explore polymorphism by using a unified interface for different objects.',
        lessonKey: 'advanced_oop_polymorphism',
      ),
      buildLessonCard(
        title: '7. Operator Overloading',
        code: '''
class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __add__(self, other):
        return Point(self.x + other.x, self.y + other.y)

p1 = Point(1, 2)
p2 = Point(3, 4)
result = p1 + p2
print(result.x, result.y)
  ''',
        description:
            'Learn how to overload operators like `+` for custom behavior.',
        lessonKey: 'advanced_oop_operator_overloading',
      ),
      buildLessonCard(
        title: '8. Encapsulation',
        code: '''
class Person:
    def __init__(self, name, age):
        self._name = name
        self.__age = age

    def get_age(self):
        return self.__age

p = Person("Alice", 25)
print(p.get_age())
  ''',
        description:
            'Understand data hiding with private and protected attributes.',
        lessonKey: 'advanced_oop_encapsulation',
      ),
      buildLessonCard(
        title: '9. Multiple Inheritance',
        code: '''
class Base1:
    def feature1(self):
        print("Feature 1")

class Base2:
    def feature2(self):
        print("Feature 2")

class Derived(Base1, Base2):
    pass

d = Derived()
d.feature1()
d.feature2()
  ''',
        description: 'Learn how to implement multiple inheritance in Python.',
        lessonKey: 'advanced_oop_multiple_inheritance',
      ),
      buildLessonCard(
        title: '10. Method Resolution Order (MRO)',
        code: '''
class A:
    def show(self):
        print("A")

class B(A):
    def show(self):
        print("B")

class C(B, A):
    pass

c = C()
c.show()
print(C.mro())
  ''',
        description:
            'Understand the order in which methods are resolved in inheritance hierarchies.',
        lessonKey: 'advanced_oop_mro',
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
