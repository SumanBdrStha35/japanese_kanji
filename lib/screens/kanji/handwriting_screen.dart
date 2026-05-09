import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

/// Handwriting practice screen for kanji writing practice
class HandwritingScreen extends StatefulWidget {
  const HandwritingScreen({super.key});

  @override
  State<HandwritingScreen> createState() => _HandwritingScreenState();
}

class _HandwritingScreenState extends State<HandwritingScreen> {
  late SignatureController _signatureController;
  final String _targetKanji = '一';
  double _accuracy = 0;
  bool _showFeedback = false;

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 5,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  void _checkHandwriting() {
    // Mock handwriting recognition
    // In production, this would use ML Kit or TensorFlow Lite
    setState(() {
      _accuracy = 75 + (DateTime.now().millisecond % 26).toDouble();
      _showFeedback = true;
    });
  }

  void _clearCanvas() {
    _signatureController.clear();
    setState(() {
      _showFeedback = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Handwriting Practice'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Target Kanji Display
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Write this kanji:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Container(
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
                      _targetKanji,
                      style: const TextStyle(fontSize: 80),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Drawing Canvas
          Expanded(
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Signature(
                controller: _signatureController,
                backgroundColor: Colors.grey.withOpacity(0.1),
              ),
            ),
          ),

          // Feedback if shown
          if (_showFeedback)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _accuracy > 70
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                border: Border.all(
                  color: _accuracy > 70 ? Colors.green : Colors.orange,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Accuracy',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_accuracy.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: _accuracy / 100, minHeight: 8),
                ],
              ),
            ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearCanvas,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _checkHandwriting,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Check'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
