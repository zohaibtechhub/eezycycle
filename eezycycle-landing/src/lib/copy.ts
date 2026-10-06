import type { FeatureSlug } from "./constants";

export const hero = {
  brand: "EezyCycle",
  headline: "Your cycle, clearly mapped",
  support:
    "EezyCycle helps you log periods, estimate ovulation and fertile days, follow pregnancy week by week, navigate perimenopause, invite a partner, and learn from trusted articles — privately, and free to start as a guest.",
  primaryCta: "Download the app",
  secondaryCta: "Explore features",
} as const;

export const homeFeaturesIntro = {
  title: "One app for every chapter",
  support:
    "Switch experience modes anytime — Track cycle, Get pregnant, Track pregnancy, or Perimenopause — without losing your history.",
} as const;

export const homeGoals = {
  title: "What people use EezyCycle for",
  support:
    "Pick the goals that match your life. The app personalizes insights, articles, and reminders around what you choose.",
  items: [
    {
      title: "Track my period",
      detail: "See what’s coming next with clearer period timing estimates.",
    },
    {
      title: "Get pregnant",
      detail: "Focus on fertile-window and ovulation estimates while you try.",
    },
    {
      title: "Track my pregnancy",
      detail: "Week-by-week baby and body insights after you switch modes.",
    },
    {
      title: "Take charge of well-being",
      detail: "Phase-aware tips for mood, energy, sleep, and daily habits.",
    },
    {
      title: "Understand symptoms",
      detail: "Log cramps, mood, discharge, and more to spot your patterns.",
    },
    {
      title: "Invite a partner",
      detail: "Share a high-level cycle view — keep intimate logs private.",
    },
  ],
} as const;

export const homeTrust = {
  title: "Built to earn your trust",
  items: [
    {
      title: "Guest-friendly",
      detail:
        "Start without an account. Create one later (email or Google) when you want sync and recovery across devices.",
    },
    {
      title: "Privacy first",
      detail:
        "We never sell your health data to advertisers. You can delete your data anytime from the app or by emailing us.",
    },
    {
      title: "Estimates, clearly labeled",
      detail:
        "Predictions improve the more cycles you log. They are not contraception, diagnosis, or a medical guarantee.",
    },
  ],
} as const;

export const predictions = {
  title: "How predictions work",
  support:
    "Predictions improve as you log cycles. We estimate period timing, ovulation, and fertile windows from your history — always estimates, never a medical guarantee.",
  steps: [
    {
      label: "Log your periods",
      detail:
        "Mark start and end days on the calendar. After you save at least one full period, ovulation and fertile-window estimates unlock.",
    },
    {
      label: "We learn your rhythm",
      detail:
        "Your history shapes a personal cycle profile. Irregular cycles are okay — confidence adjusts as more data comes in.",
    },
    {
      label: "See clear estimates",
      detail:
        "Period, ovulation, and fertile-window cues show on your home date strip and calendar so you can plan ahead.",
    },
  ],
} as const;

export const homeInsights = {
  title: "Insights for the day you’re in",
  support:
    "Home isn’t only a calendar. EezyCycle brings phase-aware tips, articles, and gentle reminders so you always know what your body may be doing.",
  items: [
    {
      title: "Daily cycle insights",
      detail:
        "Short, practical notes matched to follicular, ovulation, luteal, or period days — estimates based on your logs.",
    },
    {
      title: "Health articles",
      detail:
        "Evidence-minded reads on mood, sleep, fertility, pregnancy, intimacy, and wellness — recommended for your phase.",
    },
    {
      title: "Symptom logging",
      detail:
        "Quick actions for mood, cramps, discharge, tests, and more so patterns become easier to see over time.",
    },
    {
      title: "Optional reminders",
      detail:
        "Gentle nudges before period and fertile days when you allow notifications — you stay in control.",
    },
  ],
} as const;

export const homePartner = {
  title: "Built for partners, too",
  support:
    "Partner Space is opt-in. Invite with a code so they can see a read-only cycle calendar and support tips — without opening your private logs.",
  bullets: [
    "High-level phase and period / fertile estimates only",
    "Practical tips for emotional support, space, and planning",
    "Sex logs, detailed symptoms, tests, and notes stay with you",
    "Disconnect anytime in the app",
  ],
} as const;

