import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';

class StepTrackerScreen extends StatefulWidget {
  const StepTrackerScreen({super.key});

  @override
  State<StepTrackerScreen> createState() => _StepTrackerScreenState();
}

class _StepTrackerScreenState extends State<StepTrackerScreen> {
  late Stream<StepCount> _stepCountStream;
  int _steps = 0;

  @override
  void initState() {
    super.initState();
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);
  }

  void onStepCount(StepCount event) {
    setState(() => _steps = event.steps);
  }

  void onStepCountError(error) {
    setState(() => _steps = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Step Tracker')),
      body: Center(
        child: Text('Steps: $_steps', style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
