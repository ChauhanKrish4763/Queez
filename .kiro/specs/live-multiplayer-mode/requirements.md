# Requirements Document

## Introduction

The Live Multiplayer Mode feature enables real-time, synchronous quiz gameplay where multiple participants join a session hosted by a quiz creator and compete simultaneously. This feature transforms the quiz application from a solo experience into an interactive, competitive multiplayer environment where players answer questions in real-time, see live leaderboards, and experience immediate feedback on their performance relative to other participants.

## Glossary

- **Quiz System**: The overall application managing quiz creation, storage, and gameplay
- **Host**: The user who creates and controls a live multiplayer session
- **Participant**: A user who joins an existing live multiplayer session
- **Session**: A temporary multiplayer game instance with a unique code
- **WebSocket Connection**: A persistent bidirectional communication channel between client and server
- **Session Code**: A unique alphanumeric identifier used to join a specific session
- **Game State**: The current status of the quiz including question index, participant answers, and scores
- **Leaderboard**: A ranked list of participants ordered by score
- **Question Timer**: A countdown mechanism limiting time to answer each question
- **Answer Submission**: The act of a participant selecting and sending their answer choice
- **Score Calculation**: The process of determining points based on correctness and response time
- **Session Lifecycle**: The progression from waiting → active → completed states
- **Reconnection**: The process of re-establishing a dropped connection and resuming participation

## Requirements

### Requirement 1

**User Story:** As a quiz host, I want to create a live multiplayer session for my quiz, so that multiple participants can join and compete in real-time.

#### Acceptance Criteria

1. WHEN a host selects a quiz and chooses live multiplayer mode THEN the Quiz System SHALL create a unique session with a 6-character alphanumeric code
2. WHEN a session is created THEN the Quiz System SHALL establish a WebSocket connection for the host
3. WHEN a session is created THEN the Quiz System SHALL set the session expiration to 24 hours from creation time
4. WHEN a session is created THEN the Quiz System SHALL initialize the Game State with waiting status
5. WHEN a session is created THEN the Quiz System SHALL display the Session Code prominently to the host

### Requirement 2

**User Story:** As a participant, I want to join a live multiplayer session using a session code, so that I can compete with other players.

#### Acceptance Criteria

1. WHEN a participant enters a valid Session Code THEN the Quiz System SHALL establish a WebSocket Connection for that participant
2. WHEN a participant joins THEN the Quiz System SHALL add the participant to the session participant list
3. WHEN a participant joins THEN the Quiz System SHALL broadcast the updated participant count to all connected clients
4. WHEN a participant attempts to join an expired session THEN the Quiz System SHALL reject the join request with an error message
5. WHEN a participant attempts to join a session that has already started THEN the Quiz System SHALL reject the join request with an error message
6. WHEN a participant joins THEN the Quiz System SHALL send the current Game State to that participant

### Requirement 3

**User Story:** As a host, I want to see all participants who have joined my session, so that I know when everyone is ready to start.

#### Acceptance Criteria

1. WHEN a participant joins or leaves THEN the Quiz System SHALL broadcast the updated participant list to all connected clients
2. WHEN displaying participants THEN the Quiz System SHALL show each participant's username and join timestamp
3. WHEN the host views the waiting lobby THEN the Quiz System SHALL display the total participant count
4. WHEN a participant disconnects THEN the Quiz System SHALL mark that participant as disconnected in the participant list
5. WHEN a disconnected participant reconnects within 60 seconds THEN the Quiz System SHALL restore their participant status

### Requirement 4

**User Story:** As a host, I want to start the quiz when all participants are ready, so that the game begins for everyone simultaneously.

#### Acceptance Criteria

1. WHEN the host initiates quiz start THEN the Quiz System SHALL validate that at least 2 participants are connected
2. WHEN the host initiates quiz start THEN the Quiz System SHALL transition the Game State from waiting to active
3. WHEN the quiz starts THEN the Quiz System SHALL broadcast the first question to all participants simultaneously
4. WHEN the quiz starts THEN the Quiz System SHALL prevent new participants from joining
5. WHEN the quiz starts THEN the Quiz System SHALL initialize the Question Timer for the first question

### Requirement 5

**User Story:** As a participant, I want to answer questions in real-time with a countdown timer, so that I can compete fairly with other players.

#### Acceptance Criteria

1. WHEN a question is displayed THEN the Quiz System SHALL start a Question Timer counting down from 30 seconds
2. WHEN a participant submits an answer THEN the Quiz System SHALL record the submission timestamp
3. WHEN a participant submits an answer THEN the Quiz System SHALL validate the answer against the correct answer
4. WHEN the Question Timer reaches zero THEN the Quiz System SHALL mark all unsubmitted answers as incorrect
5. WHEN all participants have answered or the timer expires THEN the Quiz System SHALL advance to the next question
6. WHEN a participant submits an answer THEN the Quiz System SHALL prevent that participant from changing their answer

