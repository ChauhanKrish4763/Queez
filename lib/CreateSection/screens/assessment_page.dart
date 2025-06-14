import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';

class AssessmentPage extends StatelessWidget {
  const AssessmentPage({super.key});

  void _onQuizTap(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create a Quiz tapped!')),
    );
  }

  void _onPollTap(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create a Poll tapped!')),
    );
  }

  void _onSurveyTap(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create a Survey tapped!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Create Assessment',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.iconActive),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _onQuizTap(context),
                child: Card(
                  elevation: 6,
                  color: Colors.grey[150],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  shadowColor: Colors.black26,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon
                        Image.asset(
                          'assets/icons/quiz_icon.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 16),

                        // Texts
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Create a Quiz',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Test knowledge with multiple choice, true/false, and open-ended questions',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Arrow indicator
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.iconActive,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () => _onPollTap(context),
                child: Card(
                  elevation: 6,
                  color: Colors.grey[150],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  shadowColor: Colors.black26,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon
                        Image.asset(
                          'assets/icons/poll_icon.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 16),

                        // Texts
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Create a Poll',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Gather quick opinions and instant feedback from your audience',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Arrow indicator
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.iconActive,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () => _onSurveyTap(context),
                child: Card(
                  elevation: 6,
                  color: Colors.grey[150],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  shadowColor: Colors.black26,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon
                        Image.asset(
                          'assets/icons/survey_icon.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 16),

                        // Texts
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Create a Survey',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Collect detailed responses and comprehensive data insights',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Arrow indicator
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.iconActive,
                          size: 18,
                        ),
                      ],
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