export const homeCommunity = {
  title: "Secret Chat — ask quietly",
  support:
    "An anonymous community inside the app for questions you might not ask elsewhere. Post only what you’re comfortable sharing with other members.",
} as const;

export const privacy = {
  title: "Your body, your data",
  support:
    "Reproductive health data is sensitive. EezyCycle is built so you keep control — from guest mode to deletion.",
  bullets: [
    "We never sell your personal or reproductive health data",
    "You can delete your data anytime",
    "Data in transit uses HTTPS / TLS",
    "Start as a guest — create an account when you want sync",
    "Partner sharing is opt-in and limited by design",
  ],
} as const;

export const faqItems = [
  {
    id: "download",
    question: "Where do I download EezyCycle?",
    answer:
      "Download the EezyCycle app from our Download page (Google Play). Until the listing is live, that page will show the latest link.",
  },
  {
    id: "account",
    question: "Do I need an account to use EezyCycle?",
    answer:
      "No. You can start as a guest and log periods, track symptoms, and use most features right away. Creating an account (email or Google) keeps your data tied to you so you can sign in again on the same or another device without losing your history.",
  },
  {
    id: "first",
    question: "What should I do first after installing the app?",
    answer:
      "Accept privacy & terms, choose how you’ll use EezyCycle (for yourself or with a partner code), pick your goals (e.g. Track cycle), then log your last period dates. Predictions improve after you save at least one full period.",
  },
  {
    id: "modes",
    question:
      "What’s the difference between Track cycle, Get pregnant, and Pregnancy modes?",
    answer:
      "Track cycle focuses on period and ovulation predictions for everyday awareness. Get pregnant emphasizes fertile-window timing. Pregnancy mode shifts the home experience to pregnancy week estimates and due-date support. You can switch modes later from the drawer under Your EezyCycle Experience.",
  },
  {
    id: "log-period-prompt",
    question: "Why does the home screen show “Log your period”?",
    answer:
      "That message appears when we don’t yet have enough period history to build predictions. Open the calendar, tap your period days, then press Log (top right). After you save, ovulation and fertile-window estimates unlock.",
  },
  {
    id: "offline",
    question: "Can I use EezyCycle offline?",
    answer:
      "You need a connection to sync logs, predictions, partner status, and secret chat. Brief offline moments may show cached home content, but saving periods and account actions require the API to be reachable.",
  },
  {
    id: "accuracy",
    question: "How accurate are the cycle and ovulation predictions?",
    answer:
      "Predictions improve the more cycles you log. We use standard cycle-length and luteal-phase estimates adjusted by your history. Treat fertile and ovulation days as estimates only — not contraception and not a medical diagnosis.",
  },
  {
    id: "log-edit",
    question: "How do I log or edit period days?",
    answer:
      "Open the calendar from the home header. Tap days to mark or unmark period flow (changes stay local until you save). Tap Log in the top right to send one update to the server. If you go back with unsaved taps, you’ll be asked to Discard or Log.",
  },
  {
    id: "future-dates",
    question: "Can I log periods on future dates?",
    answer:
      "No. Period days can only be logged for today or past dates. Future dates on the home strip show predictions (fertile window, ovulation, next period) so you can plan ahead — they aren’t editable as logged bleeds.",
  },
  {
    id: "irregular",
    question: "How do I log irregular cycles or spotting?",
    answer:
      "Use the calendar to tap any past or current day that had spotting or flow, then Log. Symptoms (cramps, mood, discharge, and more) can be logged from Home quick actions. Larger cycle swings automatically widen prediction confidence over time.",
  },
  {
    id: "fertile-window",
    question: "What is the fertile window?",
    answer:
      "The fertile window is the stretch of days when conception is more likely, ending around ovulation. EezyCycle marks these from your cycle length and luteal phase. Timing estimates are not birth control — use contraception if you are avoiding pregnancy.",
  },
  {
    id: "luteal",
    question: "What does “luteal phase” mean in my profile?",
    answer:
      "The luteal phase is the time from ovulation to the start of your next period (often about 14 days). Your profile stores an average used for predictions. If your clinician recommends a different value, update it in your cycle settings when available.",
  },
  {
    id: "patterns",
    question: "What are “Your patterns” on Home?",
    answer:
      "Your patterns are personal timing insights built from your symptom and cycle logs (for example, when cramps or mood shifts tend to appear). They’re educational summaries — not a diagnosis. Patterns appear after you’ve logged enough history.",
  },
  {
    id: "graphs",
    question: "Where can I see cycle length and ovulation stats?",
    answer:
      "Open the drawer → Graphs & reports → Cycle and ovulation. You’ll see average cycle/period length, phase breakdown, and recent history trends based on your logged data.",
  },
  {
    id: "medical",
    question: "Does EezyCycle replace medical advice?",
    answer:
      "No. The app is for personal tracking and education. Always talk to a qualified healthcare professional about contraception, fertility treatment, pregnancy concerns, severe pain, unusually heavy bleeding, or missed periods.",
  },
  {
    id: "pregnancy-mode",
    question: "How does pregnancy mode change the app?",
    answer:
      "When pregnancy mode is active, Home focuses on pregnancy week and due-date style estimates instead of fertile-window countdowns. Cycle logging and partner sharing behave according to your pregnancy settings. Switch modes from the drawer when your goals change.",
  },
  {
    id: "predictions-change",
    question: "Why did my predictions change after I logged a period?",
    answer:
      "Each saved period updates your averages and rebuilds upcoming fertile and ovulation estimates. That’s expected — more real data makes the next cycle’s forecast closer to your body.",
  },
  {
    id: "lh-tests",
    question: "Can I track LH / ovulation tests?",
    answer:
      "Yes. From Home, use Tests / LH (or the logging sheet) to record ovulation-test results for a selected date. Positive or peak tests help you reflect on timing alongside predicted ovulation — they don’t replace clinical care.",
  },
  {
    id: "partner",
    question: "How does Partner Mode work?",
    answer:
      "You generate a 6-character invite code. Your partner chooses “I have a partner code” during onboarding and enters it. They get a read-only home with cycle phases and relationship tips. They cannot edit or delete your health logs.",
  },
  {
    id: "partner-code",
    question: "How do I generate a partner connection code?",
    answer:
      "Open the Partner tab (or Partner connection from the drawer), create or view your invite code, and share the 6-character code securely with your partner. Codes expire or close when linked — generate a new one if you need to reconnect.",
  },
  {
    id: "partner-sees",
    question: "What can my partner see?",
    answer:
      "Partners see high-level cycle phases (period, fertile window, ovulation estimates), pregnancy status when relevant, and supportive tips. They do not see detailed symptom notes, sex logs, test results, or your secret chat content.",
  },
  {
    id: "partner-edit",
    question: "Can my partner change my period dates or profile photo?",
    answer:
      "No. Partners are read-only. Your photo appears for them so they recognize your shared space, but only you can update cycle logs and profile photo from your account.",
  },
  {
    id: "partner-disconnect",
    question: "How do I disconnect a partner?",
    answer:
      "From Partner connection / status on your account, end the link. Your partner loses access to shared cycle views. Your personal logs stay on your account. You can invite someone again later with a new code.",
  },
  {
    id: "partner-calendar",
    question: "I’m a partner — why can’t I open the full calendar editor?",
    answer:
      "Partners get a shared, read-only view of the cycle. Logging periods, symptoms, and tests stays with the person who owns the cycle data. Use tips and phase info to support them day to day.",
  },
  {
    id: "secret-chat",
    question: "What is Secret Chat?",
    answer:
      "Secret Chat is an anonymous community space inside EezyCycle. You pick a username and optional tags, then can post and comment without showing your real email. It’s meant for supportive cycle and wellness conversation.",
  },
  {
    id: "secret-anonymous",
    question: "Is Secret Chat really anonymous?",
    answer:
      "Posts and comments show your secret username and profile photo, not your email. Don’t share identifying details in posts if you want to stay private. Moderators may still act on reports of harmful content.",
  },
  {
    id: "secret-username",
    question: "How do I set or change my secret username?",
    answer:
      "Open Secret Chat → your profile / edit profile. Choose a username (about 3–40 characters) and optional tags like PCOS or Trying to conceive. Your account profile photo is used for the community avatar.",
  },
  {
    id: "secret-delete",
    question: "Can I delete a post I made?",
    answer:
      "Yes. On your post, use Delete and confirm. You’ll see a short loading state while the post is removed. Deleted posts disappear for everyone in the community feed.",
  },
  {
    id: "secret-partner",
    question: "Does my partner see Secret Chat?",
    answer:
      "No. Secret Chat is separate from Partner Mode. Partners never see your posts, comments, or secret username through the partner link.",
  },
  {
    id: "privacy-secure",
    question: "Is my reproductive health data secure?",
    answer:
      "We transmit data over HTTPS and store account and health records on secured servers. We do not sell your reproductive health data to advertisers. Read the in-app Privacy Policy for full details on retention and your rights.",
  },
  {
    id: "privacy",
    question: "Do you sell my health data?",
    answer:
      "No. We do not sell your personal or reproductive health data to advertisers. Request deletion via the app or info@eezycycle.com.",
  },
  {
    id: "privacy-partner-symptoms",
    question: "Can my partner see all my intimate logged symptoms?",
    answer:
      "No. Partner Mode only shares high-level cycle phases and supportive tips. Intimate notes, sex logs, and specific test details stay private to you.",
  },
  {
    id: "privacy-photo",
    question: "Who can see my profile photo?",
    answer:
      "Your photo appears in the app header, drawer, profile, and Secret Chat. A linked partner sees your photo as read-only context. It is not shown publicly outside the app.",
  },
  {
    id: "privacy-settings",
    question: "How do I review privacy settings?",
    answer:
      "Open the drawer → User Privacy (or Privacy Policy / Terms from legal screens). You can revisit consent documents anytime. Contact support through official channels if you need account deletion help.",
  },
  {
    id: "guest-end",
    question: "Does ending a guest session delete my data?",
    answer:
      "Ending a guest session on this device starts a fresh guest experience locally. Registered account data stays safely on the server so you can sign in again. Upgrade to an account if you want a lasting backup of your logs.",
  },
  {
    id: "sign-in",
    question: "How do I create an account or sign in?",
    answer:
      "From the drawer, use the email / password or Google options. Guests upgrade in place so your cycle logs stay with you. Already registered? Use Sign in — your saved periods and settings load after authentication.",
  },
  {
    id: "forgot-password",
    question: "I forgot my password — what do I do?",
    answer:
      "On the sign-in screen, choose Forgot password. Enter your email, verify the OTP we send, then set a new password. Check spam if the email is slow, and make sure you use the same address as your account.",
  },
  {
    id: "profile-photo",
    question: "Can I change my profile photo?",
    answer:
      "Yes — open My Profile from the drawer and tap your photo (guests and registered users). Partners cannot change the woman’s photo. The new image syncs to Secret Chat and partner views.",
  },
  {
    id: "after-signin",
    question: "Why don’t I see my periods right after signing in?",
    answer:
      "After login we refresh Home and calendar for your account. Stay on Home a moment while data loads. If something still looks empty, pull to refresh or reopen Cycle and ovulation from the drawer.",
  },
  {
    id: "logout-vs-guest",
    question: "What’s the difference between Log out and ending a guest session?",
    answer:
      "Registered users Log out and can sign back in later. Guests “end session” clears the local guest session and starts fresh on this device. Registered data on the server is not deleted by logging out.",
  },
  {
    id: "google",
    question: "Can I use Google to sign in?",
    answer:
      "Yes. Choose Google on the auth screens. If that Google email is new, your guest upgrades in place. If it already belongs to an account, you sign into that existing account and your cycle history for that user loads.",
  },
  {
    id: "help-legal",
    question: "Where do I find Help, FAQ, and legal documents?",
    answer:
      "Open the drawer and look for Help & FAQ, Privacy Policy, and Terms. Those screens explain how EezyCycle works and how we handle your information. On the website, see FAQ and Privacy in the footer.",
  },
  {
    id: "bookmarks",
    question: "How do I bookmark articles?",
    answer:
      "On article screens that support bookmarks, tap the bookmark control. Saved pieces appear under Bookmarks in the drawer so you can reopen educational content later (requires a signed-in session — guest or registered).",
  },
] as const;


