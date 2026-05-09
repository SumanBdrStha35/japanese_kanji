# 👨‍💻 Developer Notes & Architecture Documentation

## System Design Overview

### Three-Layer Architecture

```
┌─────────────────────────────────────┐
│  PRESENTATION LAYER (UI)            │
│  ├─ Screens (11 files)              │
│  ├─ Widgets (13 components)         │
│  └─ Theme (Light/Dark)              │
└──────────────┬──────────────────────┘
               │
┌──────────────┴──────────────────────┐
│  STATE MANAGEMENT (Providers)        │
│  ├─ KanjiProvider                    │
│  ├─ GamificationProvider             │
│  ├─ QuizProvider                     │
│  ├─ ThemeProvider                    │
│  └─ SettingsProvider                 │
└──────────────┬──────────────────────┘
               │
┌──────────────┴──────────────────────┐
│  DATA LAYER (Models + Storage)       │
│  ├─ Models (6 types)                 │
│  ├─ Repositories (2 types)           │
│  ├─ Datasources (500 kanji)          │
│  └─ SharedPreferences                │
└─────────────────────────────────────┘
```

### Data Flow Diagram

```
User Action (UI)
    ↓
Provider Method Called
    ↓
Repository Method Called
    ↓
Data Updated (Model)
    ↓
notifyListeners()
    ↓
UI Rebuilds (Consumer/watch)
    ↓
saveProgress() to SharedPreferences
```

---

## Detailed Component Breakdown

### 1. KanjiProvider (State: Learning)

**Purpose**: Manages learned kanji, weak kanji, and user progress

**Key Methods**:

- `markKanjiLearned(id)` → +10 XP, adds to learned set
- `markKanjiWeak(id)` → Tracks failures
- `loadProgress()` → Load from SharedPreferences
- `saveProgress()` → Save to SharedPreferences
- `getUnlearnedKanji(week, day)` → Returns kanji for given week/day

**State Structure**:

```dart
class KanjiProvider extends ChangeNotifier {
  Set<String> learnedKanjiIds = {};        // Which kanji learned
  Set<String> weakKanjiIds = {};           // Failed in quiz
  int totalKanjiLearned = 0;               // Counter
  // Persistence via SharedPreferences
}
```

**Integration Points**:

- LearnScreen: Call `markKanjiLearned()` when user taps card
- QuizScreen: Call `markKanjiWeak()` on wrong answers
- HomeScreen: Display `totalKanjiLearned` counter
- ProgressScreen: Show weak kanji list

---

### 2. GamificationProvider (State: XP/Leveling)

**Purpose**: Manages XP, levels, achievements, missions, streaks

**Key Methods**:

- `addXP(amount)` → Add XP, check for level-up
- `checkLevelUp()` → Triggers at 100 XP increments
- `unlockAchievement(id)` → Mark achievement unlocked
- `incrementStreak()` → Called on daily login
- `resetStreakIfNeeded()` → Checks if 24+ hours passed
- `updateMissionProgress(type, amount)` → Mission tracking

**XP System**:

```
10 XP  = Learn 1 kanji
5 XP   = Correct quiz answer
15 XP  = Daily login
50 XP  = Complete review day
100 XP = Level up threshold
```

**Streak System**:

```
Day 1: +15 XP
Day 2: +15 XP × 1.1 (10% bonus)
Day 3: +15 XP × 1.2 (20% bonus)
Break: Resets to Day 1
```

**Achievement System** (10+ types):

- First Learn (learn 1 kanji)
- Century (100 kanji)
- Quiz Master (100% quiz accuracy)
- 7-Day Streak
- Level 5
- etc.

---

### 3. QuizProvider (State: Quiz Session)

**Purpose**: Manages quiz state during quiz session

**Key Methods**:

- `startQuiz(type)` → Generate 10 questions
- `selectAnswer(qIndex, answer)` → Record user answer
- `isAnswerCorrect(q)` → Check if answer matches key
- `getQuizSummary()` → Return stats
- `getWeakKanjiIds()` → Extract failed kanji

**Quiz Types**:

```dart
enum QuizType {
  meaning,        // What's the meaning? → 4 choices
  reading,        // What's the reading? → 4 choices
  writingRecall,  // Write the kanji → 4 choices (stroke order)
  mixed,          // Random mix of above
}
```

**Question Structure**:

