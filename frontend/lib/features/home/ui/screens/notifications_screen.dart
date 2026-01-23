import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        "title": "Booking Confirmed! ✅",
        "body": "Your slot at Royal Badminton Arena is confirmed for 5:00 PM today.",
        "time": "2 hours ago",
        "isNew": true,
      },
      {
        "title": "New Tournament Alert 🏆",
        "body": "Registration for the Summer Slam is now open. Join your team!",
        "time": "1 day ago",
        "isNew": false,
      },
      {
        "title": "Payment Successful",
        "body": "Transaction ID #88392 for LKR 1500 was successful.",
        "time": "2 days ago",
        "isNew": false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = notifications[index];
          final isNew = item['isNew'] as bool;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: isNew ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 1) : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isNew ? AppColors.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_active_rounded, 
                    color: isNew ? AppColors.primary : Colors.grey,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['title'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          if (isNew)
                            Container(
                              width: 8, height: 8,
                              decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['body'] as String,
                        style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['time'] as String,
                        style: TextStyle(color: Colors.grey[400], fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}