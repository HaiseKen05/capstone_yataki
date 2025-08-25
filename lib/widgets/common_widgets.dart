import 'package:flutter/material.dart';

/// A reusable loading spinner widget
class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          if (message != null) ...[
            SizedBox(height: 12),
            Text(message!, style: TextStyle(fontSize: 16)),
          ],
        ],
      ),
    );
  }
}

/// A reusable error message widget
class ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorMessage({required this.message, this.onRetry, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 48),
            SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh),
                label: Text("Retry"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A reusable card for displaying sensor logs
class SensorLogCard extends StatelessWidget {
  final Map<String, dynamic> sensor;

  const SensorLogCard({required this.sensor, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.memory),
        title: Text("Log ID: ${sensor['id']}"),
        subtitle: Text(
          "Steps: ${sensor['steps']} | "
          "V: ${sensor['voltage']}V | "
          "I: ${sensor['current']}A",
        ),
        trailing: Text(sensor['datetime'] ?? ""),
      ),
    );
  }
}
