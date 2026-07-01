import 'package:flutter/cupertino.dart';
import '../../../domain/models/scan_result.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/glass_card.dart';
import 'confidence_bar.dart';

class ResultOverlay extends StatelessWidget {
  final ScanResult result;

  const ResultOverlay({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = result.confidence == 0.0;

    return GlassCard(
      hasPurpleTint: true,
      blur: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: result.category.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: result.category.color.withValues(alpha: 0.5)),
              ),
              child: Text(
                result.category.label.toUpperCase(),
                style: AppTextStyles.categoryLabel.copyWith(color: result.category.color),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            result.label,
            style: isEmpty ? AppTextStyles.scoreText : AppTextStyles.resultLabel,
          ),
          if (!isEmpty) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Confidence', style: AppTextStyles.scoreText),
                Text(
                  '${(result.confidence * 100).toStringAsFixed(1)}%',
                  style: AppTextStyles.scoreText.copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ConfidenceBar(
              confidence: result.confidence,
              color: result.category.color,
            ),
          ],
        ],
      ),
    );
  }
}
