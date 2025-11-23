# Design Document

## Overview

This design addresses 5 critical UI/UX bugs in the live multiplayer quiz system that affect visual consistency, user feedback, and interaction quality. The bugs span the host dashboard leaderboard display, multiple choice answer feedback, and drag-and-drop question interface.

The system is built with Flutter/Dart and uses a component-based architecture with Riverpod for state management. The fixes focus on improving visual consistency with the app's green color theme, ensuring proper feedback mechanisms, and resolving state synchronization issues in the drag-and-drop interface.

## Architecture

### Current System Components

**Frontend (Flutter/Dart):**
- `HostLeaderboardPanel`: Host dashboard widget showing participant rankings and progress
- `PodiumWidget`: Animated display of top 3 participants with trophy icons
- `MultipleChoiceOptions`: MCQ option buttons with answer feedback
- `DragDropInterface`: Drag-and-drop question UI with matching functionality
- `LiveMultiplayerResults`: Final results screen (reference implementation)
- `AppColors`: Application color design system

### Component Relationships

```
LiveHostView
  └── HostLeaderboardPanel
        ├── PodiumWidget (MISSING - Bug #1)
        └── Participant List

LiveMultiplayerQuiz
  └── MultipleChoiceOptions (Bug #2)
  └── DragDropInterface (Bugs #3, #4, #5)

LiveMultiplayerResults (Reference)
  └── PodiumWidget (WORKING)
```

## Components and Interfaces

### Bug 1: Host Dashboard Podium Missing

**Problem:** The host dashboard shows circular badges for top 3 instead of the animated podium widget that participants see on the results screen.

**Root Cause:** The `HostLeaderboardPanel` widget has conditional logic that renders `PodiumWidget` only when `rankings.length >= 3`, but during the quiz, the podium is not being displayed at all. The component exists and is imported, but it's only shown in a small leaderboard format.

**Solution:**
- The `HostLeaderboardPanel` already has the correct structure with `PodiumWidget` imported
- The widget is conditionally rendered: `if (rankings.length >= 3) PodiumWidget(...)`
- The issue is that this condition works, but the podium needs to be more prominent
- Ensure the podium is positioned above the participant list (already correct in current code)
- Verify that `rankings` data is being populated correctly during the quiz

**Implementation Details:**
- File: `quiz_app/lib/LibrarySection/LiveMode/widgets/host_leaderboard_panel.dart`
- The structure is already correct (lines 73-79)
- Need to verify that `rankings` prop is being passed with updated data
- The podium should update in real-time as scores change

**Affected Files:**
- `quiz_app/lib/LibrarySection/LiveMode/widgets/host_leaderboard_panel.dart` (verify data flow)
- `quiz_app/lib/LibrarySection/LiveMode/screens/live_host_view.dart` (verify rankings prop)

### Bug 2: Wrong Answer Not Highlighting Red

**Problem:** When a participant selects a wrong answer in MCQ, the selected option doesn't turn red with an X icon. Only the correct answer highlights green.

**Root Cause:** The logic in `_buildOptionButton` method (lines 57-84) determines colors based on `isSelected` and `isCorrectOption`. The condition for showing red feedback exists (lines 71-76), but there may be an issue with how `correctAnswer` is being parsed or compared.

**Analysis of Current Logic:**
```dart
// Lines 48-56: Parsing correctAnswer
final correctIndex = int.tryParse(correctAnswer!);
if (correctIndex != null) {
  isCorrectOption = correctIndex == index;
} else {
  isCorrectOption = correctAnswer!.toLowerCase() == option.toLowerCase();
}
```

The logic handles both index-based and text-based correct answers. The red highlighting logic (lines 71-76) should work:
```dart
else if (isSelected && !isCorrectOption) {
  backgroundColor = AppColors.error;
  borderColor = AppColors.error;
  textColor = AppColors.white;
  feedbackIcon = Icons.cancel;
  iconColor = AppColors.white;
}
```

**Potential Issues:**
1. `correctAnswer` might not be set when `hasAnswered` is true
2. The `isCorrect` prop might be interfering with the logic
3. The answer comparison might be failing due to type mismatch

