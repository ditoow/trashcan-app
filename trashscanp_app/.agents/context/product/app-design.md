# 🎨 UI Design Spec
## TrashScan — Camera Screen Only
**v3.0** | Flutter | Apple Glassmorphism · Purple `#8538C7`

---

## 1. Satu Screen, Banyak Layer

Seluruh UI hidup di atas `CameraPreview`. Tidak ada navigasi, tidak ada halaman lain.
Semua komponen mengapung sebagai glass layer di atas live feed.

```
CameraScreen
└── Stack
    ├── CameraPreview          ← live feed, fullscreen
    ├── _PurpleVignette        ← atmospheric glow, bukan overlay solid
    ├── StatusPill             ← pojok kiri atas
    ├── PauseButton            ← pojok kanan atas
    └── ResultPanel            ← bottom, glass card utama
```

---

## 2. Color System

```dart
class AppColors {
  // === PRIMARY PURPLE ===
  static const purple           = Color(0xFF8538C7);
  static const purpleLight      = Color(0xFFA855F7); // sedikit lebih terang
  static const purpleDark       = Color(0xFF6D28A8); // lebih gelap
  static const purpleGlow       = Color(0x668538C7); // purple 40% — glow effect
  static const purpleGlowSoft   = Color(0x338538C7); // purple 20% — subtle glow
  static const purpleGlowFaint  = Color(0x1A8538C7); // purple 10% — atmosphere

  // === GLASS LAYERS (semua translucent) ===
  static const glassBase        = Color(0x1FFFFFFF); // white 12%
  static const glassMedium      = Color(0x33FFFFFF); // white 20%
  static const glassStrong      = Color(0x4DFFFFFF); // white 30%
  static const glassBorder      = Color(0x2BFFFFFF); // white 17%
  static const glassBorderBright= Color(0x4DFFFFFF); // white 30% — pressed

  // === BACKGROUND (non-camera screens) ===
  // Dark purple-tinted — kamera tetap jadi background utama
  static const bgDark           = Color(0xFF0C0612);
  static const bgMid            = Color(0xFF130D1F);

  // === CATEGORY — tetap readable di atas glass purple ===
  static const organicFill      = Color(0xFF34D058); // green — kontras vs purple
  static const organicGlow      = Color(0x4034D058);
  static const inorganicFill    = Color(0xFF0A84FF); // blue
  static const inorganicGlow    = Color(0x400A84FF);
  static const b3Fill           = Color(0xFFFF453A); // red
  static const b3Glow           = Color(0x40FF453A);
  static const unknownFill      = Color(0xFF98989D); // gray

  // === STATUS DOT ===
  static const statusScanning   = Color(0xFF8538C7); // purple = aktif
  static const statusLoading    = Color(0xFFFF9F0A); // amber
  static const statusPaused     = Color(0xFF636366); // gray
  static const statusError      = Color(0xFFFF453A); // red

  // === CONFIDENCE BAR ===
  static const confHigh         = Color(0xFF8538C7); // purple — score >= 0.7
  static const confMed          = Color(0xFFFF9F0A); // amber
  static const confLow          = Color(0xFFFF453A); // red

  // === TEXT (di atas gelap / glass) ===
  static const textPrimary      = Color(0xFFFFFFFF);
  static const textSecondary    = Color(0xB3FFFFFF); // 70%
  static const textTertiary     = Color(0x66FFFFFF); // 40%
}
```

---

## 3. Typography

```dart
// Font: Plus Jakarta Sans — mendekati SF Pro, tersedia Google Fonts

class AppTextStyles {

  // Label utama hasil — terbesar, paling mencolok
  static const resultLabel = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 30,
    fontWeight: FontWeight.w800,         // ExtraBold
    color: Color(0xFFFFFFFF),
    letterSpacing: -0.8,
    shadows: [
      Shadow(blurRadius: 16, color: Color(0x998538C7)),  // purple glow shadow
      Shadow(blurRadius: 4,  color: Color(0x80000000)),
    ],
  );

  // Chip kategori
  static const categoryLabel = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: Color(0xFFFFFFFF),
    letterSpacing: 0.2,
  );

  // Score persentase
  static const scoreText = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xB3FFFFFF),
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // Placeholder "Arahkan ke sampah..."
  static const placeholder = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: Color(0x66FFFFFF),
    letterSpacing: 0.1,
  );

  // Status pill label
  static const statusLabel = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: Color(0xFFFFFFFF),
    letterSpacing: 0.3,
  );

  // Education sheet title
  static const sheetTitle = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: Color(0xFFFFFFFF),
    letterSpacing: -0.3,
  );

  // Education sheet body
  static const sheetBody = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xB3FFFFFF),
    height: 1.6,
  );
}
```

