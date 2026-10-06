import '../../models/home/day_cycle_model.dart';

/// Maps Flo API day payloads → [DayCycleModel] for Home / Partner hero (DRY).
/// Copy is EezyCycle-branded but Flo-style: short lead-in + big focus line + soft subtitle.
class CycleDisplayMapper {
  static DayCycleType typeFrom(String? dayType) {
    switch (dayType) {
      case 'period':
        return DayCycleType.period;
      case 'ovulation':
        return DayCycleType.ovulation;
      case 'fertility':
        return DayCycleType.fertility;
      case 'pregnancy':
        return DayCycleType.pregnancy;
      default:
        return DayCycleType.none;
    }
  }

  static DateTime parseDate(String raw) {
    final parts = raw.split('-');
    if (parts.length == 3) {
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }
    return DateTime.tryParse(raw) ?? DateTime.now();
  }

  /// Build hero copy from GET /cycle/today (or a calendar day enriched with summary fields).
  static DayCycleModel fromTodayPayload(Map<String, dynamic> data) {
    final date = parseDate(data['date']?.toString() ?? '');
    var dayType = typeFrom(data['day_type']?.toString());
    final periodDay = data['period_day'] is int
        ? data['period_day'] as int
        : int.tryParse('${data['period_day']}');
    final daysUntilPeriod = data['days_until_next_period'] is int
        ? data['days_until_next_period'] as int
        : int.tryParse('${data['days_until_next_period']}');
    final daysUntilOv = data['days_until_ovulation'] is int
        ? data['days_until_ovulation'] as int
        : int.tryParse('${data['days_until_ovulation']}');
    var phase = data['phase']?.toString();
    final pregnancyWeek = data['pregnancy_week'] is int
        ? data['pregnancy_week'] as int
        : int.tryParse('${data['pregnancy_week']}');
    final pregnancyWeeks = data['pregnancy_weeks'] is int
        ? data['pregnancy_weeks'] as int
        : int.tryParse('${data['pregnancy_weeks']}');
    final pregnancyDays = data['pregnancy_days'] is int
        ? data['pregnancy_days'] as int
        : int.tryParse('${data['pregnancy_days']}');
    final daysUntilDue = data['days_until_due'] is int
        ? data['days_until_due'] as int
        : int.tryParse('${data['days_until_due']}');

    // Never show pregnancy copy when mode was switched off (stale payload / race).
    final pregnancyActive = _isPregnancyModeActive(data);
    if (!pregnancyActive) {
      if (dayType == DayCycleType.pregnancy) dayType = DayCycleType.none;
      if (phase == 'pregnancy') phase = null;
    }

    if (pregnancyActive &&
        (dayType == DayCycleType.pregnancy || phase == 'pregnancy')) {
      final ageLabel = _pregnancyAgeLabel(
        weeks: pregnancyWeeks,
        days: pregnancyDays,
        fallbackWeek: pregnancyWeek,
        daysUntilDue: daysUntilDue,
      );
      final due = daysUntilDue;
      final eddLabel = data['edd_source_label']?.toString() ??
          (data['profile'] is Map
              ? (data['profile'] as Map)['edd_source_label']?.toString()
              : null);
      final dueSubtitle = due == null
          ? 'Estimates only — not medical advice'
          : due >= 0
          ? due == 0
                ? 'Your due date is today'
                : due == 1
                ? '1 day until your due date'
                : '$due days until your due date'
          : '${-due} day${due == -1 ? '' : 's'} past your due date';
      final datingNote = eddLabel != null && eddLabel.isNotEmpty
          ? '$dueSubtitle · $eddLabel'
          : dueSubtitle;

      return DayCycleModel(
        date: date,
        type: DayCycleType.pregnancy,
        headline: "You're",
        highlight: ageLabel,
        subtitle: datingNote,
        partnerHeadline: "She's",
        partnerHighlight: ageLabel,
        partnerSubtitle: due == null
            ? 'A gentle check-in means a lot today'
            : due >= 0
            ? 'Due date in $due day${due == 1 ? '' : 's'} — be her calm support'
            : 'Stay close and supportive right now',
      );
    }

    if (data['message_key'] == 'today_log_period' ||
        data['cycle_day'] == null && dayType == DayCycleType.none) {
      return DayCycleModel(
        date: date,
        type: DayCycleType.none,
        headline: 'Get started',
        highlight: 'Log your period',
        subtitle: 'to unlock cycle predictions',
        partnerHeadline: 'Waiting on cycle data',
        partnerHighlight: 'No period logged yet',
        partnerSubtitle: 'Predictions appear after she logs a period',
      );
    }

    if (dayType == DayCycleType.period) {
      final p = periodDay ?? 1;
      return DayCycleModel(
        date: date,
        type: DayCycleType.period,
        headline: 'Today is',
        highlight: 'Period day $p',
        subtitle: 'Rest, hydrate, and be kind to your body',
        partnerHeadline: 'She is on',
        partnerHighlight: 'Period day $p',
        partnerSubtitle: 'Extra care, rest, and patience help today',
        periodDay: p,
      );
    }

    if (dayType == DayCycleType.ovulation) {
      final soft = _isLowConfidence(data);
      final evidenceNote = _evidenceSubtitle(data);
      return DayCycleModel(
        date: date,
        type: DayCycleType.ovulation,
        headline: soft ? 'Around now' : 'Predicted',
        highlight: soft ? 'Likely ovulation' : 'Ovulation day',
        subtitle: evidenceNote ??
            (soft
                ? 'Estimate — timing can shift a few days'
                : 'Highest chance of getting pregnant — estimate only'),
        partnerHeadline: soft ? 'Around now' : 'Predicted',
        partnerHighlight: soft ? 'Likely ovulation' : 'Her ovulation day',
        partnerSubtitle: 'A thoughtful check-in goes a long way',
      );
    }

    if (dayType == DayCycleType.fertility) {
      final ovIn = daysUntilOv;
      final softLabel = data['soft_confidence_label']?.toString();
      final highlight = ovIn == null
          ? 'Fertile window'
          : ovIn <= 0
          ? 'today'
          : ovIn == 1
          ? '1 day'
          : '$ovIn days';
      return DayCycleModel(
        date: date,
        type: DayCycleType.fertility,
        headline: ovIn != null && ovIn > 0
            ? 'Higher chance of getting pregnant in'
            : 'Higher chance of getting pregnant',
        highlight: highlight,
        subtitle: softLabel != null && softLabel.isNotEmpty
            ? softLabel
            : ovIn != null && ovIn > 0
            ? 'Estimated fertile window (timing estimate only — not contraception)'
            : 'Estimated fertile window — not contraceptive advice',
        partnerHeadline: ovIn != null && ovIn > 0
            ? 'Higher chance of conceiving in'
            : 'Higher chance of conceiving',
        partnerHighlight: highlight,
        partnerSubtitle: 'Estimated fertile window — timing estimate only',
      );
    }

    if (phase == 'follicular') {
      final ovIn = daysUntilOv ?? 0;
      return DayCycleModel(
        date: date,
        type: DayCycleType.none,
        headline: ovIn > 0 ? 'Ovulation in' : 'Right now',
        highlight: ovIn <= 0
            ? 'Follicular phase'
            : ovIn == 1
            ? '1 day'
            : '$ovIn days',
        subtitle: 'Energy often rises after your period',
        partnerHeadline: ovIn > 0 ? 'Her ovulation in' : "Your partner's cycle",
        partnerHighlight: ovIn <= 0
            ? 'Follicular phase'
            : ovIn == 1
            ? '1 day'
            : '$ovIn days',
        partnerSubtitle: 'A great stretch for shared plans and energy',
      );
    }

    final periodIn = daysUntilPeriod ?? 0;
    final soft = _isLowConfidence(data);
    final softLabel = data['soft_confidence_label']?.toString();
    return DayCycleModel(
      date: date,
      type: DayCycleType.none,
      headline: periodIn > 0
          ? (soft ? 'Period around' : 'Period in')
          : 'Right now',
      highlight: periodIn <= 0
          ? 'Luteal phase'
          : periodIn == 1
          ? '1 day'
          : '$periodIn days',
      subtitle: periodIn > 0
          ? (softLabel != null && softLabel.isNotEmpty
                ? softLabel
                : soft
                ? 'Most likely timing — estimates only, not certainty'
                : 'You may notice PMS-like changes — estimates only')
          : (softLabel != null && softLabel.isNotEmpty
                ? softLabel
                : 'Your body is winding toward the next cycle'),
      partnerHeadline: periodIn > 0
          ? (soft
                ? "Your partner's period may start around"
                : "Your partner's period may start in")
          : "Your partner's cycle",
      partnerHighlight: periodIn <= 0
          ? 'Luteal phase'
          : periodIn == 1
          ? '1 day'
          : '$periodIn days',
      partnerSubtitle: 'Gentle support and low-pressure plans help',
    );
  }

