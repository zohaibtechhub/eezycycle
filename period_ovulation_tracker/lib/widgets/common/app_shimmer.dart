import 'package:flutter/material.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';

/// Soft rose shimmer that matches EezyCycle surfaces (no extra package).
class AppShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const AppShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final t = _controller.value;
            return LinearGradient(
              begin: Alignment(-1.0 - t * 2, 0),
              end: Alignment(1.0 + (1 - t) * 2, 0),
              colors: [
                AppColors.primary.withValues(alpha: 0.04),
                AppColors.primary.withValues(alpha: 0.14),
                AppColors.primary.withValues(alpha: 0.04),
              ],
              stops: const [0.25, 0.5, 0.75],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class AppShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  const AppShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : (borderRadius ?? BorderRadius.circular(12)),
      ),
    );
  }
}

/// Profile screen skeleton — mirrors avatar, metric grid, account cards.
class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: AppShimmerBox(
                width: 96,
                height: 96,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 14),
            const Center(
              child: AppShimmerBox(width: 180, height: 16),
            ),
            const SizedBox(height: 8),
            const Center(
              child: AppShimmerBox(width: 120, height: 12),
            ),
            const SizedBox(height: 28),
            const Align(
              alignment: Alignment.centerLeft,
              child: AppShimmerBox(width: 110, height: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _metricCard()),
                const SizedBox(width: 12),
                Expanded(child: _metricCard()),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _metricCard()),
                const SizedBox(width: 12),
                Expanded(child: _metricCard()),
              ],
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: AppShimmerBox(width: 80, height: 14),
            ),
            const SizedBox(height: 12),
            _infoCard(rows: 3),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: AppShimmerBox(width: 70, height: 14),
            ),
            const SizedBox(height: 12),
            _infoCard(rows: 2),
          ],
        ),
      ),
    );
  }

  static Widget _metricCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppShimmerBox(width: 32, height: 32, borderRadius: BorderRadius.all(Radius.circular(10))),
              AppShimmerBox(width: 48, height: 12),
            ],
          ),
          SizedBox(height: 16),
          AppShimmerBox(width: 72, height: 20),
          SizedBox(height: 8),
          AppShimmerBox(width: 56, height: 12),
        ],
      ),
    );
  }

  static Widget _infoCard({required int rows}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                color: AppColors.primary.withValues(alpha: 0.06),
              ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  AppShimmerBox(
                    width: 36,
                    height: 36,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppShimmerBox(width: 90, height: 12),
                        SizedBox(height: 8),
                        AppShimmerBox(width: 140, height: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Cycle & Ovulation skeleton — hero banner, stat cards, phase list, history.
class CycleOvulationShimmer extends StatelessWidget {
  const CycleOvulationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.softGradient,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
              child: const Row(
                children: [
                  AppShimmerBox(
                    width: 56,
                    height: 56,
                    shape: BoxShape.circle,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppShimmerBox(width: 100, height: 12),
                        SizedBox(height: 10),
                        AppShimmerBox(width: double.infinity, height: 18),
                        SizedBox(height: 8),
                        AppShimmerBox(width: 160, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const AppShimmerBox(width: 120, height: 14),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _statCard()),
                const SizedBox(width: 12),
                Expanded(child: _statCard()),
              ],
            ),
            const SizedBox(height: 24),
            const AppShimmerBox(width: 160, height: 14),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < 4; i++) ...[
                    if (i > 0) const SizedBox(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppShimmerBox(width: 100, height: 14),
                            SizedBox(height: 8),
                            AppShimmerBox(width: 70, height: 12),
                          ],
                        ),
                        AppShimmerBox(
                          width: 64,
                          height: 24,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            const AppShimmerBox(width: 140, height: 14),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppShimmerBox(width: 180, height: 14),
                  SizedBox(height: 12),
                  AppShimmerBox(width: double.infinity, height: 12),
                  SizedBox(height: 8),
                  AppShimmerBox(width: 220, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _statCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppShimmerBox(width: 22, height: 22, borderRadius: BorderRadius.all(Radius.circular(6))),
          SizedBox(height: 12),
          AppShimmerBox(width: 56, height: 20),
          SizedBox(height: 8),
          AppShimmerBox(width: 90, height: 12),
          SizedBox(height: 6),
          AppShimmerBox(width: 70, height: 11),
        ],
      ),
    );
  }
}