```dart
class QuizQuestionModel {
  String kanjiId;
  String question;
  String correctAnswer;
  List<String> choices;
  String? userAnswer;
  bool get isCorrect => userAnswer == correctAnswer;
}
```

---

### 4. ThemeProvider (State: UI Theme)

**Purpose**: Manages dark/light theme toggle

**Key Methods**:

- `toggleTheme()` → Switch theme, save preference
- `isDarkMode` (getter) → Returns current mode

**Usage in main.dart**:

```dart
Consumer<ThemeProvider>(
  builder: (_, themeProvider, __) {
    return MaterialApp(
      theme: themeProvider.isDarkMode
        ? AppTheme.darkTheme
        : AppTheme.lightTheme,
    );
  },
)
```

---

### 5. SettingsProvider (State: App Settings)

**Purpose**: Manages settings and daily missions

**Key Methods**:

- `initializeMissions()` → Create today's missions
- `updateMissionProgress(type, amount)` → Update progress
- `completeMission(id)` → Mark complete, reward XP
- `resetMissionsDaily()` → Check if new day

**Daily Missions**:

```
1. Daily Login      → 15 XP
2. Learn 10 Kanji   → 50 XP
3. Complete 1 Quiz  → 20 XP
4. Review Kanji     → 100 XP
```

---

## Data Models Deep Dive

### KanjiModel

```dart
class KanjiModel {
  final String id;              // Unique ID
  final String kanji;           // The character
  final String meaning;         // English meaning
  final String onyomi;          // On'yomi reading
  final String kunyomi;         // Kun'yomi reading
  final List<String> examples;  // Example words
  final int strokeCount;        // Stroke count
  final int jlptLevel;          // JLPT N5=5, N4=4, etc.
  final int weekNumber;         // Week 1-5
  final int dayNumber;          // Day 1-7
}
```

**Stored in**: `kanji_data.dart` (static list of 500)  
**Accessed via**: `KanjiRepository.getAllKanji()`  
**Used in**: Learn screens, quiz generation

### UserProgressModel

```dart
class UserProgressModel {
  Set<String> learnedKanjiIds;  // Set of learned kanji IDs
  Set<String> weakKanjiIds;     // Set of weak kanji IDs
  int totalXP;                  // Total XP earned
  int currentLevel;             // Current level
  int streakDays;               // Current streak
  DateTime lastActiveDate;      // For streak reset
  DateTime createdDate;         // Account creation
}
```

**Persisted to**: SharedPreferences via JSON  
**Key**: `'user_progress'`  
**Updated**: On every learning action

### QuizQuestionModel

```dart
class QuizQuestionModel {
  final String kanjiId;
  final String question;        // "What's the meaning of 人?"
  final String correctAnswer;   // "person"
  final List<String> choices;   // ["person", "dog", "cat", "tree"]
  String? userAnswer;           // User's selection

  bool get isCorrect => userAnswer == correctAnswer;
}
```

**Generated**: By `QuizRepository.generate*Quiz()`  
**Managed**: In `QuizProvider` during quiz session  
**Scoring**: Tracks correct count for accuracy

### AchievementModel

```dart
class AchievementModel {
  final String id;
  final String name;            // "Century Master"
  final String description;     // "Learn 100 kanji"
  final String icon;            // Emoji
  bool unlocked;                // User's unlock status
  DateTime? unlockedDate;       // When unlocked
}
```

### StudyPlanModel

```dart
class StudyPlanModel {
  final int weekNumber;
  final List<DayPlan> days;     // 7 days per week
  bool isCompleted;
}

class DayPlan {
  final int dayNumber;
  final List<String> kanjiIds;  // ~20 kanji per day
  final bool isReviewDay;       // Review day (7/14/21/28...)
}
```

---

## Repository Pattern

### KanjiRepository

**Purpose**: Abstraction layer for kanji data

**Methods**:

```dart
List<KanjiModel> getAllKanji()
List<KanjiModel> getKanjiByWeekDay(int week, int day)
KanjiModel? getKanjiById(String id)
List<KanjiModel> filterByJLPTLevel(int level)
```

**Data Source**: `KanjiDataSource.getAllKanji()`  
**Caching**: Currently in-memory (can add DB later)

### QuizRepository

**Purpose**: Generate quiz questions from kanji data

**Methods**:

