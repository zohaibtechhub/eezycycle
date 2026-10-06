import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:period_ovulation_tracker/controllers/home/home_hero_controller.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/models/pregnancy/pregnancy_insight_models.dart';
import 'package:period_ovulation_tracker/widgets/pregnancy/pregnancy_asset_image.dart';
import 'package:story_view/story_view.dart';

/// Flo-style full-screen story viewer powered by `story_view`.
class PregnancyStoryView extends StatefulWidget {
  final List<PregnancyStory> stories;
  final int initialStoryIndex;
  final String? statusLineOverride;
  final String? footerNote;

  const PregnancyStoryView({
    super.key,
    required this.stories,
    this.initialStoryIndex = 0,
    this.statusLineOverride,
    this.footerNote,
  });

  @override
  State<PregnancyStoryView> createState() => _PregnancyStoryViewState();
}

class _PregnancyStoryViewState extends State<PregnancyStoryView> {
  late final StoryController _controller;
  late int _storyIndex;

  HomeHeroController get _hero => Get.find<HomeHeroController>();

  @override
  void initState() {
    super.initState();
    _controller = StoryController();
    _storyIndex = widget.initialStoryIndex.clamp(0, widget.stories.length - 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  PregnancyStory get _current => widget.stories[_storyIndex];

  String get _statusLine {
    if (widget.statusLineOverride != null &&
        widget.statusLineOverride!.trim().isNotEmpty) {
      return widget.statusLineOverride!;
    }
    final d = _hero.selectedDate.value;
    final age = _hero.gestationalAgeForDate(d);
    final date = DateFormat('MMMM d').format(d);
    final w = age.weeks;
    final days = age.days;
    final weekPart = w == 1 ? '1 week' : '$w weeks';
    final dayPart = days == 1 ? '1 day' : '$days days';
    return '$date • $weekPart $dayPart';
  }

  String get _footerNote =>
      widget.footerNote ?? 'All predictions are based on your due date.';

  List<StoryItem> _buildItems(PregnancyStory story) {
    return story.pages.map((page) {
      final bg = _parseColor(page.background) ?? const Color(0xFFF7F5F8);
      return StoryItem(
        ColoredBox(
          color: bg,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _statusLine,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: _pageBody(page)),
                  const SizedBox(height: 12),
                  Text(
                    _footerNote,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        duration: Duration(milliseconds: page.durationMs.clamp(2800, 12000)),
      );
    }).toList();
  }

  Widget _pageBody(PregnancyStoryPage page) {
    final child = switch (page.type) {
      'focus' => _FocusPage(page: page, selectedDate: _hero.selectedDate.value),
      'tips' => _TipsPage(page: page),
      'baby_compare' => _BabyComparePage(page: page),
      'body_week' => _BodyWeekPage(page: page),
      _ => _BabyComparePage(page: page),
    };
    return _StoryEnter(child: child);
  }

  void _onComplete() {
    if (_storyIndex < widget.stories.length - 1) {
      setState(() => _storyIndex += 1);
    } else {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildItems(_current);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F8),
      body: Stack(
        children: [
          KeyedSubtree(
            key: ValueKey('preg_story_$_storyIndex'),
            child: StoryView(
              storyItems: items,
              controller: _controller,
              onComplete: _onComplete,
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) Get.back();
              },
              indicatorColor: Colors.black12,
              indicatorForegroundColor: AppColors.textPrimary,
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 4,
            right: 8,
            child: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    var h = hex.replaceAll('#', '');
    if (h.length == 6) h = 'FF$h';
    final v = int.tryParse(h, radix: 16);
    if (v == null) return null;
    return Color(v);
  }
}

class _FocusPage extends StatelessWidget {
  final PregnancyStoryPage page;
  final DateTime selectedDate;

  const _FocusPage({required this.page, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final milestone = page.milestoneOffsetDays;
    String? milestoneLabel;
    if (milestone != null && milestone > 0) {
      final d = selectedDate.add(Duration(days: milestone));
      milestoneLabel = DateFormat('MMMM d').format(d);
    }

    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3E0E6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      page.iconKey == 'body'
                          ? Icons.favorite_rounded
                          : Icons.child_care_rounded,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (page.eyebrow != null && page.eyebrow!.isNotEmpty)
                          Text(
                            page.eyebrow!,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.35,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        const SizedBox(height: 6),
                        _PulseFocusWord(text: page.focusWord ?? page.title),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (page.image != null && page.image!.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: PregnancyAssetImage(
                path: page.image,
                fit: BoxFit.cover,
                fallbackIcon: Icons.auto_awesome,
                backgroundColor: const Color(0xFFF3E6EA),
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],
        Text(
          page.body,
          style: const TextStyle(
            fontSize: 15,
            height: 1.45,
            color: AppColors.textSecondary,
          ),
        ),
        if (milestoneLabel != null) ...[
          const SizedBox(height: 22),
          Text(
            milestoneLabel,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2C3340),
            ),
          ),
        ],
      ],
    );
  }
}

/// Soft fade + slide-up when a story page appears.
class _StoryEnter extends StatefulWidget {
  final Widget child;

  const _StoryEnter({required this.child});

  @override
  State<_StoryEnter> createState() => _StoryEnterState();
}

class _StoryEnterState extends State<_StoryEnter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    _scale = Tween<double>(begin: 0.97, end: 1).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeOutBack),
    );
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(scale: _scale, child: widget.child),
      ),
    );
  }
}

