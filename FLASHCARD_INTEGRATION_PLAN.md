# 🎴 Flashcard Feature Integration Plan

## 📋 Overview

This plan integrates flashcard creation and playback functionality into QuizAppTest2, combining the UI/UX patterns from FlashcardsApp2 with the backend architecture of QuizAppTest2.

---

## 🎯 Goals

1. ✅ Create flashcard sets with custom cards (question/answer pairs)
2. ✅ Store flashcards in MongoDB via FastAPI backend
3. ✅ Display flashcards in library section alongside quizzes
4. ✅ Play flashcards (flip card animation)
5. ✅ Share flashcards (reuse quiz sharing system)

---

## 📁 File Structure Changes

### **Frontend (Flutter) - New Files**

```
quiz_app/lib/
├── CreateSection/
│   ├── models/
│   │   └── flashcard_set.dart                    [NEW] - FlashcardSet & Flashcard models
│   ├── screens/
│   │   ├── flashcard_details_page.dart           [NEW] - Details input (like quiz_details.dart)
│   │   └── flashcard_creation_page.dart          [EXISTS - ENHANCE] - Card creation UI
│   ├── services/
│   │   └── flashcard_service.dart                [EXISTS - ENHANCE] - API calls for flashcards
│   └── widgets/
│       ├── flashcard_input_card.dart             [NEW] - Individual card input widget
│       └── flashcard_navigation_bar.dart         [NEW] - Bottom navigation for cards
│
├── LibrarySection/
│   ├── models/
│   │   └── flashcard_library_item.dart           [NEW] - Library display model
│   ├── PlaySection/
│   │   └── screens/
│   │       ├── flashcard_play_screen.dart        [NEW] - Flip card animation play
│   │       └── flashcard_study_complete.dart     [NEW] - Study session results
│   └── widgets/
│       ├── flashcard_library_card.dart           [NEW] - Library display card
│       └── library_item_factory.dart             [NEW] - Factory for quiz/flashcard items
│
└── utils/
    └── animations/
        └── flip_animation.dart                    [NEW] - Card flip animation
```

### **Backend (Python) - New Files**

```
backend/app/
├── models/
│   └── flashcard.py                              [NEW] - Flashcard Pydantic models
├── api/
│   └── routes/
│       └── flashcards.py                         [NEW] - Flashcard CRUD endpoints
└── core/
    └── database.py                               [MODIFY] - Add flashcard_sets collection
```

---

## 🎨 UI/UX Flow

### **1. Creation Flow**

```
Create Page
    ↓
[Flashcard Button] ← User clicks
    ↓
Flashcard Details Page (flashcard_details_page.dart)
├── Title input
├── Description input
├── Category dropdown (same as quiz)
├── Cover image (optional)
└── [Get Started Button]
    ↓
Flashcard Creation Page (flashcard_creation_page.dart)
├── Card 1: Front/Back input
├── Card 2: Front/Back input
├── ... (scrollable list)
├── [Add Card] button (bottom)
├── Card preview
└── [Save] button (top-right)
    ↓
Saves to Backend → Library
```

**Design Reference:**

- **Details Page**: Copy layout from `quiz_details.dart` (QuizAppTest2)
- **Creation Page**: Copy card input UI from `create_flashcards_screen.dart` (FlashcardsApp2)

### **2. Library Display**

```
Library Page
├── Search bar (shared with quizzes)
├── Filter: [All | Quizzes | Flashcards] ← NEW TABS
└── Items:
    ├── Quiz Card (existing)
    │   └── Buttons: [Play] [Share]
    └── Flashcard Card (new)
        ├── Shows: card count, category, created date
        └── Buttons: [Play] [Share]
```

**Design Reference:**

- **Card Design**: Similar to `item_card.dart` but with flashcard icon
- **Layout**: Reuse `library_body.dart` with type filter

### **3. Play/Study Flow**

```
Flashcard Play Screen
├── Top: Progress (5/20 cards)
├── Middle: Flip Card
│   ├── Front: Question
│   └── Back: Answer (tap to flip)
├── Bottom Controls:
│   ├── [← Previous]
│   ├── Flip indicator
│   └── [Next →]
└── [Complete] → Study Complete Screen
```

**Design Reference:**

