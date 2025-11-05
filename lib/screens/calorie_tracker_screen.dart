import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CalorieTrackerScreen extends StatefulWidget {
  const CalorieTrackerScreen({super.key});

  @override
  State<CalorieTrackerScreen> createState() => _CalorieTrackerScreenState();
}

class _CalorieTrackerScreenState extends State<CalorieTrackerScreen> {
  final supabase = Supabase.instance.client;
  final _quantityController = TextEditingController();

  String? _selectedMeal;
  String? _selectedUnit;

  List<Map<String, dynamic>> _loggedMeals = [];
  double _totalCalories = 0;

  final Map<String, Map<String, double>> calorieReference = {
    'Chapati': {'piece': 150},
    'Rice': {'cup': 216, 'gram': 1.3},
    'Chicken': {'gram': 1.65},
    'Ugali': {'gram': 3.6},
    'Beans': {'cup': 240, 'gram': 1.2},
    'Fish': {'gram': 2.0},
    'Njahi': {'cup': 280, 'gram': 1.4},
    'Ndengu': {'cup': 230},
    'Kamande (Lentils)': {'cup': 230},
    'Spaghetti': {'cup': 220},
    'Indomie': {'packet': 350},
    'Bread': {'slice': 80},
    'Milk Tea': {'cup': 120},
    'Strong Tea': {'cup': 5},
    'Githeri': {'cup': 280},
    'Pizza': {'slice': 285},
    'Burger': {'piece': 300},
    'Cabbage': {'cup': 22},
    'Sukumawiki': {'cup': 35},
    'Managu': {'cup': 40},
    'Porridge': {'cup': 150},
    'Sweet Potatoes': {'piece': 100},
    'Peas': {'cup': 160},
    'Minced Meat': {'gram': 2.5},
    'Boiled Irish Potatoes': {'piece': 130},
    'Roasted Irish Potatoes': {'piece': 150},
    'Beef': {'gram': 2.5},
    'Goat Meat': {'gram': 2.94},
    'Mutton': {'gram': 2.94},
    'Pork': {'gram': 2.7},
    'Matoke': {'cup': 115},
    'Arrowroots': {'piece': 118},
    'Pumpkin': {'cup': 49},
    'Cassava': {'cup': 160},
    'Avocado': {'piece': 240},
    'Fried Eggs': {'piece': 90},
    'Boiled Eggs': {'piece': 78},
    'Whole Milk': {'cup': 150},
    'Plain Yogurt': {'cup': 150},
    'Mandazi': {'piece': 190},
    'Samosa': {'piece': 250},
    'Sausage': {'piece': 150},
    'Boiled Maize': {'cob': 180},
    'Roasted Maize': {'cob': 220},
    'Fried Tilapia': {'gram': 2.4},
    'Fried Omena': {'cup': 180},
    'Fried Cabbage': {'cup': 60},
    'Fried Sukumawiki': {'cup': 80},


  };

  Future<void> _logMeal() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null || _selectedMeal == null || _selectedUnit == null) return;

    final quantity = double.tryParse(_quantityController.text.trim()) ?? 0;
    final caloriesPerUnit = calorieReference[_selectedMeal!]?[_selectedUnit!] ?? 0;
    final total = quantity * caloriesPerUnit;
    final today = DateTime.now().toIso8601String().substring(0, 10);

    await supabase.from('calorie_logs').insert({
      'user_id': userId,
      'date': today,
      'meal': _selectedMeal,
      'quantity': quantity,
      'calories': total,
    });

    setState(() {
      _loggedMeals.add({
        'meal': _selectedMeal,
        'unit': _selectedUnit,
        'quantity': quantity,
        'calories': total,
      });
      _totalCalories += total;
      _selectedMeal = null;
      _selectedUnit = null;
      _quantityController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final units = _selectedMeal != null ? calorieReference[_selectedMeal!]!.keys.toList() : [];

    return Scaffold(
      appBar: AppBar(title: const Text('Calorie Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedMeal,
              hint: const Text('Select Meal'),
              items: calorieReference.keys.map((meal) {
                return DropdownMenuItem(value: meal, child: Text(meal));
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedMeal = val;
                  _selectedUnit = null;
                });
              },
            ),
            if (units.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _selectedUnit,
                hint: const Text('Select Unit'),
                items: units.map((unit) {
                  return DropdownMenuItem(value: unit, child: Text(unit));
                }).toList(),
                onChanged: (val) => setState(() => _selectedUnit = val),
              ),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _logMeal,
              child: const Text('Log Meal'),
            ),
            const SizedBox(height: 20),
            Text(
              'Total Calories Today: ${_totalCalories.toStringAsFixed(0)} kcal',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _loggedMeals.length,
                itemBuilder: (context, index) {
                  final meal = _loggedMeals[index];
                  return ListTile(
                    title: Text('${meal['meal']} × ${meal['quantity']} ${meal['unit']}'),
                    subtitle: Text('${meal['calories'].toStringAsFixed(0)} kcal'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

