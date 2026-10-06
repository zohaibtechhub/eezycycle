import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/extensions/theme_extension.dart';
import '../text/text_widget.dart';

// MARK: - Premium Particle Model
class PremiumParticle {
  final double baseRadius;
  final double speed;
  final double orbitTilt;
  final double phase;
  final double baseSize;
  final double pulseSpeed;
  final double maxOpacity;
  final bool hasSparkleBloom;

  PremiumParticle({
    required this.baseRadius,
    required this.speed,
    required this.orbitTilt,
    required this.phase,
    required this.baseSize,
    required this.pulseSpeed,
    required this.maxOpacity,
    required this.hasSparkleBloom,
  });

  factory PremiumParticle.generate(math.Random rand, double minR, double maxR) {
    return PremiumParticle(
      baseRadius: minR + rand.nextDouble() * (maxR - minR),
      speed: (rand.nextBool() ? 1 : -1) * (0.25 + rand.nextDouble() * 0.45),
      orbitTilt: 0.75 + rand.nextDouble() * 0.4,
      phase: rand.nextDouble() * 2 * math.pi,
      baseSize: 1.8 + rand.nextDouble() * 2.8,
      pulseSpeed: 1.2 + rand.nextDouble() * 2.0,
      maxOpacity: 0.45 + rand.nextDouble() * 0.50,
      hasSparkleBloom: rand.nextDouble() > 0.65,
    );
  }
}

// MARK: - Controller
class EezyAnalyzingAnimationController extends GetxController
    with GetTickerProviderStateMixin {
  late final AnimationController entranceController;
  late final Animation<double> logoScale;
  late final Animation<double> logoOpacity;

  late final AnimationController loopController;
  late final AnimationController textDriftController;
  late final AnimationController dotPulseController;

  final RxBool showIntro = true.obs;
  Timer? _introTimer;

  final List<PremiumParticle> particles = [];
  final int particleCount = 28;

  @override
  void onInit() {
    super.onInit();

    // 1. Entrance animation for the logo
    entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    logoScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: entranceController, curve: Curves.easeOutBack),
    );

    logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    // 2. Primary smooth continuous loop
    loopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // 3. Subtle floating drift for the text capsule
    textDriftController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    // 4. Dot indicator pulse loop
    dotPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _initParticles();
    entranceController.forward();

    // Display "Hey, I am Ask Eezy..." for 2.2 seconds before transitioning
    _introTimer = Timer(const Duration(milliseconds: 2200), () {
      showIntro.value = false;
    });
  }

  void _initParticles() {
    final rand = math.Random();
    for (int i = 0; i < particleCount; i++) {
      particles.add(PremiumParticle.generate(rand, 65.0, 135.0));
    }
  }

  @override
  void onClose() {
    _introTimer?.cancel();
    entranceController.dispose();
    loopController.dispose();
    textDriftController.dispose();
    dotPulseController.dispose();
    super.onClose();
  }
}

// MARK: - Canvas Painter (Aurora + Sparkles + Depth)
class PremiumAuraCanvasPainter extends CustomPainter {
  final List<PremiumParticle> particles;
  final double progress;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isDark;

  PremiumAuraCanvasPainter({
    required this.particles,
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final time = progress * 2 * math.pi;

    // Outer Aura Halo
    final auraRadius = size.width * 0.46;
    final ambientPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withValues(alpha: isDark ? 0.30 : 0.20),
          secondaryColor.withValues(alpha: isDark ? 0.14 : 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: auraRadius));

    canvas.drawCircle(center, auraRadius, ambientPaint);

    // Inner Specular Glow Core
    final pulseScale = 1.0 + 0.08 * math.sin(time * 2);
    final coreRadius = size.width * 0.28 * pulseScale;
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withValues(alpha: isDark ? 0.45 : 0.30),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: coreRadius));

    canvas.drawCircle(center, coreRadius, corePaint);

    // Rotating Orbital Energy Arcs
    final ringPaint1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          primaryColor.withValues(alpha: isDark ? 0.40 : 0.28),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(time),
      ).createShader(Rect.fromCircle(center: center, radius: 92));

    final ringPaint2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          secondaryColor.withValues(alpha: isDark ? 0.35 : 0.22),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(-time * 1.4),
      ).createShader(Rect.fromCircle(center: center, radius: 118));

    canvas.drawCircle(center, 92, ringPaint1);
    canvas.drawCircle(center, 118, ringPaint2);

    // Sparkle Particles
    for (final p in particles) {
      final angle = p.phase + (p.speed * time);
      final r = p.baseRadius + (math.sin(time * 2 + p.phase) * 8.0);

      final x = center.dx + r * math.cos(angle);
      final y = center.dy + (r * math.sin(angle) * p.orbitTilt);

      final dynamicOpacity =
          (p.maxOpacity * (0.4 + 0.6 * math.sin(time * p.pulseSpeed + p.phase)))
              .clamp(0.15, 0.95);

      final particleColor = isDark
          ? Color.lerp(Colors.white, primaryColor, 0.35)!
          : Color.lerp(primaryColor, secondaryColor, 0.40)!;

      if (p.hasSparkleBloom) {
        final bloomPaint = Paint()
          ..color = particleColor.withValues(alpha: dynamicOpacity * 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);
        canvas.drawCircle(Offset(x, y), p.baseSize * 2.2, bloomPaint);
      }

      final coreParticlePaint = Paint()
        ..color = particleColor.withValues(alpha: dynamicOpacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), p.baseSize, coreParticlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant PremiumAuraCanvasPainter oldDelegate) => true;
}

