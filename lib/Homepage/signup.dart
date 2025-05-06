import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalprojects8/Homepage/auth_page.dart';
import 'package:finalprojects8/Homepage/loginpage.dart';
import 'package:finalprojects8/quiz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  final Function()? onTap;
  const SignupPage({super.key, required this.onTap});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Timer? _emailCheckTimer;
  Timer? _timeoutTimer;
  bool _isLoading = false;
  bool _isVerifying = false;
  bool _isTimeout = false;

  void _signUpUser() async {
    if (!_validateInput()) return;

    setState(() {
      _isLoading = true;
      _isTimeout = false;
    });

    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final User? user = userCredential.user;

      if (user != null) {
        await user.sendEmailVerification();

        _showMessageDialog(
          title: 'Verify Your Email',
          message:
              'A verification email has been sent. Please verify your email within 30 seconds.',
        );

        _startEmailVerificationCheck(user);
        _startVerificationTimeout();
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startEmailVerificationCheck(User user) {
    setState(() => _isVerifying = true);

    _emailCheckTimer =
        Timer.periodic(const Duration(seconds: 3), (timer) async {
      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser != null && refreshedUser.emailVerified) {
        timer.cancel();
        _timeoutTimer?.cancel();

        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'IntermediateUnlocked': false,
          'AdvancedUnlocked': false,
          'emailVerified': true,
          'createdAt': FieldValue.serverTimestamp(),
        });

        _showMessageDialog(
          title: 'Email Verified',
          message: 'Your email has been verified successfully!',
          onOkPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const QuizIntro()),
            );
          },
        );

        setState(() => _isVerifying = false);
      }
    });
  }

  ///  Timer for verification timeout (30 seconds)
  void _startVerificationTimeout() {
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      _emailCheckTimer?.cancel();
      setState(() {
        _isVerifying = false;
        _isTimeout = true;
      });

      //  Show "Not Verified" message
      _showErrorMessage("Email not verified. Please try again.");
    });
  }

  ///  Validate Input Fields
  bool _validateInput() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorMessage("Please fill in all fields.");
      return false;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _showErrorMessage("Enter a valid email.");
      return false;
    }

    if (password.length < 6) {
      _showErrorMessage("Password must be at least 6 characters.");
      return false;
    }

    return true;
  }

  ///  Handle Auth Exceptions with specific messages
  void _handleAuthException(FirebaseAuthException e) {
    if (e.code == 'user-not-found') {
      _showErrorMessage("Email not found. Please sign up.");
    } else if (e.code == 'wrong-password') {
      _showErrorMessage("Incorrect password.");
    } else if (e.code == 'email-already-in-use') {
      _showErrorMessage("Email already in use. Please login.");
    } else {
      _showErrorMessage(e.message ?? "Sign-up failed.");
    }
  }

  /// Show Message Dialog
  void _showMessageDialog({
    required String title,
    required String message,
    VoidCallback? onOkPressed,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onOkPressed != null) onOkPressed();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  ///  Show Error Message Dialog
  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red,
        title: const Center(
          child: Text(
            'Error',
            style: TextStyle(color: Colors.white),
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailCheckTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //  Background Image
          Positioned.fill(
            child: Image.asset(
              'lib/images/bk1.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'CREATE AN ACCOUNT',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 247, 248, 248),
                    ),
                  ),
                  const SizedBox(height: 20),

                  //  Email TextField
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.email),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 243, 243, 244),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),

                  const SizedBox(height: 15),

                  //  Password TextField
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 254, 255, 255),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signUpUser,
                    child: const Text("SIGN UP"),
                  ),

                  const SizedBox(height: 15),

                  if (_isVerifying)
                    const CircularProgressIndicator(color: Colors.green),

                  if (_isTimeout)
                    const Text("Email not verified!",
                        style: TextStyle(color: Colors.red)),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(onTap: widget.onTap),
                        ),
                      );
                    },
                    child: const Text(
                      "Already  have an account? Log in",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
