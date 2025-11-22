# Design Document

## Overview

The Live Quiz UI Fixes feature enhances the existing live multiplayer quiz implementation by addressing critical user experience gaps and implementing a beautiful, polished interface. The design focuses on five key areas: (1) displaying question text prominently, (2) providing immediate visual feedback for answer correctness, (3) supporting all question types with appropriate UI, (4) implementing role-based UI visibility (host vs participant), and (5) creating a consistent, animated, and visually appealing experience throughout.

The architecture builds upon the existing WebSocket-based communication system and Riverpod state management, adding new UI components, animation controllers, and enhanced state properties. The design emphasizes smooth transitions, clear visual hierarchy, and delightful micro-interactions that make the quiz experience engaging and professional.

## Architecture

### High-Level Component Structure

```
┌─────────────────────────────────────────────────────────┐
│                  Existing System                         │
│  ┌──────────────┐    ┌──────────────┐                  │
│  │  WebSocket   │◄──►│    Backend   │                  │
│  │   Service    │    │  (FastAPI)   │                  │
│  └──────────────┘    └──────────────┘                  │
│         ▲                                                │
│         │                                                │
│  ┌──────┴───────────────────────────┐                  │
│  │   State Management (Riverpod)    │                  │
│  │  - GameProvider                   │                  │
│  │  - SessionProvider                │                  │
│  │  - LeaderboardProvider            │                  │
│  └──────────────────────────────────┘                  │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│                  New UI Layer                            │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Question Display Components                      │  │
│  │  - QuestionTextWidget (NEW)                       │  │
│  │  - MultipleChoiceOptions (ENHANCED)               │  │
│  │  - TrueFalseOptions (NEW)                         │  │
│  │  - SingleAnswerInput (NEW)                        │  │
│  │  - DragDropInterface (NEW)                        │  │
│  └──────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Feedback Components                              │  │
│  │  - AnswerFeedbackOverlay (NEW)                    │  │
│  │  - PointsEarnedPopup (NEW)                        │  │
│  │  - CorrectAnswerHighlight (NEW)                   │  │
│  └──────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Role-Based Components                            │  │
│  │  - ParticipantScoreCard (NEW)                     │  │
│  │  - HostLeaderboardPanel (ENHANCED)                │  │
│  └──────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Animation Controllers                            │  │
│  │  - FeedbackAnimationController (NEW)              │  │
│  │  - ScoreCounterAnimation (NEW)                    │  │
│  │  - TransitionAnimationController (NEW)            │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```


### State Management Enhancements

The existing `GameState` will be enhanced with additional properties to support visual feedback and animations:

```dart
class GameState {
  // Existing properties
  final QuizQuestion? currentQuestion;
  final int questionIndex;
  final int totalQuestions;
  final int timeRemaining;
  final bool hasAnswered;
  
  // NEW: Answer feedback properties
  final bool? lastAnswerCorrect;
  final int? pointsEarned;
  final dynamic selectedAnswer;
  final String? correctAnswer;
  final Map<dynamic, int>? answerDistribution;
  
  // NEW: Animation state
  final bool showingFeedback;
  final bool showingCorrectAnswer;
  final int feedbackCountdown; // 2 seconds countdown
  
  // NEW: Role-based visibility
  final bool isHost;
  final int? currentScore;
}
```

### Backend Message Protocol Enhancements

The backend will be modified to send role-specific messages:

**Current (problematic):**
```json
{
  "type": "answer_reveal",
  "payload": {
    "correct_answer": 1,
    "rankings": [...],  // ❌ Sent to ALL
    "is_correct": true
  }
}
```

**New (role-based):**
```json
// To HOST only
{
  "type": "leaderboard_update",
  "payload": {
    "rankings": [...],
    "answer_distribution": {"0": 2, "1": 5, "2": 1, "3": 0}
  }
}

// To PARTICIPANT only
{
  "type": "answer_feedback",
  "payload": {
    "is_correct": true,
    "points_earned": 1350,
    "correct_answer": 1,
    "your_score": 2850,
    "answer_distribution": {"0": 2, "1": 5, "2": 1, "3": 0}
  }
}
```

## Components and Interfaces

### 1. Question Text Display Component

**Purpose**: Display question text prominently above answer options

```dart
class QuestionTextWidget extends StatelessWidget {
  final String questionText;
  final String? imageUrl;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(imageUrl!),
            ),
            SizedBox(height: 16),
          ],
          Text(
            questionText,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
```


