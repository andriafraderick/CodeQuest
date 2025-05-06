import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalprojects8/Homepage/Advanced.dart';
import 'package:finalprojects8/Homepage/Intermediate.dart';
import 'package:finalprojects8/Homepage/beginner.dart';
import 'package:finalprojects8/Homepage/login_register.dart';
import 'package:finalprojects8/Homepage/loginpage.dart';
import 'package:finalprojects8/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  Future<String?> _getUserLevel() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        return doc.data()?['level'] as String?;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserLevel(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          final level = snapshot.data;
          if (level == "beginner") {
            return Beginner();
          } else if (level == "intermediate") {
            return Intermediate();
          } else if (level == "advanced") {
            return const Advanced();
          }
        }
        return const LoginRegister();
      },
    );
  }
}