```dart
List<QuizQuestionModel> generateMeaningQuiz(List<String> kanjiIds)
List<QuizQuestionModel> generateReadingQuiz(List<String> kanjiIds)
List<QuizQuestionModel> generateWritingRecallQuiz(List<String> kanjiIds)
List<QuizQuestionModel> generateMixedQuiz(List<String> kanjiIds)
```

**Generation Logic**:

1. Select random kanji from provided list
2. Create question text based on quiz type
3. Add correct answer
4. Generate 3 wrong answers (from other kanji)
5. Shuffle choices
6. Return QuizQuestionModel

---

## Screen Hierarchy

### MainNavigationScreen (Root)

```
MainNavigationScreen
├─ BottomNavigationBar (5 tabs)
├─ PageView (smooth transitions)
└─ 5 Screen Pages
    ├─ Page 1: HomeScreen
    ├─ Page 2: KanjiHomeScreen
    ├─ Page 3: QuizScreen (placeholder)
    ├─ Page 4: ProgressScreen
    └─ Page 5: SettingsScreen
```

### Kanji Module (Tab 2)

```
KanjiHomeScreen
├─ "Learn Kanji" Button → LearnScreen
│   └─ Week/Day Selectors → KanjiCard List
├─ "Take Quiz" Button → QuizScreen
│   └─ Quiz Type Selection → QuizQuestionWidget
│   └─ QuizSummaryScreen
├─ "Study Plan" Button → StudyPlanScreen
│   └─ 5 Expandable Weeks → Day Plans
└─ "Handwriting" Button → HandwritingScreen
    └─ DrawingCanvas
```

---

## State Management Flow Examples

### Example 1: Learn Kanji and Earn XP

```
User taps "Mark as Learned" on kanji card
    ↓
KanjiCard widget calls:
    kanjiProvider.markKanjiLearned(kanji.id)
    ↓
KanjiProvider.markKanjiLearned():
    - Add kanji.id to learnedKanjiIds
    - Call gamificationProvider.addXP(10)
    - Increment totalKanjiLearned
    - Call saveProgress()
    - notifyListeners()
    ↓
GamificationProvider.addXP(10):
    - totalXP += 10
    - Check if totalXP >= 100:
        - If yes: currentLevel++, coins += 100, notifyListeners()
        - Triggers LevelUpDialog with confetti
    ↓
UI rebuilds automatically via Consumer widgets
    - HomeScreen XP bar updates
    - Level counter updates
    - Coins display updates
```

### Example 2: Complete Quiz

```
User answers 10 quiz questions
    ↓
QuizScreen calls:
    quizProvider.selectAnswer(index, answer)
    after each question
    ↓
QuizProvider.selectAnswer():
    - questions[index].userAnswer = answer
    - notifyListeners()
    ↓
User submits quiz → QuizSummaryScreen
    ↓
QuizSummaryScreen displays:
    - Total correct: 7/10 (70% accuracy)
    - XP earned: 35 (5 XP per correct)
    ↓
On submit, calls:
    - gamificationProvider.addXP(35)
    - kanjiProvider.markKanjiWeak() for wrong answers
    - Update quiz accuracy tracking
    ↓
All data persists to SharedPreferences
```

### Example 3: Toggle Dark Mode

```
User taps dark mode toggle in SettingsScreen
    ↓
SettingsScreen calls:
    themeProvider.toggleTheme()
    ↓
ThemeProvider.toggleTheme():
    - isDarkMode = !isDarkMode
    - Save to SharedPreferences
    - notifyListeners()
    ↓
Consumer<ThemeProvider> in main.dart rebuilds
    ↓
MaterialApp's theme property updates
    - All Material widgets respect new theme
    - Automatic UI color changes
```

---

## Performance Considerations

### Memory Usage

- Kanji dataset: ~500 items in memory (~2MB)
- Provider instances: 5 shared (lightweight)
- SharedPreferences cache: Minimal (~1MB)
- Total typical usage: 5-10MB

### Rendering Performance

- KanjiCard: Heavy widget (72pt kanji text)
  - Solution: Use `const` constructor, limit list size
- Progress charts: Expensive calculations
  - Solution: Cache calculated values, update only on data change
- Quiz questions: Lightwe widget (text only)
  - No performance issues

### Optimization Done

- Provider `select()` for fine-grained control
- `const` constructors on stateless widgets
- Lazy loading of screens (PageView)
- No unnecessary rebuilds (proper provider scoping)

---

## Error Handling Strategy

### Provider Initialization

