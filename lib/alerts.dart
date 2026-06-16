import 'package:flutter/material.dart';

class NoiseEvent {
  final String message;
  final double db;
  final DateTime time;
  final EventType type;

  NoiseEvent({
    required this.message,
    required this.db,
    required this.time,
    required this.type,
  });
}

enum EventType { spike, warning, calibration }

class Alerts extends StatefulWidget {
  const Alerts({super.key});

  @override
  State<Alerts> createState() => _AlertsState();
}

class _AlertsState extends State<Alerts> {
  // 📟 Single machine event log
  final List<NoiseEvent> events = [
    NoiseEvent(
      message: "Noise spike detected",
      db: 87,
      time: DateTime.now().subtract(const Duration(minutes: 3)),
      type: EventType.spike,
    ),
    NoiseEvent(
      message: "Moderate noise level",
      db: 65,
      time: DateTime.now().subtract(const Duration(minutes: 25)),
      type: EventType.warning,
    ),
    NoiseEvent(
      message: "Device calibrated",
      db: 42,
      time: DateTime.now().subtract(const Duration(hours: 1)),
      type: EventType.calibration,
    ),
  ];

  Color getColor(EventType type, double db) {
    switch (type) {
      case EventType.calibration:
        return Colors.blue;
      case EventType.spike:
        return Colors.red;
      case EventType.warning:
        return Colors.orange;
    }
  }

  IconData getIcon(EventType type) {
    switch (type) {
      case EventType.calibration:
        return Icons.tune;
      case EventType.spike:
        return Icons.warning;
      case EventType.warning:
        return Icons.volume_up;
    }
  }

  String formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Device Noise Log"), centerTitle: true),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: getColor(event.type, event.db),
                child: Icon(getIcon(event.type), color: Colors.white),
              ),

              title: Text(
                event.message,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text("Level: ${event.db.toStringAsFixed(1)} dB"),
                  Text("Time: ${formatTime(event.time)}"),
                ],
              ),

              trailing: Text(
                "${event.db.toStringAsFixed(0)} dB",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}
