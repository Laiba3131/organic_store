import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the notification message passed from the navigator
    final RemoteMessage? message = ModalRoute.of(context)!.settings.arguments as RemoteMessage?;

    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Details'),
      ),
      body: message != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.notification?.title ?? 'No Title',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  message.notification?.body ?? 'No Body',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Text(
                  'Data: ${message.data}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            )
          : Center(
              child: Text('No notification data available'),
            ),
    );
  }
}
