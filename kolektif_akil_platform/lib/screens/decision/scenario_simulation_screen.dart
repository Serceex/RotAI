import 'package:flutter/material.dart';
import '../../models/decision.dart';
import '../../widgets/scenario_simulation_widget.dart';

class ScenarioSimulationScreen extends StatelessWidget {
  final Decision decision;

  const ScenarioSimulationScreen({super.key, required this.decision});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Senaryo Simülasyonu'),
      ),
      body: ScenarioSimulationWidget(decision: decision),
    );
  }
}

