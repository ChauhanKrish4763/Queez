# Implementation Plan

- [x] 1. Create design system constants and utilities





  - Create `quiz_app/lib/utils/quiz_design_system.dart` file
  - Define QuizColors class with all color constants (correct, incorrect, gold, silver, bronze)
  - Define QuizTextStyles class with typography constants (questionText, optionText, scoreText, feedbackText, pointsText)
  - Define QuizSpacing class with spacing constants (xs, sm, md, lg, xl, xxl)
  - Define QuizBorderRadius class with border radius constants
  - Define QuizAnimations class with duration constants
  - _Requirements: 7.1, 7.2, 7.3, 7.5_

- [x] 2. Enhance GameState model with feedback properties




  - [x] 2.1 Update GameState model in `game_provider.dart`

    - Add `bool? lastAnswerCorrect` field
    - Add `int? pointsEarned` field
    - Add `dynamic selectedAnswer` field
    - Add `String? correctAnswer` field
    - Add `Map<dynamic, int>? answerDistribution` field
    - Add `bool showingFeedback` field (default false)
    - Add `bool showingCorrectAnswer` field (default false)
    - Add `int feedbackCountdown` field (default 0)
    - Add `bool isHost` field (default false)
    - Add `int currentScore` field (default 0)
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.6, 2.7, 4.1, 4.2, 4.4, 5.1_
  
  - [ ]* 2.2 Write property test for GameState feedback properties
    - **Property 6, 8: Answer feedback colors**
    - **Validates: Requirements 2.1, 2.3**

- [x] 3. Create question text display component





  - [x] 3.1 Create `quiz_app/lib/LibrarySection/LiveMode/widgets/question_text_widget.dart`


    - Implement QuestionTextWidget as StatelessWidget
    - Accept questionText and optional imageUrl parameters
    - Use Container with padding (24px) and rounded corners (16px)
    - Display image if imageUrl is provided using ClipRRect
    - Display question text with QuizTextStyles.questionText
    - Ensure text wraps properly with no overflow
    - Add card shadow for depth
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_
  
  - [ ]* 3.2 Write property test for question text rendering
    - **Property 1: Question text rendering**
    - **Validates: Requirements 1.1**
  
  - [ ]* 3.3 Write property test for text wrapping
    - **Property 5: Text wrapping**
    - **Validates: Requirements 1.5**

- [x] 4. Create True/False question component




  - [x] 4.1 Create `quiz_app/lib/LibrarySection/LiveMode/widgets/true_false_options.dart`

    - Implement TrueFalseOptions as StatelessWidget
    - Accept onSelect callback, selectedAnswer, correctAnswer, hasAnswered, isCorrect parameters
    - Render exactly two buttons: "True" and "False"
    - Use Row with Expanded for equal width buttons
    - Implement _buildOptionButton helper method
    - Apply green background if correct and selected
    - Apply red background if incorrect and selected
    - Apply green tint if correct answer (not selected)
    - Use AnimatedContainer for smooth color transitions (300ms)
    - Add checkmark icon for correct, X icon for incorrect
    - Disable buttons after answer is submitted
    - _Requirements: 3.2, 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [ ]* 4.2 Write unit test for True/False rendering
    - Verify exactly 2 buttons are rendered
    - Verify buttons are labeled "True" and "False"
    - _Requirements: 3.2_

- [x] 5. Create Single Answer input component




  - [x] 5.1 Create `quiz_app/lib/LibrarySection/LiveMode/widgets/single_answer_input.dart`


    - Implement SingleAnswerInput as StatefulWidget
    - Accept onSubmit callback, hasAnswered, isCorrect parameters
    - Render TextField with custom decoration
    - Add submit button below text field
    - Disable input after submission
    - Show feedback icon (checkmark or X) after submission
    - Apply border color based on correctness (green/red)
    - Use QuizTextStyles for text styling
    - _Requirements: 3.3, 2.1, 2.2, 2.3, 2.4_

