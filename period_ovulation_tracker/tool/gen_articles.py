#!/usr/bin/env python3
"""Build assets/articles/articles.json with 50 full articles."""
from __future__ import annotations

import json
from pathlib import Path

OUT = Path(__file__).resolve().parents[1] / "assets" / "articles" / "articles.json"

# Curated Unsplash covers (lifestyle / wellness — no explicit imagery)
IMG = {
    "couple_soft": "https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?q=80&w=1200&auto=format&fit=crop",
    "friends": "https://images.unsplash.com/photo-1529156069898-49953e39b3ac?q=80&w=1200&auto=format&fit=crop",
    "health": "https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?q=80&w=1200&auto=format&fit=crop",
    "calm": "https://images.unsplash.com/photo-1529333166437-7750a6dd5a70?q=80&w=1200&auto=format&fit=crop",
    "reflect": "https://images.unsplash.com/photo-1474552226712-ac0f0961a954?q=80&w=1200&auto=format&fit=crop",
    "stretch": "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=1200&auto=format&fit=crop",
    "yoga": "https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=1200&auto=format&fit=crop",
    "food": "https://images.unsplash.com/photo-1498837167922-ddd27525d352?q=80&w=1200&auto=format&fit=crop",
    "rest": "https://images.unsplash.com/photo-1515377905703-c4788e51af15?q=80&w=1200&auto=format&fit=crop",
    "bump": "https://images.unsplash.com/photo-1555252333-9f8e92e65df9?q=80&w=1200&auto=format&fit=crop",
    "run": "https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?q=80&w=1200&auto=format&fit=crop",
    "sleep": "https://images.unsplash.com/photo-1541781775937-74c2a5c0c0e5?q=80&w=1200&auto=format&fit=crop",
    "tea": "https://images.unsplash.com/photo-1571934811356-5cc061b6821f?q=80&w=1200&auto=format&fit=crop",
    "nature": "https://images.unsplash.com/photo-1441974231531-c6227db76b6e?q=80&w=1200&auto=format&fit=crop",
    "journal": "https://images.unsplash.com/photo-1517842645767-c639042777db?q=80&w=1200&auto=format&fit=crop",
    "water": "https://images.unsplash.com/photo-1548840221-0b4b71fdd78d?q=80&w=1200&auto=format&fit=crop",
    "strength": "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=1200&auto=format&fit=crop",
    "walk": "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?q=80&w=1200&auto=format&fit=crop",
    "fruit": "https://images.unsplash.com/photo-1610832958506-aa563bf9faeb?q=80&w=1200&auto=format&fit=crop",
    "hands": "https://images.unsplash.com/photo-1529333166437-7750a6dd5a70?q=80&w=1200&auto=format&fit=crop",
    "sunrise": "https://images.unsplash.com/photo-1495615080073-6b89c9839ce0?q=80&w=1200&auto=format&fit=crop",
    "meditation": "https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=1200&auto=format&fit=crop",
    "kitchen": "https://images.unsplash.com/photo-1556910103-1c02745aae4d?q=80&w=1200&auto=format&fit=crop",
    "blanket": "https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?q=80&w=1200&auto=format&fit=crop",
    "desk": "https://images.unsplash.com/photo-1486312338219-ce68d2c6f44d?q=80&w=1200&auto=format&fit=crop",
}


def a(
    id_,
    title,
    description,
    category,
    category_type,
    phase,
    image_key,
    hero,
    sections,
    takeaways,
    phases=None,
    read_time="4 min read",
    image_alt="",
):
    return {
        "id": id_,
        "title": title,
        "description": description,
        "category": category,
        "category_type": category_type,
        "read_time": read_time,
        "author": "EezyCycle Editorial",
        "published_date": "Updated recently",
        "image": IMG[image_key],
        "image_alt": image_alt or title,
        "phase": phase,
        **({"phases": phases} if phases else {}),
        "hero_summary": hero,
        "sections": [{"heading": h, "body": b} for h, b in sections],
        "takeaways": takeaways,
    }


