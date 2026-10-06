import 'dart:math';

import 'package:flutter/material.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/models/article/cycle_article_model.dart';
import 'package:period_ovulation_tracker/views/article/article_view.dart';

/// A short, actionable tip shown on Home → Recommended Actions.
class RecommendedAction {
  final String id;
  final String title;
  final String description;
  final String detailIntro;
  final List<ArticleSection> sections;
  final List<String> takeaways;
  final String tryThis;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String category;
  final CyclePhaseType phase;
  final List<CyclePhaseType> phases;

  const RecommendedAction({
    required this.id,
    required this.title,
    required this.description,
    required this.detailIntro,
    required this.sections,
    required this.takeaways,
    this.tryThis = '',
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.category,
    required this.phase,
    this.phases = const [],
  });

  List<CyclePhaseType> get allPhases =>
      phases.isEmpty ? [phase] : {phase, ...phases}.toList();

  bool matchesPhase(CyclePhaseType p) => allPhases.contains(p);

  /// Opens the shared article reader with full coach-style content.
  ArticleView toDetailView({String phaseLabel = ''}) {
    final trySection = tryThis.trim().isEmpty
        ? const <ArticleSection>[]
        : [
            ArticleSection(
              heading: 'Try this today',
              body: tryThis.trim(),
            ),
          ];

    return ArticleView(
      category: category,
      title: title,
      readTime: '2 min read',
      author: 'EezyCycle Coach',
      publishedDate: phaseLabel.isEmpty
          ? 'Cycle-smart tip'
          : 'For your $phaseLabel phase',
      heroSummary: detailIntro.isNotEmpty ? detailIntro : description,
      sections: [...sections, ...trySection],
      takeaways: takeaways,
    );
  }
}