// MARK: - Main Reusable Widget
class EezyAnalyzingAnimation extends StatelessWidget {
  final String logoAsset;
  final String text;
  final String introText;
  final double canvasSize;
  final double fontSize;
  final FontWeight fontWeight;
  final bool isGradientText;
  final Color? textColor;

  const EezyAnalyzingAnimation({
    super.key,
    required this.logoAsset,
    required this.text,
    this.introText = 'Hey, I am Ask Eezy...',
    this.canvasSize = 310.0,
    this.fontSize = 15.0,
    this.fontWeight = FontWeight.w600,
    this.isGradientText = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EezyAnalyzingAnimationController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = context.primaryColor;
    final secondary = context.secondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // MARK: - Logo & Ambient Canvas
        SizedBox(
          width: canvasSize,
          height: canvasSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Canvas: Auroras, Orbital Rings & Particles
              AnimatedBuilder(
                animation: controller.loopController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(canvasSize, canvasSize),
                    painter: PremiumAuraCanvasPainter(
                      particles: controller.particles,
                      progress: controller.loopController.value,
                      primaryColor: primary,
                      secondaryColor: secondary,
                      isDark: isDark,
                    ),
                  );
                },
              ),

              // Frosted Glass Disc behind Logo
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isDark ? context.surface : Colors.white).withValues(
                    alpha: isDark ? 0.75 : 0.90,
                  ),
                  border: Border.all(
                    color: (isDark ? Colors.white : primary).withValues(
                      alpha: isDark ? 0.15 : 0.20,
                    ),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: isDark ? 0.30 : 0.18),
                      blurRadius: 28,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),

              // Logo (Smooth one-time Entrance, static afterward)
              AnimatedBuilder(
                animation: controller.entranceController,
                builder: (context, child) {
                  return Opacity(
                    opacity: controller.logoOpacity.value,
                    child: Transform.scale(
                      scale: controller.logoScale.value,
                      child: child,
                    ),
                  );
                },
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: Image.asset(logoAsset, fit: BoxFit.contain),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // MARK: - Premium Glassmorphic Text Card
        AnimatedBuilder(
          animation: controller.textDriftController,
          builder: (context, child) {
            final drift =
                math.sin(controller.textDriftController.value * math.pi) * 2.0;
            return Transform.translate(offset: Offset(0, -drift), child: child);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: (isDark ? context.surface : Colors.white).withValues(
                    alpha: isDark ? 0.55 : 0.85,
                  ),
                  border: Border.all(
                    color: (isDark ? Colors.white : primary).withValues(
                      alpha: isDark ? 0.12 : 0.18,
                    ),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: isDark ? 0.18 : 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Obx(() {
                  final activeText = controller.showIntro.value
                      ? introText
                      : text;

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 450),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.35),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Row(
                      key: ValueKey<String>(activeText),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Pulsing AI Active Dot
                        AnimatedBuilder(
                          animation: controller.dotPulseController,
                          builder: (context, child) {
                            return Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primary.withValues(
                                  alpha:
                                      0.45 +
                                      (0.55 *
                                          controller.dotPulseController.value),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primary.withValues(alpha: 0.6),
                                    blurRadius:
                                        6 * controller.dotPulseController.value,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 10),

                        // Text
                        TextWidget(
                          title: activeText,
                          fontSize: fontSize,
                          fontWeight: fontWeight,
                          isGradient: isGradientText,
                          textColor: textColor ?? context.onSurface,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
