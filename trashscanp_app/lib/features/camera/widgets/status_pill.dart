import 'package:flutter/cupertino.dart';
import '../../../domain/models/scan_status.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/glass_card.dart';

class StatusPill extends StatelessWidget {
  final ScanStatus status;

  const StatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      borderRadius: 100,
      blur: 16,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulseDot(status: status),
          const SizedBox(width: 8),
          Text(
            _getStatusText(status),
            style: AppTextStyles.statusLabel,
          ),
        ],
      ),
    );
  }

  String _getStatusText(ScanStatus status) {
    switch (status) {
      case ScanStatus.scanning:
        return 'SCANNING';
      case ScanStatus.loading:
        return 'ANALYZING...';
      case ScanStatus.paused:
        return 'PAUSED';
      case ScanStatus.error:
        return 'ERROR';
    }
  }
}

class _PulseDot extends StatefulWidget {
  final ScanStatus status;
  const _PulseDot({required this.status});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color color;
    bool shouldAnimate = false;

    switch (widget.status) {
      case ScanStatus.scanning:
        color = AppColors.purple;
        shouldAnimate = true;
      case ScanStatus.loading:
        color = CupertinoColors.systemOrange;
        shouldAnimate = true;
      case ScanStatus.paused:
        color = CupertinoColors.systemGrey;
      case ScanStatus.error:
        color = CupertinoColors.systemRed;
    }

    if (!shouldAnimate) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
    }

    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4, spreadRadius: 2),
          ],
        ),
      ),
    );
  }
}