### 2. Question Type Handlers

**Purpose**: Render appropriate UI based on question type

```dart
class QuestionTypeHandler {
  static Widget buildQuestionUI({
    required QuizQuestion question,
    required Function(dynamic) onAnswerSelected,
    required bool hasAnswered,
    required dynamic selectedAnswer,
    required bool? isCorrect,
  }) {
    switch (question.type) {
      case QuestionType.multipleChoice:
        return MultipleChoiceOptions(
          options: question.options,
          onSelect: onAnswerSelected,
          selectedAnswer: selectedAnswer,
          correctAnswer: question.correctAnswer,
          hasAnswered: hasAnswered,
          isCorrect: isCorrect,
        );
      
      case QuestionType.trueFalse:
        return TrueFalseOptions(
          onSelect: onAnswerSelected,
          selectedAnswer: selectedAnswer,
          correctAnswer: question.correctAnswer,
          hasAnswered: hasAnswered,
          isCorrect: isCorrect,
        );
      
      case QuestionType.singleAnswer:
        return SingleAnswerInput(
          onSubmit: onAnswerSelected,
          hasAnswered: hasAnswered,
          isCorrect: isCorrect,
        );
      
      case QuestionType.dragAndDrop:
        return DragDropInterface(
          items: question.options,
          onOrderSubmit: onAnswerSelected,
          hasAnswered: hasAnswered,
          isCorrect: isCorrect,
        );
      
      default:
        return MultipleChoiceOptions(/* fallback */);
    }
  }
}
```

**True/False Component:**
```dart
class TrueFalseOptions extends StatelessWidget {
  final Function(bool) onSelect;
  final bool? selectedAnswer;
  final bool correctAnswer;
  final bool hasAnswered;
  final bool? isCorrect;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildOptionButton(
            context: context,
            label: 'True',
            value: true,
            icon: Icons.check_circle_outline,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildOptionButton(
            context: context,
            label: 'False',
            value: false,
            icon: Icons.cancel_outlined,
          ),
        ),
      ],
    );
  }
  
  Widget _buildOptionButton({
    required BuildContext context,
    required String label,
    required bool value,
    required IconData icon,
  }) {
    final isSelected = selectedAnswer == value;
    final isCorrectOption = correctAnswer == value;
    
    Color backgroundColor;
    if (hasAnswered && isSelected) {
      backgroundColor = isCorrect! ? Colors.green : Colors.red;
    } else if (hasAnswered && isCorrectOption) {
      backgroundColor = Colors.green.withOpacity(0.3);
    } else {
      backgroundColor = Theme.of(context).cardColor;
    }
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.white : Colors.grey.shade300,
          width: isSelected ? 3 : 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
```


### 3. Answer Feedback Components

**Purpose**: Provide immediate visual feedback for answer correctness

```dart
class AnswerFeedbackOverlay extends StatefulWidget {
  final bool isCorrect;
  final int pointsEarned;
  final VoidCallback onComplete;
  
  @override
  _AnswerFeedbackOverlayState createState() => _AnswerFeedbackOverlayState();
}

class _AnswerFeedbackOverlayState extends State<AnswerFeedbackOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _controller.forward();
    
    // Auto-dismiss after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: widget.isCorrect ? Colors.green : Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (widget.isCorrect ? Colors.green : Colors.red)
                        .withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isCorrect ? Icons.check : Icons.close,
                    size: 80,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.isCorrect ? 'Correct!' : 'Incorrect',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (widget.isCorrect) ...[
                    SizedBox(height: 8),
                    PointsEarnedPopup(points: widget.pointsEarned),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

**Points Earned Popup:**
```dart
class PointsEarnedPopup extends StatefulWidget {
  final int points;
  
  @override
  _PointsEarnedPopupState createState() => _PointsEarnedPopupState();
}