articles = [
    # --- Existing core (kept / polished) ---
    a(
        "sex_desire_cycle_01",
        "How desire shifts across your cycle",
        "Libido often rises near ovulation and softens before your period — here's what that can feel like.",
        "Sex & Intimacy",
        "sex_intimacy",
        "ovulation",
        "couple_soft",
        "Desire is not fixed. Hormones, stress, sleep, and connection all shape how intimacy feels week to week.",
        [
            (
                "Around ovulation",
                "Many people notice higher interest in sex in the fertile window. That can mean more desire, more confidence, or simply feeling more open to closeness. Estimates only — every body is different.",
            ),
            (
                "In the luteal and period weeks",
                "As progesterone rises (and during bleeding), desire can dip. Comfort, rest, and non-sexual intimacy still count. Consent and pacing matter more than any 'should'.",
            ),
            (
                "Talk about it",
                "Sharing what feels good this week — and what doesn't — keeps intimacy kind. You never owe sex; you do deserve clarity and care.",
            ),
        ],
        [
            "Desire can peak near ovulation and soften later — that is common.",
            "Low desire weeks are not a failure; try softer forms of closeness.",
            "Consent and comfort always come first.",
        ],
        phases=["follicular", "ovulation"],
        image_alt="Couple close together in soft light",
    ),
    a(
        "sex_consent_01",
        "Consent, comfort, and checking in",
        "Clear, ongoing consent makes sex safer and more connected for both partners.",
        "Sex & Intimacy",
        "sex_intimacy",
        "general",
        "friends",
        "Consent is not a one-time yes — it is an ongoing conversation before and during intimacy.",
        [
            (
                "What consent looks like",
                "Enthusiastic, freely given, and reversible. Silence, pressure, or guilt are not consent. Checking in mid-way is healthy, not awkward.",
            ),
            (
                "During your period or low-energy days",
                "It is okay to say not tonight, or to suggest cuddling, massage, or other closeness instead. Your partner's respect for that boundary is part of intimacy.",
            ),
        ],
        [
            "Consent can be withdrawn at any time.",
            "Ask, listen, and respect a no without sulking.",
            "Non-sexual intimacy still builds connection.",
        ],
        phases=["follicular", "luteal", "menstrual", "ovulation"],
        image_alt="Friends talking and connecting outdoors",
    ),
    a(
        "sex_protection_01",
        "Protection, fertile windows, and choices",
        "How fertile days relate to pregnancy chance — and why protection is still a personal choice.",
        "Sex & Intimacy",
        "sex_intimacy",
        "ovulation",
        "health",
        "Cycle tracking can help you understand fertile days. It is not contraception by itself — combine with methods you trust if you want to avoid pregnancy.",
        [
            (
                "Fertile window ≠ guaranteed pregnancy",
                "Sperm can live several days; ovulation timing is an estimate. Higher chance does not mean certainty. Lower chance days are also not a guarantee of safety.",
            ),
            (
                "Protection options",
                "Barrier methods, hormonal contraception, and other options each have trade-offs. Choose with a clinician when you can. STI protection is separate from pregnancy prevention.",
            ),
        ],
        [
            "EezyCycle predictions are estimates, not birth control.",
            "Use a method you trust if avoiding pregnancy matters.",
            "STI protection is its own conversation.",
        ],
        phases=["ovulation", "follicular"],
        read_time="5 min read",
        image_alt="Health and care — stethoscope on soft background",
    ),
    a(
        "sex_period_intimacy_01",
        "Intimacy during your period",
        "Period sex can be comfortable for some and off-limits for others — both are valid.",
        "Sex & Intimacy",
        "sex_intimacy",
        "menstrual",
        "calm",
        "Bleeding days do not automatically mean no intimacy. Comfort, towels, showers, and honest preference are the real guides.",
        [
            (
                "If you want to",
                "Use a towel, go slow, and rinse after. Some people find orgasm eases cramps. Stop if anything hurts.",
            ),
            (
                "If you don't",
                "That is enough reason. Offer or ask for other closeness instead — warmth, rest, and care still count.",
            ),
        ],
        [
            "Period intimacy is optional, never expected.",
            "Comfort tools (towel, shower) help if you choose it.",
            "Pain is a stop signal.",
        ],
        read_time="3 min read",
        image_alt="Soft lifestyle moment — calm connection",
    ),
    a(
        "sex_drive_low_01",
        "When sex drive feels low",
        "Stress, sleep, meds, and luteal hormones can all quiet desire — without meaning anything is 'wrong'.",
        "Sex & Intimacy",
        "sex_intimacy",
        "luteal",
        "reflect",
        "Low desire is common in late luteal and high-stress weeks. Curiosity and kindness beat pressure.",
        [
            (
                "Common reasons",
                "Poor sleep, anxiety, relationship tension, contraception changes, and PMS can all lower drive. Tracking patterns helps you see what is situational.",
            ),
            (
                "What helps",
                "Remove pressure, schedule non-sexual connection, and talk to a clinician if low desire is sudden, painful, or lasting many months.",
            ),
        ],
        [
            "Low drive often has a context — not a character flaw.",
            "Pressure usually makes desire worse.",
            "Seek care if pain or sudden long-term change shows up.",
        ],
        phases=["luteal", "menstrual"],
        image_alt="Quiet reflective moment outdoors",
    ),
    a(
        "follicular_energy_01",
        "Why energy often rises after your period",
        "Rising estrogen can lift mood and stamina in the follicular phase.",
        "Energy & Hormones",
        "energy_hormones",
        "follicular",
        "stretch",
        "After bleeding eases, many people feel clearer and more energetic as estrogen climbs.",
        [
            (
                "What's happening",
                "In the follicular phase, estrogen generally rises. That can support focus, social energy, and training capacity — estimates only.",
            ),
            (
                "What you can try",
                "Plan workouts, important conversations, or creative work for these days when it feels good. Still rest if your body asks.",
            ),
        ],
        [
            "Follicular weeks often feel brighter — use them kindly.",
            "Energy is not mandatory; rest still counts.",
            "Pair movement with steady meals and sleep.",
        ],
        read_time="3 min read",
        image_alt="Woman stretching in bright natural light",
    ),
    a(
        "ovulation_signs_01",
        "Recognizing fertile-window signs",
        "Cervical mucus, timing, and how EezyCycle estimates ovulation day.",
        "Fertility",
        "fertility",
        "ovulation",
        "yoga",
        "Fertile days are an estimate. Learning your body's patterns makes the calendar more useful — not perfect.",
        [
            (
                "What the app shows",
                "EezyCycle marks fertile and ovulation days from your logged periods using Flo-style calendar math. Predictions improve with regular logging.",
            ),
            (
                "Body clues",
                "Some people notice stretchier mucus or a mild twinge. These clues vary. They are not a guarantee of ovulation.",
            ),
        ],
        [
            "Fertile window = estimate, not a promise.",
            "Log periods for smarter predictions.",
            "Body clues vary person to person.",
        ],
        image_alt="Yoga and body awareness at sunrise",
    ),
    a(
        "luteal_pms_01",
        "Softening luteal mood swings",
        "Progesterone shifts can bring PMS-like changes — small supports help.",
        "PMS & Care",
        "pms_care",
        "luteal",
        "food",
        "The luteal phase can feel heavier emotionally. Sleep, food, and lower pressure plans make a real difference.",
        [
            (
                "What's common",
                "Irritability, bloating, cravings, and lower patience often show up before a period. Tracking helps you prepare instead of being surprised.",
            ),
            (
                "Gentle supports",
                "Warm meals, magnesium-rich snacks, earlier nights, and saying no to overbooking are practical, not dramatic.",
            ),
        ],
        [
            "PMS-like days are common — plan softer weeks.",
            "Sleep and food matter as much as mindset.",
            "Ask for help early, not only at boiling point.",
        ],
        image_alt="Nourishing colorful foods on a table",
    ),
    a(
        "menstrual_rest_01",
        "Rest and replenish on period days",
        "Warmth, iron-friendly foods, and permission to slow down.",
        "Rest & Flow",
        "rest_flow",
        "menstrual",
        "rest",
        "Period days are a reset, not a productivity test. Heat, hydration, and rest support recovery.",
        [
            (
                "Body care",
                "A heating pad, gentle movement, and iron-rich meals can ease cramps and fatigue for many people.",
            ),
            (
                "Pace",
                "Shrink your to-do list when flow is heavy. That is strategy, not laziness.",
            ),
        ],
        [
            "Heat + rest often help cramps.",
            "Eat for energy; don't skip meals.",
            "Protect your calendar on heavy days.",
        ],
        read_time="3 min read",
        image_alt="Restful self-care moment with soft blankets",
    ),
    a(
        "pregnancy_weeks_01",
        "Understanding weeks + days pregnant",
        "How EezyCycle counts pregnancy age from your last period (LMP + 280 days).",
        "Pregnancy",
        "pregnancy",
        "pregnancy",
        "bump",
        "Like Flo, we estimate due date from the first day of your last period plus 280 days, then show weeks and days.",
        [
            (
                "LMP dating",
                "Gestational age usually starts from LMP, even before conception. That is why early 'weeks' can feel ahead of how long you have 'felt' pregnant.",
            ),
            (
                "Estimates only",
                "Ultrasound dating may adjust your due date. App estimates are educational, not medical advice.",
            ),
        ],
        [
            "Due date ≈ LMP + 280 days.",
            "Home shows weeks + days from LMP.",
            "Confirm dating with your clinician.",
        ],
        read_time="3 min read",
        image_alt="Expecting parent holding baby bump gently",
    ),
]

