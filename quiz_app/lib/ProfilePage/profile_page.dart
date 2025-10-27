import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/models/user_model.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _userModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        final DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();

        if (userDoc.exists) {
          setState(() {
            _userModel = UserModel.fromDocument(userDoc);
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _signOut() async {
    try {
      // Clear SharedPreferences first
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('loggedIn', false);
      await prefs.setBool('profileSetupCompleted', false);
      await prefs.setString('lastRoute', '/login');

      // Sign out from Firebase
      await _auth.signOut();

      // Navigate to login page
      if (mounted) {
        customNavigateReplacement(context, '/login', AnimationType.fade);
      }
    } catch (e) {
      debugPrint('Error signing out: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (_userModel == null)
                      const Center(
                        child: Text(
                          'User data not found',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                      )
                    else ...[
                      _buildProfileHeader(),
                      const SizedBox(height: 24),
                      _buildProfileDetails(),
                    ],
                    const SizedBox(height: 32),
                    _buildSignOutButton(),
                  ],
                ),
              ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.2),
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Center(
            child: Text(
              _getInitials(_userModel!.name),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _userModel!.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _userModel!.role,
          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildProfileDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailItem(
            Icons.person_outline,
            'Age',
            _userModel!.age.toString(),
          ),
          const Divider(height: 24),
          _buildDetailItem(
            Icons.calendar_today_outlined,
            'Date of Birth',
            _userModel!.dateOfBirth,
          ),
          const Divider(height: 24),
          _buildDetailItem(
            Icons.subject_outlined,
            'Subject Area',
            _userModel!.subjectArea,
          ),
          const Divider(height: 24),
          _buildDetailItem(
            Icons.trending_up_outlined,
            'Experience Level',
            _userModel!.experienceLevel,
          ),
          if (_userModel!.interests.isNotEmpty) ...[
            const Divider(height: 24),
            _buildInterestsSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.interests_outlined,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Interests',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _userModel!.interests.map((interest) {
                return Chip(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  label: Text(
                    interest,
                    style: const TextStyle(color: AppColors.primary),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildSignOutButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: _signOut,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Sign Out',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.red.shade700,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';

    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else {
      return name.substring(0, 1).toUpperCase();
    }
  }
}