class _PointsEarnedPopupState extends State<PointsEarnedPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0, -0.5),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );
    
    _controller.forward();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Text(
              '+${widget.points}',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.yellow,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```


### 4. Role-Based UI Components

**Purpose**: Show different UI to host vs participants

```dart
class ParticipantScoreCard extends StatelessWidget {
  final int currentScore;
  final int? pointsEarned;
  final bool? lastAnswerCorrect;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Score',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 4),
              AnimatedScoreCounter(
                score: currentScore,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (lastAnswerCorrect != null) ...[
            Icon(
              lastAnswerCorrect! ? Icons.check_circle : Icons.cancel,
              size: 48,
              color: lastAnswerCorrect! ? Colors.green : Colors.red,
            ),
          ],
        ],
      ),
    );
  }
}
```

**Animated Score Counter:**
```dart
class AnimatedScoreCounter extends StatefulWidget {
  final int score;
  final TextStyle style;
  
  @override
  _AnimatedScoreCounterState createState() => _AnimatedScoreCounterState();
}

class _AnimatedScoreCounterState extends State<AnimatedScoreCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _scoreAnimation;
  int _previousScore = 0;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _updateAnimation();
  }
  
  @override
  void didUpdateWidget(AnimatedScoreCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _previousScore = oldWidget.score;
      _updateAnimation();
      _controller.forward(from: 0);
    }
  }
  
  void _updateAnimation() {
    _scoreAnimation = IntTween(
      begin: _previousScore,
      end: widget.score,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        return Text(
          _scoreAnimation.value.toString(),
          style: widget.style,
        );
      },
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

**Enhanced Host Leaderboard:**
```dart
class HostLeaderboardPanel extends StatelessWidget {
  final List<LeaderboardEntry> rankings;
  final Map<dynamic, int>? answerDistribution;
  final int questionIndex;
  final int totalQuestions;
  final int participantCount;
  final double averageScore;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question $questionIndex/$totalQuestions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Icon(Icons.people, size: 20),
                  SizedBox(width: 8),
                  Text('$participantCount participants'),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // Average score
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Average Score: ${averageScore.toStringAsFixed(0)}',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          
          // Leaderboard list
          Text(
            'Leaderboard',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: rankings.length,
              itemBuilder: (context, index) {
                final entry = rankings[index];
                return AnimatedLeaderboardEntry(
                  entry: entry,
                  index: index,
                );
              },
            ),
          ),
          
          // Answer distribution (if available)
          if (answerDistribution != null) ...[
            SizedBox(height: 24),
            Text(
              'Answer Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            AnswerDistributionChart(distribution: answerDistribution!),
          ],
        ],
      ),
    );
  }
}
```


### 5. Animation Controllers

**Purpose**: Manage smooth transitions and animations

```dart
class TransitionAnimationController {
  static Future<void> transitionToNextQuestion({
    required BuildContext context,
    required VoidCallback onComplete,
  }) async {
    // Fade out current question
    await Future.delayed(Duration(milliseconds: 200));
    
    // Show transition overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuestionTransitionOverlay(),
    );
    
    await Future.delayed(Duration(milliseconds: 400));
    
    // Load next question
    onComplete();
    
    // Fade in new question
    Navigator.of(context).pop();
  }
}

class QuestionTransitionOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Next Question...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Data Models

### Enhanced Game State

```dart
@freezed
class GameState with _$GameState {
  const factory GameState({
    // Existing fields
    QuizQuestion? currentQuestion,
    @Default(0) int questionIndex,
    @Default(0) int totalQuestions,
    @Default(30) int timeRemaining,
    @Default(false) bool hasAnswered,
    
    // NEW: Answer feedback fields
    bool? lastAnswerCorrect,
    int? pointsEarned,
    dynamic selectedAnswer,
    String? correctAnswer,
    Map<dynamic, int>? answerDistribution,
    
    // NEW: Animation state fields
    @Default(false) bool showingFeedback,
    @Default(false) bool showingCorrectAnswer,
    @Default(0) int feedbackCountdown,
    
    // NEW: Role and score fields
    @Default(false) bool isHost,
    @Default(0) int currentScore,
  }) = _GameState;
  
  factory GameState.fromJson(Map<String, dynamic> json) =>
      _$GameStateFromJson(json);
}
```

### Backend Message Types

**Answer Feedback Message (to participant):**
```dart
@freezed
class AnswerFeedbackMessage with _$AnswerFeedbackMessage {
  const factory AnswerFeedbackMessage({
    required bool isCorrect,
    required int pointsEarned,
    required dynamic correctAnswer,
    required int yourScore,
    required Map<dynamic, int> answerDistribution,
  }) = _AnswerFeedbackMessage;
  
  factory AnswerFeedbackMessage.fromJson(Map<String, dynamic> json) =>
      _$AnswerFeedbackMessageFromJson(json);
}
```

**Leaderboard Update Message (to host):**
```dart
@freezed
class LeaderboardUpdateMessage with _$LeaderboardUpdateMessage {
  const factory LeaderboardUpdateMessage({
    required List<LeaderboardEntry> rankings,
    required Map<dynamic, int> answerDistribution,
    required int answeredCount,
    required int totalParticipants,
  }) = _LeaderboardUpdateMessage;
  
  factory LeaderboardUpdateMessage.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardUpdateMessageFromJson(json);
}
```

## Design System

### Color Palette

```dart
class QuizColors {
  // Feedback colors
  static const Color correct = Color(0xFF4CAF50);      // Green
  static const Color incorrect = Color(0xFFE53935);    // Red
  static const Color warning = Color(0xFFFFA726);      // Orange
  static const Color info = Color(0xFF42A5F5);         // Blue
  
  // Accent colors
  static const Color gold = Color(0xFFFFD700);         // 1st place
  static const Color silver = Color(0xFFC0C0C0);       // 2nd place
  static const Color bronze = Color(0xFFCD7F32);       // 3rd place
  
  // Neutral colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFE0E0E0);
}
```

### Typography

```dart
class QuizTextStyles {
  static const TextStyle questionText = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: QuizColors.textPrimary,
  );
  
  static const TextStyle optionText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: QuizColors.textPrimary,
  );
  
  static const TextStyle scoreText = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: QuizColors.textPrimary,
  );
  
  static const TextStyle feedbackText = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static const TextStyle pointsText = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: QuizColors.gold,
  );
}
```

### Spacing

```dart
class QuizSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}
```

### Border Radius

```dart
class QuizBorderRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double circular = 999.0;
}
```

### Animation Durations

```dart
class QuizAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration feedback = Duration(milliseconds: 600);
  static const Duration counter = Duration(milliseconds: 800);
  static const Duration transition = Duration(milliseconds: 1000);
}
```


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Question Display Properties

Property 1: Question text rendering
*For any* question, the rendered widget tree should contain the question text positioned above the answer options
**Validates: Requirements 1.1**

Property 2: Typography consistency
*For any* displayed text, the text style should match the defined typography in the design system (font size, weight, color)
**Validates: Requirements 1.2, 7.2**

Property 3: Visual hierarchy
*For any* question display, the question text styling should be visually distinct from option text styling (different font size or weight)
**Validates: Requirements 1.3**

Property 4: Image and text display
*For any* question with an imageUrl, both the image widget and text widget should be present in the rendered tree
**Validates: Requirements 1.4**

Property 5: Text wrapping
*For any* question text of any length, the text should wrap without overflow errors
**Validates: Requirements 1.5**

### Answer Feedback Properties

Property 6: Correct answer color feedback
*For any* correct answer submission, the selected option's background color should be green
**Validates: Requirements 2.1**

Property 7: Correct answer icon feedback
*For any* correct answer submission, a checkmark icon should be displayed on the selected option
**Validates: Requirements 2.2**

Property 8: Incorrect answer color feedback
*For any* incorrect answer submission, the selected option's background color should be red
**Validates: Requirements 2.3**

Property 9: Incorrect answer icon feedback
*For any* incorrect answer submission, an X icon should be displayed on the selected option
**Validates: Requirements 2.4**

Property 10: Feedback display duration
*For any* answer feedback, the feedback state should persist for at least 2 seconds before advancing
**Validates: Requirements 2.6, 9.1**

Property 11: Points popup display
*For any* correct answer submission, a points earned popup should be displayed with the earned points value
**Validates: Requirements 2.7**

### Question Type Properties

Property 12: Multiple choice rendering
*For any* multiple choice question, the number of rendered option buttons should equal the number of options in the question
**Validates: Requirements 3.1**

Property 13: Question type routing
*For any* question, the rendered UI component type should match the question's questionType field (MCQ → buttons, TrueFalse → 2 buttons, SingleAnswer → TextField, DragDrop → draggable interface)
**Validates: Requirements 3.5**

### Role-Based Visibility Properties

Property 14: Participant leaderboard exclusion
*For any* participant (isHost=false), the full leaderboard component should not be present in the widget tree after answering
**Validates: Requirements 4.1, 4.3, 4.5**

Property 15: Participant feedback visibility
*For any* participant answer submission, correctness feedback (correct/incorrect indicator) should be displayed
**Validates: Requirements 4.2**

Property 16: Participant points display
*For any* participant answer submission, the points earned for that question should be displayed
**Validates: Requirements 4.4**

Property 17: Host leaderboard visibility
*For any* host (isHost=true) after a question is answered, the full leaderboard component should be present in the widget tree
**Validates: Requirements 5.1**

Property 18: Host leaderboard completeness
*For any* host leaderboard display, all participants should be shown with their scores and ranks
**Validates: Requirements 5.2**

Property 19: Top 3 special styling
*For any* leaderboard display, the top 3 ranked participants should have distinct styling (gold, silver, bronze colors)
**Validates: Requirements 5.4**

Property 20: Real-time leaderboard updates
*For any* answer submission, the host's leaderboard should update to reflect the new scores and rankings
**Validates: Requirements 5.5**

### Animation Properties

Property 21: Score counter animation
*For any* score update, the score display should animate from the old value to the new value rather than jumping instantly
**Validates: Requirements 6.2**

Property 22: Leaderboard rank animations
*For any* leaderboard ranking change, participants should animate to their new positions rather than jumping instantly
**Validates: Requirements 6.3, 8.6**

Property 23: Answer feedback animations
*For any* answer feedback display, smooth color transitions and scale effects should be applied using AnimatedContainer and Transform.scale
**Validates: Requirements 6.4**

Property 24: Points popup animations
*For any* points earned display, the popup should use fade-in and float-up animations (SlideTransition and FadeTransition)
**Validates: Requirements 6.5**

Property 25: Rank improvement highlighting
*For any* participant who moves up in rank, a pulse effect animation should be applied to highlight the improvement
**Validates: Requirements 8.7**

### Design Consistency Properties

Property 26: Theme color consistency
*For any* screen in the live quiz flow, all colors used should come from the application's theme or defined color palette
**Validates: Requirements 7.1**

Property 27: Spacing consistency
*For any* UI element with padding or margin, the spacing values should be from the defined set (8, 16, 24, 32 pixels)
**Validates: Requirements 7.3**

Property 28: Button style consistency
*For any* button in the live quiz flow, the button should use consistent styling (border radius, padding, text style)
**Validates: Requirements 7.4**

Property 29: Panel style consistency
*For any* panel or card container, the border radius and shadow values should be consistent across all instances
**Validates: Requirements 7.5**

### Host Dashboard Properties

Property 30: Participant count display
*For any* host dashboard view, the displayed participant count should match the actual number of participants in the session
**Validates: Requirements 8.2**

Property 31: Question progress format
*For any* host dashboard view, the question progress should be displayed in the format "Question X/Y" where X is current and Y is total
**Validates: Requirements 8.3**

Property 32: Average score calculation
*For any* host dashboard view, the displayed average score should equal the sum of all participant scores divided by the participant count
**Validates: Requirements 8.4**

Property 33: Unanswered participant highlighting
*For any* host dashboard view, participants who have not yet answered the current question should have distinct visual styling
**Validates: Requirements 8.5**

### Answer Reveal Properties

Property 34: Correct answer highlighting
*For any* answer reveal phase, the correct answer option should be highlighted with a distinct color for at least 2 seconds
**Validates: Requirements 9.2**

Property 35: Answer distribution display
*For any* answer reveal phase, the number of participants who selected each option should be displayed
**Validates: Requirements 9.3**

Property 36: Countdown indicator display
*For any* waiting period between questions, a countdown indicator showing time remaining should be displayed
**Validates: Requirements 9.5**

### Backend Message Properties

Property 37: Host-only leaderboard broadcast
*For any* answer result broadcast, leaderboard rankings should be sent only to connections where isHost=true
**Validates: Requirements 10.1**

Property 38: Individual score updates
*For any* answer result broadcast, each participant should receive a message containing their personal score update
**Validates: Requirements 10.2**

Property 39: Answer response completeness
*For any* answer submission, the response message should include both is_correct and points_earned fields
**Validates: Requirements 10.3**

Property 40: Host statistics access
*For any* session data request from a host, the response should include detailed statistics (average score, answer distribution) not sent to participants
**Validates: Requirements 10.4**

Property 41: Question text inclusion
*For any* question broadcast message, the payload should include the question text field
**Validates: Requirements 10.5**


## Error Handling

### Missing Question Text

**Scenario**: Question data received without question text field
**Handling**:
1. Frontend validates question object has non-empty question field
2. If missing, display placeholder text: "Question text unavailable"
3. Log error to console for debugging
4. Continue with quiz flow (don't crash)

### Invalid Question Type

**Scenario**: Question has unrecognized questionType value
**Handling**:
1. Frontend checks questionType against known enum values
2. If invalid, default to multiple choice rendering
3. Log warning to console
4. Display all options as buttons (safe fallback)

### Animation Performance Issues

**Scenario**: Animations cause lag on low-end devices
**Handling**:
1. Use `AnimatedBuilder` instead of `setState` for performance
2. Dispose animation controllers properly to prevent memory leaks
3. Limit concurrent animations (max 3 at once)
4. Provide option to disable animations in settings (future enhancement)

### WebSocket Message Delays

**Scenario**: Answer feedback message arrives late or out of order
**Handling**:
1. Frontend maintains local state for immediate UI feedback
2. Use sequence numbers in messages to detect out-of-order delivery
3. If feedback arrives after timeout (5 seconds), ignore it
4. Show loading indicator if feedback is delayed > 1 second

## Testing Strategy

### Unit Testing

**Frontend Unit Tests** (flutter_test):
- Question text widget rendering with various text lengths
- Question type routing logic (switch statement)
- Answer feedback color logic (correct → green, incorrect → red)
- Score counter animation calculations
- Leaderboard sorting and ranking logic
- Role-based visibility logic (isHost checks)
- Typography and spacing consistency checks
- Animation controller initialization and disposal

**Backend Unit Tests** (pytest):
- Message routing logic (host vs participant)
- Answer feedback message construction
- Leaderboard update message construction
- Question payload completeness (includes question text)
- Role-based data filtering

### Property-Based Testing

The system will use **Hypothesis** (Python) for backend property-based testing and **flutter_test** with randomized inputs for frontend property-based testing. Each property-based test will run a minimum of 100 iterations with randomly generated inputs.

**Property Test Configuration**:
- Each property-based test MUST be tagged with a comment explicitly referencing the correctness property
- Tag format: `// Feature: live-quiz-ui-fixes, Property X: [property description]`
- Each correctness property MUST be implemented by a SINGLE property-based test
- Tests MUST run at least 100 iterations