  /// Soft copy when engine confidence is low (Phase 2).
  static bool _isLowConfidence(Map<String, dynamic> data) {
    final c = data['confidence']?.toString().toLowerCase();
    if (c == 'low') return true;
    final profile = data['profile'];
    if (profile is Map) {
      final pc = profile['prediction_confidence']?.toString().toLowerCase();
      if (pc == 'low') return true;
    }
    return false;
  }

  /// Soft evidence wording (v4.1) — timing estimates only; never confirmed ovulation.
  static String? _evidenceSubtitle(Map<String, dynamic> data) {
    final status = data['estimate_status']?.toString();
    final level = data['evidence_level']?.toString().toUpperCase();
    final sources = data['evidence_sources'];
    final list = <String>[];
    if (sources is List) {
      list.addAll(sources.map((e) => e.toString()));
    } else if (sources is String) {
      list.add(sources);
    }

    final hasLh = list.any(
      (s) => s.contains('ovulation_test') || s.contains('lh'),
    );
    final hasBbt = list.any((s) => s.contains('bbt'));

    if (status == 'retrospective_estimate' || level == 'D' || hasBbt) {
      return 'Timing estimate narrowed from your temperature pattern — not a confirmed ovulation day';
    }
    if (status == 'updated_estimate' || level == 'C' || hasLh) {
      return 'Timing estimate updated from your LH test (expected within about 1–2 days after a positive result) — still an estimate, not certainty';
    }
    if (level == 'B') {
      return 'Timing estimate uses your personal cycle history';
    }
    return null;
  }

