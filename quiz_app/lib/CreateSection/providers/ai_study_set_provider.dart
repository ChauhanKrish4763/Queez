import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/CreateSection/models/ai_study_set_models.dart';
import 'package:quiz_app/CreateSection/models/study_set.dart';
import 'package:quiz_app/CreateSection/services/ai_study_set_service.dart';

// State class to hold all AI study set data
class AIStudySetState {
  final List<UploadedFile> uploadedFiles;
  final StudySetConfig config;
  final GenerationSettings settings;
  final bool isGenerating;
  final double progress;
  final String currentStep;
  final String? error;
  final StudySet? generatedStudySet;

  const AIStudySetState({
    this.uploadedFiles = const [],
    required this.config,
    required this.settings,
    this.isGenerating = false,
    this.progress = 0.0,
    this.currentStep = '',
    this.error,
    this.generatedStudySet,
  });

  bool get canGenerate {
    return uploadedFiles.isNotEmpty &&
        uploadedFiles.length <= 3 &&
        config.isValid &&
        !isGenerating;
  }

  AIStudySetState copyWith({
    List<UploadedFile>? uploadedFiles,
    StudySetConfig? config,
    GenerationSettings? settings,
    bool? isGenerating,
    double? progress,
    String? currentStep,
    String? error,
    StudySet? generatedStudySet,
  }) {
    return AIStudySetState(
      uploadedFiles: uploadedFiles ?? this.uploadedFiles,
      config: config ?? this.config,
      settings: settings ?? this.settings,
      isGenerating: isGenerating ?? this.isGenerating,
      progress: progress ?? this.progress,
      currentStep: currentStep ?? this.currentStep,
      error: error,
      generatedStudySet: generatedStudySet,
    );
  }
}

// Notifier for managing AI study set state (Riverpod 3.0+)
class AIStudySetNotifier extends Notifier<AIStudySetState> {
  @override
  AIStudySetState build() {
    return AIStudySetState(
      config: StudySetConfig(),
      settings: GenerationSettings(),
    );
  }

  /// Upload a file to Gemini via backend
  Future<void> uploadFile(File file) async {
    if (state.uploadedFiles.length >= 3) {
      throw Exception('Maximum 3 files allowed');
    }

    // Check file size (20MB limit)
    final fileSize = await file.length();
    if (fileSize > 20 * 1024 * 1024) {
      throw Exception('File size exceeds 20MB limit');
    }

    try {
      state = state.copyWith(error: null);

      debugPrint('Uploading file via backend...');

      final uploadedFile = await AIStudySetService.uploadFileToGemini(
        file: file,
      );

      final updatedFiles = [...state.uploadedFiles, uploadedFile];
      state = state.copyWith(uploadedFiles: updatedFiles);

      debugPrint(
        'File uploaded: ${uploadedFile.fileName} -> ${uploadedFile.fileUri}',
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      debugPrint('Error uploading file: $e');
      rethrow;
    }
  }

  /// Remove an uploaded file
  void removeFile(int index) {
    if (index >= 0 && index < state.uploadedFiles.length) {
      final updatedFiles = List<UploadedFile>.from(state.uploadedFiles);
      updatedFiles.removeAt(index);
      state = state.copyWith(uploadedFiles: updatedFiles);
    }
  }

  /// Update study set configuration
  void updateConfig({
    String? name,
    String? description,
    String? category,
    String? language,
    String? coverImagePath,
  }) {
    final updatedConfig =
        StudySetConfig()
          ..name = name ?? state.config.name
          ..description = description ?? state.config.description
          ..category = category ?? state.config.category
          ..language = language ?? state.config.language
          ..coverImagePath = coverImagePath ?? state.config.coverImagePath;

    state = state.copyWith(config: updatedConfig);
  }

  /// Update generation settings
  void updateSettings({
    int? quizCount,
    int? flashcardSetCount,
    int? noteCount,
    String? difficulty,
    int? questionsPerQuiz,
    int? cardsPerSet,
  }) {
    final updatedSettings =
        GenerationSettings()
          ..quizCount = quizCount ?? state.settings.quizCount
          ..flashcardSetCount =
              flashcardSetCount ?? state.settings.flashcardSetCount
          ..noteCount = noteCount ?? state.settings.noteCount
          ..difficulty = difficulty ?? state.settings.difficulty
          ..questionsPerQuiz =
              questionsPerQuiz ?? state.settings.questionsPerQuiz
          ..cardsPerSet = cardsPerSet ?? state.settings.cardsPerSet;

    state = state.copyWith(settings: updatedSettings);
  }

  /// Update progress
  void _updateProgress(double progress, String step) {
    state = state.copyWith(progress: progress, currentStep: step);
  }

  /// Generate study set
  Future<StudySet> generateStudySet() async {
    if (!state.canGenerate) {
      throw Exception('Cannot generate: invalid configuration or files');
    }

    try {
      state = state.copyWith(
        isGenerating: true,
        error: null,
        generatedStudySet: null,
      );
      _updateProgress(0, 'Preparing your documents...');

      // Simulate initial progress
      await Future.delayed(const Duration(milliseconds: 500));
      _updateProgress(10, 'Sending files to Gemini...');

      await Future.delayed(const Duration(milliseconds: 500));
      _updateProgress(20, 'Analyzing document content...');

      // Extract file URIs
      final fileUris = state.uploadedFiles.map((f) => f.fileUri).toList();

      // Call backend to generate
      _updateProgress(30, 'Generating study materials...');

      final studySet = await AIStudySetService.generateStudySet(
        fileUris: fileUris,
        config: state.config,
        settings: state.settings,
      );

      // Simulate generation phases
      await Future.delayed(const Duration(milliseconds: 800));
      _updateProgress(50, 'Creating quiz questions...');

      await Future.delayed(const Duration(milliseconds: 800));
      _updateProgress(70, 'Building flashcard sets...');

      await Future.delayed(const Duration(milliseconds: 600));
      _updateProgress(85, 'Compiling study notes...');

      await Future.delayed(const Duration(milliseconds: 400));
      _updateProgress(95, 'Finalizing your study set...');

      await Future.delayed(const Duration(milliseconds: 300));
      _updateProgress(100, 'Complete!');

      state = state.copyWith(generatedStudySet: studySet, isGenerating: false);

      return studySet;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isGenerating: false,
        progress: 0,
        currentStep: '',
      );
      debugPrint('Error generating study set: $e');
      rethrow;
    }
  }

  /// Reset all state
  void reset() {
    state = AIStudySetState(
      config: StudySetConfig(),
      settings: GenerationSettings(),
    );
  }
}

// The Riverpod provider (Riverpod 3.0+ syntax)
final aiStudySetProvider =
    NotifierProvider<AIStudySetNotifier, AIStudySetState>(() {
      return AIStudySetNotifier();
    });