**Frontend Property Test Examples**:

1. **Question Text Rendering** (Property 1):
   - Generate random questions with varying text content
   - Render QuestionTextWidget for each
   - Verify widget tree contains Text widget with question text
   - Verify Text widget appears before option widgets in tree

2. **Typography Consistency** (Property 2):
   - Generate random text elements across different screens
   - Extract TextStyle from each
   - Verify font sizes match design system values
   - Verify font weights match design system values

3. **Answer Feedback Colors** (Properties 6, 8):
   - Generate random answer submissions (correct and incorrect)
   - Render option widgets with feedback state
   - Verify correct answers have green background
   - Verify incorrect answers have red background

4. **Question Type Routing** (Property 13):
   - Generate questions of all types (MCQ, TrueFalse, SingleAnswer, DragDrop)
   - Render each using QuestionTypeHandler
   - Verify MCQ renders MultipleChoiceOptions
   - Verify TrueFalse renders TrueFalseOptions
   - Verify SingleAnswer renders TextField
   - Verify DragDrop renders DragDropInterface

5. **Role-Based Visibility** (Properties 14, 17):
   - Generate game states with isHost=true and isHost=false
   - Render quiz screen for each
   - Verify participants (isHost=false) don't have leaderboard widget
   - Verify hosts (isHost=true) have leaderboard widget