---

## 4. GlassCard Widget

```dart
// lib/shared/widgets/glass_card.dart
// Dipakai oleh semua komponen floating di atas kamera

class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    this.blur = 20.0,
    this.color = const Color(0x1FFFFFFF),   // glassBase default
    this.borderColor = const Color(0x2BFFFFFF),
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.all(16),
    this.hasPurpleTint = false,             // tambah purple tint opsional
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            // Purple tint opsional — dipakai untuk ResultPanel
            color: hasPurpleTint
                ? Color.alphaBlend(
                    const Color(0x1A8538C7), // purple 10% tint
                    color,
                  )
                : color,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: 0.5),
            // Subtle inner glow di border kiri atas
            gradient: hasPurpleTint
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0x338538C7), // purple 20%
                      const Color(0x0DFFFFFF), // white 5%
                    ],
                  )
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
```

**4 preset yang dipakai:**

| Preset | blur | color | hasPurpleTint | Dipakai di |
|--------|------|-------|---------------|-----------|
| `.pill` | 16 | `glassBase` | false | StatusPill, CategoryChip |
| `.button` | 12 | `glassMedium` | false | PauseButton |
| `.panel` | 24 | `glassBase` | **true** | ResultPanel — purple tint |

---

## 5. Layout Stack — Detail Lengkap

### 5.1 _PurpleVignette (atmospheric layer)

```dart
// Bukan overlay solid — hanya gradient atmosfer di sudut bawah
// Membuat kamera terasa "dalam dunia" purple tanpa menghalangi feed

Container(
  decoration: const BoxDecoration(
    gradient: RadialGradient(
      center: Alignment(0.0, 1.2),   // dari bawah tengah
      radius: 1.0,
      colors: [
        Color(0x668538C7),            // purple 40% di bawah
        Color(0x00000000),            // transparan ke atas
      ],
    ),
  ),
)
```

### 5.2 StatusPill — kiri atas

```dart
Positioned(
  top: MediaQuery.of(context).padding.top + 12,
  left: 16,
  child: GlassCard.pill(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    borderRadius: 100,  // pill shape
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PulseDot(status: status),    // 8dp dot, animasi pulse jika scanning
        const SizedBox(width: 6),
        Text(_statusLabel(status), style: AppTextStyles.statusLabel),
      ],
    ),
  ),
)
```

### 5.3 PauseButton — kanan atas

```dart
Positioned(
  top: MediaQuery.of(context).padding.top + 12,
  right: 16,
  child: _PressableGlass(          // wrapper dengan scale 0.95 on press
    child: GlassCard.button(
      padding: const EdgeInsets.all(11),
      borderRadius: 14,
      child: Icon(
        isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
        color: Colors.white,
        size: 20,
      ),
    ),
  ),
)
```

### 5.4 ResultPanel — bottom, komponen utama

```dart
Positioned(
  bottom: 0, left: 0, right: 0,
  child: GlassCard.panel(
    borderRadius: 28,              // top corners only
    padding: EdgeInsets.fromLTRB(20, 16, 20,
        MediaQuery.of(context).padding.bottom + 20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DragHandle(),             // 36×4dp, white 25%, center
        const SizedBox(height: 16),
        _TopRow(),                 // CategoryChip + score %
        const SizedBox(height: 8),
        _ResultLabel(),            // AnimatedSwitcher — nama sampah
        const SizedBox(height: 12),
        _ConfidenceBar(),          // AnimatedContainer fill
        const SizedBox(height: 4),
      ],
    ),
  ),
)
```

**_TopRow:**
```dart
Row(children: [
  // CategoryChip — glass pill dengan warna kategori
  GlassCard.pill(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    borderRadius: 100,
    color: _categoryGlow(category),  // misal: organicGlow = Color(0x4034D058)
    borderColor: _categoryFill(category).withOpacity(0.4),
    child: Text(categoryName, style: AppTextStyles.categoryLabel),
  ),
  const Spacer(),
  // Score
  Text('${(score * 100).round()}%', style: AppTextStyles.scoreText),
])
```

