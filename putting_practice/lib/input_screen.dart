import 'package:flutter/material.dart';
import 'database_helper.dart';

enum DistanceLabel {
  onem('1 m', 1),
  twom('2 m', 2),
  threem('3 m', 3);

  final String label;
  final int value;

  const DistanceLabel(this.label, this.value);
}

class InputScreen extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  DistanceLabel? _selectedDistance;
  int _putts = 5;
  int? _successfulPutts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Input Putting Results')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<DistanceLabel>(
                      decoration: const InputDecoration(labelText: 'Distance'),
                      value: _selectedDistance,
                      onChanged: (DistanceLabel? newValue) {
                        setState(() {
                          _selectedDistance = newValue!;
                        });
                      },
                      items: DistanceLabel.values.map((DistanceLabel distance) {
                        return DropdownMenuItem<DistanceLabel>(
                          value: distance,
                          child: Text(distance.label),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a distance';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Putts'),
                      value: _putts,
                      onChanged: (int? newValue) {
                        setState(() {
                          _putts = newValue!;
                        });
                      },
                      items: [5, 6, 7, 8, 9, 10].map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Successful'),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => _successfulPutts = int.parse(value!),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the number of successful putts';
                        }
                        int? successfulPutts = int.tryParse(value);
                        if (successfulPutts == null) {
                          return 'Please enter a valid number';
                        }
                        if (successfulPutts < 0) {
                          return 'Number of successful putts cannot be negative';
                        }
                        if (successfulPutts > _putts) {
                          return 'Number of successful putts cannot be more than number of putts';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      double successRate = (_successfulPutts! / _putts) * 100;
                      PuttingResult newResult = PuttingResult(
                        distance: _selectedDistance!.value,
                        successRate: successRate,
                        dateOfPractice: DateTime.now().toIso8601String(),
                      );
                      await DatabaseHelper().insertResult(newResult);

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Result saved!')),
                      );
                    }
                  },
                  child: const Text('Save Result'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