**Backend Property Test Examples**:

1. **Host-Only Leaderboard Broadcast** (Property 37):
   - Generate random session with multiple participants (some hosts, some not)
   - Simulate answer reveal
   - Verify leaderboard messages sent only to host connections
   - Verify participant connections don't receive leaderboard

2. **Individual Score Updates** (Property 38):
   - Generate random participants with different scores
   - Broadcast answer results
   - Verify each participant receives message with their own score
   - Verify scores are not mixed up between participants

3. **Question Text Inclusion** (Property 41):
   - Generate random questions with various text content
   - Create question broadcast message
   - Verify payload contains 'question' field
   - Verify 'question' field is non-empty

### Widget Testing

**Flutter Widget Tests**:
- QuestionTextWidget with and without images
- TrueFalseOptions with different selected states
- AnswerFeedbackOverlay with correct/incorrect states
- PointsEarnedPopup animation sequence
- ParticipantScoreCard with score updates
- HostLeaderboardPanel with various participant counts
- AnimatedScoreCounter incrementing behavior
- Leaderboard entry animations

### Integration Testing

**End-to-End Flow Tests**:
- Complete quiz flow from participant perspective (no leaderboard shown)
- Complete quiz flow from host perspective (leaderboard shown)
- Question type switching (MCQ → TrueFalse → SingleAnswer)
- Answer feedback display and timing (2 second delay)
- Score counter animation on score updates
- Leaderboard rank change animations
- Transition animations between questions