  /// Lightweight day cell model from GET /cycle/calendar (or /partner/calendar).
  /// Always fills partner copy so Partner Home doesn't flash woman headlines
  /// when tapping the date strip before /today returns.
  static DayCycleModel fromCalendarDay(Map<String, dynamic> day) {
    final date = parseDate(day['date']?.toString() ?? '');
    final type = typeFrom(
      day['day_type']?.toString() ?? day['prediction_type']?.toString(),
    );
    final periodDay = day['period_day'] is int
        ? day['period_day'] as int
        : int.tryParse('${day['period_day']}');

    switch (type) {
      case DayCycleType.period:
        final pLabel =
            periodDay != null ? 'Period day $periodDay' : 'Period day';
        return DayCycleModel(
          date: date,
          type: type,
          headline: 'Today is',
          highlight: pLabel,
          subtitle: 'Rest, hydrate, and be kind to your body',
          partnerHeadline: 'She is on',
          partnerHighlight: pLabel,
          partnerSubtitle: 'Extra care, rest, and patience help today',
          periodDay: periodDay,
        );
      case DayCycleType.ovulation:
        return DayCycleModel(
          date: date,
          type: type,
          headline: 'Predicted',
          highlight: 'Ovulation day',
          subtitle: 'Highest chance of getting pregnant — estimate only',
          partnerHeadline: 'Predicted',
          partnerHighlight: 'Her ovulation day',
          partnerSubtitle: 'A thoughtful check-in goes a long way',
        );
      case DayCycleType.fertility:
        return DayCycleModel(
          date: date,
          type: type,
          headline: 'Higher chance of getting pregnant',
          highlight: 'Fertile window',
          subtitle: 'Estimated fertile window — not contraceptive advice',
          partnerHeadline: 'Higher chance of conceiving',
          partnerHighlight: 'Fertile window',
          partnerSubtitle: 'Estimated fertile window — timing estimate only',
        );
      case DayCycleType.pregnancy:
        return DayCycleModel(
          date: date,
          type: type,
          headline: "You're",
          highlight: 'Expecting',
          subtitle: 'Estimates only — not medical advice',
          partnerHeadline: "She's",
          partnerHighlight: 'Expecting',
          partnerSubtitle: 'A gentle check-in means a lot today',
        );
      case DayCycleType.none:
        return DayCycleModel(
          date: date,
          type: type,
          headline: 'Cycle day',
          highlight: 'Tracking',
          partnerHeadline: "Your partner's cycle",
          partnerHighlight: 'Steady day',
          partnerSubtitle: 'Small gestures of care make a big difference',
        );
    }
  }