- [x] 6. Create Drag and Drop question component





  - [x] 6.1 Create `quiz_app/lib/LibrarySection/LiveMode/widgets/drag_drop_interface.dart`


    - Implement DragDropInterface as StatefulWidget
    - Accept items list, onOrderSubmit callback, hasAnswered, isCorrect parameters
    - Render draggable items using Draggable widget
    - Render drop zones using DragTarget widget
    - Track item order in local state
    - Show submit button when all items are placed
    - Disable dragging after submission
    - Show feedback (green/red borders) after submission
    - _Requirements: 3.4, 2.1, 2.3_

- [x] 7. Create question type handler utility




  - [x] 7.1 Create `quiz_app/lib/LibrarySection/LiveMode/utils/question_type_handler.dart`


    - Implement QuestionTypeHandler class with static buildQuestionUI method
    - Accept question, onAnswerSelected, hasAnswered, selectedAnswer, isCorrect parameters
    - Use switch statement on question.type
    - Return MultipleChoiceOptions for QuestionType.multipleChoice
    - Return TrueFalseOptions for QuestionType.trueFalse
    - Return SingleAnswerInput for QuestionType.singleAnswer
    - Return DragDropInterface for QuestionType.dragAndDrop
    - Default to MultipleChoiceOptions as fallback
    - _Requirements: 3.5_
  
  - [ ]* 7.2 Write property test for question type routing
    - **Property 13: Question type routing**
    - **Validates: Requirements 3.5**

- [x] 8. Create answer feedback overlay component




  - [x] 8.1 Create `quiz_app/lib/LibrarySection/LiveMode/widgets/answer_feedback_overlay.dart`


    - Implement AnswerFeedbackOverlay as StatefulWidget with SingleTickerProviderStateMixin
    - Accept isCorrect, pointsEarned, onComplete parameters
    - Create AnimationController with 600ms duration
    - Create scale animation (0.0 to 1.0) with elasticOut curve
    - Create fade animation (0.0 to 1.0) with easeIn curve
    - Display circular container with green (correct) or red (incorrect) background
    - Show checkmark icon for correct, X icon for incorrect (size 80)
    - Display "Correct!" or "Incorrect" text
    - Include PointsEarnedPopup for correct answers
    - Auto-dismiss after 2 seconds by calling onComplete
    - Add glow shadow effect matching background color
    - Dispose controller in dispose method
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 6.4_
  
  - [ ]* 8.2 Write property test for feedback display duration
    - **Property 10: Feedback display duration**
    - **Validates: Requirements 2.6**

- [x] 9. Create points earned popup component




  - [x] 9.1 Create `quiz_app/lib/LibrarySection/LiveMode/widgets/points_earned_popup.dart`


    - Implement PointsEarnedPopup as StatefulWidget with SingleTickerProviderStateMixin
    - Accept points parameter
    - Create AnimationController with 1000ms duration
    - Create slide animation (Offset(0,0) to Offset(0,-0.5)) with easeOut curve
    - Create fade animation (1.0 to 0.0) starting at 50% progress
    - Display "+{points}" text in yellow with large font (36px)
    - Add text shadow for visibility
    - Use SlideTransition and Opacity for animations
    - Auto-start animation in initState
    - Dispose controller in dispose method
    - _Requirements: 2.7, 6.5_
  
  - [ ]* 9.2 Write property test for points popup animations
    - **Property 24: Points popup animations**
    - **Validates: Requirements 6.5**

- [x] 10. Create animated score counter component




  - [x] 10.1 Create `quiz_app/lib/LibrarySection/LiveMode/widgets/animated_score_counter.dart`


    - Implement AnimatedScoreCounter as StatefulWidget with SingleTickerProviderStateMixin
    - Accept score and style parameters
    - Create AnimationController with 800ms duration
    - Create IntTween animation from previous score to new score
    - Use easeOut curve for smooth counting
    - Track previous score in state
    - Update animation when score prop changes
    - Display animated score value using AnimatedBuilder
    - Dispose controller in dispose method
    - _Requirements: 6.2_
  
  - [ ]* 10.2 Write property test for score counter animation
    - **Property 21: Score counter animation**
    - **Validates: Requirements 6.2**