### Visual Regression Testing

**Screenshot Comparison Tests**:
- Question display with long text (wrapping)
- Answer feedback overlay (correct and incorrect)
- Leaderboard with 10+ participants
- Host dashboard with statistics
- True/False question layout
- Points earned popup animation frames
- Color consistency across screens

## Performance Considerations

### Animation Performance

- Use `AnimatedBuilder` for efficient rebuilds (only animating widget rebuilds)
- Dispose all `AnimationController` instances in `dispose()` method
- Limit concurrent animations to prevent frame drops
- Use `RepaintBoundary` for complex animated widgets
- Target 60 FPS for all animations

### Widget Rebuild Optimization

- Use `const` constructors where possible
- Implement `shouldRebuild` in custom widgets
- Use `Consumer` instead of `ConsumerWidget` for partial rebuilds
- Avoid rebuilding entire screen on small state changes
- Use `ListView.builder` for long leaderboards (lazy loading)

### Memory Management

- Dispose animation controllers properly
- Clear image caches for questions with images
- Limit leaderboard display to top 50 participants
- Use weak references for callback handlers
- Profile memory usage during long quiz sessions

## Deployment Considerations

### Backend Changes

**Modified Files**:
- `websocket.py`: Update message routing logic for role-based broadcasts
- `game_controller.py`: Include question text in question payloads
- `session_manager.py`: Track isHost flag for each connection

