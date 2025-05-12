import 'package:flutter/material.dart';

void main() => runApp(const WaterReminderApp());

class WaterReminderApp extends StatelessWidget {
  const WaterReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue[50],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shadowColor: Colors.blue.withOpacity(0.5),
            elevation: 5,
          ),
        ),
      ),
      home: const WaterReminderPage(),
    );
  }
}

class WaterReminderPage extends StatefulWidget {
  const WaterReminderPage({super.key});

  @override
  _WaterReminderPageState createState() => _WaterReminderPageState();
}

class _WaterReminderPageState extends State<WaterReminderPage> {
  final List<Map<String, dynamic>> _reminders = [];
  final TextEditingController _amountController = TextEditingController();
  double _dailyGoal = 2000;
  final List<double> _goalOptions = [1000, 1500, 2000, 2500, 3000];
  TimeOfDay _selectedTime = TimeOfDay.now();

  void _addReminder() {
    if (_amountController.text.isEmpty ||
        double.tryParse(_amountController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Iltimos, to\'g\'ri suv miqdorini kiriting!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final reminderTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    setState(() {
      _reminders.add({
        'time': reminderTime,
        'amount': double.parse(_amountController.text),
      });
      _amountController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Eslatma qo\'shildi!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  double _getTotalWater() {
    return _reminders.fold(0, (sum, item) => sum + item['amount']);
  }

  double _getTodayWater() {
    final today = DateTime.now();
    return _reminders
        .where((r) {
          final reminderDate = r['time'] as DateTime;
          return reminderDate.year == today.year &&
              reminderDate.month == today.month &&
              reminderDate.day == today.day;
        })
        .fold(0, (sum, item) => sum + item['amount']);
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return Colors.green;
    if (progress >= 0.7) return Colors.lightGreen;
    if (progress >= 0.4) return Colors.orange;
    return Colors.red;
  }

  String _getProgressText(double today, double goal) {
    if (today >= goal) {
      return 'Normadan ${(today - goal).toStringAsFixed(0)} ml ortiqcha';
    } else {
      return 'Normani bajarish uchun   ${(goal - today).toStringAsFixed(0)} ml ichish kerak';
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayWater = _getTodayWater();
    final progress = (todayWater / _dailyGoal).clamp(0.0, 1.0);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suv Ichish Eslatmasi'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightBlue, Colors.cyan],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        DropdownButton<double>(
                          value: _dailyGoal,
                          onChanged: (value) {
                            setState(() {
                              _dailyGoal = value!;
                            });
                          },
                          items: _goalOptions
                              .map((goal) => DropdownMenuItem(
                                    value: goal,
                                    child: Text('$goal ml'),
                                  ))
                              .toList(),
                          isExpanded: true,
                          hint: const Text('Kunlik maqsad'),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _amountController,
                          decoration: const InputDecoration(
                            labelText: 'Suv miqdori (ml)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.water_drop),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _selectTime(context),
                          child: Text(
                            'Vaqt: ${_selectedTime.format(context)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: CircularProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey[300],
                                color: _getProgressColor(progress),
                                strokeWidth: 12,
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  '${todayWater.toStringAsFixed(0)} ml',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '/ ${_dailyGoal.toStringAsFixed(0)} ml',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _getProgressText(todayWater, _dailyGoal),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addReminder,
                  child: const Text(
                    'Eslatma qo\'shish',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Statistika',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Umumiy suv: ${_getTotalWater().toStringAsFixed(0)} ml',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Bugungi suv: ${todayWater.toStringAsFixed(0)} ml',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Eslatmalar tarixi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 300,
                  child: _reminders.isEmpty
                      ? const Center(
                          child: Text('Hozircha eslatmalar mavjud emas'),
                        )
                      : ListView.builder(
                          itemCount: _reminders.length,
                          itemBuilder: (context, index) {
                            final reminder = _reminders[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              color: Colors.white.withOpacity(0.85),
                              child: ListTile(
                                leading: const Icon(Icons.water_drop,
                                    color: Colors.blue),
                                title: Text(
                                  '${reminder['amount'].toStringAsFixed(0)} ml',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Vaqt: ${TimeOfDay.fromDateTime(reminder['time']).format(context)}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _reminders.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}