export const finalCta = {
  title: "Ready to know your cycle better?",
  support:
    "Download EezyCycle free. Guest mode available. Privacy first. Predictions that improve as you log.",
  primaryCta: "Download the app",
} as const;

export const disclaimer =
  "EezyCycle is a personal wellness tool. Predictions are estimates and are not contraception, diagnosis, or medical advice. Always consult a qualified healthcare professional for medical decisions.";

export type FeaturePageContent = {
  slug: FeatureSlug;
  eyebrow: string;
  title: string;
  description: string;
  bullets: string[];
  ctaNote: string;
};

export const featurePages: Record<FeatureSlug, FeaturePageContent> = {
  "period-tracker": {
    slug: "period-tracker",
    eyebrow: "Track cycle",
    title: "Know when your period is coming",
    description:
      "Log period days and symptoms in a calm calendar built for everyday use. Predictions get sharper the more you track — so you can plan ahead without guesswork.",
    bullets: [
      "Simple period logging on a clear calendar (today and past days)",
      "Home date strip with period, fertile, and ovulation color cues",
      "Symptom and mood tracking from quick actions on Home",
      "Upcoming period estimates that improve with your history",
      "Cycle and ovulation graphs when you want the bigger picture",
      "Switch modes later without losing past logs",
    ],
    ctaNote: "Download EezyCycle and log your last period in under a minute.",
  },
  "ovulation-fertility": {
    slug: "ovulation-fertility",
    eyebrow: "Get pregnant · Fertility awareness",
    title: "See your fertile window estimates",
    description:
      "When you’re trying to conceive — or simply want to understand your body — EezyCycle highlights estimated ovulation and fertile days based on your logged cycles.",
    bullets: [
      "Fertile-window and ovulation day estimates on calendar and home",
      "Get pregnant mode tuned for timing and conception education",
      "Articles and tips on body signals, timing, and preparation",
      "Optional gentle reminders for fertile days and test windows",
      "Partner can join later with a limited shared summary",
      "Estimates only — not a guarantee of ovulation or pregnancy",
    ],
    ctaNote: "Download free and switch to Get pregnant mode anytime.",
  },
  pregnancy: {
    slug: "pregnancy",
    eyebrow: "Track pregnancy",
    title: "Week-by-week support after a positive test",
    description:
      "Pregnancy mode shifts your home experience to due-date support and daily insights for baby and body — so you feel guided through each week.",
    bullets: [
      "Pregnancy week estimates and due-date focus on Home",
      "Daily baby and body insight cards you can open as stories",
      "A calmer home layout designed for pregnancy mode",
      "Suggestions and tips that change with your week",
      "Switch modes without losing your past cycle data",
      "Educational only — always follow your clinician’s advice",
    ],
    ctaNote: "Download EezyCycle and activate pregnancy mode when you’re ready.",
  },
  perimenopause: {
    slug: "perimenopause",
    eyebrow: "Track perimenopause",
    title: "Navigate changing cycles with clarity",
    description:
      "Perimenopause can feel unpredictable. EezyCycle helps you log symptoms, track period changes, and get practical tips tailored to this transition.",
    bullets: [
      "Symptom logging for common perimenopause signs",
      "Track how periods, mood, and energy shift over time",
      "Tips on sleep, nutrition, and wellness for this stage",
      "Bring your existing cycle history with you when you switch",
      "Change your goal anytime in Settings / the drawer",
      "Supportive education — not a medical diagnosis",
    ],
    ctaNote: "Download the app and choose Track perimenopause in your experience.",
  },
  partner: {
    slug: "partner",
    eyebrow: "Partner Space",
    title: "Support without oversharing",
    description:
      "Invite your partner with a code. They get a read-only cycle calendar and practical ways to help — while your intimate logs stay private.",
    bullets: [
      "Opt-in invite via partner code",
      "Read-only phase and period / fertile estimates",
      "Tips for emotional support, practical help, and space",
      "Sex logs, detailed symptoms, tests, and notes stay with you",
      "Improve communication with cycle-aware context",
      "Disconnect anytime — sharing stops for new data",
    ],
    ctaNote: "Download EezyCycle — then invite from Partner Space when you’re ready.",
  },
  "secret-chat": {
    slug: "secret-chat",
    eyebrow: "Community",
    title: "Ask what you can’t ask elsewhere",
    description:
      "Secret Chat is an anonymous community inside EezyCycle. Post questions and experiences — only share what you’re comfortable making visible to other members.",
    bullets: [
      "Anonymous posting and comments",
      "A quieter space for real cycle and fertility questions",
      "You control what you publish",
      "Separate from your private health logs",
      "Safety tools as the community grows",
      "Available when you’re signed in to the app",
    ],
    ctaNote: "Download the app to join Secret Chat when you’re signed in.",
  },
};