**New Message Types**:
- `answer_feedback`: Personal feedback to participants
- `leaderboard_update`: Full leaderboard to host only

**Backward Compatibility**:
- Old clients will still receive `answer_reveal` messages
- New clients will handle both old and new message formats
- Gradual rollout: backend supports both formats for 2 weeks

### Frontend Changes

**Modified Files**:
- `live_multiplayer_quiz.dart`: Add question text display, question type handling, answer feedback
- `game_provider.dart`: Add new state properties for feedback and animations
- `live_host_view.dart`: Enhanced dashboard with statistics

**New Files**:
- `question_text_widget.dart`: Question display component
- `true_false_options.dart`: True/False question UI
- `single_answer_input.dart`: Text input for single answer
- `drag_drop_interface.dart`: Drag and drop UI
- `answer_feedback_overlay.dart`: Feedback animation
- `points_earned_popup.dart`: Points animation
- `participant_score_card.dart`: Participant score display
- `animated_score_counter.dart`: Animated score widget
- `quiz_design_system.dart`: Colors, typography, spacing constants

### Migration Strategy

1. **Phase 1**: Backend changes (role-based messaging)
   - Deploy backend with new message types
   - Keep old message types for compatibility
   - Monitor message delivery success rates

2. **Phase 2**: Frontend UI enhancements
   - Deploy question text display
   - Deploy question type handling
   - Deploy answer feedback animations
   - Monitor crash rates and performance

3. **Phase 3**: Role-based UI
   - Deploy participant vs host UI differences
   - Monitor user feedback and engagement
   - A/B test with old vs new experience

4. **Phase 4**: Cleanup
   - Remove old message format support
   - Remove feature flags
   - Optimize based on performance data

## Future Enhancements

1. **Accessibility**: Screen reader support, high contrast mode, larger text options
2. **Customization**: Allow hosts to customize colors and animations
3. **Sound Effects**: Audio feedback for correct/incorrect answers
4. **Haptic Feedback**: Vibration on answer submission (mobile)
5. **Advanced Statistics**: Question difficulty analysis, participant performance trends
6. **Replay Mode**: Review quiz with all answers and timing
7. **Theming**: Dark mode, custom color schemes
8. **Localization**: Multi-language support for UI text

