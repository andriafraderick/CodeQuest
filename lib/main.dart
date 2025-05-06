import 'package:finalprojects8/Homepage/LESSONS/intro.dart';
import 'package:finalprojects8/Homepage/auth_page.dart';
import 'package:finalprojects8/Homepage/loginpage.dart';
import 'package:finalprojects8/Homepage/signup.dart';
import 'package:finalprojects8/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:finalprojects8/Homepage/Intermediate.dart';
import 'package:finalprojects8/Homepage/beginner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CodeQuestApp());
}

class CodeQuestApp extends StatelessWidget {
  const CodeQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'CodeQuest',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
