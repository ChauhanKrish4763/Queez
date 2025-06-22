import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/services/quiz_cache_manager.dart';
import 'package:quiz_app/CreateSection/widgets/custom_dropdown.dart';
import 'package:quiz_app/CreateSection/widgets/custom_text_field.dart';
import 'package:quiz_app/CreateSection/widgets/image_picker.dart';
import 'package:quiz_app/CreateSection/widgets/primary_button.dart';
import 'package:quiz_app/CreateSection/widgets/section_title.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/color.dart';

class QuizDetails extends StatefulWidget {
  const QuizDetails({super.key});

  @override
  _QuizDetailsState createState() => _QuizDetailsState();
}

class _QuizDetailsState extends State<QuizDetails> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedTag;
  String? _selectedLanguage;
  String? _coverImagePath;
  bool _autoValidate = false;

  final List<String> _tags = [
    'Language Learning',
    'Science and Technology',
    'Law',
    'Other',
  ];

  final List<String> _languages = ['English', 'Spanish', 'French', 'Others'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Create Quiz',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Simple Title
                  Text(
                    'Fill the details to get started',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Quiz Title Field
                  SectionTitle(
                    title: 'Quiz Title',
                    child: CustomTextField(
                      controller: _titleController,
                      hintText: 'Enter the title',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                      autoValidate: _autoValidate,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Language Dropdown
                  SectionTitle(
                    title: 'Language',
                    child: CustomDropdown(
                      value: _selectedLanguage,
                      items: _languages,
                      hintText: 'Select a language',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a language';
                        }
                        return null;
                      },
                      autoValidate: _autoValidate,
                      onChanged: (value) {
                        setState(() {
                          _selectedLanguage = value;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Cover Image Section
                  SectionTitle(
                    title: 'Cover Image',
                    child: ImagePickerWidget(
                      imagePath: _coverImagePath,
                      onTap: () {
                        // TODO: Implement image picker
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description Field
                  SectionTitle(
                    title: 'Description',
                    child: CustomTextField(
                      controller: _descriptionController,
                      hintText: 'Describe your quiz...',
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                      autoValidate: _autoValidate,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Category Dropdown
                  SectionTitle(
                    title: 'Category',
                    child: CustomDropdown(
                      value: _selectedTag,
                      items: _tags,
                      hintText: 'Select a category',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                      autoValidate: _autoValidate,
                      onChanged: (value) {
                        setState(() {
                          _selectedTag = value;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Get Started Button
                  PrimaryButton(
                    text: 'Get Started',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Add this cache functionality here
                        QuizCacheManager.instance.cacheQuizDetails(
                          title: _titleController.text,
                          description: _descriptionController.text,
                          language: _selectedLanguage!,
                          category: _selectedTag!,
                          coverImagePath: _coverImagePath,
                        );

                        customNavigate(
                          context,
                          '/quiz_questions',
                          AnimationType.slideLeft,
                        );
                      } else {
                        setState(() {
                          _autoValidate = true;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