- [x] 11. Create participant score card component




  - [x] 11.1 Create `quiz_app/lib/LibrarySection/LiveMode/widgets/participant_score_card.dart`

    - Implement ParticipantScoreCard as StatelessWidget
    - Accept currentScore, pointsEarned, lastAnswerCorrect parameters
    - Use Container with card styling (padding, border radius, shadow)
    - Display "Your Score" label in secondary text color
    - Use AnimatedScoreCounter for score display
    - Show correctness icon (checkmark or X) if lastAnswerCorrect is not null
    - Use Row for horizontal layout
    - Apply QuizColors and QuizSpacing from design system
    - _Requirements: 4.1, 4.2, 4.4_
  
  - [ ]* 11.2 Write property test for participant score display
    - **Property 16: Participant points display**
    - **Validates: Requirements 4.4**

- [ ] 12. Create answer distribution chart component


  - [x] 12.1 Create `quiz_app/lib/LibrarySection/LiveMode/widgets/answer_distribution_chart.dart`



    - Implement AnswerDistributionChart as StatelessWidget
    - Accept distribution Map<dynamic, int> parameter
    - Calculate total responses
    - For each option, display horizontal bar showing percentage
    - Use Container with AnimatedContainer for bar width
    - Show option label and count
    - Use different colors for each bar
    - Apply rounded corners to bars
    - _Requirements: 9.3_

- [x] 13. Create animated leaderboard entry component




  - [x] 13.1 Create `quiz_app/lib/LibrarySection/LiveMode/widgets/animated_leaderboard_entry.dart`


    - Implement AnimatedLeaderboardEntry as StatefulWidget
    - Accept entry (LeaderboardEntry) and index parameters
    - Track previous rank in state
    - Detect rank changes (moved up, moved down, stayed same)
    - Apply pulse animation when rank improves
    - Use AnimatedContainer for smooth position transitions
    - Display rank badge with special styling for top 3 (gold, silver, bronze)
    - Show username and score
    - Highlight rank changes with color indicators
    - _Requirements: 5.3, 5.4, 6.3, 8.6, 8.7_
  
  - [ ]* 13.2 Write property test for rank change animations
    - **Property 22: Leaderboard rank animations**
    - **Validates: Requirements 6.3**

- [x] 14. Create enhanced host leaderboard panel




  - [x] 14.1 Create `quiz_app/lib/LibrarySection/LiveMode/widgets/host_leaderboard_panel.dart`


    - Implement HostLeaderboardPanel as StatelessWidget
    - Accept rankings, answerDistribution, questionIndex, totalQuestions, participantCount, averageScore parameters
    - Display header with question progress ("Question X/Y")
    - Show participant count with icon
    - Display average score in highlighted container
    - Render leaderboard title
    - Use ListView.builder for rankings list with AnimatedLeaderboardEntry
    - Include AnswerDistributionChart if answerDistribution is provided
    - Apply card styling with padding and border radius
    - Use QuizColors and QuizSpacing from design system
    - _Requirements: 5.1, 5.2, 5.4, 5.5, 8.1, 8.2, 8.3, 8.4, 8.5, 9.3_
  
  - [ ]* 14.2 Write property test for average score calculation
    - **Property 32: Average score calculation**
    - **Validates: Requirements 8.4**

- [x] 15. Update live_multiplayer_quiz.dart to display question text



  - [x] 15.1 Modify `quiz_app/lib/LibrarySection/LiveMode/screens/live_multiplayer_quiz.dart`


    - Import QuestionTextWidget
    - Add QuestionTextWidget above answer options in build method
    - Pass currentQuestion['question'] as questionText parameter
    - Pass currentQuestion['imageUrl'] if available
    - Ensure proper spacing between question and options (24px)
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_
  
  - [ ]* 15.2 Write property test for question text inclusion
    - **Property 1: Question text rendering**
    - **Validates: Requirements 1.1**

