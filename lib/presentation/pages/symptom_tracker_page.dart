import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SymptomTrackerPage extends StatefulWidget {
  const SymptomTrackerPage({super.key});

  @override
  State<SymptomTrackerPage> createState() => _SymptomTrackerPageState();
}

class _SymptomTrackerPageState extends State<SymptomTrackerPage> {
  final List<String> _commonSymptoms = [
    'Nausea',
    'Headache',
    'Fatigue',
    'Back Pain',
    'Swelling',
    'Heartburn',
    'Insomnia',
    'Cramps',
  ];

  List<SymptomLog> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('symptom_logs');
    if (savedData != null) {
      final List<dynamic> decoded = jsonDecode(savedData);
      setState(() {
        _logs = decoded.map((e) => SymptomLog.fromJson(e)).toList();
        _logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      });
    }
  }

  Future<void> _saveLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _logs.map((e) => e.toJson()).toList();
    await prefs.setString('symptom_logs', jsonEncode(data));
  }

  void _addLog(String name, int severity) {
    setState(() {
      _logs.insert(0, SymptomLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        severity: severity,
        timestamp: DateTime.now(),
      ));
    });
    _saveLogs();
  }

  void _showAddSymptomDialog() {
    String selectedSymptom = _commonSymptoms[0];
    int selectedSeverity = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Log Symptom'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedSymptom,
                items: _commonSymptoms.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setDialogState(() => selectedSymptom = val!),
                decoration: const InputDecoration(labelText: 'Symptom'),
              ),
              const SizedBox(height: 20),
              const Text('Severity'),
              Slider(
                value: selectedSeverity.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: selectedSeverity.toString(),
                onChanged: (val) => setDialogState(() => selectedSeverity = val.toInt()),
              ),
              Text(
                selectedSeverity == 1 ? 'Mild' : selectedSeverity == 5 ? 'Severe' : 'Moderate',
                style: TextStyle(color: _getSeverityColor(selectedSeverity)),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                _addLog(selectedSymptom, selectedSeverity);
                Navigator.pop(context);
              },
              child: const Text('Log'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(int severity) {
    if (severity <= 2) return Colors.green;
    if (severity <= 3) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptom Tracker'),
      ),
      body: _logs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.healing_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No symptoms logged yet', style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 12,
                      decoration: BoxDecoration(
                        color: _getSeverityColor(log.severity),
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                      ),
                    ),
                    title: Text(log.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('MMM dd, yyyy • hh:mm a').format(log.timestamp)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Severity: ${log.severity}', style: TextStyle(color: _getSeverityColor(log.severity), fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () {
                            setState(() => _logs.removeAt(index));
                            _saveLogs();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSymptomDialog,
        icon: const Icon(Icons.add),
        label: const Text('Log Symptom'),
      ),
    );
  }
}

class SymptomLog {
  final String id;
  final String name;
  final int severity;
  final DateTime timestamp;

  SymptomLog({required this.id, required this.name, required this.severity, required this.timestamp});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'severity': severity,
    'timestamp': timestamp.toIso8601String(),
  };

  factory SymptomLog.fromJson(Map<String, dynamic> json) => SymptomLog(
    id: json['id'],
    name: json['name'],
    severity: json['severity'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}
