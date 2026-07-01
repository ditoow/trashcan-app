import 'package:flutter/cupertino.dart';
import '../../../domain/models/scan_result.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';

class ObjectBoundingBox extends StatelessWidget {
  final ScanResult result;

  const ObjectBoundingBox({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    if (result.rect == null || result.confidence == 0.0) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double left = result.rect!.left * constraints.maxWidth;
        final double top = result.rect!.top * constraints.maxHeight;
        final double width = result.rect!.width * constraints.maxWidth;
        final double height = result.rect!.height * constraints.maxHeight;

        // Don't render if too small
        if (width < 10 || height < 10) return const SizedBox.shrink();

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Label positioned above the box
            AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutQuart,
              left: left,
              top: (top - 20).clamp(0.0, constraints.maxHeight),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.85),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  '${result.label} ${(result.confidence * 100).toStringAsFixed(0)}%',
                  style: AppTextStyles.categoryLabel.copyWith(
                    fontSize: 10,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ),
            // Bounding box
            AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutQuart,
              left: left,
              top: top,
              width: width,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.purple.withValues(alpha: 0.8),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
