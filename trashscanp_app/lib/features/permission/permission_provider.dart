import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final permissionProvider = NotifierProvider<PermissionNotifier, PermissionStatus>(
  PermissionNotifier.new,
);

class PermissionNotifier extends Notifier<PermissionStatus> {
  bool _isRequesting = false;

  @override
  PermissionStatus build() {
    checkPermission();
    return PermissionStatus.denied;
  }

  Future<void> checkPermission() async {
    final status = await Permission.camera.status;
    state = status;
  }

  Future<void> requestPermission() async {
    if (_isRequesting) return;
    
    _isRequesting = true;
    try {
      final status = await Permission.camera.request();
      state = status;
    } finally {
      _isRequesting = false;
    }
  }
}