/// 30 curated actions. Home shows a random 3 matched to the current cycle phase.
abstract final class RecommendedActionsCatalog {
  static const List<RecommendedAction> all = [
    // —— Menstrual (period) ——
    RecommendedAction(
      id: 'm1',
      title: 'Rest with intention',
      description:
          'Your body is shedding — honor low energy with a slower morning and warm layers.',
      detailIntro:
          'During your period, prostaglandins and blood loss can leave you drained. Rest is not laziness — it is recovery your body is asking for.',
      sections: [
        ArticleSection(
          heading: 'Why this helps',
          body:
              'Estrogen and progesterone are at their lowest. Heart rate and core temperature often dip slightly, and many people feel more sensitive to cold and stress. Giving yourself a softer morning reduces the urge to “push through” and flare cramps or fatigue.',
        ),
        ArticleSection(
          heading: 'How to do it',
          body:
              'Keep the first 60–90 minutes of your day low-stimulus: warm drink, loose clothes, no back-to-back meetings if you can help it. If you must work, batch deep focus later when energy often improves.',
        ),
      ],
      takeaways: [
        'Low hormones = lower reserve — plan fewer “musts”.',
        'Warmth + slower pace often eases period discomfort.',
        'Rest today supports a stronger week ahead.',
      ],
      tryThis:
          'Block 20 minutes this morning for nothing: sit with a warm drink, stretch gently, or lie with a heat pack. No phone scrolling if you can avoid it.',
      icon: Icons.bedtime_rounded,
      iconBg: Color(0xFFFFEBEE),
      iconColor: AppColors.period,
      category: 'Rest & Flow',
      phase: CyclePhaseType.menstrual,
    ),
    RecommendedAction(
      id: 'm2',
      title: 'Warm comfort foods',
      description:
          'Soups, stews, and iron-rich meals can ease cramps and top up energy.',
      detailIntro:
          'Bleeding uses iron and fluids. Warm, mineral-rich meals are easier to digest when appetite dips and can take the edge off cramps.',
      sections: [
        ArticleSection(
          heading: 'What to put on the plate',
          body:
              'Think beans, lentils, leafy greens, eggs, lean red meat if you eat it, or fortified grains. Pair plant iron with vitamin C (citrus, peppers, tomatoes) to absorb more. Ginger or turmeric in broths may feel soothing.',
        ),
        ArticleSection(
          heading: 'What to ease up on',
          body:
              'Very salty snacks can worsen bloating. Excess caffeine may intensify cramps for some people. Notice your own pattern rather than following rigid rules.',
        ),
      ],
      takeaways: [
        'Warm meals often feel better than cold salads on heavy days.',
        'Iron + vitamin C is a useful period pairing.',
        'Hydrating soups count toward fluids and comfort.',
      ],
      tryThis:
          'Make or reheat one warm bowl today (soup, dal, or stew) and add something iron-friendly — spinach, beans, or a soft-boiled egg.',
      icon: Icons.soup_kitchen_rounded,
      iconBg: Color(0xFFFFF3E0),
      iconColor: AppColors.warning,
      category: 'Nutrition',
      phase: CyclePhaseType.menstrual,
    ),
    RecommendedAction(
      id: 'm3',
      title: 'Gentle stretch or yoga',
      description:
          'Light hip openers and breathing can reduce pelvic tension without overdoing it.',
      detailIntro:
          'You do not need a hard workout on day 1–2. Gentle mobility can calm the nervous system and loosen the low back and hips where period tension collects.',
      sections: [
        ArticleSection(
          heading: 'Safe movement ideas',
          body:
              'Child’s pose, cat-cow, supine twists, and slow walking are usually enough. Keep intensity conversational — if you cannot breathe easily, dial it back.',
        ),
        ArticleSection(
          heading: 'When to skip',
          body:
              'Skip inverted or intense poses if you feel dizzy, faint, or have unusually heavy bleeding. Listen to pain (sharp vs dull) and stop if something feels wrong.',
        ),
      ],
      takeaways: [
        'Mobility > intensity on heavy flow days.',
        'Breathing out longer than you breathe in can soften cramps.',
        '10–15 minutes is enough to count.',
      ],
      tryThis:
          'Do 8 slow cat-cows and 1 minute in child’s pose. Breathe: inhale 4 counts, exhale 6.',
      icon: Icons.self_improvement_rounded,
      iconBg: Color(0xFFF3E5F5),
      iconColor: AppColors.fertility,
      category: 'Fitness',
      phase: CyclePhaseType.menstrual,
    ),
    RecommendedAction(
      id: 'm4',
      title: 'Heat for comfort',
      description:
          'A warm compress on your lower belly can help ease period discomfort.',
      detailIntro:
          'Heat increases local blood flow and can reduce the intensity of uterine muscle contractions that cause cramps.',
      sections: [
        ArticleSection(
          heading: 'How to use heat well',
          body:
              'Place a warm (not scalding) pack on your lower abdomen or low back for 15–20 minutes. A warm shower aimed at the same area works too. Reapply as needed through the day.',
        ),
        ArticleSection(
          heading: 'Pair it with',
          body:
              'Hydration, a short walk, or over-the-counter pain relief you already tolerate (follow label guidance). Heat alone helps many people enough to stay functional.',
        ),
      ],
      takeaways: [
        'Warm, not hot — protect your skin.',
        '15–20 minutes per session is a solid target.',
        'Low back heat helps if cramps radiate there.',
      ],
      tryThis:
          'Set a timer for 15 minutes with a heat pack while you listen to a calm playlist or podcast.',
      icon: Icons.thermostat_rounded,
      iconBg: Color(0xFFFFEBEE),
      iconColor: AppColors.accent,
      category: 'PMS Care',
      phase: CyclePhaseType.menstrual,
    ),
    RecommendedAction(
      id: 'm5',
      title: 'Hydrate a little extra',
      description:
          'Warm water or herbal tea supports circulation and may soften bloating.',
      detailIntro:
          'Fluid shifts and prostaglandins can leave you feeling puffy and sluggish. Steady sipping often feels better than chugging large amounts at once.',
      sections: [
        ArticleSection(
          heading: 'Smart fluids',
          body:
              'Warm water, herbal teas (ginger, peppermint, chamomile if you like them), and broths count. If you feel lightheaded, include a snack with electrolytes or a pinch of salt in food — not only plain water all day.',
        ),
        ArticleSection(
          heading: 'A simple rhythm',
          body:
              'Aim for a glass with breakfast, mid-morning, lunch, afternoon, and evening. Adjust for climate and activity. Pale straw-colored urine is a rough guide you are doing fine.',
        ),
      ],
      takeaways: [
        'Warm drinks often feel kinder on period days.',
        'Sip through the day instead of one big chug.',
        'Tea and broth count toward hydration.',
      ],
      tryThis:
          'Fill a bottle or mug now and finish it before your next meal. Repeat once more this afternoon.',
      icon: Icons.water_drop_rounded,
      iconBg: Color(0xFFE3F2FD),
      iconColor: AppColors.info,
      category: 'Wellness',
      phase: CyclePhaseType.menstrual,
    ),
    RecommendedAction(
      id: 'm6',
      title: 'Protect your calendar',
      description:
          'Keep tonight lighter if you can — fewer commitments, more recovery.',
      detailIntro:
          'Social and work load rarely pause for your cycle. When you can, reduce optional demands on the heaviest days so your nervous system is not fighting on two fronts.',
      sections: [
        ArticleSection(
          heading: 'What “lighter” looks like',
          body:
              'Move a non-urgent meeting, order in instead of cooking a big meal, or say no to a late night. This is temporary triage, not quitting life.',
        ),
        ArticleSection(
          heading: 'Communicate simply',
          body:
              'You do not owe a medical essay. “I’m running low energy tonight — can we keep it short / reschedule?” is enough with people who care about you.',
        ),
      ],
      takeaways: [
        'Fewer decisions = less drain on period days.',
        'Protecting recovery is a skill, not a weakness.',
        'One lighter evening can change how tomorrow feels.',
      ],
      tryThis:
          'Cancel or shorten one optional commitment today. Replace it with an early wind-down.',
      icon: Icons.event_busy_rounded,
      iconBg: Color(0xFFFCE4EC),
      iconColor: AppColors.period,
      category: 'Wellness',
      phase: CyclePhaseType.menstrual,
    ),

    // —— Follicular ——
    RecommendedAction(
      id: 'f1',
      title: 'Plan a high-energy activity',
      description:
          'Estrogen is rising — a great window for workouts, creative work, or social plans.',
      detailIntro:
          'After your period, estrogen climbs. Many people feel clearer, more outgoing, and more capable of harder training or bigger projects.',
      sections: [
        ArticleSection(
          heading: 'Use the window',
          body:
              'Schedule the thing that needs spark: a tough workout, a presentation, a date, or deep creative work. Your brain’s reward and verbal fluency often feel sharper here.',
        ),
        ArticleSection(
          heading: 'Stay grounded',
          body:
              'Rising energy can tip into overcommitment. Pick one high-value activity — not five — so you finish the day proud instead of fried.',
        ),
      ],
      takeaways: [
        'Follicular phase favors challenge and novelty.',
        'One intentional “high-energy” plan beats a packed chaos day.',
        'Capture ideas — this phase is great for brainstorming.',
      ],
      tryThis:
          'Put one energizing plan on today’s calendar (workout, coffee with a friend, or a creative block) and protect that slot.',
      icon: Icons.favorite_outline_rounded,
      iconBg: AppColors.primaryLight,
      iconColor: AppColors.accent,
      category: 'Fitness',
      phase: CyclePhaseType.follicular,
    ),
    RecommendedAction(
      id: 'f2',
      title: 'Try something new',
      description:
          'Curiosity peaks now. Start a habit, class, or project you’ve been postponing.',
      detailIntro:
          'Rising estrogen is linked with more exploratory mood for many people. Novelty feels less scary and more exciting — a useful time to begin.',
      sections: [
        ArticleSection(
          heading: 'Start tiny',
          body:
              'A new recipe, a 10-minute language lesson, a different walking route, or the first page of a project counts. Momentum matters more than perfection.',
        ),
        ArticleSection(
          heading: 'Why now',
          body:
              'Habits stick better when you attach them to a phase where energy cooperates. Tag this start to “post-period week” so you remember to retry next cycle.',
        ),
      ],
      takeaways: [
        'Novelty is easier when energy is rising.',
        'Small starts beat waiting for the perfect plan.',
        'Note what you begin — review next follicular week.',
      ],
      tryThis:
          'Spend 15 minutes on one new thing you have postponed. Stop when the timer ends — progress, not polish.',
      icon: Icons.auto_awesome_rounded,
      iconBg: Color(0xFFFFF8E1),
      iconColor: AppColors.ovulation,
      category: 'Wellness',
      phase: CyclePhaseType.follicular,
    ),
    RecommendedAction(
      id: 'f3',
      title: 'Fresh, colorful plates',
      description:
          'Lean proteins, greens, and fermented foods support this rebuilding phase.',
      detailIntro:
          'Your body is rebuilding the uterine lining and often tolerates lighter, fresher food better than heavy comfort meals.',
      sections: [
        ArticleSection(
          heading: 'Build the plate',
          body:
              'Half colorful plants, a palm of protein (fish, eggs, tofu, legumes, yogurt), and a fist of complex carbs. Fermented foods (yogurt, kimchi, kefir) can support gut comfort if you tolerate them.',
        ),
        ArticleSection(
          heading: 'Fuel the rising energy',
          body:
              'Do not under-eat just because you feel lighter. Training and brain work need carbs — fruit, oats, rice, or potatoes keep you from mid-afternoon crashes.',
        ),
      ],
      takeaways: [
        'Colorful plants + protein = solid follicular fuel.',
        'Eat enough to match your higher activity.',
        'Fermented foods are optional — use what agrees with you.',
      ],
      tryThis:
          'Build one meal today with a bright vegetable, a protein, and a carb you enjoy. Photograph it if that helps you repeat it.',
      icon: Icons.restaurant_rounded,
      iconBg: Color(0xFFE8F5E9),
      iconColor: AppColors.success,
      category: 'Nutrition',
      phase: CyclePhaseType.follicular,
    ),
    RecommendedAction(
      id: 'f4',
      title: 'Strength or cardio push',
      description:
          'Training adaptations often feel easier — aim for a solid session if you feel good.',
      detailIntro:
          'Many athletes feel stronger as estrogen rises. Pain tolerance and recovery can feel better than in late luteal — a smart window for progressive overload.',
      sections: [
        ArticleSection(
          heading: 'Session ideas',
          body:
              'Strength: add a small load or one extra set on compounds you know well. Cardio: intervals or a longer steady effort. Warm up thoroughly — energy is high, but joints still need prep.',
        ),
        ArticleSection(
          heading: 'Guardrails',
          body:
              'If sleep was poor or you are sick, skip the PR chase. High motivation can hide fatigue. Stop if form breaks down.',
        ),
      ],
      takeaways: [
        'Follicular weeks suit progressive training.',
        'Quality form beats ego weight.',
        'Log the session so you can compare next cycle.',
      ],
      tryThis:
          'Do one focused workout today and write one sentence after: what felt strong, what to repeat next week.',
      icon: Icons.fitness_center_rounded,
      iconBg: Color(0xFFE8EAF6),
      iconColor: AppColors.secondary,
      category: 'Fitness',
      phase: CyclePhaseType.follicular,
    ),
    RecommendedAction(
      id: 'f5',
      title: 'Schedule important talks',
      description:
          'Communication often feels clearer mid-follicular — a good day for hard conversations.',
      detailIntro:
          'Verbal fluency and social confidence often improve as estrogen rises. Hard conversations tend to go smoother when you feel steady and articulate.',
      sections: [
        ArticleSection(
          heading: 'Prep lightly',
          body:
              'Write 2–3 points you want understood, not a script. Aim for curiosity (“Can we talk about…?”) instead of accusation. Pick a time when neither of you is rushing.',
        ),
        ArticleSection(
          heading: 'Aftercare',
          body:
              'Even good talks can be draining. Plan a short reset afterward — walk, water, or quiet — so you do not stack stress onto the rest of your day.',
        ),
      ],
      takeaways: [
        'Clarity is a cycle strength in this phase.',
        'Two or three points beat a long monologue.',
        'Timing matters as much as wording.',
      ],
      tryThis:
          'Send or schedule one important conversation today while you feel clear. Keep it to three talking points.',
      icon: Icons.chat_bubble_outline_rounded,
      iconBg: Color(0xFFE3F2FD),
      iconColor: AppColors.info,
      category: 'Wellness',
      phase: CyclePhaseType.follicular,
    ),
    RecommendedAction(
      id: 'f6',
      title: 'Morning sunlight walk',
      description:
          'A short outdoor walk can boost mood and reinforce your circadian rhythm.',
      detailIntro:
          'Morning light helps set your body clock, which supports sleep later and steadier daytime energy — especially useful as your cycle energy rises.',
      sections: [
        ArticleSection(
          heading: 'How long',
          body:
              'Even 8–12 minutes outside (or by a bright window if needed) helps. Leave sunglasses off for a few minutes if safe for your eyes and brightness level, then use them as usual.',
        ),
        ArticleSection(
          heading: 'Stack habits',
          body:
              'Pair the walk with a voice note of today’s priority or a podcast. Movement + light + intention is a strong follicular morning stack.',
        ),
      ],
      takeaways: [
        'Morning light supports mood and sleep timing.',
        'Short walks count — consistency wins.',
        'Pair with one clear intention for the day.',
      ],
      tryThis:
          'Step outside within an hour of waking for a 10-minute walk. Note one priority for today while you walk.',
      icon: Icons.wb_sunny_rounded,
      iconBg: Color(0xFFFFF8E1),
      iconColor: AppColors.warning,
      category: 'Wellness',
      phase: CyclePhaseType.follicular,
    ),

    // —— Ovulation / fertility window ——
    RecommendedAction(
      id: 'o1',
      title: 'Lean into connection',
      description:
          'Desire and social energy often peak — plan intimacy or quality time if it feels right.',
      detailIntro:
          'Around ovulation, many people feel more magnetic, flirtatious, or simply more eager to connect. That is biology meeting psychology — not a demand.',
      sections: [
        ArticleSection(
          heading: 'Consent and comfort',
          body:
              'Higher desire never overrides consent — yours or a partner’s. Share what you want in plain language. If you are solo, connection can mean friendship, creativity, or self-pleasure without shame.',
        ),
        ArticleSection(
          heading: 'Practical intimacy',
          body:
              'Schedule uninterrupted time, silence phones, and reduce friction (lube, slower start, aftercare). Fertile-window sex can feel different physically — more lubrication for some, more sensitivity for others.',
        ),
      ],
      takeaways: [
        'Desire peaks are normal near ovulation.',
        'Consent and comfort stay non-negotiable.',
        'Connection can be partnered or solo.',
      ],
      tryThis:
          'Invite one form of connection today: a date night, a long hug, a vulnerable text, or private time for yourself.',
      icon: Icons.favorite_rounded,
      iconBg: Color(0xFFFCE4EC),
      iconColor: AppColors.accent,
      category: 'Sex & Intimacy',
      phase: CyclePhaseType.ovulation,
    ),
    RecommendedAction(
      id: 'o2',
      title: 'Track fertile signs',
      description:
          'Note cervical mucus, libido, or ovulation tests if you’re trying to conceive or avoid.',
      detailIntro:
          'Your fertile window is short. Logging signs teaches your personal pattern far better than a generic calendar alone.',
      sections: [
        ArticleSection(
          heading: 'What to notice',
          body:
              'Clear/stretchy cervical mucus, a rise in desire, mild one-sided twinges, or positive OPKs (if you use them). Not everyone gets every sign — track what is reliable for you.',
        ),
        ArticleSection(
          heading: 'How EezyCycle helps',
          body:
              'Combine your logs with cycle predictions. Over a few cycles, your fertile window estimates usually tighten. This is educational timing support — not a guarantee of ovulation or contraception.',
        ),
      ],
      takeaways: [
        'Personal signs beat generic calendars alone.',
        'Log even “maybe” days — patterns emerge.',
        'Predictions are estimates, not medical certainty.',
      ],
      tryThis:
          'Open your daily log and record mucus, desire, or a test result for today — even a one-word note helps.',
      icon: Icons.insights_rounded,
      iconBg: Color(0xFFFFF3E0),
      iconColor: AppColors.ovulation,
      category: 'Fertility',
      phase: CyclePhaseType.ovulation,
    ),
    RecommendedAction(
      id: 'o3',
      title: 'Show up for yourself',
      description:
          'Confidence often rises around ovulation — wear something that makes you feel strong.',
      detailIntro:
          'Feeling more “yourself” near ovulation is common. Lean into presentation and posture as a mood tool, not a performance for others.',
      sections: [
        ArticleSection(
          heading: 'Small identity cues',
          body:
              'An outfit you love, groomed hair, lipstick, or simply standing taller changes how you move through the day. Use it for a meeting, date, or just grocery shopping.',
        ),
        ArticleSection(
          heading: 'Keep it kind',
          body:
              'If body image is tender, choose comfort that still feels intentional — soft fabrics, favorite scent, jewelry that means something to you.',
        ),
      ],
      takeaways: [
        'Confidence cues can amplify a high-energy day.',
        'Dress for you, not an audience.',
        'One intentional detail is enough.',
      ],
      tryThis:
          'Pick one clothing or grooming choice today that makes you feel capable — then take a photo if you want a mood archive.',
      icon: Icons.spa_rounded,
      iconBg: Color(0xFFF3E5F5),
      iconColor: AppColors.fertility,
      category: 'Wellness',
      phase: CyclePhaseType.ovulation,
    ),
    RecommendedAction(
      id: 'o4',
      title: 'Peak-performance workout',
      description:
          'Many people hit PRs near ovulation — challenge yourself if energy is high.',
      detailIntro:
          'Strength, power, and pain tolerance often feel best around ovulation for people who menstruate. It can be a great day to chase a smart personal best.',
      sections: [
        ArticleSection(
          heading: 'Train smart',
          body:
              'Warm up longer than usual. Attempt a PR only on movements you know well. Keep 1–2 reps in reserve on heavy sets if you are unsure. Cool down and eat protein + carbs afterward.',
        ),
        ArticleSection(
          heading: 'Watch the crash',
          body:
              'Some people feel fantastic mid-day then fade. Schedule the hard session when you typically feel strongest, and keep evening plans flexible.',
        ),
      ],
      takeaways: [
        'Ovulation week can favor power and speed.',
        'Warm up thoroughly before any PR attempt.',
        'Refuel after — glycogen and recovery matter.',
      ],
      tryThis:
          'Choose one lift or interval set to push today. Write the result so you can compare next cycle.',
      icon: Icons.directions_run_rounded,
      iconBg: Color(0xFFE8F5E9),
      iconColor: AppColors.success,
      category: 'Fitness',
      phase: CyclePhaseType.ovulation,
    ),
    RecommendedAction(
      id: 'o5',
      title: 'Stay cool and hydrated',
      description:
          'Core temperature can tick up — sip water and avoid overheating in workouts.',
      detailIntro:
          'After ovulation, progesterone rises and basal temperature often increases. You may feel warmer, sweat more, or tire faster in heat.',
      sections: [
        ArticleSection(
          heading: 'Practical cooling',
          body:
              'Wear breathable layers, choose cooler workout times, and keep a water bottle nearby. Electrolyte drinks help in long sweaty sessions or hot climates.',
        ),
        ArticleSection(
          heading: 'Sleep angle',
          body:
              'A slightly higher night temperature can disrupt sleep. Cool the bedroom, use lighter bedding, and avoid late heavy meals if nights feel restless.',
        ),
      ],
      takeaways: [
        'Feeling warmer after ovulation is common.',
        'Hydration + cooling beat pushing through heat.',
        'Bedroom temperature affects luteal sleep.',
      ],
      tryThis:
          'Carry a water bottle for the next 4 hours and finish it. For evening, lower your room temperature one notch if you can.',
      icon: Icons.water_drop_outlined,
      iconBg: Color(0xFFE3F2FD),
      iconColor: AppColors.info,
      category: 'Wellness',
      phase: CyclePhaseType.ovulation,
    ),
    RecommendedAction(
      id: 'o6',
      title: 'Capture the good mood',
      description:
          'Journal one win or gratitude — it anchors the clarity of this phase.',
      detailIntro:
          'High days pass. Capturing what felt good builds a personal library you can reread on harder luteal or period days.',
      sections: [
        ArticleSection(
          heading: 'Keep it short',
          body:
              'Three bullets: one win, one gratitude, one thing you want to remember. No essay required. Voice notes count.',
        ),
        ArticleSection(
          heading: 'Why it matters',
          body:
              'Your brain weights negative days heavily. A written record of high-energy clarity balances the story you tell yourself across the cycle.',
        ),
      ],
      takeaways: [
        'Document good days while you are in them.',
        'Three bullets are enough.',
        'Future-you will thank present-you on hard days.',
      ],
      tryThis:
          'Write (or voice-note) one win and one gratitude before bed tonight.',
      icon: Icons.edit_note_rounded,
      iconBg: Color(0xFFFFF8E1),
      iconColor: AppColors.ovulation,
      category: 'Wellness',
      phase: CyclePhaseType.ovulation,
    ),

    // —— Luteal / PMS ——
    RecommendedAction(
      id: 'l1',
      title: 'Prioritize self-care',
      description:
          'Progesterone can bring fatigue and mood shifts — protect downtime tonight.',
      detailIntro:
          'In the luteal phase, progesterone rises then falls before your period. Fatigue, sensitivity, and lower social battery are common — not personal failure.',
      sections: [
        ArticleSection(
          heading: 'What self-care means here',
          body:
              'Earlier bedtime, fewer optional plans, softer lighting, and saying no without a long justification. Sensory calm beats elaborate spa routines when you are depleted.',
        ),
        ArticleSection(
          heading: 'Work and relationships',
          body:
              'If you feel snappier, pause before sending the message. Delay non-urgent conflict when you can. Tell a trusted person “I’m in a low-bandwidth day” if that helps.',
        ),
      ],
      takeaways: [
        'Luteal fatigue is physiological for many people.',
        'Protect downtime like an appointment.',
        'Soft no’s prevent hard crashes.',
      ],
      tryThis:
          'Pick a wind-down time 30 minutes earlier than usual tonight. Silence non-essential notifications after that.',
      icon: Icons.self_improvement_rounded,
      iconBg: Color(0xFFF3E5F5),
      iconColor: AppColors.fertility,
      category: 'PMS Care',
      phase: CyclePhaseType.luteal,
    ),
    RecommendedAction(
      id: 'l2',
      title: 'Magnesium-friendly snacks',
      description:
          'Nuts, seeds, dark chocolate, or leafy greens may ease tension and cravings.',
      detailIntro:
          'Cravings and muscle tension often rise before a period. Magnesium-rich foods will not fix PMS alone, but they are a practical, food-first support many people find helpful.',
      sections: [
        ArticleSection(
          heading: 'Easy options',
          body:
              'A handful of almonds or pumpkin seeds, a square of dark chocolate, spinach in an omelette, or banana with peanut butter. Pair with protein so blood sugar stays steadier.',
        ),
        ArticleSection(
          heading: 'Craving strategy',
          body:
              'If you want sweets, combine them with a meal instead of grazing all evening. Deprivation often backfires in late luteal — satisfaction with a plan works better.',
        ),
      ],
      takeaways: [
        'Magnesium foods can support calm and cravings.',
        'Pair carbs with protein for steadier energy.',
        'Planned treats beat all-or-nothing restriction.',
      ],
      tryThis:
          'Have one magnesium-friendly snack today (seeds, nuts, dark chocolate, or greens) with a protein.',
      icon: Icons.eco_rounded,
      iconBg: Color(0xFFE8F5E9),
      iconColor: AppColors.success,
      category: 'Nutrition',
      phase: CyclePhaseType.luteal,
    ),
    RecommendedAction(
      id: 'l3',
      title: 'Softer workout intensity',
      description:
          'Swap max effort for walks, mobility, or yoga if your body asks for less.',
      detailIntro:
          'Perceived exertion often rises in late luteal even at the same weights. Training smarter — not quitting — protects consistency across the whole cycle.',
      sections: [
        ArticleSection(
          heading: 'Swap examples',
          body:
              'Replace HIIT with Zone 2 walking or cycling. Swap heavy PR attempts for technique work and mobility. Keep showing up; change the dial, not the identity of “someone who moves.”',
        ),
        ArticleSection(
          heading: 'Red flags to rest',
          body:
              'Dizziness, unusual shortness of breath, sharp pain, or crushing fatigue means rest today. Movement should leave you feeling better, not wrecked.',
        ),
      ],
      takeaways: [
        'Lower intensity still counts as training.',
        'Consistency across the cycle beats one heroic session.',
        'Listen for “tired” vs “injured.”',
      ],
      tryThis:
          'Do a 20–30 minute easy walk or stretch session instead of a max-effort workout today.',
      icon: Icons.directions_walk_rounded,
      iconBg: Color(0xFFE8EAF6),
      iconColor: AppColors.secondary,
      category: 'Fitness',
      phase: CyclePhaseType.luteal,
    ),
    RecommendedAction(
      id: 'l4',
      title: 'Improve your sleep',
      description:
          'A consistent wind-down routine supports mood and next-day energy in the luteal phase.',
      detailIntro:
          'Progesterone can make you sleepy earlier — and also fragment sleep for some. A predictable wind-down reduces how hard nights feel before your period.',
      sections: [
        ArticleSection(
          heading: 'Wind-down stack',
          body:
              'Dim lights 45–60 minutes before bed, cut caffeine after mid-afternoon, cool the room, and park the phone outside arm’s reach. A short stretch or shower marks “day is done.”',
        ),
        ArticleSection(
          heading: 'If you wake at 3 a.m.',
          body:
              'Avoid clock-watching. Slow breathing or a boring audiobook on low volume helps more than scrolling. Get daylight the next morning to reset.',
        ),
      ],
      takeaways: [
        'Luteal sleep often needs more protection.',
        'Same bedtime ±30 minutes helps mood.',
        'Cool, dark, phone-away is a strong trio.',
      ],
      tryThis:
          'Start a 45-minute wind-down tonight: dim lights, no caffeine, phone charging outside the bed.',
      icon: Icons.bedtime_rounded,
      iconBg: Color(0xFFE3F2FD),
      iconColor: AppColors.info,
      category: 'Sleep',
      phase: CyclePhaseType.luteal,
    ),
    RecommendedAction(
      id: 'l5',
      title: 'Name the mood, don’t fight it',
      description:
          'Irritability can be hormonal — pause before reacting and give yourself grace.',
      detailIntro:
          'PMS mood shifts are real for many people. Naming “this might be luteal” creates a gap between feeling and reaction — that gap is where better choices live.',
      sections: [
        ArticleSection(
          heading: 'A 10-second pause',
          body:
              'When irritation spikes: feel your feet on the floor, exhale longer than you inhale, and ask “Is this urgent or hormonal volume?” You can still address real issues — just not at maximum volume.',
        ),
        ArticleSection(
          heading: 'Support, not dismissal',
          body:
              'Hormones do not erase valid needs. They can amplify how needs are expressed. Journal the need (“I need quiet / help / food”) separately from the story (“everyone is against me”).',
        ),
      ],
      takeaways: [
        'Naming luteal mood reduces shame.',
        'Pause → name need → respond.',
        'Real issues deserve calm timing when possible.',
      ],
      tryThis:
          'The next time irritation hits, write one sentence: “I feel ___ because I need ___.” Act on the need if you can.',
      icon: Icons.psychology_alt_rounded,
      iconBg: Color(0xFFFCE4EC),
      iconColor: AppColors.accent,
      category: 'PMS Care',
      phase: CyclePhaseType.luteal,
    ),
    RecommendedAction(
      id: 'l6',
      title: 'Prep for your period',
      description:
          'Stock pads/tampons, heat pack, and easy meals so day 1 feels less chaotic.',
      detailIntro:
          'Late luteal is the perfect time to set Period Day You up for success. Future comfort is a gift you can give in under 15 minutes.',
      sections: [
        ArticleSection(
          heading: 'Quick checklist',
          body:
              'Products in bag and bathroom, clean heat pack, pain relief you tolerate, cozy clothes, and at least one easy meal or snack ready. Charge your phone and water bottle before bed if days 1–2 hit hard.',
        ),
        ArticleSection(
          heading: 'Work prep',
          body:
              'If possible, lighten tomorrow’s morning. Move early meetings or pack a backup outfit. Small logistics prevent big stress when cramps arrive.',
        ),
      ],
      takeaways: [
        'Prep reduces day-1 chaos.',
        'Bag + heat + easy food is a strong trio.',
        '15 minutes now saves hours of friction later.',
      ],
      tryThis:
          'Spend 10 minutes stocking products, setting out a heat pack, and choosing tomorrow’s easy breakfast.',
      icon: Icons.checklist_rounded,
      iconBg: Color(0xFFFFEBEE),
      iconColor: AppColors.period,
      category: 'Rest & Flow',
      phase: CyclePhaseType.luteal,
    ),

    // —— Pregnancy (when active) ——
    RecommendedAction(
      id: 'p1',
      title: 'Short movement breaks',
      description:
          'Gentle walks and posture resets support circulation as your body adapts.',
      detailIntro:
          'Pregnancy changes circulation, balance, and energy. Short, frequent movement usually beats rare intense sessions — especially early on when fatigue is high.',
      sections: [
        ArticleSection(
          heading: 'Safe defaults',
          body:
              'Walks, prenatal-approved stretches, and standing desk breaks are solid. Avoid overheating and movements your clinician has cautioned against. When unsure, ask your care team.',
        ),
        ArticleSection(
          heading: 'Posture resets',
          body:
              'Every hour: roll shoulders, unclench jaw, stand and sway side to side. Small resets reduce back and hip ache as ligaments loosen.',
        ),
      ],
      takeaways: [
        'Short walks beat all-or-nothing workouts.',
        'Avoid overheating; listen to dizziness.',
        'Ask your clinician about exercise limits.',
      ],
      tryThis:
          'Take three 5-minute walk or stretch breaks today — morning, afternoon, evening.',
      icon: Icons.pregnant_woman_rounded,
      iconBg: Color(0xFFE8F5E9),
      iconColor: AppColors.pregnancy,
      category: 'Pregnancy',
      phase: CyclePhaseType.pregnancy,
    ),
    RecommendedAction(
      id: 'p2',
      title: 'Steady protein & snacks',
      description:
          'Small, regular meals can ease nausea and keep energy more even.',
      detailIntro:
          'Blood sugar dips and nausea often improve with smaller, more frequent eating rather than large empty-stomach gaps.',
      sections: [
        ArticleSection(
          heading: 'Snack formulas',
          body:
              'Carb + protein: crackers with cheese, yogurt with fruit, toast with peanut butter, hummus with veggies. Keep one “emergency” snack in your bag.',
        ),
        ArticleSection(
          heading: 'Morning tip',
          body:
              'If mornings are rough, try a few bites before getting fully upright. Bland and cold foods are easier for some people than hot aromatic meals.',
        ),
      ],
      takeaways: [
        'Small frequent eats can calm nausea.',
        'Pair carbs with protein.',
        'Keep a backup snack with you.',
      ],
      tryThis:
          'Pack one protein-plus-carb snack and eat it before you get overly hungry today.',
      icon: Icons.lunch_dining_rounded,
      iconBg: Color(0xFFFFF3E0),
      iconColor: AppColors.warning,
      category: 'Pregnancy',
      phase: CyclePhaseType.pregnancy,
    ),
    RecommendedAction(
      id: 'p3',
      title: 'Nap without guilt',
      description:
          'First-trimester fatigue is real — rest is productive, not lazy.',
      detailIntro:
          'Building a placenta and rising progesterone can feel like a full-time job. Sleepiness is a signal, not a character flaw.',
      sections: [
        ArticleSection(
          heading: 'Make rest usable',
          body:
              'A 20–30 minute nap or horizontal rest with eyes closed helps more than pushing through fog. Dim the room and set an alarm so you do not wake disoriented.',
        ),
        ArticleSection(
          heading: 'Talk to your people',
          body:
              'Tell partners or housemates you may need earlier nights for a while. Support works better when expectations are spoken.',
        ),
      ],
      takeaways: [
        'Fatigue in early pregnancy is common.',
        'Short planned rest beats accidental collapse.',
        'Ask for support out loud.',
      ],
      tryThis:
          'Schedule a 25-minute lie-down today. Treat it like a meeting you cannot skip.',
      icon: Icons.hotel_rounded,
      iconBg: Color(0xFFE8EAF6),
      iconColor: AppColors.pregnancy,
      category: 'Pregnancy',
      phase: CyclePhaseType.pregnancy,
    ),

    // —— General (fallback / any phase) ——
    RecommendedAction(
      id: 'g1',
      title: 'Log how you feel',
      description:
          'A quick mood or symptom note helps EezyCycle learn your unique pattern.',
      detailIntro:
          'Your cycle is personal. A 20-second log today compounds into better insights across weeks — mood, energy, pain, and bleed patterns included.',
      sections: [
        ArticleSection(
          heading: 'What to capture',
          body:
              'Mood, energy, cramps, sleep quality, or anything unusual. Consistency beats detail. One emoji-level note is better than a perfect journal you skip.',
        ),
        ArticleSection(
          heading: 'How it pays off',
          body:
              'Over a few cycles you will see which weeks feel social, which feel tender, and what habits help. That is the real power of tracking — self-knowledge, not perfection.',
        ),
      ],
      takeaways: [
        'Short logs beat skipped perfect entries.',
        'Patterns appear after a few cycles.',
        'Tracking is for you, not for judgment.',
      ],
      tryThis:
          'Open today’s log and add one mood and one symptom — then close the app. Done.',
      icon: Icons.edit_calendar_rounded,
      iconBg: AppColors.primaryLight,
      iconColor: AppColors.primary,
      category: 'Wellness',
      phase: CyclePhaseType.general,
      phases: [
        CyclePhaseType.menstrual,
        CyclePhaseType.follicular,
        CyclePhaseType.ovulation,
        CyclePhaseType.luteal,
        CyclePhaseType.general,
      ],
    ),
    RecommendedAction(
      id: 'g2',
      title: 'Drink a full glass of water',
      description:
          'Simple hydration supports energy, skin, and how your body handles hormones.',
      detailIntro:
          'Hydration is boring advice that still works. Hormone shifts change fluid balance — a full glass now is an easy win in any phase.',
      sections: [
        ArticleSection(
          heading: 'Make it stick',
          body:
              'Link water to existing habits: after brushing teeth, when you open your laptop, or with each meal. Flavor with citrus or herbal tea if plain water is hard to finish.',
        ),
        ArticleSection(
          heading: 'Do not overdo extremes',
          body:
              'You do not need gallons. Steady intake through the day beats forcing huge amounts that just send you to the bathroom every 10 minutes.',
        ),
      ],
      takeaways: [
        'One full glass is a complete action.',
        'Habit stacking beats willpower.',
        'Steady > extreme chugging.',
      ],
      tryThis:
          'Drink one full glass right now before you switch apps. Refill once more this afternoon.',
      icon: Icons.local_drink_rounded,
      iconBg: Color(0xFFE3F2FD),
      iconColor: AppColors.info,
      category: 'Wellness',
      phase: CyclePhaseType.general,
      phases: [
        CyclePhaseType.menstrual,
        CyclePhaseType.follicular,
        CyclePhaseType.ovulation,
        CyclePhaseType.luteal,
        CyclePhaseType.pregnancy,
        CyclePhaseType.general,
      ],
    ),
    RecommendedAction(
      id: 'g3',
      title: 'Five quiet breaths',
      description:
          'A one-minute nervous-system reset — inhale slowly, exhale longer.',
      detailIntro:
          'Longer exhales nudge the body toward calm. This works in any phase when stress spikes — meetings, cramps, arguments, or scrolling overload.',
      sections: [
        ArticleSection(
          heading: 'The pattern',
          body:
              'Inhale through the nose for 4 counts, exhale through the mouth or nose for 6–8 counts. Repeat five times. Drop your shoulders on each exhale.',
        ),
        ArticleSection(
          heading: 'When to use it',
          body:
              'Before sending a tense message, during a cramp wave, or when you notice your jaw is clenched. It is portable, free, and private.',
        ),
      ],
      takeaways: [
        'Exhale longer than inhale to calm down.',
        'Five breaths take under a minute.',
        'Use it as a bridge before reacting.',
      ],
      tryThis:
          'Right now: 5 breaths — inhale 4, exhale 6. Notice one thing that feels slightly softer afterward.',
      icon: Icons.air_rounded,
      iconBg: Color(0xFFF3E5F5),
      iconColor: AppColors.fertility,
      category: 'Wellness',
      phase: CyclePhaseType.general,
      phases: [
        CyclePhaseType.menstrual,
        CyclePhaseType.follicular,
        CyclePhaseType.ovulation,
        CyclePhaseType.luteal,
        CyclePhaseType.pregnancy,
        CyclePhaseType.general,
      ],
    ),
  ];

