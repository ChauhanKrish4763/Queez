# Design Document

## Overview

This design addresses six critical issues in the live multiplayer quiz feature:
1. Host final results page inconsistency with participant view
2. Drag-and-drop question functionality issues
3. Quiz progression affecting other participants incorrectly
4. Points calculation and display problems
5. Answer feedback showing incorrect state before correct state
6. Mid-quiz leaderboard filtering and display issues

The fixes focus on UI consistency, state management, and proper data flow between frontend and backend.

## Architecture

### Component Structure

The live quiz system consists of:
- **Frontend (Flutter/Dart)**: UI components, state management (Riverpod), WebSocket client
- **Backend (Python/FastAPI)**: WebSocket server, game controller, session manager, leaderboard manager
- **State Management**: Game provider and session provider manage quiz state on the client
- **Communication**: WebSocket messages for real-time updates

### Key Components to Modify

1. **LiveHostView** - Host dashboard that needs to show final results
2. **LiveMultiplayerResults** - Final results page (already has podium)
3. **DragDropInterface** - Drag-and-drop UI component
4. **GameController** (backend) - Answer evaluation and scoring
5. **GameProvider** (frontend) - Client-side state management
6. **Leaderboard components** - Mid-quiz leaderboard filtering

## Components and Interfaces

### 1. Host Results Navigation

**Current Issue**: Host sees `LiveHostView` during quiz but doesn't navigate to `LiveMultiplayerResults` at the end.

**Solution**: Modify host's quiz completion logic to navigate to the same `LiveMultiplayerResults` page as participants.

**Interface Changes**:
- Add navigation logic in `LiveHostView` or host's quiz screen to detect quiz completion
- Navigate to `LiveMultiplayerResults` when quiz ends
- Ensure `LiveMultiplayerResults` works for both host and participants

### 2. Drag-and-Drop Answer Submission

**Current Issue**: Drag-and-drop interface may not be correctly submitting ordered lists.

**Solution**: Ensure `DragDropInterface` properly formats and submits the ordered list of items.

**Interface Changes**:
