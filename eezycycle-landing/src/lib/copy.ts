import type { FeatureSlug } from "./constants";

export const hero = {
  brand: "EezyCycle",
  headline: "The cycle app you’ll actually open",
  support:
    "Period timing, ovulation estimates, pregnancy insights, and partner support — private by design. Download the app and start as a guest.",
  primaryCta: "Download app",
  secondaryCta: "Explore features",
} as const;

export const homeFeaturesIntro = {
  title: "Everything your cycle journey needs",
  support:
    "One app. Multiple modes. Pick what fits today — switch anytime in Settings.",
} as const;

export const homeTrust = {
  title: "Built to earn your trust",
  items: [
    {
      title: "Guest-friendly",
      detail: "Track without an account. Upgrade when you want sync.",
    },
    {
      title: "Privacy first",
      detail: "We never sell your health data. Delete anytime.",
    },
    {
      title: "Estimates, clearly labeled",
      detail: "Predictions improve with your logs — not medical claims.",
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
      detail: "Mark start and end days on the calendar in seconds.",
    },
    {
      label: "We learn your rhythm",
      detail: "Your history shapes a personal cycle profile over time.",
    },
    {
      label: "See clear estimates",
      detail: "Period, ovulation, and fertile-window cues on your calendar.",
    },
  ],
} as const;

export const privacy = {
  title: "Your body, your data",
  support: "Reproductive health data stays yours.",
  bullets: [
    "We never sell your data",
    "You can delete your data anytime",
    "Encrypted in transit (HTTPS / TLS)",
    "Start as a guest — account when you want sync",
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
      "No. You can start as a guest and log periods, track symptoms, and use most features right away. Creating an account keeps your data recoverable across devices.",
  },
  {
    id: "accuracy",
    question: "How accurate are the cycle and ovulation predictions?",
    answer:
      "Predictions improve the more cycles you log. Treat fertile and ovulation days as estimates only — not contraception and not a medical diagnosis.",
  },
  {
    id: "modes",
    question: "What’s the difference between the experience modes?",
    answer:
      "Track cycle focuses on period and ovulation awareness. Get pregnant emphasizes fertile-window timing. Pregnancy mode shifts to week estimates and due-date support. Perimenopause helps with changing cycles. Switch anytime in the app.",
  },
  {
    id: "partner",
    question: "How does Partner Space work?",
    answer:
      "Partner linking is optional. With a partner code, they see a high-level cycle summary and support tips — not sex logs, detailed symptoms, test results, or private notes.",
  },
  {
    id: "medical",
    question: "Is EezyCycle a medical device?",
    answer:
      "No. EezyCycle is a personal wellness tool for tracking and education. Always consult a qualified healthcare professional for medical decisions.",
  },
  {
    id: "privacy",
    question: "Do you sell my health data?",
    answer:
      "No. We do not sell your personal or reproductive health data to advertisers. Request deletion via the app or info@eezycycle.com.",
  },
] as const;

export const finalCta = {
  title: "Download the app",
  support: "Free to start. Guest mode available. Your data stays yours.",
  primaryCta: "Download app",
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
      "Simple period logging on a clear calendar",
      "Symptom and mood tracking that fits your routine",
      "Upcoming period estimates that improve with history",
      "Graphs and history when you want the bigger picture",
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
      "Fertile-window and ovulation day estimates",
      "Mode tuned for trying to conceive",
      "Education on body signals and timing",
      "Reminders you can turn on gently (optional)",
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
      "Pregnancy week estimates and due-date focus",
      "Daily baby and body insight cards",
      "A calmer home layout for pregnancy",
      "Switch modes without losing your past cycle data",
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
      "Track how periods and energy shift over time",
      "Trusted tips on sleep, mood, and wellness",
      "Bring your existing cycle history with you",
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
      "Opt-in partner invite via code",
      "Read-only phase and period estimates",
      "Tips for emotional and practical support",
      "Sex logs, symptoms, and notes stay with you",
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
      "A quieter space for real cycle questions",
      "You control what you publish",
      "Report and safety tools as the community grows",
    ],
    ctaNote: "Download the app to join Secret Chat when you’re signed in.",
  },
};
