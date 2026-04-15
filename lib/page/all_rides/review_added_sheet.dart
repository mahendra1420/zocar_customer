// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';

import '../../themes/constant_colors.dart';
import '../../widget/star_rating.dart';

class ReviewAddedSheet extends StatelessWidget {
  final num givenRating;
  final String givenComment;
  final num receivedRating;
  final String receivedComment;

  const ReviewAddedSheet({
    Key? key,
    required this.givenRating,
    required this.givenComment,
    required this.receivedRating,
    required this.receivedComment,
  }) : super(key: key);

  // Static method to show the bottom sheet
  static void show(
      BuildContext context, {
        required num givenRating,
        required String givenComment,
        required num receivedRating,
        required String receivedComment,
      }) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ReviewAddedSheet(
        givenRating: givenRating,
        givenComment: givenComment,
        receivedRating: receivedRating,
        receivedComment: receivedComment,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Success icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 40,
              ),
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              'Review Added Successful!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            if (givenRating != 0) ...[
              // Given Rating Section
              _buildRatingSection(
                context: context,
                title: 'Rating You Gave',
                rating: givenRating,
                comment: givenComment,
                iconColor: Colors.blue,
                icon: Icons.arrow_upward,
              ),

              const SizedBox(height: 16),
            ],

            // Divider
            Divider(
              color: Colors.grey[300],
              thickness: 1,
            ),

            const SizedBox(height: 16),

            if (receivedRating != 0) ...[
              // Received Rating Section
              _buildRatingSection(
                context: context,
                title: 'Rating You Received',
                rating: receivedRating,
                comment: receivedComment,
                iconColor: Colors.green,
                icon: Icons.arrow_downward,
              ),

              const SizedBox(height: 24),
            ],

            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ConstantColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection({
    required BuildContext context,
    required String title,
    required num rating,
    required String comment,
    required Color iconColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Star rating
          Center(
            child: StarRating(
              rating: rating.toDouble(),
              starCount: 5,
              color: Colors.amber,
              size: 28,
              mainAxisSize: MainAxisSize.min,
            ),
          ),

          const SizedBox(height: 4),

          // Rating value
          Center(
            child: Text(
              '${rating.toStringAsFixed(1)} / 5.0',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Comment section
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                comment,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
