import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _master;
  late final AnimationController _glow;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _circuitDraw;
  late final Animation<double> _textProgress;
  late final Animation<double> _exitFade;
  late final Animation<double> _exitScale;

  static const _text = 'HARDWARE VAULT';

  @override
  void initState() {
    super.initState();

    _master = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
          parent: _master,
          curve: const Interval(0.00, 0.30, curve: Curves.easeOutBack)),
    );
    _logoFade = CurvedAnimation(
        parent: _master, curve: const Interval(0.00, 0.20));

    _circuitDraw = CurvedAnimation(
        parent: _master,
        curve: const Interval(0.10, 0.70, curve: Curves.easeOutQuart));

    _textProgress = CurvedAnimation(
        parent: _master,
        curve: const Interval(0.30, 0.85, curve: Curves.easeOut));

    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _master, curve: const Interval(0.88, 1.00)),
    );
    _exitScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
          parent: _master,
          curve: const Interval(0.85, 1.00, curve: Curves.easeIn)),
    );

    _master.forward().whenComplete(_goToMain);
  }

  void _goToMain() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const MainShell(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _master.dispose();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnimatedBuilder(
        animation: Listenable.merge([_master, _glow]),
        builder: (_, __) {
          final visibleChars =
              (_text.length * _textProgress.value).round().clamp(0, _text.length);
          final shownText = _text.substring(0, visibleChars);
          final glowT = _glow.value;
          final glowOpacity =
              (0.15 + 0.55 * math.sin(glowT * math.pi)).clamp(0.0, 1.0);
          final glowBlur = 30 + 40 * glowT;

          return Opacity(
            opacity: _exitFade.value,
            child: Transform.scale(
              scale: _exitScale.value,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.9,
                    colors: [
                      Color(0xFF0E1A12),
                      AppTheme.background,
                    ],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _CircuitPainter(progress: _circuitDraw.value),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Opacity(
                          opacity: _logoFade.value,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(36),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accentGlow
                                        .withOpacity(glowOpacity),
                                    blurRadius: glowBlur,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(36),
                                child: Image.asset(
                                  'assets/images/app_icon.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 28,
                          child: Text(
                            shownText,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 6,
                              shadows: [
                                Shadow(
                                  color: AppTheme.primary
                                      .withOpacity(0.6),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Opacity(
                          opacity:
                              (_textProgress.value * 1.2 - 0.2).clamp(0.0, 1.0),
                          child: Container(
                            width: 80,
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primary.withOpacity(0),
                                  AppTheme.primary,
                                  AppTheme.primary.withOpacity(0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CircuitPainter extends CustomPainter {
  final double progress;

  _CircuitPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = AppTheme.primary.withOpacity(0.35 * progress)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = AppTheme.primary.withOpacity(0.7 * progress)
      ..style = PaintingStyle.fill;

    final maxLen = math.max(size.width, size.height) * 0.6 * progress;

    final segments = <List<Offset>>[
      [center, center + Offset(-maxLen * 0.6, 0), Offset(-maxLen, maxLen * 0.4)],
      [center, center + Offset(maxLen * 0.6, 0), Offset(maxLen, -maxLen * 0.5)],
      [center, center + Offset(0, -maxLen * 0.55), Offset(maxLen * 0.45, -maxLen)],
      [center, center + Offset(0, maxLen * 0.55), Offset(-maxLen * 0.5, maxLen)],
      [center, center + Offset(-maxLen * 0.4, -maxLen * 0.4)],
      [center, center + Offset(maxLen * 0.4, maxLen * 0.4)],
    ];

    for (final seg in segments) {
      final path = Path()..moveTo(seg.first.dx, seg.first.dy);
      Offset acc = seg.first;
      for (var i = 1; i < seg.length; i++) {
        acc = acc + seg[i];
        path.lineTo(acc.dx, acc.dy);
      }
      canvas.drawPath(path, paint);
      canvas.drawCircle(acc, 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CircuitPainter old) =>
      old.progress != progress;
}