# --- Additional articles to reach 50 ---
extra = [
    ("sex_aftercare_01", "Aftercare that actually feels caring", "Water, warmth, and a check-in matter as much as the moment itself.", "Sex & Intimacy", "sex_intimacy", "general", "hands", "Intimacy does not end when sex ends. Aftercare protects connection and nervous systems.", [("What aftercare can look like", "A glass of water, a warm shower, cuddling, or simply asking how their body feels. Small rituals reduce awkwardness and build trust."), ("When someone says no", "Aftercare also means respecting a no without punishment. Soft closeness can replace sex without scorekeeping.")], ["Ask how they feel afterward.", "Comfort is part of intimacy.", "A no deserves kindness too."], ["follicular", "luteal", "ovulation", "menstrual"], "3 min read"),
    ("sex_communication_01", "Talking about sex without freezing up", "Scripts and soft openers make desire and boundaries easier to share.", "Sex & Intimacy", "sex_intimacy", "general", "friends", "Most people were never taught how to talk about sex. Simple language beats perfect language.", [("Start soft", "Try: \"I have been thinking about what feels good lately…\" or \"Can we talk about pace and pressure?\" Timing matters — not mid-argument."), ("Keep it ongoing", "One talk is not a lifetime contract. Preferences shift with stress, cycle phase, and life seasons.")], ["Soft openers lower shame.", "Preferences can change week to week.", "Curiosity beats criticism."], ["follicular", "ovulation"], "4 min read"),
    ("sex_pressure_01", "When intimacy starts to feel like pressure", "Desire shrinks under obligation — how to reset the dynamic kindly.", "Sex & Intimacy", "sex_intimacy", "luteal", "reflect", "Feeling owed or behind on intimacy is a common relationship stressor. Naming it gently creates room for real desire.", [("Spot the pattern", "Scorekeeping, sulking after a no, or \"we never…\" complaints often signal pressure. Desire needs safety more than schedules."), ("Reset together", "Agree that closeness includes non-sexual options. Rebuild playfulness before rebuilding frequency.")], ["Pressure kills desire.", "Non-sexual closeness still counts.", "Reset as teammates."], ["luteal", "menstrual"], "4 min read"),
    ("follicular_focus_01", "Using follicular clarity for goals", "Rising estrogen often supports focus — channel it without burnout.", "Energy & Hormones", "energy_hormones", "follicular", "desk", "Many people feel mentally sharper after their period. That window is useful — and still finite.", [("Lean in gently", "Batch creative work, hard conversations, or training progressions when energy is naturally higher."), ("Guard the edges", "Do not spend the whole lift on overcommitment. Leave margin for the luteal week ahead.")], ["Use bright weeks intentionally.", "Margin prevents later crash.", "Rest still belongs here."], None, "3 min read"),
    ("follicular_social_01", "Social energy after your period", "Why hangouts and plans can feel easier in the follicular phase.", "Energy & Hormones", "energy_hormones", "follicular", "sunrise", "As bleeding eases and estrogen rises, social drive often returns. That does not mean you must say yes to everything.", [("Say yes selectively", "Choose plans that refill you — friends, dates, movement — not obligation-only events."), ("Still honor quiet", "Introversion does not disappear because hormones shifted. Protect downtime.")], ["Social energy can rebound post-period.", "Selective yeses beat FOMO.", "Quiet time still matters."], None, "3 min read"),
    ("follicular_strength_01", "Strength training in the follicular window", "Many feel stronger mid-cycle — how to train smart, not reckless.", "Fitness", "fitness", "follicular", "strength", "Some athletes notice better power and recovery as estrogen rises. Use that edge with form and fuel.", [("What to try", "Progressive lifts, skill practice, and higher-intensity sessions if you feel good."), ("Safety first", "Energy is not immunity. Warm up, eat enough, and stop for pain that is not normal training discomfort.")], ["Follicular weeks can support harder sessions.", "Fuel the work.", "Pain ≠ progress."], ["follicular", "ovulation"], "4 min read"),
    ("ovulation_confidence_01", "Confidence near ovulation", "Feeling bolder mid-cycle is common — use it kindly.", "Energy & Hormones", "energy_hormones", "ovulation", "stretch", "Around ovulation, some people feel more outgoing, flirtatious, or decisive. Enjoy it without treating other weeks as \"less than.\"", [("Ride the wave", "Pitch the idea, take the photo, ask for the date — if it feels authentic."), ("Stay grounded", "Confidence is a state, not a personality requirement. Later weeks deserve compassion too.")], ["Mid-cycle confidence is common.", "Authenticity > performance.", "Compassion for quieter weeks."], ["ovulation", "follicular"], "3 min read"),
    ("ovulation_timing_01", "What \"ovulation day\" really means", "A predicted day is a midpoint estimate inside a fertile window.", "Fertility", "fertility", "ovulation", "yoga", "EezyCycle marks an ovulation estimate from your cycle length and luteal assumption. Think window, not single magic hour.", [("Why a window", "Eggs survive briefly; sperm can live days. Chance clusters around ovulation, not only on one calendar square."), ("Logging helps", "Irregular cycles widen uncertainty. More logged periods improve averages — they do not create certainty.")], ["Treat ovulation as an estimate.", "Windows matter more than one day.", "Logging improves predictions."], None, "4 min read"),
    ("ovulation_discharge_01", "Cervical mucus basics (without obsessing)", "How discharge can change near fertile days — and when to ignore the noise.", "Fertility", "fertility", "ovulation", "water", "Some people notice clearer, stretchier mucus near ovulation. Others never do. Both experiences are normal.", [("Useful, not absolute", "Mucus can be a clue alongside timing. Illness, arousal, and products also change discharge."), ("When to ask a clinician", "Odorous, painful, or very unusual discharge deserves medical advice — not just cycle apps.")], ["Mucus clues vary widely.", "Apps do not diagnose infection.", "Seek care for pain or odor."], ["ovulation", "follicular"], "4 min read"),
    ("luteal_cravings_01", "Working with luteal cravings", "Blood sugar, comfort, and why willpower alone fails before a period.", "Nutrition", "nutrition", "luteal", "fruit", "Cravings before a period are common. Pairing protein, fiber, and kindness beats white-knuckle restriction.", [("What helps", "Regular meals, protein at breakfast, and planned treats reduce binge-restrict cycles."), ("What hurts", "Skipping meals then \"being good\" often backfires by evening.")], ["Eat regularly in luteal weeks.", "Planned treats reduce chaos.", "Restriction feeds cravings."], None, "3 min read"),
    ("luteal_bloating_01", "Easing luteal bloating", "Salt, fiber, movement, and when swelling signals something else.", "PMS & Care", "pms_care", "luteal", "tea", "Progesterone and fluid shifts can leave you feeling puffy. Gentle habits help; shame does not.", [("Practical supports", "Steady hydration, potassium-rich foods, light walks, and looser waistbands on peak days."), ("Red flags", "Sudden severe swelling, pain with breathing, or one-sided leg swelling needs urgent care — not wait-and-see.")], ["Bloating is common pre-period.", "Gentle movement helps.", "Know emergency red flags."], None, "3 min read"),
    ("luteal_boundaries_01", "Protecting your calendar before your period", "Lower bandwidth weeks need fewer obligations — plan them early.", "PMS & Care", "pms_care", "luteal", "journal", "If you know week three tends to feel heavier, design it that way in advance instead of apologizing later.", [("Plan soft", "Move big deadlines, social marathons, and conflict-heavy talks when you can."), ("Communicate early", "A simple \"I am protecting a quieter week\" sets expectations without oversharing.")], ["Anticipate low-bandwidth days.", "Fewer plans ≠ failure.", "Early communication helps."], ["luteal"], "3 min read"),
    ("luteal_irritability_01", "When everything feels louder", "Nervous systems can be more reactive before bleeding — tools that help.", "PMS & Care", "pms_care", "luteal", "nature", "Sounds, comments, and unfinished tasks can hit harder in late luteal. That is physiology meeting life load.", [("Short resets", "Step outside, drink water, delay the reply, or ask for twenty quiet minutes."), ("Repair fast", "If you snap, a specific apology repairs faster than explaining hormones as an excuse.")], ["Reactivity can rise pre-period.", "Short resets help.", "Repair without self-erasure."], None, "4 min read"),
    ("menstrual_cramps_01", "Gentle ways to ease period cramps", "Heat, movement, meds, and when pain needs a clinician.", "Rest & Flow", "rest_flow", "menstrual", "blanket", "Cramps are common, but \"suffering in silence\" is not a requirement. Layer supports and escalate when pain is extreme.", [("First-line helps", "Heat packs, light walking, hydration, and OTC pain relief used as directed help many people."), ("See a clinician if", "Pain is disabling, suddenly worse, or paired with very heavy clotting — do not tough it out forever.")], ["Heat + gentle movement help many.", "Meds as directed are valid.", "Disabling pain deserves care."], None, "4 min read"),
    ("menstrual_iron_01", "Iron-friendly eating on period days", "Replenish without complicated meal plans.", "Nutrition", "nutrition", "menstrual", "kitchen", "Bleeding can increase iron needs. Simple meals beat perfect macros when energy is low.", [("Easy ideas", "Lentils, beans, eggs, leafy greens, fortified cereals, and vitamin C sides to help absorption."), ("Be kind", "If nausea is high, smaller frequent snacks still count.")], ["Prioritize iron-friendly foods.", "Pair with vitamin C when you can.", "Small meals still help."], ["menstrual"], "3 min read"),
    ("menstrual_movement_01", "Move gently while you bleed", "Why light movement can ease pain — and when to rest flat.", "Fitness", "fitness", "menstrual", "walk", "A short walk or stretch can reduce cramp intensity for some. Heavy training can wait if you feel wiped.", [("Green light", "Walking, mobility, easy yoga, and breathing drills."), ("Yellow light", "Skip max lifts or long HIIT if dizziness, heavy flow, or sharp pain shows up.")], ["Gentle movement can ease cramps.", "Listen to dizziness and pain.", "Rest is a valid workout."], None, "3 min read"),
    ("sleep_cycle_01", "How your cycle can mess with sleep", "Progesterone, temperature, and late-luteal wake-ups.", "Sleep", "sleep", "luteal", "sleep", "Many people sleep worse the week before a period. That pattern is common — and workable.", [("What helps", "Cooler room, earlier wind-down, consistent wake time, and less late caffeine."), ("What to avoid", "Doomscrolling in bed while angry at yourself for not sleeping.")], ["Late luteal sleep can fragment.", "Cool + consistent routines help.", "Self-blame worsens insomnia."], ["luteal", "menstrual"], "4 min read"),
    ("sleep_follicular_01", "Protecting sleep when energy returns", "High-energy weeks still need a bedtime — or burnout follows.", "Sleep", "sleep", "follicular", "sunrise", "Feeling wired after your period can tempt late nights. Sleep debt shows up later as mood and cravings.", [("Keep the anchor", "Hold a consistent lights-out even when you feel unstoppable."), ("Stack recovery", "Pair training progress with protein and earlier screens-off.")], ["Energy ≠ permission to skip sleep.", "Consistency beats occasional long nights.", "Recovery fuels the bright week."], None, "3 min read"),
    ("nutrition_protein_01", "Protein across the cycle", "Steady protein supports energy, training, and luteal stability.", "Nutrition", "nutrition", "general", "food", "You do not need a different diet every phase — but protein at most meals helps almost every phase.", [("Simple rule", "Include a palm-sized protein source at breakfast and lunch when you can."), ("Cycle note", "Late luteal hunger may need slightly larger portions — that is physiology, not failure.")], ["Protein steadies energy.", "Breakfast protein helps many.", "Hunger shifts are normal."], ["follicular", "luteal", "menstrual", "ovulation"], "3 min read"),
    ("nutrition_hydration_01", "Hydration that actually sticks", "Water, electrolytes, and why \"just drink more\" fails.", "Nutrition", "nutrition", "general", "water", "Dehydration amplifies headaches, fatigue, and cramp perception. Make water frictionless.", [("Make it easy", "Bottle on the desk, flavored options you like, and water with meals."), ("During bleeding", "Replace fluids thoughtfully if flow is heavy — ask a clinician about dizziness.")], ["Keep water visible.", "Flavor is allowed.", "Dizziness with heavy flow needs care."], ["menstrual", "luteal"], "3 min read"),
    ("fitness_listening_01", "Training by feel, not only by plan", "Cycle-aware fitness means adjusting intensity without quitting identity.", "Fitness", "fitness", "general", "run", "Plans are useful. Bodies are wiser in the moment. Scaling a session is athletic, not weak.", [("Traffic-light check", "Green: push. Yellow: modify. Red: walk, mobility, or rest."), ("Identity trap", "You are still an athlete on rest days.")], ["Adjusting intensity is smart.", "Rest days keep you training.", "Feel matters alongside plans."], ["follicular", "luteal", "menstrual", "ovulation"], "4 min read"),
    ("fitness_ovulation_01", "Peak-week training tips", "Confidence and power can rise — warm-ups still matter.", "Fitness", "fitness", "ovulation", "strength", "Some notice a performance bump near ovulation. Enjoy it, but do not skip mobility and fuel.", [("Use the bump", "Skill work, tempo runs, or a confidence PR attempt if recovery feels good."), ("Stay humble", "Ligament laxity and risk vary. Pain is still a stop sign.")], ["Peak weeks can feel strong.", "Warm up thoroughly.", "Pain ends the set."], ["ovulation", "follicular"], "3 min read"),
    ("wellness_stress_01", "Stress and your cycle predictions", "High stress can delay periods — apps estimate; life still wins.", "Wellness", "wellness", "general", "nature", "Travel, illness, and chronic stress can shift ovulation and period timing. Predictions will lag until data catches up.", [("What to do", "Keep logging, lower what you can, and avoid panicking at one late day."), ("When to check in", "Missed periods with pregnancy possibility, or many months of chaos, deserve clinical advice.")], ["Stress can delay cycles.", "Keep logging calmly.", "Seek care for prolonged disruption."], ["luteal", "follicular"], "4 min read"),
    ("wellness_logging_01", "Why logging periods improves predictions", "Sparse data means wider guesses — consistency teaches the algorithm.", "Wellness", "wellness", "general", "journal", "EezyCycle predictions improve when period starts and lengths are logged honestly. Mistaps and gaps create noise.", [("Best practice", "Mark actual bleed days, not \"I think it started Tuesday.\" Correct quickly if you tapped wrong."), ("Patience", "Averages stabilize over several cycles, not overnight.")], ["Honest logs beat perfect memory.", "Fix mistaps quickly.", "Averages need a few cycles."], None, "3 min read"),
    ("wellness_mood_01", "Separating mood from identity", "Feeling flat pre-period does not mean you \"are\" irritable.", "Wellness", "wellness", "luteal", "reflect", "Hormonal weeks can color mood. Naming the weather helps you not rewrite your whole personality.", [("Try this language", "\"I am having a loud-feelings day\" instead of \"I am impossible.\""), ("Support", "Ask for practical help and fewer decisions rather than a personality debate.")], ["Mood weather ≠ identity.", "Name the state kindly.", "Ask for practical support."], ["luteal", "menstrual"], "3 min read"),
    ("pregnancy_nausea_01", "Early pregnancy nausea — gentle supports", "Small meals, triggers, and when to call your clinician.", "Pregnancy", "pregnancy", "pregnancy", "tea", "Nausea is common early on. App tips are educational — your clinician guides treatment.", [("What often helps", "Small frequent snacks, bland foods, ginger if approved, and rest after eating."), ("Call sooner if", "You cannot keep fluids down, lose significant weight, or feel severely dehydrated.")], ["Small frequent meals help many.", "Rest after eating.", "Severe vomiting needs care."], None, "4 min read"),
    ("pregnancy_energy_01", "First-trimester fatigue is real", "Sleeping more is not laziness — it is a common adaptation.", "Pregnancy", "pregnancy", "pregnancy", "sleep", "Progesterone and metabolic shifts can flatten energy early. Lower the bar and raise support.", [("Practical shifts", "Naps when possible, earlier bedtimes, and saying no without essays."), ("Partner note", "Help with meals and chores is medical-adjacent kindness.")], ["Fatigue is common early.", "Lower the productivity bar.", "Ask for concrete help."], None, "3 min read"),
    ("pregnancy_movement_01", "Moving safely while pregnant", "Unless told otherwise, gentle activity often helps — get personal clearance.", "Pregnancy", "pregnancy", "pregnancy", "walk", "Walking and prenatal-approved movement support mood and circulation for many. Always follow your clinician's guidance.", [("Generally friendly", "Walking, swimming, and prenatal yoga if cleared."), ("Avoid assumptions", "What was fine last pregnancy may differ this time — ask.")], ["Get clinician clearance.", "Walking helps many.", "No one-size rule."], None, "3 min read"),
    ("rest_permission_01", "Permission to do less", "Rest is a health behavior, not a moral failure.", "Rest & Flow", "rest_flow", "menstrual", "blanket", "Culture praises push-through. Bodies often need pause — especially on heavy or painful days.", [("Micro-rest", "Ten minutes horizontal, phone away, heat on the abdomen."), ("Macro-rest", "Cancel one non-essential plan without replacing it.")], ["Rest is productive for healing.", "Cancel one thing.", "Heat + horizontal helps."], ["menstrual", "luteal"], "3 min read"),
    ("rest_heat_01", "Heat therapy without the fuss", "Pads, bottles, and baths — simple tools for cramp days.", "Rest & Flow", "rest_flow", "menstrual", "tea", "Warmth relaxes pelvic muscles for many people. Keep tools ready before pain peaks.", [("Setup", "Plug-in pad, microwavable wrap, or warm bath if safe for you."), ("Pairing", "Combine with hydration and a lighter schedule.")], ["Prep heat before peak pain.", "Hydrate alongside warmth.", "Lighten the day."], None, "2 min read"),
    ("energy_afternoon_01", "Afternoon dips across the month", "Not every slump is \"just hormones\" — but hormones can amplify them.", "Energy & Hormones", "energy_hormones", "general", "desk", "Post-lunch crashes happen to everyone. In luteal weeks they can feel sharper. Food timing and light movement help.", [("Quick fixes", "Protein + carb snack, short walk, daylight if possible."), ("Avoid", "Only coffee on an empty stomach as your entire strategy.")], ["Snacks + daylight help dips.", "Walks beat another empty espresso.", "Luteal weeks may feel sharper."], ["luteal", "follicular"], "3 min read"),
    ("energy_caffeine_01", "Caffeine, anxiety, and cycle weeks", "The same latte can feel different before your period.", "Energy & Hormones", "energy_hormones", "luteal", "tea", "Some people get jitterier on the same caffeine dose in late luteal. Experiment gently.", [("Experiment", "Try earlier cutoff times or half-caf in the pre-period window."), ("Sleep link", "Late caffeine plus luteal insomnia is a rough combo.")], ["Sensitivity can rise pre-period.", "Earlier cutoff helps.", "Watch late-day cups."], None, "3 min read"),
    ("fertility_myths_01", "Fertility myths worth retiring", "Position, one perfect day, and other sticky ideas.", "Fertility", "fertility", "ovulation", "health", "Internet fertility advice is loud. A few myths create unnecessary stress.", [("Myth: one perfect hour", "Fertile windows span days. Obsession with a single hour often increases anxiety without improving odds."), ("Myth: apps replace clinicians", "Tracking supports conversations with care providers — it does not replace them.")], ["Windows beat magic hours.", "Apps support, not replace care.", "Lower anxiety where you can."], ["ovulation", "follicular"], "4 min read"),
    ("fertility_trying_01", "Trying to conceive without burning out", "Hope, data, and protecting your relationship.", "Fertility", "fertility", "ovulation", "couple_soft", "TTC can turn intimacy into a project. Schedule tenderness that is not only about conception.", [("Protect connection", "Plan non-goal intimacy and dates that are not calendar-driven."), ("Know when to escalate", "Age, history, and months of trying change when to seek fertility care — ask a clinician for your timeline.")], ["Keep non-TTC intimacy alive.", "Data should serve you, not rule you.", "Ask about your personal timeline."], ["ovulation", "follicular"], "5 min read"),
    ("pms_partner_01", "How partners can help with PMS", "Concrete help beats \"let me know if you need anything.\"", "PMS & Care", "pms_care", "luteal", "hands", "Vague offers create more work. Specific help — meals, chores, quieter evenings — lands better.", [("Better offers", "\"I can handle dinner Tuesday\" or \"Want the heating pad while I do dishes?\""), ("What to avoid", "Diagnosing her mood or joking that she is \"crazy this week.\"")], ["Specific help > vague offers.", "Skip PMS jokes.", "Quieter plans help."], ["luteal"], "3 min read"),
    ("wellness_body_image_01", "Body image across the month", "Bloating and water retention can distort the mirror — you did not \"fail.\"", "Wellness", "wellness", "luteal", "reflect", "Clothes fitting differently pre-period is often fluid, not fat gain overnight. Soften the commentary.", [("Try", "Looser favorites that week; delay weigh-ins if they spiral you."), ("Language", "\"My body is holding water\" instead of \"I ruined everything.\"")], ["Fluid shifts are common.", "Softer clothes help.", "Delay harsh weigh-ins."], ["luteal", "menstrual"], "3 min read"),
    ("nutrition_magnesium_01", "Magnesium-friendly foods for softer evenings", "Leafy greens, nuts, and cocoa — food first before supplements.", "Nutrition", "nutrition", "luteal", "food", "Some people find magnesium-rich foods ease evening tension. Food sources are a gentle start; ask a clinician before high-dose supplements.", [("Food ideas", "Pumpkin seeds, almonds, spinach, black beans, and dark chocolate in modest amounts."), ("Supplements", "Not everyone needs them — check interactions and dosing with a professional.")], ["Food first when possible.", "Ask before supplementing.", "Evening calm is multifactorial."], ["luteal"], "3 min read"),
    ("fitness_walks_01", "Why walking works every phase", "Low barrier, high return for mood and cramps.", "Fitness", "fitness", "general", "walk", "Walking is underrated cycle care. It scales from period days to high-energy weeks.", [("Make it stick", "Ten minutes counts. Pair with a podcast or a friend."), ("Phase note", "Keep it flat and easy on heavy days; add hills when energy rises.")], ["Ten minutes still counts.", "Scale intensity by phase.", "Mood benefits are real."], ["menstrual", "follicular", "luteal", "ovulation"], "2 min read"),
    ("sleep_screens_01", "Screens, scrolling, and late-luteal brains", "Anxious brains + bright phones = longer nights.", "Sleep", "sleep", "luteal", "sleep", "If your brain runs hot before a period, scrolling rarely soothes it. Build a boring wind-down on purpose.", [("Swap", "Paper book, stretch, audio with a timer, lights down."), ("Boundary", "Phone charges outside the bedroom if you can.")], ["Boring wind-downs win.", "Charge outside the bedroom.", "Timers beat endless scroll."], ["luteal"], "3 min read"),
    ("wellness_self_compassion_01", "Self-compassion on hard cycle days", "Talk to yourself like someone you love.", "Wellness", "wellness", "menstrual", "calm", "Harsh self-talk stacks on top of physical discomfort. Soft language does not make pain imaginary — it makes coping possible.", [("Script", "\"This is a hard body day. I can do less and still be worthy.\""), ("Action", "One comfort + one boundary + one ask for help.")], ["Soft language helps coping.", "Do less without shame.", "Ask for one concrete help."], ["menstrual", "luteal"], "3 min read"),
]

for row in extra:
    (id_, title, desc, cat, ctype, phase, img, hero, secs, takes, phases, read) = (*row[:10], row[10] if len(row) > 10 else None, row[11] if len(row) > 11 else "4 min read")
    articles.append(
        a(
            id_,
            title,
            desc,
            cat,
            ctype,
            phase,
            img,
            hero,
            secs,
            takes,
            phases=phases,
            read_time=read,
        )
    )

assert len(articles) == 50, f"expected 50, got {len(articles)}"
ids = [x["id"] for x in articles]
assert len(ids) == len(set(ids)), "duplicate ids"

OUT.write_text(
    json.dumps(
        {"version": 1, "image_source": "unsplash", "articles": articles},
        indent=2,
        ensure_ascii=False,
    )
    + "\n",
    encoding="utf-8",
)
print(f"Wrote {len(articles)} articles → {OUT}")
from collections import Counter
print(Counter(x["phase"] for x in articles))
print(Counter(x["category_type"] for x in articles))