- **Flip Animation**: Copy from FlashcardsApp2 `play_screen.dart`
- **Card Design**: Clean, minimal, focus on content

---

## 🗄️ Data Models

### **Frontend (Dart)**

```dart
// flashcard_set.dart
class FlashcardSet {
  String? id;
  String title;
  String description;
  String category;
  String? coverImagePath;
  String creatorId;
  List<Flashcard> cards;
  DateTime createdAt;

  FlashcardSet({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    this.coverImagePath,
    required this.creatorId,
    List<Flashcard>? cards,
    DateTime? createdAt,
  }) : cards = cards ?? [],
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'coverImagePath': coverImagePath,
    'creatorId': creatorId,
    'cards': cards.map((c) => c.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory FlashcardSet.fromJson(Map<String, dynamic> json) => FlashcardSet(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    category: json['category'],
    coverImagePath: json['coverImagePath'],
    creatorId: json['creatorId'],
    cards: (json['cards'] as List).map((c) => Flashcard.fromJson(c)).toList(),
    createdAt: DateTime.parse(json['createdAt']),
  );
}

class Flashcard {
  String? id;
  String front;  // Question/Term
  String back;   // Answer/Definition

  Flashcard({
    this.id,
    required this.front,
    required this.back,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'front': front,
    'back': back,
  };

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
    id: json['id'],
    front: json['front'],
    back: json['back'],
  );
}

// flashcard_library_item.dart
class FlashcardLibraryItem {
  final String id;
  final String title;
  final String description;
  final String? coverImagePath;
  final String? createdAt;
  final int cardCount;
  final String category;
  final String? originalOwner;
  final String? originalOwnerUsername;

  FlashcardLibraryItem({
    required this.id,
    required this.title,
    required this.description,
    this.coverImagePath,
    this.createdAt,
    required this.cardCount,
    required this.category,
    this.originalOwner,
    this.originalOwnerUsername,
  });

  factory FlashcardLibraryItem.fromJson(Map<String, dynamic> json) => FlashcardLibraryItem(
    id: json['id'],
    title: json['title'],
    description: json['description'] ?? '',
    coverImagePath: json['coverImagePath'],
    createdAt: json['createdAt'],
    cardCount: json['cardCount'] ?? 0,
    category: json['category'] ?? '',
    originalOwner: json['originalOwner'],
    originalOwnerUsername: json['originalOwnerUsername'],
  );
}
```

### **Backend (Python)**

```python
# app/models/flashcard.py
from pydantic import BaseModel
from typing import List, Optional

class Card(BaseModel):
    id: Optional[str] = None
    front: str
    back: str

class FlashcardSet(BaseModel):
    id: Optional[str] = None
    title: str
    description: str
    category: str
    coverImagePath: Optional[str] = None
    creatorId: str
    originalOwner: Optional[str] = None
    cards: List[Card]
    createdAt: Optional[str] = None

class FlashcardSetResponse(BaseModel):
    id: str
    message: str

class FlashcardLibraryItem(BaseModel):
    id: str
    title: str
    description: str
    coverImagePath: Optional[str] = None
    createdAt: Optional[str] = None
    cardCount: int
    category: str
    originalOwner: Optional[str] = None
    originalOwnerUsername: Optional[str] = None

class FlashcardLibraryResponse(BaseModel):
    success: bool
    data: List[FlashcardLibraryItem]
    count: int
```

---

## 🔌 Backend API Endpoints

### **New Routes: `/flashcards`**

```python
# app/api/routes/flashcards.py

@router.post("", response_model=FlashcardSetResponse)
async def create_flashcard_set(flashcard_set: FlashcardSet):
    """Create a new flashcard set"""
    # Validation
    # Set default cover image by category
    # Insert to MongoDB flashcard_sets collection
    # Return ID and success message

@router.get("/library/{user_id}", response_model=FlashcardLibraryResponse)
async def get_flashcard_library_by_user(user_id: str):
    """Get all flashcard sets created by user"""
    # Query flashcard_sets collection
    # Return list of FlashcardLibraryItem

@router.get("/{flashcard_set_id}", response_model=FlashcardSet)
async def get_flashcard_set(flashcard_set_id: str, user_id: str):
    """Get full flashcard set details with all cards"""
    # Verify user access
    # Return complete flashcard set

@router.delete("/{flashcard_set_id}")
async def delete_flashcard_set(flashcard_set_id: str):
    """Delete a flashcard set"""
    # Delete from MongoDB
    # Return success message

@router.post("/add-to-library")
async def add_flashcard_to_library(data: dict):
    """Add someone else's flashcard set to your library"""
    # Similar to quiz sharing
    # Create copy with originalOwner field
```

