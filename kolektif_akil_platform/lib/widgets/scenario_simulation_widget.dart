import 'package:flutter/material.dart';
import '../models/decision.dart';
import '../models/scenario.dart';

class ScenarioSimulationWidget extends StatefulWidget {
  final Decision decision;

  const ScenarioSimulationWidget({super.key, required this.decision});

  @override
  State<ScenarioSimulationWidget> createState() =>
      _ScenarioSimulationWidgetState();
}

class _ScenarioSimulationWidgetState extends State<ScenarioSimulationWidget> {
  String? _selectedOption;
  Scenario? _scenario;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.decision.question,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (widget.decision.optionA != null)
            _ScenarioOption(
              option: 'A',
              text: widget.decision.optionA!,
              isSelected: _selectedOption == 'A',
              onTap: () => setState(() => _selectedOption = 'A'),
            ),
          const SizedBox(height: 16),
          if (widget.decision.optionB != null)
            _ScenarioOption(
              option: 'B',
              text: widget.decision.optionB!,
              isSelected: _selectedOption == 'B',
              onTap: () => setState(() => _selectedOption = 'B'),
            ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _selectedOption != null ? _runSimulation : null,
            child: const Text('Simülasyonu Çalıştır'),
          ),
          if (_scenario != null) ...[
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Simülasyon Sonucu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(_scenario!.description),
                    if (_scenario!.result != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _scenario!.result!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _runSimulation() {
    if (_selectedOption == null) return;

    // Senaryo oluştur (basitleştirilmiş)
    setState(() {
      _scenario = Scenario(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        decisionId: widget.decision.id,
        title: 'Simülasyon: ${_selectedOption == 'A' ? widget.decision.optionA : widget.decision.optionB}',
        description: 'Bu seçeneğin olası sonuçları simüle ediliyor...',
        selectedOption: _selectedOption!,
        createdAt: DateTime.now(),
        result: 'Simülasyon tamamlandı. Bu seçeneğin sonuçlarını analiz edin.',
      );
    });
  }
}

class _ScenarioOption extends StatelessWidget {
  final String option;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _ScenarioOption({
    required this.option,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
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
        ),
      ),
    );
  }
}

