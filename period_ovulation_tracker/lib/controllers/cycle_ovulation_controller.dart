import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../core/services/api_service.dart';
import '../core/services/cycle_display_mapper.dart';
import 'auth_controller.dart';

class CyclePhaseRow {
  const CyclePhaseRow({
    required this.title,
    required this.daysLabel,
    required this.status,
    required this.isCurrent,
  });

  final String title;
  final String daysLabel;
  final String status;
  final bool isCurrent;
}

class CycleOvulationController extends GetxController {
  final ApiClient _api = ApiClient();

  final RxBool isLoading = true.obs;
  final RxBool hasLoaded = false.obs;
  final RxBool hasError = false.obs;
  final RxBool pregnancyMode = false.obs;
  final RxBool needsPeriodLog = false.obs;

  final RxString ovulationHeadline = '—'.obs;
  final RxString ovulationSubtitle = ''.obs;
  final RxString avgCycleLabel = '—'.obs;
  final RxString avgCycleHint = ''.obs;
  final RxString avgPeriodLabel = '—'.obs;
  final RxString avgPeriodHint = ''.obs;
  final RxString historyTitle = 'Recent History Trends'.obs;
  final RxString historyBody = ''.obs;
  final RxList<CyclePhaseRow> phases = <CyclePhaseRow>[].obs;

  @override
  void onInit() {
    super.onInit();
    Future.microtask(load);
  }

  Future<void> load() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      if (Get.isRegistered<AuthController>()) {
        await Get.find<AuthController>().ensureGuestSession();
      }

      final now = DateTime.now();
      final from = DateFormat('yyyy-MM-dd').format(
        DateTime(now.year - 1, now.month, now.day),
      );
      final to = DateFormat('yyyy-MM-dd').format(now);
      final todayPath =
          '${ApiEndPoints.cycleToday}?date=${DateFormat('yyyy-MM-dd').format(now)}';
      final periodPath = '${ApiEndPoints.cyclePeriodDays}?from=$from&to=$to';

      final results = await Future.wait([
        _api.get(todayPath),
        _api.get(periodPath),
      ]);

      final today = ApiClient.unwrapData(results[0]);
      final periodPayload = ApiClient.unwrapData(results[1]);
      if (today == null) {
        hasError.value = true;
        _applyEmpty();
        return;
      }