```dart
// In KanjiProvider.loadProgress()
try {
  final data = prefs.getString('user_progress');
  if (data != null) {
    // Parse and restore
  }
} catch (e) {
  // Log error, use defaults
  debugPrint('Error loading progress: $e');
}
```

### Quiz Generation

```dart
// In QuizRepository
List<QuizQuestionModel> generateQuiz(List<String> kanjiIds) {
  if (kanjiIds.isEmpty) return [];

  // Ensure we have enough kanji for 4 choices
  if (kanjiIds.length < 4) {
    // Use all + padding
  }

  // Generate questions safely
}
```

---

## Testing Strategy

### Unit Tests (Recommended)

```dart
test('XP calculation', () {
  expect(calculateLevel(100), equals(2));
  expect(calculateLevel(200), equals(3));
});

test('Streak reset', () {
  final now = DateTime.now();
  final yesterday = now.subtract(Duration(days: 1));
  expect(shouldResetStreak(yesterday), true);
});
```

### Widget Tests (Recommended)

```dart
testWidgets('KanjiCard displays properly', (tester) async {
  await tester.pumpWidget(
    TestApp(
      home: KanjiCard(kanji: testKanji),
    ),
  );

  expect(find.text('木'), findsOneWidget);
  expect(find.text('tree'), findsOneWidget);
});
```

### Integration Tests

```dart
testWidgets('Complete learning flow', (tester) async {
  // Launch app
  // Navigate to Learn
  // Select week/day
  // Mark kanji learned
  // Verify XP increased
  // Navigate Home
  // Verify progress saved
});
```

---

## Extension Points for Future Development

### 1. Database Integration

```dart
// Replace SharedPreferences with Hive/SQLite
class KanjiRepository {
  Future<void> saveKanjiProgress(UserProgress progress) async {
    await _db.save(progress); // Instead of SharedPreferences
  }
}
```

### 2. Cloud Sync

```dart
// Add Firebase integration
class GamificationProvider {
  Future<void> syncToCloud() async {
    await _firestore.collection('users').doc(uid).set(toJson());
  }
}
```

### 3. ML Handwriting Recognition

```dart
// Integrate TensorFlow Lite
class HandwritingService {
  Future<double> recognizeHandwriting(Uint8List imageData) async {
    // Use tflite_flutter to run model
    // Return confidence score
  }
}
```

### 4. Spaced Repetition Algorithm

```dart
// Add SRS scheduling
class KanjiProvider {
  List<String> getKanjiForReview() {
    // Calculate next review dates using SRS formula
    // Return kanji due for review today
  }
}
```

---

## Dependency Graph

```
main.dart
├─ MultiProvider (all 5)
│  ├─ KanjiProvider
│  │  └─ KanjiRepository
│  │     └─ KanjiDataSource
│  ├─ GamificationProvider
│  ├─ QuizProvider
│  │  └─ QuizRepository
│  │     └─ KanjiRepository
│  ├─ ThemeProvider
│  └─ SettingsProvider
└─ MaterialApp
   ├─ MainNavigationScreen
   │  ├─ HomeScreen
   │  │  ├─ XpProgressBar (KanjiProvider, GamificationProvider)
   │  │  └─ MissionsList (SettingsProvider)
   │  ├─ KanjiHomeScreen
   │  ├─ LearnScreen (KanjiProvider)
   │  │  └─ KanjiCard (KanjiProvider, GamificationProvider)
   │  ├─ QuizScreen (QuizProvider, GamificationProvider)
   │  │  └─ QuizQuestionWidget
   │  ├─ ProgressScreen (KanjiProvider, GamificationProvider)
   │  │  ├─ ProgressCharts
   │  │  └─ AchievementBadge (GamificationProvider)
   │  └─ SettingsScreen (ThemeProvider, SettingsProvider)
   └─ Theme (AppTheme)
```

---

## Deployment Checklist

- [ ] Update version in `pubspec.yaml`
- [ ] Update `README.md` with feature list
- [ ] Run `flutter analyze` - no errors
- [ ] Run `flutter test` - all tests pass
- [ ] Build APK: `flutter build apk --release`
- [ ] Build iOS: `flutter build ios --release`
- [ ] Test on real device (not just emulator)
- [ ] Get app signed (Android/iOS)
- [ ] Submit to stores

---

**Last Updated**: May 8, 2026  
**Framework**: Flutter 3.11.4+  
**Architecture**: Clean Architecture + Provider Pattern  
**Status**: Production Ready
