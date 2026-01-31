import 'package:flutter/material.dart';

class DataRowWidget extends StatelessWidget {
  final String title;
  final String value;
  final String status;

  const DataRowWidget({
    super.key,
    required this.title,
    required this.value,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color getStatusColor() {
      switch (status) {
        case 'Normal':
        case 'Çok iyi':
          return Colors.green;
        case 'Dikkat':
          return Colors.red;
        default:
          return Colors.orange;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Row(
            children: [
              Text(value, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Text(status, style: TextStyle(fontSize: 16, color: getStatusColor())),
            ],
          ),
        ],
      ),
    );
  }
}
