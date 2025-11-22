# Implementation Plan


- [x] 1. Set up backend infrastructure and dependencies
  - Install and configure Redis for session state management
  - Install FastAPI WebSocket dependencies (websockets, python-socketio)
  - Configure environment variables for Redis and WebSocket settings
  - Set up connection pooling for Redis
  - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [x] 2. Implement backend WebSocket connection manager
  - Create ConnectionManager class to handle WebSocket connections
  - Implement connect() method to register new WebSocket connections
  - Implement disconnect() method to clean up closed connections
  - Implement send_personal_message() for one-to-one messaging
  - Implement broadcast_to_session() for broadcasting to all participants in a session
  - Implement broadcast_except() for broadcasting to all except one participant
  - _Requirements: 2.1, 2.3, 3.1_

- [x] 3. Implement backend session manager
  - Create SessionManager class with Redis and MongoDB clients
  - Implement create_session() to generate unique 6-character session codes
  - Implement session code uniqueness validation using Redis
  - Implement get_session() to retrieve session state from Redis
  - Implement add_participant() to add users to session participant list
  - Implement remove_participant() to handle participant leaving
  - Implement start_session() to transition session from waiting to active
  - Implement end_session() to mark session as completed
  - Implement is_host() to validate host permissions
  - _Requirements: 1.1, 1.3, 1.4, 2.2, 4.2, 11.1_

- [x] 4. Implement backend game controller
  - Create GameController class for quiz gameplay logic
  - Implement get_current_question() to fetch question from quiz data
  - Implement submit_answer() to validate and record participant answers
  - Implement calculate_score() with base points (1000) and time bonus (0-500)
  - Implement check_all_answered() to determine if all participants have responded
  - Implement advance_question() to move to next question
  - Implement reveal_answer() to broadcast correct answer and statistics
  - Add timer tracking for question start time
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 6.1, 6.2, 6.3, 8.1, 8.2, 8.3_

- [x] 5. Implement backend leaderboard manager
  - Create LeaderboardManager class using Redis Sorted Sets
  - Implement update_score() to increment participant scores in Redis ZSET
  - Implement get_rankings() to retrieve top N participants
  - Implement get_user_rank() to get specific participant's rank
  - Implement clear_leaderboard() for session cleanup
  - _Requirements: 6.4, 6.5, 7.1, 7.2, 7.3_

- [x] 6. Implement WebSocket endpoint and message routing
  - Create FastAPI WebSocket endpoint at /ws/{session_code}
  - Implement WebSocket connection acceptance with authentication
  - Implement message type routing (join, submit_answer, start_quiz, end_quiz, ping)
  - Implement heartbeat/ping-pong mechanism (30-second interval)
  - Handle WebSocket disconnections and cleanup
  - _Requirements: 1.2, 2.1, 3.4, 10.1_

- [x] 7. Implement session join flow
  - Handle "join" message type in WebSocket endpoint
  - Validate session exists and is not expired
  - Validate session status is "waiting" (reject if active/completed)
  - Add participant to session using SessionManager
  - Broadcast participant list update to all connected clients
  - Send current session state to newly joined participant
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 3.1, 3.2_


- [x] 8. Implement quiz start flow
  - Handle "start_quiz" message type in WebSocket endpoint
  - Validate requesting user is the session host
  - Validate at least 2 participants are connected
  - Transition session status from "waiting" to "active"
  - Load first question from quiz data
  - Broadcast first question to all participants with 30-second timer
  - Initialize question start timestamp
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 5.1_

- [x] 9. Implement answer submission flow
  - Handle "submit_answer" message type in WebSocket endpoint
  - Validate submission timestamp is within question timer window
  - Validate participant hasn't already answered current question
  - Record answer with timestamp in session state
  - Validate answer correctness against quiz data
  - Calculate score (base + time bonus)
  - Update participant score in leaderboard
  - Send personal answer result to participant
  - Check if all participants have answered
  - If all answered or timer expired, trigger answer reveal
  - _Requirements: 5.2, 5.3, 5.4, 5.6, 6.1, 6.2, 6.3, 6.4, 12.1, 12.2_

- [x] 10. Implement answer reveal and progression flow
  - Implement answer reveal logic when all answered or timer expires
  - Calculate answer distribution statistics (count per option)
  - Broadcast answer reveal message with correct answer and statistics
  - Include personal correctness feedback for each participant
  - Wait 5 seconds before advancing
  - Update and broadcast leaderboard rankings
  - Advance to next question or complete quiz if last question
  - _Requirements: 5.5, 7.3, 7.4, 8.1, 8.2, 8.3, 8.4, 8.5_


- [x] 11. Implement quiz completion flow
  - Detect when last question is answered
  - Transition session status to "completed"
  - Calculate final rankings for all participants
  - Calculate accuracy percentage for each participant
  - Broadcast final results with top 10 participants
  - Persist session results to MongoDB
  - Schedule session cleanup after results display
  - _Requirements: 9.1, 9.2, 9.3, 9.5, 9.6_


