import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/services/notification_service.dart';

class NotificationTestButton extends StatefulWidget {
  const NotificationTestButton({super.key});

  @override
  State<NotificationTestButton> createState() =>
      _NotificationTestButtonState();
}

class _NotificationTestButtonState extends State<NotificationTestButton> {
  int _seconds = 0;
  Timer? _timer;

  void _startTest() async {
    if (_seconds > 0) return;

    final scheduledTime = DateTime.now().add(const Duration(seconds: 10));

    // Bildirişi meýilleşdirýäris
    await NotificationService().scheduleReminder(
      sessionId: 1000, // Test üçin ýörite ID
      title: "Test Bildiriş",
      body: "Bu 10 sekuntdan soň gelmeli barlaýyş habarydyr!",
      scheduledTime: scheduledTime,
    );

    if (!mounted) return;
    setState(() {
      _seconds = 10;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 1) {
        if (mounted) {
          setState(() {
            _seconds--;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _seconds = 0;
          });
        }
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _startTest,
          icon: const Icon(Icons.notifications_active),
          label: Text(
            _seconds > 0
                ? "Bildirişe galdy: $_seconds sek"
                : "Bildirişi barla (10 sek)",
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _seconds > 0 ? Colors.orange.shade100 : null,
          ),
        ),
      ),
    );
  }
}
