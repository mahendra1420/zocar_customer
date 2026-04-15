

import 'package:flutter/material.dart';

class PackageDetailsBottomSheet extends StatelessWidget {
  const PackageDetailsBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Text(
            //   'Package Details',
            //   style: Theme.of(context).textTheme.titleLarge?.copyWith(
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            // const SizedBox(height: 20),
            _buildDetailItem(
              icon: Icons.access_time,
              text: 'Extra time charged at ₹1.5/min',
            ),
            const SizedBox(height: 16),
            _buildDetailItem(
              icon: Icons.route,
              text: 'Extra distance charged at ₹9/km',
            ),
            const SizedBox(height: 16),
            _buildDetailItem(
              icon: Icons.toll,
              text: 'Toll and parking charges are extra',
            ),
            const SizedBox(height: 16),
            _buildDetailItem(
              icon: Icons.location_on,
              text: 'Multiple stops allowed within the package',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.blue,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}