# Requirements Document

## Introduction

This document specifies requirements for fixing critical UI and functionality issues in the live multiplayer quiz feature. The system currently has issues with leaderboard display consistency, drag-and-drop functionality, quiz flow synchronization, scoring display, answer feedback timing, and mid-quiz leaderboard filtering.

## Glossary

- **Host**: The user who creates and controls the quiz session
- **Participant**: A user who joins a quiz session to answer questions
- **Leaderboard**: A ranked list of participants showing scores and progress
- **Podium Widget**: A visual display showing the top 3 participants with animated placement
- **Self-Paced Mode**: Quiz mode where each participant progresses through questions independently
- **Answer Feedback**: Visual indication showing whether a submitted answer is correct or incorrect
- **Mid-Quiz Leaderboard**: The leaderboard popup shown during the quiz after answering a question
- **Final Results Page**: The results screen shown when the quiz is completed

## Requirements

### Requirement 1

**User Story:** As a host, I want to see the same podium-style final results page as participants, so that I have a consistent and engaging view of the quiz outcomes.

#### Acceptance Criteria

1. WHEN the quiz completes and the host views the final results THEN the system SHALL display the podium widget showing the top 3 participants
2. WHEN the host views the final results page THEN the system SHALL display the same leaderboard layout as participants see
3. WHEN the host views the final results THEN the system SHALL show animated score displays and rankings identical to the participant view

### Requirement 2

**User Story:** As a participant, I want the drag-and-drop question interface to work correctly, so that I can submit my answers for ordering questions.

#### Acceptance Criteria

1. WHEN a participant drags an item to a drop zone THEN the system SHALL place the item in that position
2. WHEN a participant has placed all items in the drop zones THEN the system SHALL enable the submit button
3. WHEN a participant submits a drag-and-drop answer THEN the system SHALL send the ordered list to the backend
4. WHEN the backend receives a drag-and-drop answer THEN the system SHALL correctly evaluate the answer against the correct order
5. WHEN a drag-and-drop answer is evaluated THEN the system SHALL provide visual feedback showing whether the answer is correct or incorrect

### Requirement 3

**User Story:** As a participant, I want the quiz to progress only for me when I answer, so that other participants can answer at their own pace without being affected by my actions.

#### Acceptance Criteria

1. WHEN a participant submits an answer THEN the system SHALL advance only that participant to the next question
2. WHEN a participant is viewing a question THEN the system SHALL NOT advance them to the next question when another participant submits an answer
3. WHEN a participant requests the next question THEN the system SHALL send only that participant their next question based on their individual progress

### Requirement 4

**User Story:** As a participant, I want to see my points update correctly with time-based bonuses, so that I can track my performance accurately.

#### Acceptance Criteria

1. WHEN a participant submits a correct answer THEN the system SHALL calculate points as base points plus time bonus
2. WHEN calculating time bonus THEN the system SHALL award more points for faster answers within the time limit
3. WHEN a participant's score updates THEN the system SHALL display the new total score immediately in the UI
4. WHEN the leaderboard updates THEN the system SHALL reflect the correct current scores for all participants

### Requirement 5

**User Story:** As a participant, I want to see immediate and correct answer feedback, so that I know whether my answer was right without confusing visual transitions.

#### Acceptance Criteria

1. WHEN a participant submits an answer THEN the system SHALL display the correct feedback state immediately without showing incorrect state first
2. WHEN answer feedback is displayed THEN the system SHALL highlight the selected answer with the appropriate color based on correctness
3. WHEN the correct answer is revealed THEN the system SHALL highlight it distinctly from the participant's selected answer if different

### Requirement 6

**User Story:** As a participant, I want to see all participants in the mid-quiz leaderboard, so that I can track everyone's progress during the quiz.

#### Acceptance Criteria

1. WHEN a participant opens the mid-quiz leaderboard THEN the system SHALL display all participants who have joined the session
2. WHEN displaying the mid-quiz leaderboard THEN the system SHALL exclude the host from the participant list
3. WHEN the mid-quiz leaderboard shows participants THEN the system SHALL display their current scores and question progress
4. WHEN all participants have not yet answered the current question THEN the system SHALL show a waiting indicator with completion count
