import 'package:flutter/material.dart';

class QuizQuestions extends StatelessWidget {
  const QuizQuestions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Questions'),
      ),
      body: Center(child: Text("Hello",),),
    );
  }
}