- [x] 12. Implement early termination flow
  - Handle "end_quiz" message type in WebSocket endpoint
  - Validate requesting user is the session host
  - Transition session status to "completed"
  - Calculate partial scores based on answered questions only
  - Broadcast final results to all participants
  - Close all WebSocket connections after results display
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_


- [x] 13. Implement reconnection handling
  - Handle participant disconnection events
  - Mark participant as disconnected in session state
  - Keep participant data for 60-second reconnection window
  - Handle reconnection attempts with session validation
  - Restore participant state on successful reconnection
  - Send current question and game state to reconnected participant
  - Mark remaining answers as incorrect if disconnected > 60 seconds
  - _Requirements: 3.4, 3.5, 10.1, 10.2, 10.3, 10.4_


- [x] 14. Checkpoint - Ensure all backend tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 15. Download and integrate Kenney UI Pack Sci-Fi assets
  - Download UI Pack Sci-Fi from https://kenney.nl/assets/ui-pack-sci-fi (CC0 License)
  - Create assets/ui/sci-fi/ directory in Flutter project
  - Extract and organize 130+ UI assets (buttons, panels, sliders, backgrounds)
  - Update pubspec.yaml to include sci-fi UI assets
  - Create UI asset constants file for easy reference
  - Document asset naming conventions and usage guidelines
  - _Requirements: UI/UX Enhancement_

- [x] 16. Create sci-fi themed UI component library
  - Create SciFiButton widget using Kenney button assets
  - Create SciFiPanel widget using Kenney panel assets
  - Create SciFiSlider widget for timer visualization
  - Create SciFiCard widget for participant and leaderboard entries
  - Create SciFiDialog widget for modals and confirmations
  - Create SciFiBackground widget for screen backgrounds
  - Create SciFiTheme class with color palette (neon blues, cyans, purples, greens)
  - Define typography with futuristic fonts
  - Implement consistent spacing, colors, and animations
  - Add glow effects and sci-fi transitions
  - Create reusable animation presets (pulse, glow, scan, warp)
  - _Requirements: UI/UX Enhancement_

- [x] 17. Set up Flutter frontend dependencies
  - Add web_socket_channel package for WebSocket connections
  - Add flutter_riverpod package for state management
  - Add freezed and json_serializable for data models
  - Configure code generation for freezed models
  - _Requirements: 1.2, 2.1_

- [x] 18. Implement Flutter WebSocket service
  - Create WebSocketService class with IOWebSocketChannel
  - Implement connect() method with session code and user ID
  - Implement disconnect() method with cleanup
  - Implement sendMessage() for sending JSON messages
  - Create messageStream for receiving messages
  - Implement reconnect() with exponential backoff (0s, 1s, 2s, 4s, 8s, 16s, 30s)
  - Add connection state tracking (connected, disconnected, reconnecting)
  - _Requirements: 1.2, 2.1, 10.1_

- [x] 19. Create Flutter data models
  - Create Participant model with freezed
  - Create QuizQuestion model with freezed
  - Create SessionState model with freezed
  - Create GameState model with freezed
  - Create LeaderboardState model with freezed
  - Create LeaderboardEntry model with freezed
  - Add JSON serialization for all models
  - _Requirements: 3.2, 7.2_

- [x] 20. Implement session state management with Riverpod
  - Create SessionNotifier extending StateNotifier<SessionState>
  - Implement joinSession() method
  - Implement startSession() method for host
  - Implement handleMessage() for WebSocket message routing
  - Implement handleDisconnection() for connection loss
  - Create sessionProvider StateNotifierProvider
  - Handle session status transitions (initial, waiting, active, completed)
  - _Requirements: 1.4, 2.1, 2.6, 4.2_

- [x] 21. Implement game state management with Riverpod
  - Create GameNotifier extending StateNotifier<GameState>
  - Implement handleQuestionReceived() to update current question
  - Implement submitAnswer() to send answer via WebSocket
  - Implement startTimer() with 30-second countdown
  - Implement stopTimer() for cleanup
  - Implement handleAnswerRevealed() to show correct answer
  - Create gameProvider StateNotifierProvider
  - Track hasAnswered flag to prevent duplicate submissions
  - _Requirements: 4.5, 5.1, 5.2, 5.6, 8.1, 8.4_

- [x] 22. Implement leaderboard state management with Riverpod
  - Create LeaderboardNotifier extending StateNotifier<LeaderboardState>
  - Implement updateLeaderboard() to update rankings
  - Implement updateScore() to update participant's score
  - Create leaderboardProvider StateNotifierProvider
  - Sort rankings by score descending
  - _Requirements: 6.4, 6.5, 7.1, 7.2, 7.3_