- [x] 16. Update live_multiplayer_quiz.dart to handle question types




  - [x] 16.1 Modify `quiz_app/lib/LibrarySection/LiveMode/screens/live_multiplayer_quiz.dart`


    - Import QuestionTypeHandler
    - Replace hardcoded MultipleChoiceOptions with QuestionTypeHandler.buildQuestionUI
    - Pass currentQuestion, onAnswerSelected callback, hasAnswered, selectedAnswer, isCorrect
    - Remove assumption that all questions are multiple choice
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_
  
  - [ ]* 16.2 Write property test for question type routing
    - **Property 13: Question type routing**
    - **Validates: Requirements 3.5**

- [x] 17. Update live_multiplayer_quiz.dart to show answer feedback





  - [x] 17.1 Modify `quiz_app/lib/LibrarySection/LiveMode/screens/live_multiplayer_quiz.dart`


    - Import AnswerFeedbackOverlay
    - Add conditional rendering of AnswerFeedbackOverlay when showingFeedback is true
    - Pass isCorrect, pointsEarned from gameState
    - Implement onComplete callback to hide feedback and advance
    - Use Stack to overlay feedback on top of quiz content
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7_
  
  - [ ]* 17.2 Write property test for feedback visibility
    - **Property 15: Participant feedback visibility**
    - **Validates: Requirements 4.2**
- [x] 18. Update live_multiplayer_quiz.dart to remove leaderboard for participants



- [ ] 18. Update live_multiplayer_quiz.dart to remove leaderboard for participants

  - [x] 18.1 Modify `quiz_app/lib/LibrarySection/LiveMode/screens/live_multiplayer_quiz.dart`


    - Remove LeaderboardWidget from participant view
    - Add conditional check: only show leaderboard if isHost is true
    - Replace leaderboard with ParticipantScoreCard for participants
    - Pass currentScore, pointsEarned, lastAnswerCorrect to ParticipantScoreCard
    - _Requirements: 4.1, 4.3, 4.5_
  
  - [ ]* 18.2 Write property test for participant leaderboard exclusion
    - **Property 14: Participant leaderboard exclusion**
    - **Validates: Requirements 4.1, 4.3**

- [x] 19. Update live_host_view.dart with enhanced dashboard




  - [x] 19.1 Modify `quiz_app/lib/LibrarySection/LiveMode/screens/live_host_view.dart`


    - Import HostLeaderboardPanel
    - Replace basic leaderboard with HostLeaderboardPanel
    - Calculate and pass averageScore (sum of scores / participant count)
    - Pass questionIndex, totalQuestions, participantCount
    - Pass answerDistribution if available
    - Add session code display with copy button at top
    - Highlight participants who haven't answered yet
    - Use QuizColors and QuizSpacing for consistent styling
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 8.1, 8.2, 8.3, 8.4, 8.5_
  
  - [ ]* 19.2 Write property test for host leaderboard visibility
    - **Property 17: Host leaderboard visibility**
    - **Validates: Requirements 5.1**


- [x] 20. Update game_provider.dart to handle answer feedback messages



  - [x] 20.1 Modify `quiz_app/lib/providers/game_provider.dart`

    - Add handler for "answer_feedback" message type
    - Extract isCorrect, pointsEarned, correctAnswer, yourScore, answerDistribution from payload
    - Update state with lastAnswerCorrect, pointsEarned, correctAnswer, answerDistribution, currentScore
    - Set showingFeedback to true
    - Start 2-second timer to set showingFeedback to false
    - _Requirements: 2.6, 4.2, 4.4, 10.2, 10.3_
  
  - [ ]* 20.2 Write property test for answer feedback state updates
    - **Property 39: Answer response completeness**
    - **Validates: Requirements 10.3**

- [x] 21. Update game_provider.dart to handle leaderboard update messages