### Requirement 6

**User Story:** As a participant, I want to see my score update in real-time, so that I know how well I'm performing.

#### Acceptance Criteria

1. WHEN an answer is submitted THEN the Quiz System SHALL calculate the score based on correctness and response time
2. WHEN calculating score THEN the Quiz System SHALL award 1000 points for correct answers
3. WHEN calculating score THEN the Quiz System SHALL apply a time bonus of up to 500 points based on response speed
4. WHEN a score changes THEN the Quiz System SHALL broadcast the updated score to the participant
5. WHEN a score changes THEN the Quiz System SHALL update the Leaderboard rankings

### Requirement 7

**User Story:** As a participant, I want to see a live leaderboard showing all players' rankings, so that I can track my position relative to others.

#### Acceptance Criteria

1. WHEN scores change THEN the Quiz System SHALL recalculate Leaderboard rankings
2. WHEN displaying the Leaderboard THEN the Quiz System SHALL show rank, username, and total score for each participant
3. WHEN the Leaderboard updates THEN the Quiz System SHALL broadcast the updated rankings to all participants
4. WHEN a question is answered THEN the Quiz System SHALL display the Leaderboard before advancing to the next question
5. WHEN displaying the Leaderboard THEN the Quiz System SHALL highlight the current participant's position

### Requirement 8

**User Story:** As a participant, I want to see the correct answer after each question, so that I can learn from my mistakes.

#### Acceptance Criteria

1. WHEN all participants have answered or the timer expires THEN the Quiz System SHALL reveal the correct answer
2. WHEN revealing the answer THEN the Quiz System SHALL display which option was correct
3. WHEN revealing the answer THEN the Quiz System SHALL show how many participants selected each option
4. WHEN revealing the answer THEN the Quiz System SHALL display the answer for 5 seconds before advancing
5. WHEN revealing the answer THEN the Quiz System SHALL show whether the current participant answered correctly

### Requirement 9

**User Story:** As a host or participant, I want to see final results when the quiz ends, so that I can see who won and review performance.

#### Acceptance Criteria

1. WHEN the last question is answered THEN the Quiz System SHALL transition the Game State to completed
2. WHEN the quiz completes THEN the Quiz System SHALL calculate final rankings for all participants
3. WHEN displaying final results THEN the Quiz System SHALL show the top 10 participants with their scores
4. WHEN displaying final results THEN the Quiz System SHALL highlight the winner
5. WHEN displaying final results THEN the Quiz System SHALL show each participant's accuracy percentage
6. WHEN the quiz completes THEN the Quiz System SHALL persist the session results to the database

### Requirement 10

**User Story:** As a participant, I want my connection to automatically reconnect if I lose network connectivity, so that I don't lose my progress.

#### Acceptance Criteria

1. WHEN a WebSocket Connection drops THEN the Quiz System SHALL attempt automatic reconnection with exponential backoff
2. WHEN reconnecting THEN the Quiz System SHALL restore the participant's session state
3. WHEN a participant reconnects THEN the Quiz System SHALL send the current question and Game State
4. WHEN a participant is disconnected for more than 60 seconds THEN the Quiz System SHALL mark their remaining answers as incorrect
5. WHEN reconnection succeeds THEN the Quiz System SHALL display a brief reconnection notification

### Requirement 11

**User Story:** As a host, I want to end the quiz early if needed, so that I can handle unexpected situations.

#### Acceptance Criteria

1. WHEN the host initiates early termination THEN the Quiz System SHALL validate that the requesting user is the host
2. WHEN the host ends the quiz early THEN the Quiz System SHALL transition the Game State to completed
3. WHEN the quiz ends early THEN the Quiz System SHALL calculate final scores based on answered questions
4. WHEN the quiz ends early THEN the Quiz System SHALL broadcast the final results to all participants
5. WHEN the quiz ends early THEN the Quiz System SHALL close all WebSocket Connections after displaying results

### Requirement 12

**User Story:** As a system administrator, I want all client actions validated on the server, so that cheating is prevented.

#### Acceptance Criteria

1. WHEN a participant submits an answer THEN the Quiz System SHALL validate the submission timestamp against the Question Timer
2. WHEN a participant submits an answer THEN the Quiz System SHALL reject submissions after the timer expires
3. WHEN calculating scores THEN the Quiz System SHALL perform all calculations on the server
4. WHEN a host action is received THEN the Quiz System SHALL validate that the requesting user is the session host
5. WHEN any state change occurs THEN the Quiz System SHALL validate the action against the current Game State
