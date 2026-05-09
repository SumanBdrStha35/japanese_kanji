# 🔧 Troubleshooting & Debugging Guide

## Common Issues & Solutions

### 1. Build Errors on `flutter pub get`

#### Error: "Package not found"

```
Could not find package X in hosted url https://pub.dev
```

**Solution:**

```bash
flutter clean
flutter pub cache clean
flutter pub get
```

#### Error: "Version constraint"

```
version constraint on flutter SDK: >=3.11.4 <4.0.0
```

**Solution:** Update Flutter

```bash
flutter upgrade
flutter --version  # Verify 3.11.4+
```

---

### 2. Runtime Crashes

#### App crashes immediately on launch

**Check:**

1. Console output: `flutter run --verbose`
2. Look for red text indicating the error
3. Common causes:
   - Missing provider initialization in `main.dart`
   - Missing import statement
   - Widget tree error

**Fix:**

```dart
// main.dart should have all 5 providers
return MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => KanjiProvider()),
    ChangeNotifierProvider(create: (_) => GamificationProvider()),
    ChangeNotifierProvider(create: (_) => QuizProvider()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => SettingsProvider()),
  ],
  child: const MyApp(),
);
```

#### "Null safety" error

```
The argument type 'Null' can't be assigned to the parameter type
```

**Solution:** Check for uninitialized variables. Add `late` or provide defaults:

```dart
late String kanji; // Declare late if initialized later
String kanji = ''; // Or provide default value
```

---

### 3. UI Issues

#### Blank screen instead of BottomNavigationBar

**Check:**

- Is `MainNavigationScreen` set as home in `main.dart`?
- Are all imports present in `main_navigation_screen.dart`?

**Fix:**

```dart
// main.dart - should have:
home: MainNavigationScreen(),
```

#### Kanji cards not displaying

**Check:**

- Is `kanji_data.dart` loading properly?
- Are there kanji entries in the dataset?
- Is `KanjiProvider` initialized?

**Debug:**

```dart
// Add to console in learn_screen.dart
print('Kanji count: ${kanjiProvider.unlearned.length}');
print('Selected week: $selectedWeek, day: $selectedDay');
```

#### Dark mode toggle not working

**Check:**

1. Is `ThemeProvider` in `MultiProvider`?
2. Is `Consumer<ThemeProvider>` wrapping `MaterialApp`?

**Fix:**

```dart
// main.dart should have:
return Consumer<ThemeProvider>(
  builder: (_, themeProvider, __) {
    return MaterialApp(
      theme: themeProvider.isDarkMode ? darkTheme : lightTheme,
      // ...
    );
  },
);
```

---

### 4. State Management Issues

#### XP not increasing when marking kanji learned

**Debug steps:**

1. Add print statement in `kanji_provider.dart`:

```dart
void markKanjiLearned(String kanjiId) {
  learnedKanjiIds.add(kanjiId);
  print('Kanji learned: $kanjiId');

  // Get gamification provider
  final gamification = Provider.of<GamificationProvider>(context, listen: false);
  gamification.addXP(10);
  print('XP added: ${gamification.totalXP}');

  saveProgress();
  notifyListeners();
}
```

2. Check console for print statements
3. Verify `GamificationProvider.addXP()` is being called

#### Streak not resetting

**Check:** Is `resetStreakIfNeeded()` being called in `GamificationProvider`?

**Solution:** Ensure it's called in `loadProgress()`:

```dart
Future<void> loadProgress() async {
  resetStreakIfNeeded(); // Add this
  // ... rest of load logic
}
```

#### Progress not saving

**Debug:**

```dart
// In any provider's saveProgress() method:
print('Saving to SharedPreferences...');
await prefs.setString('key', jsonEncode(data));
print('Saved successfully');
```

**Common cause:** Missing `await` or error in JSON encoding

---

### 5. Quiz Issues

#### Quiz not loading questions

**Check:** Is `QuizRepository.generateQuestions()` working?

**Debug:**

```dart
// In quiz_screen.dart
print('Quiz type: $selectedType');
print('Questions generated: ${quizProvider.questions.length}');
```

#### Answers not being registered

**Check:** Is `QuizProvider.selectAnswer()` being called?

**Debug:**

```dart
void selectAnswer(int qIndex, String answer) {
  print('Q$qIndex: Selected answer=$answer');
  questions[qIndex].userAnswer = answer;
  notifyListeners();
}
```

#### Quiz summary showing wrong results

**Check:** Is `isAnswerCorrect()` calculating properly?

```dart
bool isAnswerCorrect(QuizQuestionModel question) {
  final isCorrect = question.userAnswer == question.correctAnswer;
  print('Q${question.id}: Expected=${question.correctAnswer}, Got=${question.userAnswer}, Correct=$isCorrect');
  return isCorrect;
}
```

---

### 6. Data Persistence Issues

#### Data not persisting after app restart

**Check:** Are you calling `saveProgress()` and `loadProgress()`?

**Debug:**

```dart
// In provider's init:
Future<void> loadProgress() async {
  final prefs = await SharedPreferences.getInstance();
  print('SharedPreferences keys: ${prefs.getKeys()}');

  final data = prefs.getString('user_progress');
  print('Loaded data: $data');

  if (data != null) {
    // Parse and restore
  }
}
```

#### SharedPreferences returning null

**Solution:**

```dart
// Provide default values
final data = prefs.getString('key') ?? '{}';
```

#### Data corruption (can't parse JSON)

