import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/model_variant.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/glass_card.dart';
import '../providers/scan_provider.dart';

class ModelSelector extends ConsumerWidget {
  const ModelSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(scanProvider.select((s) => s.selectedVariant));

    return GestureDetector(
      onTap: () => _showPicker(context, ref, selected),
      child: GlassCard(
        blur: 12,
        color: AppColors.glassMedium,
        borderRadius: 100,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.square_grid_2x2, color: AppColors.purpleLight, size: 14),
            const SizedBox(width: 6),
            Text(
              selected.label,
              style: AppTextStyles.statusLabel,
            ),
            const SizedBox(width: 4),
            const Icon(CupertinoIcons.chevron_down, color: AppColors.textSecondary, size: 12),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context, WidgetRef ref, ModelVariant current) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Pilih Model', style: TextStyle(color: AppColors.textPrimary)),
        message: const Text('Model lebih besar = lebih akurat tapi lebih lambat',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        actions: [
          for (final variant in ModelVariant.variants)
            CupertinoActionSheetAction(
              isDefaultAction: variant.id == current.id,
              onPressed: () {
                Navigator.pop(context);
                ref.read(scanProvider.notifier).switchModel(variant);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    variant.label,
                    style: TextStyle(
                      fontWeight: variant.id == current.id ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    variant.description,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Batal', style: TextStyle(color: AppColors.purpleLight)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