/// Gentle pulse on the big Flo-style focus word.
class _PulseFocusWord extends StatefulWidget {
  final String text;

  const _PulseFocusWord({required this.text});

  @override
  State<_PulseFocusWord> createState() => _PulseFocusWordState();
}

class _PulseFocusWordState extends State<_PulseFocusWord>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.035).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      alignment: Alignment.centerLeft,
      child: Text(
        widget.text,
        style: const TextStyle(
          fontSize: 34,
          height: 1.05,
          fontWeight: FontWeight.w800,
          color: Color(0xFF2C3340),
        ),
      ),
    );
  }
}

class _TipsPage extends StatelessWidget {
  final PregnancyStoryPage page;

  const _TipsPage({required this.page});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(
          page.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2C3340),
          ),
        ),
        if (page.body.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            page.body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 16),
        for (final tip in page.tips) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  color: const Color(0xFFEDE8F0),
                  child: Text(
                    tip.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Text(
                    tip.body,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _BabyComparePage extends StatelessWidget {
  final PregnancyStoryPage page;

  const _BabyComparePage({required this.page});

  @override
  Widget build(BuildContext context) {
    final baby = page.babyImage ?? page.image;
    final size = page.sizeImage;

    return ListView(
      children: [
        Text(
          page.title.isEmpty ? 'Your baby this week' : page.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2C3340),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              Expanded(child: _img(baby)),
              Container(width: 1, color: AppColors.border),
              Expanded(child: _img(size)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _kv('Length', page.lengthLabel ?? '—'),
        const SizedBox(height: 10),
        _kv('Weight', page.weightLabel ?? '—'),
        const SizedBox(height: 10),
        _kv('Size', page.sizeLabel ?? page.body),
        const SizedBox(height: 16),
        const Text(
          'Measurements are approximate and can vary within the normal range.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _img(String? path) {
    return PregnancyAssetImage(
      path: path,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      fallbackIcon: Icons.child_care_rounded,
      backgroundColor: Colors.white,
    );
  }

  Widget _kv(String k, String v) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$k: ',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2C3340),
            ),
          ),
          TextSpan(
            text: v,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyWeekPage extends StatelessWidget {
  final PregnancyStoryPage page;

  const _BodyWeekPage({required this.page});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(
          page.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2C3340),
          ),
        ),
        if (page.body.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            page.body,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 14),
        if (page.image != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 1.15,
              child: PregnancyAssetImage(
                path: page.image,
                fit: BoxFit.cover,
                fallbackIcon: Icons.favorite_rounded,
                backgroundColor: const Color(0xFFDCEEF8),
              ),
            ),
          ),
        if (page.detailLabel != null) ...[
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: page.detailLabel!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2C3340),
                  ),
                ),
                TextSpan(
                  text: ' ${page.detailBody ?? ''}',
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