- [x] 23. Create waiting lobby screen with sci-fi UI
  - Create LiveMultiplayerLobby widget as ConsumerWidget
  - Use SciFiPanel for main lobby container with space-themed background
  - Display session code prominently using SciFiPanel with glow effect
  - Show list of joined participants using SciFiCard widgets
  - Show total participant count with animated sci-fi counter
  - Display "Start Quiz" SciFiButton for host only with pulse animation
  - Display "Waiting for host..." message with sci-fi typography
  - Show loading indicator using sci-fi themed spinner
  - Handle session join errors with SciFiDialog
  - Add particle effects and ambient animations
  - _Requirements: 1.5, 2.1, 2.2, 2.3, 3.1, 3.2, 3.3_

- [x] 24. Create quiz gameplay screen with sci-fi UI
  - Create LiveMultiplayerQuiz widget as ConsumerWidget
  - Use SciFiBackground with animated starfield or space theme
  - Display current question in SciFiPanel with holographic effect
  - Show question number using sci-fi styled progress indicator
  - Display countdown timer using SciFiSlider with color transitions (green→yellow→red)
  - Implement answer selection using SciFiButton with hover effects
  - Disable answer selection after submission with visual feedback
  - Show "Waiting for other players..." with animated sci-fi loading
  - Display answer result with particle burst effects (correct=green, incorrect=red)
  - Show answer reveal with correct answer highlighted using glow effect
  - Display answer distribution statistics using sci-fi styled bar charts
  - Add sound effects for interactions (optional)
  - _Requirements: 4.3, 5.1, 5.2, 5.3, 5.6, 6.1, 8.2, 8.3, 8.4, 8.5_

- [x] 25. Create leaderboard display component with sci-fi UI
  - Create LeaderboardWidget as ConsumerWidget
  - Use SciFiPanel with semi-transparent background for leaderboard container
  - Display top 10 participants using SciFiCard with rank badges
  - Show rank numbers with metallic sci-fi styling
  - Highlight current participant's position with glowing border
  - Show participant's current rank and score with animated counters
  - Animate rank changes with smooth transitions and particle effects
  - Add podium-style highlighting for top 3 positions (gold, silver, bronze glow)
  - Display between questions and at quiz completion with slide-in animation
  - Add holographic scan line effects
  - _Requirements: 7.2, 7.3, 7.4, 7.5, 9.3_

- [x] 26. Create final results screen with sci-fi UI
  - Create LiveMultiplayerResults widget as ConsumerWidget
  - Use SciFiBackground with victory/completion theme
  - Display final rankings using SciFiCard with metallic finish
  - Highlight the winner with special crown icon and golden glow effect
  - Show current participant's final rank and score in prominent SciFiPanel
  - Display accuracy percentage using sci-fi styled circular progress indicators
  - Show "Return to Library" SciFiButton with exit animation
  - Add confetti/particle burst animation for winner
  - Display achievement badges for milestones (perfect score, fastest answer, etc.)
  - Add victory fanfare animation with holographic effects
  - Include share results button with sci-fi styling
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

- [x] 27. Implement reconnection UI handling with sci-fi UI
  - Display "Reconnecting..." overlay using semi-transparent SciFiPanel
  - Show reconnection attempt count with animated sci-fi counter
  - Display "Connection lost" error using SciFiDialog with warning styling
  - Show "Reconnected" success message briefly with green glow effect
  - Add scanning/loading animation during reconnection
  - Automatically sync state after reconnection with transition effect
  - Handle reconnection during different game phases with appropriate visuals
  - Add pulsing connection status indicator
  - _Requirements: 10.1, 10.2, 10.3, 10.5_

- [x] 28. Implement error handling and user feedback with sci-fi UI
  - Display error messages using SciFiDialog with red warning theme
  - Show "Session not found" error with search/scan animation
  - Show "Session expired" error with time-out visual effect
  - Show "Already started" error with locked icon animation
  - Show "Late submission" error with timer expired visual
  - Show "Unauthorized" error with access denied animation
  - Use sci-fi styled toast notifications for non-critical errors
  - Use SciFiDialog for critical errors requiring user action
  - Add appropriate icons and color coding (red=error, yellow=warning, blue=info)
  - _Requirements: 2.4, 2.5, 5.4, 11.1, 12.4_
x
- [x] 29. Implement host controls with sci-fi UI
  - Add "Start Quiz" SciFiButton in lobby with special host styling (host only)
  - Add "End Quiz" SciFiButton during gameplay with warning color (host only)
  - Show confirmation SciFiDialog before ending quiz early with countdown
  - Disable host controls for non-host participants with locked visual state
  - Add host badge/crown icon next to host's name
  - Use distinct button styling for host actions (larger, glowing)
  - _Requirements: 4.1, 4.2, 11.1, 11.2_

- [x] 30. Add navigation and routing with sci-fi transitions
  - Update existing LiveMultiplayerDashboard to navigate to lobby with slide transition
  - Add route from lobby to quiz gameplay screen with fade/warp effect
  - Add route from quiz to results screen with victory transition
  - Handle back button to prevent accidental exits during quiz (show SciFiDialog confirmation)
  - Return to library after quiz completion with smooth exit animation
  - Use sci-fi themed page transitions (warp, slide, fade with particles)
  - _Requirements: 1.5, 2.1, 9.1_