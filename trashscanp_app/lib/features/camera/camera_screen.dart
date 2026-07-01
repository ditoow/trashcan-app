import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/scan_status.dart';
import 'providers/scan_provider.dart';
import 'widgets/object_bounding_box.dart';
import 'widgets/result_overlay.dart';
import 'widgets/status_pill.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final controller = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await controller.initialize();
      if (!mounted) return;

      // Enable continuous autofocus for sharp image
      await controller.setFocusMode(FocusMode.auto);

      await controller.startImageStream((image) {
        ref.read(scanProvider.notifier).setLatestFrame(image);
      });

      setState(() {
        _controller = controller;
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Camera initialization failed: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      // Null out first to prevent build() from using disposed controller
      setState(() {
        _isInitialized = false;
        _controller = null;
      });
      cameraController.dispose();
      ref.read(scanProvider.notifier).stopScanning();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
      ref.read(scanProvider.notifier).startScanning();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanProvider);

    if (!_isInitialized || _controller == null) {
      return const CupertinoPageScaffold(
        backgroundColor: AppColors.bgDark,
        child: Center(child: CupertinoActivityIndicator(color: AppColors.purple, radius: 15)),
      );
    }

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double cameraAspect = _controller!.value.aspectRatio;
                final double scale = constraints.maxHeight / (constraints.maxWidth / cameraAspect);

                return ClipRect(
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.center,
                    child: Center(
                      child: CameraPreview(_controller!),
                    ),
                  ),
                );
              },
            ),
          ),

          // Purple Vignette Gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, 1.2),
                  radius: 1.2,
                  colors: [
                    AppColors.purpleGlow.withValues(alpha: 0.4),
                    CupertinoColors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: ObjectBoundingBox(result: scanState.result),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusPill(status: scanState.status),
                      if (scanState.inferenceMs > 0)
                        GlassCard(
                          blur: 12,
                          color: AppColors.glassMedium,
                          borderRadius: 100,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          child: Text(
                            '${scanState.inferenceMs.toStringAsFixed(0)}ms',
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      GestureDetector(
                        onTap: () {
                          final notifier = ref.read(scanProvider.notifier);
                          scanState.status == ScanStatus.paused
                              ? notifier.startScanning()
                              : notifier.stopScanning();
                        },
                        child: GlassCard(
                          blur: 12,
                          color: AppColors.glassMedium,
                          borderRadius: 100,
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            scanState.status == ScanStatus.paused
                                ? CupertinoIcons.play_arrow_solid
                                : CupertinoIcons.pause_fill,
                            color: CupertinoColors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ResultOverlay(result: scanState.result),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