**Solution:** Add error handling:

```dart
try {
  final data = jsonDecode(prefs.getString('key') ?? '{}');
} catch (e) {
  print('JSON decode error: $e');
  prefs.remove('key'); // Clear corrupted data
}
```

---

### 7. Widget Issues

#### "Cannot find widget" errors in tests

**Solution:** Use `find` with proper matchers:

```dart
find.byType(KanjiCard)
find.byKey(ValueKey('kanji_${kanji.id}'))
find.text('Mark as Learned')
```

#### Confetti not showing on level-up

**Check:** Is `ConfettiController` initialized?

**Debug:**

```dart
// In level_up_dialog.dart
@override
void initState() {
  super.initState();
  _confettiController = ConfettiController(
    duration: const Duration(seconds: 3),
  );
  print('Confetti controller initialized');
  _confettiController.play();
  print('Confetti play triggered');
}
```

#### Charts not rendering

**Check:** Is data being provided to `fl_chart`?

**Debug:**

```dart
print('Data points: ${data.length}');
print('Max value: ${data.map((e) => e.y).reduce((a, b) => a > b ? a : b)}');
```

---

### 8. Performance Issues

#### App is slow/laggy

**Causes:**

- Large widget tree rebuilding unnecessarily
- Provider rebuilding entire screen on single value change
- Too many kanji cards rendering at once

**Solutions:**

1. Use `Consumer` instead of `watch` for fine-grained control:

```dart
// Instead of:
context.watch<KanjiProvider>() // Rebuilds everything

// Use:
Consumer<KanjiProvider>(
  builder: (_, provider, __) {
    return Text(provider.totalLearned.toString()); // Only this rebuilds
  },
)
```

2. Add `const` constructors:

```dart
const KanjiCard(kanji: kanji) // Won't rebuild if parent rebuilds
```

3. Limit quiz/kanji lists with pagination or limited render windows

---

### 9. Android-Specific Issues

#### "Gradle build failed"

```bash
flutter clean
cd android
./gradlew clean  # or gradlew.bat on Windows
cd ..
flutter pub get
flutter run
```

#### "App not installed"

- Make sure emulator is running
- Try different API level
- Check available devices: `flutter devices`

#### Text-to-speech not working on emulator

- TTS requires Google Play Services
- Works on real devices
- Add mock in emulator testing

---

### 10. iOS-Specific Issues

#### "Pod install" fails

```bash
cd ios
rm Podfile.lock
pod repo update
pod install
cd ..
```

#### TTS not working

Add to `ios/Podfile`:

```ruby
pod 'TFLiteSwift'
```

---

## 🔍 Debugging Tools

### Enable Verbose Logging

```bash
flutter run --verbose 2>&1 | tee debug.log
```

### Check Device Logs

```bash
adb logcat | grep flutter
```

### Add Debug Print Statements

```dart
import 'dart:developer' as developer;

developer.log('Debug message', name: 'kanji_provider');
```

### Use DevTools

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

Then open browser to `http://localhost:9100`

### Step Through Code (VS Code Debugging)

1. Set breakpoints (click line number)
2. Run with `flutter run` in debug mode
3. Use VS Code debugging panel to step through

---

## 📋 Verification Checklist

After any changes, verify:

- [ ] `flutter analyze` shows no errors
- [ ] `flutter pub get` completes successfully
- [ ] `flutter run` launches without crashes
- [ ] All 5 tabs clickable and navigate
- [ ] Kanji cards display with content
- [ ] Marking kanji learned increases XP
- [ ] Level-up at 100 XP shows dialog
- [ ] Quiz loads and completes
- [ ] Progress saves and persists
- [ ] Dark mode toggles
- [ ] No console errors or warnings

---

## 🆘 Still Having Issues?

### Step 1: Gather Information

```bash
flutter doctor -v > flutter_info.txt
flutter run --verbose > run_output.txt
```

### Step 2: Check Specific File

Look for red underlines in VS Code. Common files with issues:

- `main.dart` - Provider setup
- `kanji_provider.dart` - Data loading
- `main_navigation_screen.dart` - Navigation

### Step 3: Minimal Reproduction

Try these minimal steps:

1. New Flutter project: `flutter create test_app`
2. Copy just `main.dart` refactor
3. Does it work? Yes → Gradually add other files
4. Does it work? No → Issue is in core setup

### Step 4: Review Implementation

Compare your code with:

- `lib/main.dart` - Should have MultiProvider with 5 providers
- `pubspec.yaml` - Should have all dependencies
- Any file with red underlines - Check imports

---

## 📞 Quick Reference

| Issue             | Likely Cause        | Solution                                      |
| ----------------- | ------------------- | --------------------------------------------- |
| Blank screen      | Navigation not set  | Set `MainNavigationScreen` as home            |
| App won't start   | Missing provider    | Add to `MultiProvider` in main.dart           |
| XP not increasing | Provider not called | Call `gamificationProvider.addXP()`           |
| Data not saving   | No persist call     | Call `saveProgress()` after changes           |
| Dark mode broken  | No consumer         | Wrap MaterialApp in `Consumer<ThemeProvider>` |
| Kanji not loading | Empty dataset       | Check `kanji_data.dart` has entries           |
| Quiz crashes      | No questions        | Check `QuizRepository.generate*()`            |
| Charts blank      | No data             | Verify data source in repository              |

---

**Last Updated**: 2026-05-08  
**Status**: Production Troubleshooting Guide
