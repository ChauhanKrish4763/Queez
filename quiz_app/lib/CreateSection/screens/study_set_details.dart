import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quiz_app/CreateSection/screens/study_set_dashboard.dart';
import 'package:quiz_app/CreateSection/services/study_set_cache_manager.dart';
import 'package:quiz_app/CreateSection/widgets/custom_dropdown.dart';
import 'package:quiz_app/CreateSection/widgets/custom_text_field.dart';
import 'package:quiz_app/CreateSection/widgets/image_picker.dart';
import 'package:quiz_app/CreateSection/widgets/primary_button.dart';
import 'package:quiz_app/CreateSection/widgets/section_title.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/color.dart';

class StudySetDetails extends StatefulWidget {
  const StudySetDetails({super.key});

  @override
  StudySetDetailsState createState() => StudySetDetailsState();
}

class StudySetDetailsState extends State<StudySetDetails> {
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
          'Create Study Set',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fill the details to get started',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Study Set Title Field
                  SectionTitle(
                    title: 'Study Set Title',
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
                      onChanged:
                          (value) => setState(() => _selectedLanguage = value),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Cover Image Section
                  SectionTitle(
                    title: 'Cover Image',
                    child: ImagePickerWidget(
                      imagePath: _coverImagePath,
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          setState(() {
                            _coverImagePath = image.path;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description Field
                  SectionTitle(
                    title: 'Description',
                    child: CustomTextField(
                      controller: _descriptionController,
                      hintText: 'Describe your study set...',
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
                      onChanged:
                          (value) => setState(() => _selectedTag = value),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Get Started Button
                  PrimaryButton(
                    text: 'Get Started',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final userId = FirebaseAuth.instance.currentUser?.uid;
                        if (userId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('User not authenticated'),
                            ),
                          );
                          return;
                        }

                        // Generate unique ID for study set
                        final studySetId =
                            DateTime.now().millisecondsSinceEpoch.toString();

                        // Initialize study set in cache
                        StudySetCacheManager.instance.initializeStudySet(
                          id: studySetId,
                          name: _titleController.text,
                          description: _descriptionController.text,
                          category: _selectedTag!,
                          language: _selectedLanguage!,
                          ownerId: userId,
                          coverImagePath: _coverImagePath,
                        );

                        // Navigate to dashboard with the details
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                            ) {
                              return PageTransition(
                                animation: animation,
                                animationType: AnimationType.slideLeft,
                                child: StudySetDashboard(
                                  title: _titleController.text,
                                  description: _descriptionController.text,
                                  language: _selectedLanguage!,
                                  category: _selectedTag!,
                                  coverImagePath: _coverImagePath,
                                  studySetId: studySetId,
                                ),
                              );
                            },
                            transitionDuration: const Duration(
                              milliseconds: 300,
                            ),
                          ),
                        );
                      } else {
                        setState(() => _autoValidate = true);
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