- [ ] 21. Update game_provider.dart to handle leaderboard update messages
  - [x] 21.1 Modify `quiz_app/lib/providers/game_provider.dart`


    - Add handler for "leaderboard_update" message type (host only)
    - Extract rankings and answerDistribution from payload
    - Update leaderboard state with new rankings
    - Store answerDistribution in game state
    - Only process if isHost is true
    - _Requirements: 5.5, 10.1_
  
  - [ ]* 21.2 Write property test for host-only leaderboard updates
    - **Property 20: Real-time leaderboard updates**
    - **Validates: Requirements 5.5**
-

- [x] 22. Update backend websocket.py for role-based messaging



  - [x] 22.1 Modify `backend/app/services/websocket_manager.py`


    - Add broadcast_to_host method to send messages only to host connection
    - Track isHost flag for each connection in session
    - Modify reveal_answer to send different messages to host vs participants
    - Send "leaderboard_update" with rankings to host only
    - Send "answer_feedback" with personal data to each participant individually
    - Include answerDistribution in both message types
    - _Requirements: 10.1, 10.2_
  
  - [ ]* 22.2 Write property test for host-only broadcast
    - **Property 37: Host-only leaderboard broadcast**
    - **Validates: Requirements 10.1**

- [x] 23. Update backend game_controller.py to include question text





  - [x] 23.1 Modify `backend/app/services/game_controller.py`


    - Ensure get_current_question includes 'question' field in returned dict
    - Verify question text is not empty before sending
    - Include questionType field in question payload
    - _Requirements: 10.5_
  
  - [ ]* 23.2 Write property test for question text inclusion
    - **Property 41: Question text inclusion**
    - **Validates: Requirements 10.5**

- [x] 24. Add correct answer highlighting and countdown





  - [x] 24.1 Create `quiz_app/lib/LibrarySection/LiveMode/widgets/correct_answer_highlight.dart`


    - Implement CorrectAnswerHighlight as StatefulWidget
    - Accept correctAnswer and countdown parameters
    - Display correct answer with distinct green highlight
    - Show countdown timer (2 seconds)
    - Use AnimatedContainer for smooth color transition
    - Auto-advance when countdown reaches 0
    - _Requirements: 9.1, 9.2, 9.5_
  
  - [x] 24.2 Integrate CorrectAnswerHighlight into live_multiplayer_quiz.dart


    - Show after answer feedback is dismissed
    - Pass correctAnswer from game state
    - Start 2-second countdown
    - Transition to next question when countdown completes
    - _Requirements: 9.1, 9.2, 9.4, 9.5_
- [x] 25. Add question transition animations



- [ ] 25. Add question transition animations

  - [x] 25.1 Create `quiz_app/lib/LibrarySection/LiveMode/utils/transition_animation_controller.dart`


    - Implement TransitionAnimationController class
    - Add static transitionToNextQuestion method
    - Implement fade-out of current question (200ms)
    - Show QuestionTransitionOverlay with loading indicator
    - Wait 400ms for transition
    - Call onComplete callback to load next question
    - Fade-in new question
    - _Requirements: 6.1, 9.4_
  
  - [x] 25.2 Integrate transition animations into live_multiplayer_quiz.dart







    - Use TransitionAnimationController when advancing to next question
    - Apply fade transition effect
    - Show "Next Question..." message during transition
    - _Requirements: 6.1, 9.4_


- [x] 26. Apply consistent styling across all components



  - [x] 26.1 Audit all live quiz components for style consistency


    - Replace hardcoded colors with QuizColors constants
    - Replace hardcoded spacing with QuizSpacing constants
    - Replace hardcoded text styles with QuizTextStyles constants
    - Replace hardcoded border radius with QuizBorderRadius constants
    - Replace hardcoded durations with QuizAnimations constants
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_
  
  - [ ]* 26.2 Write property tests for design consistency
    - **Property 26: Theme color consistency**
    - **Property 27: Spacing consistency**
    - **Property 28: Button style consistency**
    - **Property 29: Panel style consistency**
    - **Validates: Requirements 7.1, 7.3, 7.4, 7.5**
-

- [x] 27. Checkpoint - Ensure all tests pass




  - Ensure all tests pass, ask the user if questions arise.

