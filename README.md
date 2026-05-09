# JLPT N5 Kanji Learner (Flutter)

Offline-first Flutter app to study **JLPT N5 kanji** with learning cards, quizzes, handwriting practice, and progress tracking.

---

## 🚀 Quick Start

```bash
cd c:\Flutterdev\flutter_jap_test\jap_n5_learn
flutter pub get
flutter run
```

The app opens with a **5-tab** navigation:

- **Home** – XP, streaks, overview
- **Kanji** – Learn, Study Plan, Handwriting, Quiz entry
- **Quiz** – Quiz selection and results
- **Progress** – Analytics & weak kanji
- **Settings** – Theme and data management

---

## 🎯 Features

### Core Learning

- **Learn Mode**: Study kanji by **week/day** (500 kanji dataset)
- **Study Plan**: 5-week curriculum with review scheduling
- **Handwriting Practice**: Canvas-based writing practice
- **Audio (TTS)**: Text-to-speech pronunciation

### Quiz System

- 4 quiz types: **Meaning**, **Reading**, **Writing**, **Mixed**
- Immediate feedback + quiz summary
- Weak kanji are tracked automatically

### Gamification

- **XP** rewards for learning, quizzes, and daily missions
- **Leveling** at XP thresholds (with level-up celebration)
- **Coins** and **Achievements**
- **Daily streaks**

### Progress Tracking + Persistence

- Stats dashboard (totals, streaks, XP/level)
- Weak kanji list + accuracy tracking
- Data saved locally via **SharedPreferences** (no login required)

---

## 📚 Documentation

- **QUICK_START.md** – 60-second setup + first-time user walkthrough
- **IMPLEMENTATION_GUIDE.md** – architecture + feature integration details
- **VALIDATION_CHECKLIST.md** – validation/status checklist
- **TROUBLESHOOTING.md** – common issues + fixes

---

## 🧱 Project Structure (High Level)

- `lib/config/` – constants + theming
- `lib/data/` – dataset, repositories
- `lib/models/` – data models
- `lib/providers/` – state management (Provider)
- `lib/screens/` – UI screens (tabs/modules)
- `lib/widgets/` – reusable UI components
- `lib/services/` – TTS + handwriting services
- `lib/utils/` – helpers/extensions

---

## 🐛 Troubleshooting (Fast)

```bash
flutter clean
flutter pub get
flutter run --verbose
```

---

## 📦 Platforms

- **Android**: ready
- **iOS**: ready
- **Web**: ready (`flutter run -d web`)
- **Windows/Linux**: ready (with dependencies)

---

## 📌 Status

- Implementation Date: **May 8, 2026**
- Status: **✅ Production Ready**