  static String titleForExperienceMode(String? mode) {
    switch (mode) {
      case 'track_cycle':
        return 'Track cycle';
      case 'get_pregnant':
        return 'Get pregnant';
      case 'track_pregnancy':
        return 'Track pregnancy';
      case 'perimenopause':
        return 'Track perimenopause';
      case 'partner':
        return 'Partner';
      default:
        return 'Track cycle';
    }
  }

  static String experienceModeFromTitle(String title) {
    switch (title) {
      case 'Track cycle':
        return 'track_cycle';
      case 'Get pregnant':
        return 'get_pregnant';
      case 'Track pregnancy':
        return 'track_pregnancy';
      case 'Track perimenopause':
        return 'perimenopause';
      case 'Partner':
        return 'partner';
      default:
        return 'track_cycle';
    }
  }

  static bool _isPregnancyModeActive(Map<String, dynamic> data) {
    bool asBool(dynamic v) =>
        v == true || v == 1 || v?.toString() == '1' || v?.toString() == 'true';

    if (asBool(data['pregnancy_mode_active']) ||
        asBool(data['pregnancy_mode'])) {
      return true;
    }
    final profile = data['profile'];
    if (profile is Map) {
      return asBool(profile['pregnancy_mode_active']);
    }
    // Legacy payloads with pregnancy day_type but no flag — treat as active.
    final dayType = data['day_type']?.toString();
    final phase = data['phase']?.toString();
    final mode = data['experience_mode']?.toString() ??
        (profile is Map ? profile['experience_mode']?.toString() : null);
    if (mode != null && mode.isNotEmpty && mode != 'track_pregnancy') {
      return false;
    }
    return dayType == 'pregnancy' || phase == 'pregnancy';
  }

  /// e.g. "1 week 1 day pregnant", "12 weeks 3 days pregnant"
  static String _pregnancyAgeLabel({
    int? weeks,
    int? days,
    int? fallbackWeek,
    int? daysUntilDue,
  }) {
    var w = weeks;
    var d = days;
    if (w == null || d == null) {
      if (daysUntilDue != null) {
        final pregnant = (280 - daysUntilDue).clamp(0, 300);
        w = pregnant ~/ 7;
        d = pregnant % 7;
      } else {
        w = (fallbackWeek ?? 1) - 1;
        if (w < 0) w = 0;
        d = 0;
      }
    }

    final weekPart = w == 1 ? '1 week' : '$w weeks';
    final dayPart = d == 1 ? '1 day' : '$d days';

    if (w <= 0 && d <= 0) return '1 day pregnant';
    if (w <= 0) return '$dayPart pregnant';
    if (d == 0) return '$weekPart pregnant';
    return '$weekPart $dayPart pregnant';
  }
}