**Solution:**
- Add debug logging to verify `correctAnswer` value and type
- Ensure `correctAnswer` is passed from parent component when answer feedback is received
- Verify that `hasAnswered` is set to true before `correctAnswer` is available
- Test with both index-based and text-based correct answers

**Affected Files:**
- `quiz_app/lib/LibrarySection/LiveMode/widgets/multiple_choice_options.dart` (lines 42-90)
- `quiz_app/lib/LibrarySection/LiveMode/utils/question_type_handler.dart` (verify correctAnswer passing)

### Bug 3: Drag-and-Drop Color Inconsistency

**Problem:** The drag-and-drop interface uses colors that don't match the app's green theme, appearing "purple" or inconsistent.

**Root Cause:** The `DragDropInterface` uses `Theme.of(context).primaryColor` and `QuizColors` constants, but some colors may not align with the `AppColors` palette defined in `utils/color.dart`.

**Color Analysis:**
- `AppColors.primary` = `#5E8C61` (forest green)
- `AppColors.secondary` = `#98A88C` (sage green)
- `AppColors.accentBright` = `#6FCF97` (bright green)
- `QuizColors` may have different definitions

**Solution:**
- Replace all color references with `AppColors` constants
- Update draggable item colors to use `AppColors.primary` or `AppColors.accentBright`
- Update drop zone colors to use `AppColors.primaryLight` for backgrounds
- Update border colors to use `AppColors.primary`
- Ensure feedback colors use `AppColors.success` (green) and `AppColors.error` (red)

**Color Mapping:**
- Draggable items: `AppColors.primary` for border, `AppColors.white` for background
- Drop zones (empty): `AppColors.primaryLight` for background, `AppColors.primary` for border
- Drop zones (filled): `AppColors.white` for background, `AppColors.primary` for border
- Drag feedback: `AppColors.accentBright` for background
- Correct matches: `AppColors.success` for background
- Incorrect matches: `AppColors.error` for background

**Affected Files:**
- `quiz_app/lib/LibrarySection/LiveMode/widgets/drag_drop_interface.dart` (entire file)
- `quiz_app/lib/LibrarySection/PlaySection/widgets/question_types/drag_drop_options.dart` (similar updates)

### Bug 4: Drag-and-Drop Items Disappearing

**Problem:** When participants drop items into drop zones, the items disappear immediately and only stay after ~20 seconds, suggesting a state synchronization issue.

**Root Cause:** The `_handleItemPlaced` method (lines 71-96) updates local state with `setState`, but there may be a race condition where:
1. Local state updates immediately (item appears in drop zone)
2. WebSocket message is sent to backend
3. Backend processes and broadcasts state update
4. Incoming WebSocket message overwrites local state
5. If backend response is delayed, the item disappears until backend confirms

**Analysis of Current Implementation:**
```dart
void _handleItemPlaced(String dropTarget, String dragItem) {
  if (widget.hasAnswered) return;
  
  setState(() {
    // Remove from previous position
    // Place in new position
    _matches[dropTarget] = dragItem;
  });
  
  // Force rebuild
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      setState(() {});
    }
  });
}
```

The code already has a force rebuild mechanism, but the issue is likely that the parent widget is re-rendering and passing new props that reset the state.

**Solution:**
- Implement optimistic UI updates that persist until backend confirmation
- Add a local state flag to prevent external state updates from overwriting user actions
- Use a `didUpdateWidget` check to preserve local changes
- Consider using a state management solution that handles optimistic updates
- Add debouncing to prevent rapid state changes

**Implementation Strategy:**
1. Add `_localMatches` map to track user's immediate actions
2. Only update from props when `!hasAnswered` and no pending local changes
3. Merge backend state with local state intelligently
4. Add a `_pendingChanges` flag to prevent state reversion

**Affected Files:**
- `quiz_app/lib/LibrarySection/LiveMode/widgets/drag_drop_interface.dart` (lines 71-96, state management)

### Bug 5: Drag-and-Drop Post-Submission Feedback

**Problem:** After submitting drag-and-drop answers, the matched items don't display correctly. The drop zones show "Drop item here" instead of the matched item, and feedback icons are missing.

