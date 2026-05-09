import 'package:flutter/material.dart';
import 'package:jap_n5_learn/screens/kanji/learn_screen.dart';
import 'package:jap_n5_learn/screens/kanji/quiz_screen.dart';
import 'package:jap_n5_learn/screens/kanji/study_plan_screen.dart';
import 'package:jap_n5_learn/screens/kanji/handwriting_screen.dart';
import 'package:jap_n5_learn/models/quiz_model.dart';

/// Kanji module home screen with main learning options
class KanjiHomeScreen extends StatelessWidget {
  const KanjiHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanji Learning'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose your learning path',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Learn Option
            _LearningOptionCard(
              title: 'Learn Kanji',
              description: 'Study new kanji with audio and examples',
              icon: Icons.school,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LearnScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            // Quiz Option
            _LearningOptionCard(
              title: 'Take Quiz',
              description: 'Test your knowledge with different quiz types',
              icon: Icons.quiz,
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const QuizScreen(quizType: QuizType.mixed),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            // Study Plan Option
            _LearningOptionCard(
              title: 'Study Plan',
              description: 'Follow the 5-week N5 study schedule',
              icon: Icons.calendar_month,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudyPlanScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            // Handwriting Option
            _LearningOptionCard(
              title: 'Handwriting Practice',
              description: 'Practice writing kanji by hand',
              icon: Icons.edit,
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HandwritingScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable learning option card
class _LearningOptionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _LearningOptionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(description),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