---

## 🔄 Service Layer

### **Frontend Service**

```dart
// flashcard_service.dart
class FlashcardService {
  static const String baseUrl = ApiConfig.baseUrl;

  // Create flashcard set
  static Future<String> createFlashcardSet(FlashcardSet flashcardSet) async {
    final response = await http.post(
      Uri.parse('$baseUrl/flashcards'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(flashcardSet.toJson()),
    );
    // Handle response, return ID
  }

  // Get user's flashcard library
  static Future<List<FlashcardLibraryItem>> getFlashcardLibrary(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/flashcards/library/$userId'),
    );
    // Parse and return list
  }

  // Get full flashcard set with cards
  static Future<FlashcardSet> getFlashcardSet(String setId, String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/flashcards/$setId?user_id=$userId'),
    );
    // Parse and return
  }

  // Delete flashcard set
  static Future<void> deleteFlashcardSet(String setId) async {
    await http.delete(Uri.parse('$baseUrl/flashcards/$setId'));
  }

  // Add to library (for sharing)
  static Future<void> addToLibrary(String setId, String userId) async {
    await http.post(
      Uri.parse('$baseUrl/flashcards/add-to-library'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'flashcard_set_id': setId, 'user_id': userId}),
    );
  }
}
```

---

## 🎭 UI Components

### **1. Flashcard Details Page**

**File**: `flashcard_details_page.dart`

**Layout** (mirrors `quiz_details.dart`):

- Title: "Create Flashcard Set"
- Form fields:
  - Set Title (required)
  - Description (required)
  - Category dropdown (reuse quiz categories)
  - Cover Image (optional, default by category)
- "Get Started" button → Navigate to creation page

### **2. Flashcard Creation Page**

**File**: `flashcard_creation_page.dart` (enhance existing)

**Key Changes**:

- Replace simple front/back fields with rich card widget
- Add bottom navigation bar with card numbers
- Add preview section
- Save button calls `FlashcardService.createFlashcardSet()`

**Widget**: `flashcard_input_card.dart`

```dart
class FlashcardInputCard extends StatelessWidget {
  final Flashcard card;
  final Function(Flashcard) onUpdate;
  final VoidCallback? onDelete;

  // Shows:
  // - Card number header
  // - Front input (multiline)
  // - Back input (multiline)
  // - Delete button (if > 1 card)
  // - Preview section
}
```

### **3. Library Integration**

**Modify**: `library_page.dart`

Add tab selector:

```dart
enum LibraryFilter { all, quizzes, flashcards }
```

**New Widget**: `flashcard_library_card.dart`

- Similar design to `item_card.dart`
- Shows flashcard icon, card count
- Buttons: [Play] [Share]

### **4. Play Screen**

**File**: `flashcard_play_screen.dart`

**Features**:

- Flip animation (copy from FlashcardsApp2)
- Swipe gestures for next/previous
- Progress indicator
- Mark as learned (optional)
- Study complete screen

**Animation**:

```dart
class FlipAnimation extends StatefulWidget {
  final String front;
  final String back;

  // 3D flip effect using Transform + AnimationController
}
```

---

## 🔀 Sharing System

### **Reuse Quiz Sharing Logic**

The flashcard sharing will work exactly like quiz sharing:

1. **Share Button** → Generate share code or link
2. **Recipient** → Enters code/link
3. **Backend** → Copies flashcard set to recipient's library
4. **Fields**:
   - `creatorId`: New owner
   - `originalOwner`: Original creator
   - `originalOwnerUsername`: Fetched from Firestore

---

## 📊 Database Schema

### **MongoDB Collection: `flashcard_sets`**

