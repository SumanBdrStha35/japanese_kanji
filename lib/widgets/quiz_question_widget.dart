import 'package:flutter/material.dart';
import 'package:jap_n5_learn/models/quiz_model.dart';

/// Widget for displaying a quiz question with 4 multiple choice options
class QuizQuestionWidget extends StatefulWidget {
  final QuizQuestionModel question;
  final Function(String) onAnswerSelected;
  final String? selectedAnswer;
  final bool isAnswered;

  const QuizQuestionWidget({
    super.key,
    required this.question,
    required this.onAnswerSelected,
    this.selectedAnswer,
    this.isAnswered = false,
  });

  @override
  State<QuizQuestionWidget> createState() => _QuizQuestionWidgetState();
}

class _QuizQuestionWidgetState extends State<QuizQuestionWidget> {
  late String? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _selectedAnswer = widget.selectedAnswer;
  }

  @override
  void didUpdateWidget(QuizQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _selectedAnswer = null;
    } else {
      _selectedAnswer = widget.selectedAnswer;
    }
  }

  bool _isCorrectAnswer(String option) {
    return option == widget.question.correctAnswer;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question title
          Text('Question', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          Text(
            widget.question.question,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),

          // Kanji (for writing recall questions)
          if (widget.question.type == QuizType.writingRecall)
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    widget.question.kanji,
                    style: const TextStyle(fontSize: 64),
                  ),
                ),
              ),
            ),
          if (widget.question.type == QuizType.writingRecall)
            const SizedBox(height: 24),

          // Options
          Text(
            'Choose the correct answer:',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 12),
          ...widget.question.options.map((option) {
            final isSelected = _selectedAnswer == option;
            final isCorrect = _isCorrectAnswer(option);
            final showResult = widget.isAnswered && isSelected;

            Color backgroundColor = Colors.transparent;
            Color borderColor = Theme.of(context).colorScheme.outline;

            if (showResult) {
              if (isCorrect) {
                backgroundColor = Colors.green.withOpacity(0.1);
                borderColor = Colors.green;
              } else {
                backgroundColor = Colors.red.withOpacity(0.1);
                borderColor = Colors.red;
              }
            } else if (widget.isAnswered && isCorrect) {
              backgroundColor = Colors.green.withOpacity(0.1);
              borderColor = Colors.green;
            }

            return GestureDetector(
              onTap: widget.isAnswered
                  ? null
                  : () {
                      setState(() {
                        _selectedAnswer = option;
                      });
                      widget.onAnswerSelected(option);
                    },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border.all(color: borderColor, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    if (showResult)
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
