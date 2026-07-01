import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'permission_provider.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';

class PermissionScreen extends ConsumerWidget {
  const PermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.bgDark,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.camera,
                size: 100,
                color: AppColors.purple,
              ),
              const SizedBox(height: 32),
              Text(
                'Izin Kamera Diperlukan',
                style: AppTextStyles.resultLabel.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Aplikasi ini memerlukan akses kamera untuk melakukan deteksi sampah secara otomatis.',
                style: AppTextStyles.scoreText,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              CupertinoButton.filled(
                onPressed: () => ref.read(permissionProvider.notifier).requestPermission(),
                child: const Text('Berikan Izin'),
              ),
              CupertinoButton(
                onPressed: () => openAppSettings(),
                child: Text(
                  'Buka Pengaturan',
                  style: AppTextStyles.scoreText.copyWith(color: AppColors.purpleLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