**_ResultLabel:**
```dart
// AnimatedSwitcher — blur crossfade saat label berganti
AnimatedSwitcher(
  duration: const Duration(milliseconds: 220),
  transitionBuilder: (child, anim) => FadeTransition(
    opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
    child: child,
  ),
  child: Text(
    result?.displayName ?? 'Arahkan ke sampah...',
    key: ValueKey(result?.displayName),
    style: result != null
        ? AppTextStyles.resultLabel
        : AppTextStyles.placeholder,
  ),
)
```

**_ConfidenceBar:**
```dart
Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  // Track
  Container(
    height: 6,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.12),
      borderRadius: BorderRadius.circular(3),
    ),
    child: LayoutBuilder(builder: (ctx, constraints) {
      return Align(
        alignment: Alignment.centerLeft,
        child: AnimatedContainer(               // interruptible — bukan keyframe
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,               // SELALU easeOut, bukan easeIn
          width: constraints.maxWidth * (result?.topScore ?? 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: _confColor(result?.topScore ?? 0),
            boxShadow: [
              BoxShadow(
                color: _confColor(result?.topScore ?? 0).withOpacity(0.6),
                blurRadius: 6,                 // glow di ujung bar
              ),
            ],
          ),
        ),
      );
    }),
  ),
])
```

---

## 6. Animation Spec

| Elemen | Animasi | Duration | Curve | Catatan |
|--------|---------|----------|-------|---------|
| ResultLabel ganti | FadeTransition | 220ms | easeOut | Bukan slide |
| ConfidenceBar fill | AnimatedContainer width | 400ms | easeOut | Interruptible |
| PauseButton press | Scale 1.0→0.95 | 120ms | easeOut | Emil: scale on active |
| StatusPill pulse | Scale 1.0→1.4, opacity loop | 1200ms | easeInOut | Hanya saat scanning |
| EducationSheet enter | SlideUp + fade | 280ms | `Cubic(0.32,0.72,0,1)` | iOS drawer curve |
| EducationSheet exit | SlideDown + fade | 180ms | easeIn | Exit lebih cepat |
| PurpleVignette | Tidak ada animasi | — | — | Static atmosphere |

> **Tidak ada `ease-in` untuk elemen masuk.** `ease-out` memberikan respons instan di momen pertama user melihat.

---

## 7. _PressableGlass — Wrapper Pressed State

```dart
// Dipakai untuk semua tombol glass
// Emil: "buttons must feel responsive — scale(0.97) on active"

class _PressableGlass extends StatefulWidget {
  const _PressableGlass({required this.child, required this.onTap});

  @override
  State<_PressableGlass> createState() => _PressableGlassState();
}

class _PressableGlassState extends State<_PressableGlass>
    with SingleTickerProviderStateMixin {

  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
  );

  late final Animation<double> _scale = Tween(begin: 1.0, end: 0.95).animate(
    CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:    (_) => _ctrl.forward(),
      onTapUp:      (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel:  ()  => _ctrl.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
```

---

## 8. Performance Rules (kamera = heavy)

| Rule | Alasan |
|------|--------|
| Maksimal **3 BackdropFilter** aktif bersamaan | Lebih dari 3 = drop FPS di mid-range |
| **Jangan** animasikan `color` property | Trigger repaint. Pakai opacity+fade |
| `AnimatedContainer` bukan `@keyframes` | Interruptible saat result update cepat |
| `RepaintBoundary` di StatusPill dan PauseButton | Isolasi repaint dari ResultPanel |
| Update state via `ref.read()` di timer, bukan `ref.watch()` | Cegah provider listen di luar widget tree |
| `ResolutionPreset.medium` di CameraController | Hemat RAM, cukup untuk klasifikasi AI |

---

## 9. Checklist Sebelum Build

```
[ ] Plus Jakarta Sans terpasang di pubspec.yaml (5 weight)
[ ] BackdropFilter di screen: StatusPill + PauseButton + ResultPanel = 3 ✅
[ ] Semua animasi pakai ease-out (bukan ease-in)
[ ] AnimatedSwitcher punya key: ValueKey(displayName)
[ ] _PressableGlass dipakai di semua tombol
[ ] PurpleVignette cukup RadialGradient, tidak ada BackdropFilter
[ ] ConfidenceBar pakai AnimatedContainer (bukan keyframe)
[ ] StatusDot pulse berhenti saat status != scanning
[ ] WidgetsBindingObserver di CameraNotifier untuk pause di background
[ ] .env tidak ter-commit (.gitignore)
```
