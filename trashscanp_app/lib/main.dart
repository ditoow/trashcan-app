import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'features/permission/permission_screen.dart';
import 'features/permission/permission_provider.dart';
import 'features/camera/camera_screen.dart';
import 'shared/theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: TrashScanApp(),
    ),
  );
}

class TrashScanApp extends ConsumerWidget {
  const TrashScanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionStatus = ref.watch(permissionProvider);

    return CupertinoApp(
      title: 'TrashScan',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.purple,
        scaffoldBackgroundColor: AppColors.bgDark,
      ),
      home: _getHome(permissionStatus),
    );
  }

  Widget _getHome(PermissionStatus status) {
    if (status.isGranted) {
      return const CameraScreen();
    }
    return const PermissionScreen();
  }
}