```json
{
  "_id": "ObjectId",
  "title": "Spanish Vocabulary",
  "description": "Basic Spanish words and phrases",
  "category": "Language Learning",
  "coverImagePath": "https://...",
  "creatorId": "firebase_user_id",
  "originalOwner": "original_creator_id",
  "cards": [
    {
      "id": "uuid",
      "front": "Hello",
      "back": "Hola"
    },
    {
      "id": "uuid",
      "front": "Goodbye",
      "back": "Adiós"
    }
  ],
  "createdAt": "November, 2025"
}
```

---

## ✅ Implementation Checklist

### **Phase 1: Models & Backend (Week 1)**

- [ ] Create `app/models/flashcard.py`
- [ ] Create `app/api/routes/flashcards.py`
- [ ] Add flashcard endpoints to main.py
- [ ] Test all endpoints with Postman
- [ ] Update backend README

### **Phase 2: Frontend Models & Services (Week 1)**

- [ ] Create `flashcard_set.dart` model
- [ ] Create `flashcard_library_item.dart` model
- [ ] Enhance `flashcard_service.dart` with API calls
- [ ] Test API integration

### **Phase 3: Creation Flow (Week 2)**

- [ ] Create `flashcard_details_page.dart`
- [ ] Enhance `flashcard_creation_page.dart`
- [ ] Create `flashcard_input_card.dart` widget
- [ ] Create `flashcard_navigation_bar.dart` widget
- [ ] Add route to create page
- [ ] Test full creation flow

### **Phase 4: Library Integration (Week 2)**

- [ ] Create `flashcard_library_card.dart`
- [ ] Modify `library_page.dart` to support filters
- [ ] Update `library_body.dart` for mixed content
- [ ] Test library display

### **Phase 5: Play Feature (Week 3)**

- [ ] Create `flip_animation.dart`
- [ ] Create `flashcard_play_screen.dart`
- [ ] Create `flashcard_study_complete.dart`
- [ ] Add gesture controls
- [ ] Test play flow

### **Phase 6: Sharing (Week 3)**

- [ ] Adapt quiz sharing for flashcards
- [ ] Test share flow
- [ ] Test add-to-library

### **Phase 7: Polish & Testing (Week 4)**

- [ ] UI/UX refinements
- [ ] Error handling
- [ ] Loading states
- [ ] Empty states
- [ ] Delete functionality
- [ ] End-to-end testing

---

## 🎨 Design Consistency

### **Colors & Styling**

- Reuse `AppColors` from QuizAppTest2
- Match button styles from quiz creation
- Card shadows and borders consistent with quiz cards

### **Icons**

- Flashcard icon: `Icons.style` or `Icons.collections_bookmark`
- Play icon: `Icons.play_circle_outline`
- Share icon: `Icons.share`

### **Typography**

- Titles: Bold, 24px
- Descriptions: Regular, 14px
- Card content: Medium, 16px

---

## 🚀 Launch Strategy

1. **Beta Test**: Internal testing with 5 flashcard sets
2. **User Feedback**: Gather input on flip animation speed, card UI
3. **Iterate**: Adjust based on feedback
4. **Full Launch**: Deploy to production

---

## 📝 Notes

- **FlashcardsApp2 uses Hive (local storage)**

  - QuizAppTest2 uses MongoDB (cloud)
  - We're adapting the UI, not the storage layer

- **No AI generation initially**

  - Focus on manual creation first
  - Can add AI later (like FlashcardsApp2's Gemini integration)

- **Study modes**
  - Start with simple flip cards
  - Can add spaced repetition, quizzes from flashcards later

---

## 🎯 Success Criteria

✅ User can create flashcard set in < 2 minutes
✅ Library shows both quizzes and flashcards seamlessly  
✅ Play screen has smooth flip animation (< 300ms)
✅ Sharing works identically to quizzes
✅ All data persists correctly in MongoDB
✅ No breaking changes to existing quiz functionality

---

## 🤝 Team Review

**Review Points**:

1. Does the UI flow make sense?
2. Are the data models complete?
3. Should we add any features (e.g., images on cards)?
4. Timeline realistic (4 weeks)?
5. Any technical concerns?

**Feedback Form**: [Add your comments here]

---

**Last Updated**: November 23, 2025
**Author**: GitHub Copilot
**Status**: 📋 Awaiting Approval
