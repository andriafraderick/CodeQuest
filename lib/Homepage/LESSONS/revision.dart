import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finalprojects8/Homepage/Advanced.dart';
import 'package:finalprojects8/Homepage/Intermediate.dart';
import 'package:finalprojects8/Homepage/beginner.dart';

class RevisionPage extends StatelessWidget {
  const RevisionPage({super.key});

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

  void _navigateToLevelPage(BuildContext context, String level) {
    if (level == "beginner") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Beginner()),
      );
    } else if (level == "intermediate") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Intermediate()),
      );
    } else if (level == "advanced") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Advanced()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revision'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Your score is below 80%. Please revise the lessons before moving forward.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final level = await _getUserLevel();
                  if (level != null) {
                    _navigateToLevelPage(context, level);
                  } else {
                    // Handle cases where level is not found
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Unable to determine user level.'),
                      ),
                    );
                  }
                },
                child: const Text('Revise Lessons'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
