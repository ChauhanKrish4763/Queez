import 'package:flutter/material.dart';
import 'package:quiz_app/ProfileSetup/widgets/profile_progress_indicator.dart';
import 'package:quiz_app/ProfileSetup/widgets/role_selection_card.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/color.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  void _onRoleSelected(String role) {
    setState(() {
      _selectedRole = role;
    });
  }

  void _onContinue() {
    if (_selectedRole != null) {
      customNavigate(
        context, 
        '/profile_basic_info', 
        AnimationType.slideLeft,
        arguments: {'role': _selectedRole},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const ProfileProgressIndicator(currentStep: 2, totalSteps: 4),
              const SizedBox(height: 32),
              const Text(
                'Choose Your Role',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Select how you\'ll be using Queez',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              RoleSelectionCard(
                title: 'Educator',
                description: 'Teach and manage classrooms',
                iconData: Icons.school,
                isSelected: _selectedRole == 'Educator',
                onTap: () => _onRoleSelected('Educator'),
              ),
              const SizedBox(height: 20),
              RoleSelectionCard(
                title: 'Individual/Personal',
                description: 'Personal learning and quizzes',
                iconData: Icons.person,
                isSelected: _selectedRole == 'Individual/Personal',
                onTap: () => _onRoleSelected('Individual/Personal'),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color:
                      _selectedRole != null
                          ? AppColors.primary
                          : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow:
                      _selectedRole != null
                          ? [
                            BoxShadow(
                              color: AppColors.accentShadow,
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                          : null,
                ),
                child: ElevatedButton(
                  onPressed: _selectedRole != null ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color:
                          _selectedRole != null
                              ? AppColors.white
                              : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