      _applyToday(today);
      _applyHistory(periodPayload, today);
    } catch (_) {
      hasError.value = true;
      _applyEmpty();
    } finally {
      isLoading.value = false;
      hasLoaded.value = true;
    }
  }

  void _applyEmpty() {
    ovulationHeadline.value = 'Unavailable';
    ovulationSubtitle.value = 'Pull to refresh or try again later';
    avgCycleLabel.value = '—';
    avgPeriodLabel.value = '—';
    avgCycleHint.value = '';
    avgPeriodHint.value = '';
    historyTitle.value = 'Recent History Trends';
    historyBody.value = 'Could not load cycle data from the server.';
    phases.clear();
    pregnancyMode.value = false;
    needsPeriodLog.value = false;
  }

  void _applyToday(Map<String, dynamic> data) {
    final profile = data['profile'] is Map
        ? Map<String, dynamic>.from(data['profile'] as Map)
        : <String, dynamic>{};

    final pregnancy = _truthy(profile['pregnancy_mode_active']) ||
        data['phase']?.toString() == 'pregnancy' ||
        data['day_type']?.toString() == 'pregnancy';
    pregnancyMode.value = pregnancy;

    final C = _intOf(data['avg_cycle_length']) ??
        _intOf(profile['avg_cycle_length']) ??
        28;
    final P = _intOf(data['avg_period_length']) ??
        _intOf(profile['avg_period_length']) ??
        5;
    final L = _intOf(data['luteal_phase_days']) ?? 14;

    avgCycleLabel.value = '$C Days';
    avgPeriodLabel.value = '$P Days';
    avgCycleHint.value = C >= 21 && C <= 35 ? 'Normal range' : 'Personal average';
    avgPeriodHint.value = P >= 3 && P <= 7 ? 'Typical range' : 'Personal average';

    if (pregnancy) {
      needsPeriodLog.value = false;
      final weeks = _intOf(data['pregnancy_weeks']) ??
          _intOf(data['pregnancy_week']);
      final days = _intOf(data['pregnancy_days']);
      final due = data['due_date']?.toString() ??
          profile['due_date']?.toString();
      ovulationHeadline.value = weeks == null
          ? 'Pregnancy mode'
          : days == null
              ? 'Week $weeks'
              : 'Week $weeks + $days days';
      ovulationSubtitle.value = due == null || due.isEmpty
          ? 'Cycle & ovulation pause while pregnancy mode is on'
          : 'Due ${_prettyDate(due)} · cycle predictions paused';
      phases.assignAll(const []);
      return;
    }

    if (data['message_key'] == 'today_log_period' ||
        data['cycle_day'] == null &&
            (data['last_period_start'] == null &&
                profile['last_period_start'] == null)) {
      needsPeriodLog.value = true;
      ovulationHeadline.value = 'Log your period';
      ovulationSubtitle.value = 'Predictions unlock after your first log';
      phases.assignAll(const []);
      return;
    }

    needsPeriodLog.value = false;

    final daysUntilOv = _intOf(data['days_until_ovulation']);
    final ovDate = data['ovulation_date']?.toString();
    final dayType = data['day_type']?.toString();
    final fertileMode =
        data['fertile_window_mode']?.toString() ??
        profile['fertile_window_mode']?.toString() ??
        'standard';

    if (dayType == 'ovulation' || daysUntilOv == 0) {
      ovulationHeadline.value = ovDate == null
          ? 'Today'
          : 'Today (${_prettyDate(ovDate)})';
      ovulationSubtitle.value = 'Predicted ovulation day';
    } else if (daysUntilOv != null && daysUntilOv > 0) {
      final when = daysUntilOv == 1 ? 'In 1 Day' : 'In $daysUntilOv Days';
      ovulationHeadline.value = ovDate == null
          ? when
          : '$when (${_prettyDate(ovDate)})';
      ovulationSubtitle.value = fertileMode == 'wide'
          ? 'Wider fertility window while cycles settle'
          : daysUntilOv <= 5
              ? 'High fertility window starts soon'
              : 'Predicted ovulation approaching';
    } else if (daysUntilOv != null && daysUntilOv < 0) {
      ovulationHeadline.value = ovDate == null
          ? 'Passed this cycle'
          : 'Was ${_prettyDate(ovDate)}';
      ovulationSubtitle.value = 'Next estimate after your next period';
    } else {
      ovulationHeadline.value = ovDate == null
          ? 'Estimating…'
          : _prettyDate(ovDate);
      ovulationSubtitle.value = 'Based on your logged cycles';
    }

    final cycleDay = _intOf(data['cycle_day']);
    final ovCycleDay = _ovulationCycleDay(data, C, L);
    phases.assignAll(_buildPhases(
      C: C,
      ovCycleDay: ovCycleDay,
      cycleDay: cycleDay,
      wideFertile: fertileMode == 'wide',
    ));
  }

  void _applyHistory(
    Map<String, dynamic>? periodPayload,
    Map<String, dynamic> today,
  ) {
    if (pregnancyMode.value) {
      historyTitle.value = 'Pregnancy mode';
      historyBody.value =
          'Cycle length trends pause while pregnancy mode is on.';
      return;
    }

    final dates = <String>[];
    final days = periodPayload?['days'];
    if (days is List) {
      for (final raw in days) {
        if (raw is! Map) continue;
        if (raw['is_predicted'] == true) continue;
        final d = raw['date']?.toString();
        if (d != null && d.isNotEmpty) dates.add(d);
      }
    }

    final runs = _groupBleedRuns(dates);
    final completed = <int>[];
    for (var i = 0; i < runs.length - 1; i++) {
      final len = _diffDays(runs[i].start, runs[i + 1].start);
      if (len >= 21 && len <= 45) completed.add(len);
    }

    final recent = completed.length > 6
        ? completed.sublist(completed.length - 6)
        : completed;

    if (recent.isEmpty) {
      historyTitle.value = 'Building your history';
      historyBody.value = runs.isEmpty
          ? 'Log a few periods so we can show regularity trends.'
          : 'Need at least two period starts to measure cycle length.';
      return;
    }

    final avg = recent.reduce((a, b) => a + b) / recent.length;
    var maxVar = 0;
    for (final len in recent) {
      final v = (len - avg).abs().round();
      if (v > maxVar) maxVar = v;
    }
    final span = recent.reduce((a, b) => a > b ? a : b) -
        recent.reduce((a, b) => a < b ? a : b);

    historyTitle.value = recent.length >= 3
        ? 'Last ${recent.length} cycles'
        : 'Recent cycle lengths';

    if (maxVar <= 2 && span <= 3) {
      historyBody.value =
          'Your cycles have been very regular with a $maxVar-day variance maximum.';
    } else if (maxVar <= 5) {
      historyBody.value =
          'Mostly steady — lengths varied by up to $span days across recent cycles.';
    } else {
      historyBody.value =
          'Lengths ranged ${recent.reduce((a, b) => a < b ? a : b)}–${recent.reduce((a, b) => a > b ? a : b)} days. Averages still guide predictions.';
    }

    // Prefer server averages when history exists; hints already set from today.
    final C = _intOf(today['avg_cycle_length']);
    if (C != null) {
      avgCycleLabel.value = '$C Days';
    }
  }

  List<CyclePhaseRow> _buildPhases({
    required int C,
    required int ovCycleDay,
    required int? cycleDay,
    required bool wideFertile,
  }) {
    final fertileStart = wideFertile
        ? (ovCycleDay - 9).clamp(1, C)
        : (ovCycleDay - 5).clamp(1, C);
    final fertileEnd = wideFertile
        ? (ovCycleDay + 4).clamp(1, C)
        : (ovCycleDay + 1).clamp(1, C);

    final follicularEnd = (fertileStart - 1).clamp(1, C);
    final lutealStart = (fertileEnd + 1).clamp(1, C);

    final ranges = [
      (title: 'Follicular Phase', start: 1, end: follicularEnd),
      (
        title: 'Ovulation Window',
        start: fertileStart,
        end: fertileEnd,
      ),
      (title: 'Luteal Phase', start: lutealStart, end: C),
    ];

    var sawUpcoming = false;
    return [
      for (final r in ranges)
        CyclePhaseRow(
          title: r.title,
          daysLabel: r.start == r.end
              ? 'Day ${r.start}'
              : 'Days ${r.start} - ${r.end}',
          status: () {
            if (cycleDay == null) return '—';
            if (cycleDay > r.end) return 'Completed';
            if (cycleDay >= r.start && cycleDay <= r.end) return 'Current';
            if (!sawUpcoming) {
              sawUpcoming = true;
              return 'Upcoming';
            }
            return 'Pending';
          }(),
          isCurrent: cycleDay != null &&
              cycleDay >= r.start &&
              cycleDay <= r.end,
        ),
    ];
  }

  int _ovulationCycleDay(Map<String, dynamic> data, int C, int L) {
    final last = data['last_period_start']?.toString() ??
        (data['profile'] is Map
            ? (data['profile'] as Map)['last_period_start']?.toString()
            : null);
    final ov = data['ovulation_date']?.toString();
    if (last != null && ov != null) {
      final d = _diffDays(last, ov) + 1;
      if (d >= 1 && d <= C + 7) return d;
    }
    // Flo phase math uses C - L as ovulation cycle day index.
    return (C - L).clamp(1, C);
  }

  String _prettyDate(String ymd) {
    try {
      return DateFormat('MMM d').format(CycleDisplayMapper.parseDate(ymd));
    } catch (_) {
      return ymd;
    }
  }

  static int? _intOf(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v');
  }

  static bool _truthy(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = '$v'.toLowerCase();
    return s == 'true' || s == '1';
  }

  static int _diffDays(String a, String b) {
    final da = CycleDisplayMapper.parseDate(a);
    final db = CycleDisplayMapper.parseDate(b);
    return db.difference(da).inDays;
  }

  static List<({String start, String end, int length})> _groupBleedRuns(
    List<String> raw,
  ) {
    final dates = {...raw.map((d) => d.trim())}.where((d) => d.isNotEmpty).toList()
      ..sort();
    if (dates.isEmpty) return [];

    final runs = <({String start, String end, int length})>[];
    var start = dates.first;
    var prev = dates.first;

    for (var i = 1; i < dates.length; i++) {
      if (_diffDays(prev, dates[i]) == 1) {
        prev = dates[i];
        continue;
      }
      runs.add((
        start: start,
        end: prev,
        length: _diffDays(start, prev) + 1,
      ));
      start = dates[i];
      prev = dates[i];
    }
    runs.add((
      start: start,
      end: prev,
      length: _diffDays(start, prev) + 1,
    ));
    return runs;
  }
}