  /// Picks [limit] actions for [phase]. Seeded by calendar day so the set
  /// stays stable across rebuilds, then refreshes tomorrow / on phase change.
  static List<RecommendedAction> pickForPhase(
    CyclePhaseType phase, {
    int limit = 3,
    DateTime? now,
  }) {
    assert(all.length >= 30, 'Expected at least 30 recommended actions');

    final matched = all.where((a) => a.matchesPhase(phase)).toList();
    final general = all
        .where((a) => a.matchesPhase(CyclePhaseType.general))
        .toList();
    final pool = matched.isNotEmpty
        ? matched
        : (general.isNotEmpty ? general : List<RecommendedAction>.from(all));

    final day = now ?? DateTime.now();
    final seed =
        day.year * 10000 + day.month * 100 + day.day + phase.index * 97;
    final shuffled = List<RecommendedAction>.from(pool)..shuffle(Random(seed));

    if (shuffled.length >= limit) {
      return shuffled.take(limit).toList();
    }

    final ids = shuffled.map((a) => a.id).toSet();
    final extras = List<RecommendedAction>.from(all)..shuffle(Random(seed + 13));
    for (final extra in extras) {
      if (ids.add(extra.id)) shuffled.add(extra);
      if (shuffled.length >= limit) break;
    }
    return shuffled.take(limit).toList();
  }
}
