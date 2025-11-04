import 'package:flutter/material.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  _TrackerScreenState createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  double height = 0, weight = 0, bmi = 0;
  int systolic = 0, diastolic = 0;
  String bmiCategory = '', bpCategory = '';

  void calculateBMI() {
    if (height > 0 && weight > 0) {
      setState(() {
        bmi = weight / ((height / 100) * (height / 100));
        if (bmi < 18.5) {
          bmiCategory = 'Underweight';
        } else if (bmi < 25) {
          bmiCategory = 'Normal weight';
        } else if (bmi < 30) {
          bmiCategory = 'Overweight';
        } else {
          bmiCategory = 'Obese';
        }
      });
    }
  }

  void analyzeBloodPressure() {
    if (systolic > 0 && diastolic > 0) {
      setState(() {
        if (systolic < 90 || diastolic < 60) {
          bpCategory = 'Low Blood Pressure';
        } else if (systolic < 120 && diastolic < 80) {
          bpCategory = 'Normal';
        } else if (systolic < 130 && diastolic < 80) {
          bpCategory = 'Elevated';
        } else if ((systolic < 140) || (diastolic < 90)) {
          bpCategory = 'High Blood Pressure (Stage 1)';
        } else if ((systolic < 180) || (diastolic < 120)) {
          bpCategory = 'High Blood Pressure (Stage 2)';
        } else {
          bpCategory = 'Hypertensive Crisis — Seek medical attention';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
                onChanged: (val) => height = double.tryParse(val) ?? 0,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                onChanged: (val) => weight = double.tryParse(val) ?? 0,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: calculateBMI,
                child: const Text('Calculate BMI'),
              ),
              const SizedBox(height: 16),
              if (bmi > 0)
                Column(
                  children: [
                    Text(
                      'Your BMI: ${bmi.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Category: $bmiCategory',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              const Divider(height: 32),
              TextField(
                decoration: const InputDecoration(labelText: 'Systolic (top number)'),
                keyboardType: TextInputType.number,
                onChanged: (val) => systolic = int.tryParse(val) ?? 0,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Diastolic (bottom number)'),
                keyboardType: TextInputType.number,
                onChanged: (val) => diastolic = int.tryParse(val) ?? 0,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: analyzeBloodPressure,
                child: const Text('Analyze Blood Pressure'),
              ),
              const SizedBox(height: 16),
              if (bpCategory.isNotEmpty)
                Column(
                  children: [
                    Text(
                      'Blood Pressure Category:',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bpCategory,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.redAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