**Root Cause:** The `_buildDropZone` method (lines 248-413) has conditional rendering that shows the matched item when `!isEmpty`, but after `hasAnswered` is true, the rendering logic may not be displaying the matched item correctly.

**Analysis of Current Code:**
```dart
// Line 340-370: Matched item display
Expanded(
  flex: 2,
  child: isEmpty
    ? Text('Drop here', ...)  // Placeholder
    : Container(
        // Matched item display
        child: Row(
          children: [
            Expanded(child: Text(matchedItem, ...)),
            if (widget.hasAnswered && isCorrectMatch != null) ...[
              Icon(isCorrectMatch ? Icons.check_circle : Icons.cancel, ...)
            ],
          ],
        ),
      ),
),
```

The logic looks correct. The issue might be:
1. `_matches[dropTarget]` is being cleared after submission
2. The `isEmpty` check is evaluating to true when it shouldn't
3. The state is being reset by parent component

**Solution:**
- Ensure `_matches` map is not cleared after submission
- Verify that `matchedItem` variable is not null after `hasAnswered` is true
- Add state preservation logic to maintain matches after submission
- Ensure parent component doesn't reset the widget state
- Add debug logging to track state changes

**Implementation Details:**
- Preserve `_matches` state after submission
- Add a `_submittedMatches` map to store the final state
- Use `_submittedMatches` for rendering when `hasAnswered` is true
- Ensure feedback icons are displayed with correct colors

**Affected Files:**
- `quiz_app/lib/LibrarySection/LiveMode/widgets/drag_drop_interface.dart` (lines 248-413, state preservation)

## Data Models

### HostLeaderboardPanel Props

```dart
{
  rankings: List<Map<String, dynamic>>,  // [{'username': 'Alice', 'score': 2850, 'user_id': '123'}]
  allParticipants: List<dynamic>,        // All participants including those with 0 points
  answerDistribution: Map<dynamic, int>?, // {0: 2, 1: 5, 2: 1, 3: 0}
  questionIndex: int,                     // Current question (1-indexed)
  totalQuestions: int,                    // Total questions in quiz
  participantCount: int,                  // Total participant count
  averageScore: double,                   // Average score across participants
}
```

### MultipleChoiceOptions Props

```dart
{
  options: List<String>,           // ['Option A', 'Option B', 'Option C', 'Option D']
  onSelect: Function(int),         // Callback when option is selected
  selectedAnswer: int?,            // Index of selected option (0-3)
  correctAnswer: String?,          // Correct answer (index as string or text)
  hasAnswered: bool,               // Whether user has submitted answer
  isCorrect: bool?,                // Whether selected answer is correct
}
```

### DragDropInterface Props

```dart
{
  dragItems: List<String>,                    // ['Cat', 'Dog', 'Bird']
  dropTargets: List<String>,                  // ['Meow', 'Bark', 'Chirp']
  onMatchSubmit: Function(Map<String, String>), // Callback with matches
  hasAnswered: bool,                          // Whether user has submitted
  isCorrect: bool?,                           // Whether answer is correct
  correctMatches: Map<String, String>?,       // {'Cat': 'Meow', 'Dog': 'Bark'}
}
```

### DragDropInterface Internal State

