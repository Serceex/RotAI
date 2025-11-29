import 'package:flutter/material.dart';
import '../../models/decision.dart';

class DecisionDuelScreen extends StatelessWidget {
  final Decision decision;

  const DecisionDuelScreen({super.key, required this.decision});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Karar Düellosu'),
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade400,
                Colors.purple.shade400,
              ],
            ),
          ),
          child: Center(
            child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      decision.question,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    if (decision.optionA != null)
                      _DuelOption(
                        option: 'A',
                        text: decision.optionA!,
                        color: Colors.blue,
                      ),
                    const SizedBox(height: 16),
                    const Text('VS', style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 16),
                    if (decision.optionB != null)
                      _DuelOption(
                        option: 'B',
                        text: decision.optionB!,
                        color: Colors.red,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DuelOption extends StatelessWidget {
  final String option;
  final String text;
  final Color color;

  const _DuelOption({
    required this.option,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                option,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

