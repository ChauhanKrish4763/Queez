import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:quiz_app/CreateSection/models/note.dart';
import 'package:quiz_app/CreateSection/services/note_service.dart';
import 'package:quiz_app/utils/color.dart';

class NoteViewerPage extends StatefulWidget {
  final String noteId;
  final String userId;
  final Note? preloadedNote;

  const NoteViewerPage({
    super.key,
    required this.noteId,
    required this.userId,
    this.preloadedNote,
  });

  @override
  State<NoteViewerPage> createState() => _NoteViewerPageState();
}

class _NoteViewerPageState extends State<NoteViewerPage> {
  late QuillController _controller;
  String? _noteTitle;

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();

    // Use preloaded note if available, otherwise fetch
    if (widget.preloadedNote != null) {
      _initializeNote(widget.preloadedNote!);
    } else {
      _loadNote();
    }
  }

  void _initializeNote(Note note) {
    try {
      // Parse the JSON content and create document
      final List<dynamic> deltaJson = jsonDecode(note.content);
      final document = Document.fromJson(deltaJson);

      setState(() {
        _controller = QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
        _noteTitle = note.title;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading note: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadNote() async {
    try {
      final note = await NoteService.getNote(widget.noteId, widget.userId);
      _initializeNote(note);
    } catch (e) {
      // Show error in snackbar instead of state
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _noteTitle ?? 'Note',
          style: const TextStyle(
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
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: QuillEditor.basic(controller: _controller),
      ),
    );
  }
}
