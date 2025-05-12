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
            // ignore: deprecated_member_use
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
  // ignore: library_private_types_in_public_api
  _WaterReminderPageState createState() => _WaterReminderPageState();
}

class _WaterReminderPageState extends State<WaterReminderPage> {
  final List<Map<String, dynamic>> _reminders = [];
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _goalController = TextEditingController(
    text: '2000',
  );
  double _dailyGoal = 2000;
  final List<String> _goalOptions = ['1000', '1500', '2000', '2500', '3000'];
  DateTime _selectedTime = DateTime.now();

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

    setState(() {
      _reminders.add({
        'time': _selectedTime,
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

  void _updateGoal() {
    if (_goalController.text.isNotEmpty &&
        double.tryParse(_goalController.text) != null) {
      setState(() {
        _dailyGoal = double.parse(_goalController.text);
      });
    }
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
    if (progress >= 0.8) return Colors.green;
    if (progress >= 0.5) return Colors.yellow;
    return Colors.red;
  }

  Future<void> _selectTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        // ignore: use_build_context_synchronously
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedTime),
      );
      if (time != null) {
        setState(() {
          _selectedTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_getTodayWater() / _dailyGoal).clamp(0.0, 1.0);
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
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        DropdownButton<String>(
                          value: _goalController.text,
                          onChanged: (value) {
                            setState(() {
                              _goalController.text = value!;
                              _updateGoal();
                            });
                          },
                          items:
                              _goalOptions
                                  .map(
                                    (goal) => DropdownMenuItem(
                                      value: goal,
                                      child: Text('$goal ml'),
                                    ),
                                  )
                                  .toList(),
                          isExpanded: true,
                          hint: const Text('Kunlik maqsad'),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _amountController,
                          decoration: const InputDecoration(
                            labelText: 'Suv miqdori (ml)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => _selectTime(context),
                          child: Text(
                            'Vaqt: ${_selectedTime.toString().substring(0, 16)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 20),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          child: CircularProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[300],
                            color: _getProgressColor(progress),
                            strokeWidth: 10,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Bugun: ${_getTodayWater().toStringAsFixed(0)} / $_dailyGoal ml',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  // ignore: deprecated_member_use
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
                        ),
                        Text(
                          'Bugungi suv: ${_getTodayWater().toStringAsFixed(0)} ml',
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
                SizedBox(
                  height: 300, // Jurnal uchun cheklangan balandlik
                  child: ListView.builder(
                    itemCount: _reminders.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.85),
                        child: ListTile(
                          title: Text(
                            '${_reminders[index]['amount'].toStringAsFixed(0)} ml',
                          ),
                          subtitle: Text(
                            'Vaqt: ${_reminders[index]['time'].toString().substring(0, 16)}',
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
