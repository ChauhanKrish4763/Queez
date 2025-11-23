# Requirements Document

## Introduction

This document specifies requirements for fixing 5 critical UI/UX bugs in the live multiplayer quiz feature. These bugs affect the host dashboard leaderboard display, answer feedback visualization, and drag-and-drop question interface usability and aesthetics.

## Glossary

- **Host Dashboard**: The screen displayed to the quiz host showing the session code, participant list, and real-time leaderboard
- **Podium Widget**: An animated visual component displaying the top 3 participants with trophy icons and gold/silver/bronze styling
- **Participant**: A user who joins a quiz session to answer questions
- **MCQ**: Multiple Choice Question where participants select one correct answer from multiple options
- **Answer Feedback**: Visual indication showing whether a submitted answer is correct (green with checkmark) or incorrect (red with X)
- **Drag-and-Drop Question**: A question type where participants must match items by dragging them to corresponding drop zones
- **Drop Zone**: A target area where draggable items can be placed
- **Matched Pair**: A combination of a target label and the item placed in its drop zone
- **System**: The Queez live multiplayer quiz application
- **AppColors**: The application's color design system defined in utils/color.dart

## Requirements

### Requirement 1

**User Story:** As a host, I want to see the animated podium widget on my dashboard during the quiz, so that I can view the top 3 participants in an engaging visual format in real-time.

#### Acceptance Criteria

1. WHEN the host views the dashboard during an active quiz THEN the System SHALL display the PodiumWidget component showing the top 3 participants
2. WHEN participant scores update during the quiz THEN the System SHALL update the podium display in real-time to reflect current rankings
3. WHEN the podium is displayed THEN the System SHALL show trophy icons with gold color for 1st place, silver color for 2nd place, and bronze color for 3rd place
4. WHEN the podium is rendered THEN the System SHALL position it above the participant list in the host dashboard
5. WHEN there are fewer than 3 participants THEN the System SHALL display only the available participants on the podium

### Requirement 2

**User Story:** As a participant, I want to see my selected wrong answer highlighted in red with an X icon, so that I can clearly understand which answer I chose incorrectly.

#### Acceptance Criteria

1. WHEN a participant selects an incorrect answer in an MCQ THEN the System SHALL highlight the selected option with red background color
2. WHEN a participant selects an incorrect answer THEN the System SHALL display an X icon on the selected option
3. WHEN a participant selects an incorrect answer THEN the System SHALL simultaneously highlight the correct answer with green background color and checkmark icon
4. WHEN displaying answer feedback THEN the System SHALL maintain both red (incorrect) and green (correct) highlights until the next question loads
5. WHEN a participant selects the correct answer THEN the System SHALL highlight only that answer with green background color and checkmark icon

### Requirement 3

**User Story:** As a participant, I want the drag-and-drop interface to use consistent green-themed colors, so that the UI matches the application's design system and appears visually cohesive.

#### Acceptance Criteria

1. WHEN the drag-and-drop interface renders THEN the System SHALL use colors exclusively from the AppColors palette
2. WHEN displaying draggable items THEN the System SHALL use AppColors primary or secondary green shades for backgrounds
3. WHEN displaying drop zones THEN the System SHALL use AppColors green shades for borders and backgrounds
4. WHEN an item is being dragged THEN the System SHALL use AppColors accent green for the drag feedback widget
5. WHEN the drag-and-drop interface renders THEN the System SHALL NOT use purple, blue, or any colors outside the green theme palette

### Requirement 4

**User Story:** As a participant, I want dragged items to stay in drop zones immediately after I drop them, so that I can complete drag-and-drop questions without items disappearing.

#### Acceptance Criteria

1. WHEN a participant drops an item into a drop zone THEN the System SHALL immediately place the item in that zone and update the local state
2. WHEN an item is placed in a drop zone THEN the System SHALL persist the item in that position without reverting or disappearing
3. WHEN the System sends the placement update to the backend THEN the System SHALL maintain the local UI state regardless of backend response timing
4. WHEN a participant places all items in drop zones THEN the System SHALL keep all items visible in their respective positions
5. WHEN the backend acknowledges a placement THEN the System SHALL NOT revert or re-render the UI in a way that causes items to disappear

### Requirement 5

**User Story:** As a participant, I want to see my matched pairs with clear correct/incorrect feedback after submitting drag-and-drop answers, so that I can understand which matches I got right or wrong.

#### Acceptance Criteria

1. WHEN a participant submits a drag-and-drop answer THEN the System SHALL display each matched pair with the target label on the left and the matched item on the right
2. WHEN displaying feedback for correct matches THEN the System SHALL highlight both the target label and matched item with green background color and display a checkmark icon
3. WHEN displaying feedback for incorrect matches THEN the System SHALL highlight both the target label and matched item with red background color and display an X icon
4. WHEN displaying post-submission feedback THEN the System SHALL NOT show "Drop item here" placeholder text in any drop zone
5. WHEN displaying post-submission feedback THEN the System SHALL show the actual matched item text in each drop zone alongside the target label