```dart
{
  _matches: Map<String, String?>,        // {dropTarget: dragItem}
  _submittedMatches: Map<String, String>?, // Preserved state after submission
  _pendingChanges: bool,                  // Flag for optimistic updates
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*


### Property 1: Podium real-time updates
*For any* score update during an active quiz, when participant scores change, the podium display should re-render with the updated rankings reflecting the new top 3 positions.
**Validates: Requirements 1.2**

### Property 2: Podium color assignments
*For any* set of top 3 participants, the podium should display gold color for 1st place, silver for 2nd place, and bronze for 3rd place.
**Validates: Requirements 1.3**

### Property 3: Incorrect answer red highlighting
*For any* MCQ where a participant selects an incorrect answer, the selected option should be highlighted with red background color (AppColors.error).
**Validates: Requirements 2.1**

### Property 4: Incorrect answer X icon
*For any* MCQ where a participant selects an incorrect answer, the selected option should display an X icon (Icons.cancel).
**Validates: Requirements 2.2**

### Property 5: Dual highlighting for wrong answers
*For any* MCQ where a participant selects an incorrect answer, both the selected option (red) and the correct option (green) should be highlighted simultaneously.
**Validates: Requirements 2.3**

### Property 6: Correct answer green highlighting
*For any* MCQ where a participant selects the correct answer, only that option should be highlighted with green background color (AppColors.success) and checkmark icon.
**Validates: Requirements 2.5**

### Property 7: Immediate drop zone state update
*For any* drag-and-drop action, when an item is dropped into a drop zone, the local state should update immediately and the item should appear in that zone without delay.
**Validates: Requirements 4.1**

### Property 8: Drop zone item persistence
*For any* item placed in a drop zone, the item should remain in that position without reverting or disappearing, regardless of time elapsed.
**Validates: Requirements 4.2**

### Property 9: Optimistic UI state preservation
*For any* drag-and-drop placement, when the system sends updates to the backend, the local UI state should be maintained regardless of backend response timing or delays.
**Validates: Requirements 4.3**

### Property 10: All items visibility
*For any* drag-and-drop question where all drop zones are filled, all items should remain visible in their respective positions.
**Validates: Requirements 4.4**

### Property 11: No state reversion on backend response
*For any* backend acknowledgment of a placement, the UI should not revert or re-render in a way that causes items to disappear.
**Validates: Requirements 4.5**

### Property 12: Post-submission matched pair display
*For any* submitted drag-and-drop answer, each matched pair should display with the target label on the left and the matched item on the right.
**Validates: Requirements 5.1**

### Property 13: Correct match green feedback
*For any* correct match in a submitted drag-and-drop answer, both the target label and matched item should be highlighted with green background (AppColors.success) and display a checkmark icon.
**Validates: Requirements 5.2**

### Property 14: Incorrect match red feedback
*For any* incorrect match in a submitted drag-and-drop answer, both the target label and matched item should be highlighted with red background (AppColors.error) and display an X icon.
**Validates: Requirements 5.3**

### Property 15: No placeholder after submission
*For any* drag-and-drop question after submission, no drop zone should display "Drop item here" placeholder text.
**Validates: Requirements 5.4**

### Property 16: Matched item text display
*For any* submitted drag-and-drop answer, each drop zone should show the actual matched item text alongside the target label.
**Validates: Requirements 5.5**

## Error Handling

### Frontend Error Handling

1. **Missing Rankings Data**
   - If `rankings` is empty or null, show loading indicator
   - Log warning and display fallback UI
   - Prevent podium rendering with insufficient data

2. **Invalid Color Values**
   - Validate all color values are from AppColors palette
   - Fall back to default colors if invalid
   - Log error for debugging

3. **Drag-and-Drop State Corruption**
   - If `_matches` map becomes corrupted, reset to initial state
   - Preserve user's last valid state if possible
   - Show error message and allow retry

4. **Widget Rebuild During Drag**
   - Preserve drag state during parent widget rebuilds
   - Use `didUpdateWidget` to detect and handle prop changes
   - Maintain local state priority over incoming props

### State Management Error Handling

1. **Race Conditions**
   - Implement optimistic UI updates with rollback capability
   - Use timestamps to resolve conflicting state updates
   - Prioritize local user actions over remote state

2. **WebSocket Disconnection During Drag**
   - Preserve local state during disconnection
   - Queue state updates for retry when reconnected
   - Show reconnection overlay without losing user progress

## Testing Strategy

### Unit Testing

**Frontend (Dart):**
- Test `HostLeaderboardPanel` renders PodiumWidget with correct props
- Test `MultipleChoiceOptions` color logic for all answer states
- Test `DragDropInterface` state management methods
- Test color assignments match AppColors palette
- Test drag-and-drop state preservation after submission

**Widget Tests:**
- Test PodiumWidget renders with 1, 2, and 3 participants
- Test MCQ option highlighting for correct/incorrect answers
- Test drag-and-drop item placement and removal
- Test post-submission feedback display

### Property-Based Testing

We will use the `test` package with `flutter_test` for Dart widget testing.

**Property Tests:**
1. Podium color assignments: Generate random rankings and verify color mapping
2. MCQ feedback: Generate random answer selections and verify highlighting
3. Drag-and-drop persistence: Generate random placements and verify state preservation
4. Color consistency: Verify all rendered colors come from AppColors palette

### Integration Testing

1. **Host Dashboard Podium Display**
   - Start quiz as host with 3+ participants
   - Verify podium appears on dashboard
   - Have participants answer questions
   - Verify podium updates in real-time

2. **MCQ Answer Feedback**
   - Answer MCQ with wrong answer
   - Verify selected option turns red with X
   - Verify correct option turns green with checkmark
   - Answer MCQ with correct answer
   - Verify only selected option turns green

3. **Drag-and-Drop Complete Flow**
   - Load drag-and-drop question
   - Drag items to drop zones
   - Verify items stay in place immediately
   - Wait 5 seconds, verify items still in place
   - Submit answer
   - Verify matched pairs display with correct feedback
   - Verify no "Drop item here" text appears

### Manual Testing Checklist

- [ ] Host sees animated podium on dashboard during quiz
- [ ] Podium shows gold/silver/bronze colors correctly
- [ ] Podium updates when scores change
- [ ] Wrong MCQ answer shows red with X icon
- [ ] Correct MCQ answer shows green with checkmark
- [ ] Both wrong and correct answers highlighted simultaneously
- [ ] Drag-and-drop uses only green theme colors
- [ ] Dragged items stay in drop zones immediately
- [ ] Items don't disappear after 20 seconds
- [ ] Post-submission shows matched items (not placeholders)
- [ ] Correct matches show green with checkmark
- [ ] Incorrect matches show red with X

## Implementation Notes

### Bug Fix Priority

1. **Bug 4 (Items disappearing)** - CRITICAL - Breaks core functionality
2. **Bug 2 (Wrong answer highlighting)** - HIGH - Confusing user experience
3. **Bug 5 (Post-submission feedback)** - HIGH - Poor UX, unclear results
4. **Bug 1 (Host podium)** - MEDIUM - Inconsistent experience
5. **Bug 3 (Color scheme)** - LOW - Cosmetic issue

### Code Changes Summary

**Bug 1 - Host Dashboard Podium:**
- Verify `rankings` prop is passed correctly to `HostLeaderboardPanel`
- Ensure rankings data is updated in real-time
- No structural changes needed (code is already correct)

**Bug 2 - MCQ Wrong Answer Highlighting:**
- Add debug logging to `_buildOptionButton` method
- Verify `correctAnswer` prop is set when `hasAnswered` is true
- Test with both index-based and text-based correct answers
- Ensure color logic executes correctly for all cases

**Bug 3 - Drag-and-Drop Colors:**
- Replace all `Theme.of(context).primaryColor` with `AppColors.primary`
- Replace `QuizColors` references with `AppColors` equivalents
- Update draggable feedback widget colors
- Update drop zone border and background colors

**Bug 4 - Items Disappearing:**
- Add `_submittedMatches` map to preserve state after submission
- Implement optimistic UI updates with local state priority
- Add `_pendingChanges` flag to prevent external state overwrites
- Use `didUpdateWidget` to intelligently merge incoming props

**Bug 5 - Post-Submission Feedback:**
- Preserve `_matches` state after submission in `_submittedMatches`
- Use `_submittedMatches` for rendering when `hasAnswered` is true
- Ensure `matchedItem` is never null when displaying feedback
- Add null checks and fallback rendering

### Performance Considerations

- PodiumWidget animations run at 60fps with `SingleTickerProviderStateMixin`
- Drag-and-drop state updates use `setState` for immediate UI response
- Avoid unnecessary rebuilds by checking `didUpdateWidget` conditions
- Use `const` constructors where possible for widget optimization

### Accessibility Considerations

- Ensure color contrast ratios meet WCAG AA standards
- Provide semantic labels for drag-and-drop actions
- Ensure feedback icons are accompanied by color changes (not color alone)
- Test with screen readers for proper announcement of state changes

### Browser/Platform Compatibility

- Test drag-and-drop on touch devices (mobile)
- Verify drag feedback works on web platform
- Ensure animations perform well on lower-end devices
- Test color rendering across different screen types
