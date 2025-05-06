import 'package:finalprojects8/Homepage/login_register.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User _currentUser;
  late TextEditingController _usernameController;

  File? _imageFile;
  Uint8List? _imageBytes;
  bool _isEditingUsername = false;
  bool _isUploading = false;

  String userEmail = "No email";
  String username = "Not set";
  String joinDate = "Unknown";
  int totalCompleted = 0;
  int percentage = 0;
  int currentStreak = 0;

  // Lesson tracking
  int basicLessonsCompleted = 0;
  int intLessonsCompleted = 0;
  int advancedLevelsCompleted = 0;
  List<String> completedBasicLessonNames = [];
  List<String> completedIntLessonNames = [];
  List<String> completedAdvancedLevelNames = [];

  // Constants for total counts
  static const int totalBasicLessons = 12;
  static const int totalIntLessons = 8;
  static const int totalAdvancedLevels = 20;
  static const int totalItems =
      totalBasicLessons + totalIntLessons + totalAdvancedLevels;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser!;
    _usernameController = TextEditingController();
    _loadUserData();
    _updateStreak();
    _loadProfilePicture();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Widget _buildProfilePicture() {
    return GestureDetector(
      onTap: _showImageOptions,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[200],
            backgroundImage: _getProfileImage(),
            child: _getProfileImage() == null
                ? Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.blueGrey,
                  )
                : null,
          ),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              Icons.camera_alt,
              size: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showImageOptions() {
    final imageProvider = _getProfileImage();
    if (imageProvider == null) {
      _pickImage();
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('View Profile Picture'),
            onTap: () {
              Navigator.pop(context);
              _showFullScreenImage();
            },
          ),
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Change Profile Picture'),
            onTap: () {
              Navigator.pop(context);
              _pickImage();
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Remove Profile Picture',
                style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _removeProfilePicture();
            },
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage() {
    final imageProvider = _getProfileImage();
    if (imageProvider == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 3.0,
              child: Image(image: imageProvider),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _removeProfilePicture() async {
    try {
      setState(() {
        _imageBytes = null;
        _imageFile = null;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('profile_picture_${_currentUser.uid}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile picture removed')),
      );
    } catch (e) {
      print("Error removing profile picture: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove profile picture')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      setState(() => _isUploading = true);

      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() => _imageBytes = bytes);
          await _saveProfilePicture(bytes);
        } else {
          setState(() => _imageFile = File(pickedFile.path));
          await _saveProfilePicture(pickedFile.path);
        }
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image. Please try again.')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _saveProfilePicture(dynamic imageData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (kIsWeb) {
        // For web - store as base64 string
        if (imageData is Uint8List) {
          await prefs.setString(
              'profile_picture_${_currentUser.uid}', base64Encode(imageData));
        }
      } else {
        // For mobile - store file path
        if (imageData is String) {
          await prefs.setString(
              'profile_picture_${_currentUser.uid}', imageData);
        }
      }
    } catch (e) {
      print("Error saving profile picture: $e");
    }
  }

  Future<void> _loadProfilePicture() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedImage = prefs.getString('profile_picture_${_currentUser.uid}');

      if (savedImage != null) {
        if (kIsWeb) {
          // For web - decode base64
          setState(() {
            _imageBytes = base64Decode(savedImage);
          });
        } else {
          // For mobile - check if file exists
          if (await File(savedImage).exists()) {
            setState(() {
              _imageFile = File(savedImage);
            });
          }
        }
      }
    } catch (e) {
      print("Error loading profile picture: $e");
    }
  }

  ImageProvider? _getProfileImage() {
    if (kIsWeb) {
      if (_imageBytes != null) {
        return MemoryImage(_imageBytes!);
      } else {
        return (_currentUser.photoURL != null
            ? NetworkImage(_currentUser.photoURL!)
            : null);
      }
    } else {
      if (_imageFile != null) {
        return FileImage(_imageFile!);
      } else {
        return (_currentUser.photoURL != null
            ? NetworkImage(_currentUser.photoURL!)
            : null);
      }
    }
  }

  Future<void> _updateUsername() async {
    if (_usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username cannot be empty')),
      );
      return;
    }

    try {
      await _firestore.collection('users').doc(_currentUser.uid).set({
        'username': _usernameController.text.trim(),
      }, SetOptions(merge: true));

      setState(() {
        username = _usernameController.text.trim();
        _isEditingUsername = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username updated successfully')),
      );
    } catch (e) {
      print("Error updating username: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update username. Please try again.')),
      );
    }
  }

  Widget _buildUsernameField() {
    if (_isEditingUsername) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'Enter new username',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.check, color: Colors.green),
              onPressed: _updateUsername,
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: () {
                setState(() {
                  _isEditingUsername = false;
                });
              },
            ),
          ],
        ),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            username,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, size: 18),
            onPressed: () {
              _usernameController.text = username;
              setState(() {
                _isEditingUsername = true;
              });
            },
          ),
        ],
      );
    }
  }

  Future<void> _updateStreak() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final streakDoc =
          await _firestore.collection('streaks').doc(_currentUser.uid).get();

      if (streakDoc.exists) {
        final lastLogin = streakDoc.data()?['lastLogin'] as String?;
        final currentStreak = streakDoc.data()?['streak'] as int? ?? 0;

        if (lastLogin != today) {
          // Check if consecutive day
          final yesterday = DateFormat('yyyy-MM-dd')
              .format(DateTime.now().subtract(Duration(days: 1)));
          final newStreak = lastLogin == yesterday ? currentStreak + 1 : 1;

          await _firestore.collection('streaks').doc(_currentUser.uid).set({
            'lastLogin': today,
            'streak': newStreak,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          setState(() {
            this.currentStreak = newStreak;
          });
        }
      } else {
        // First time tracking streak
        await _firestore.collection('streaks').doc(_currentUser.uid).set({
          'lastLogin': today,
          'streak': 1,
          'createdAt': FieldValue.serverTimestamp(),
        });
        setState(() {
          currentStreak = 1;
        });
      }
    } catch (e) {
      print("Error updating streak: $e");
    }
  }

  Future<void> _loadUserData() async {
    try {
      // Load user document
      final userDoc =
          await _firestore.collection('users').doc(_currentUser.uid).get();
      final streakDoc =
          await _firestore.collection('streaks').doc(_currentUser.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data()!;

        // Count completed basic lessons (lessons map)
        if (data['lessons'] is Map) {
          final lessonsMap = data['lessons'] as Map<String, dynamic>;
          basicLessonsCompleted =
              lessonsMap.values.where((v) => v == true).length;
          completedBasicLessonNames = lessonsMap.entries
              .where((e) => e.value == true)
              .map((e) => e.key)
              .toList();
        }

        // Count completed intermediate lessons (intlessons map)
        if (data['intlessons'] is Map) {
          final intLessonsMap = data['intlessons'] as Map<String, dynamic>;
          intLessonsCompleted =
              intLessonsMap.values.where((v) => v == true).length;
          completedIntLessonNames = intLessonsMap.entries
              .where((e) => e.value == true)
              .map((e) => e.key)
              .toList();
        }

        // Load completed advanced levels
        await _loadAdvancedLevels();

        // Calculate totals
        final newTotalCompleted = basicLessonsCompleted +
            intLessonsCompleted +
            advancedLevelsCompleted;
        final newPercentage = ((newTotalCompleted / totalItems) * 100).round();

        setState(() {
          userEmail = _currentUser.email ?? "No email";
          username = data['username']?.toString() ?? "Not set";
          totalCompleted = newTotalCompleted;
          percentage = newPercentage;
          currentStreak = streakDoc.data()?['streak'] as int? ?? 0;

          final timestamp = data['createdAt'] as Timestamp?;
          joinDate = timestamp?.toDate().toString().split(' ')[0] ?? "Unknown";
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  Future<void> _loadAdvancedLevels() async {
    try {
      final advancedLevelsDoc = await _firestore
          .collection('Advancedlevels')
          .doc(_currentUser.uid)
          .get();

      if (advancedLevelsDoc.exists) {
        final data = advancedLevelsDoc.data();

        if (data != null &&
            data.containsKey('levels') &&
            data['levels'] is Map<String, dynamic>) {
          final levelsMap = data['levels'] as Map<String, dynamic>;
          final completedLevels = levelsMap.entries
              .where((entry) => entry.value == true)
              .map((entry) => entry.key)
              .toList();

          completedLevels.sort((a, b) {
            int numA = int.parse(a.replaceAll(RegExp(r'[^0-9]'), ''));
            int numB = int.parse(b.replaceAll(RegExp(r'[^0-9]'), ''));
            return numA.compareTo(numB);
          });

          setState(() {
            advancedLevelsCompleted = completedLevels.length;
            completedAdvancedLevelNames = completedLevels
                .map((level) => level.replaceFirst('level', 'Level '))
                .toList();
          });
        }
      }
    } catch (e) {
      print("Error loading advanced levels: $e");
    }
  }

  Widget _buildProgressSection({
    required String title,
    required int completedCount,
    required int totalCount,
    required List<String> completedNames,
    Color color = Colors.blueAccent,
  }) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$title ($completedCount/$totalCount)",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: totalCount > 0 ? completedCount / totalCount : 0,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            SizedBox(height: 12),
            if (completedNames.isNotEmpty) ...[
              Text(
                "Completed:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ...completedNames.map((name) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Expanded(child: Text(name)),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginRegister()),
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadUserData,
            tooltip: "Refresh Data",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Column(
              children: [
                _buildProfilePicture(),
                if (_isUploading)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: CircularProgressIndicator(),
                  ),
                SizedBox(height: 16),
                _buildUsernameField(),
                Text(
                  userEmail,
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  "Joined: $joinDate",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Streak Display
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_fire_department,
                        color: Colors.orange, size: 30),
                    SizedBox(width: 8),
                    Text(
                      "Current Streak: $currentStreak days",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Progress Overview
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      "Progress Overview",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: Text("Total Completed"),
                      trailing: Text("$totalCompleted/$totalItems"),
                    ),
                    ListTile(
                      title: Text("Overall Completion"),
                      trailing: Text("$percentage%"),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Basic Lessons Progress
            _buildProgressSection(
              title: "Basic Lessons",
              completedCount: basicLessonsCompleted,
              totalCount: totalBasicLessons,
              completedNames: completedBasicLessonNames,
              color: Colors.blueAccent,
            ),

            // Intermediate Lessons Progress
            _buildProgressSection(
              title: "Intermediate Lessons",
              completedCount: intLessonsCompleted,
              totalCount: totalIntLessons,
              completedNames: completedIntLessonNames,
              color: Colors.green,
            ),

            // Advanced Levels Progress
            _buildProgressSection(
              title: "Advanced Levels",
              completedCount: advancedLevelsCompleted,
              totalCount: totalAdvancedLevels,
              completedNames: completedAdvancedLevelNames,
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
}
