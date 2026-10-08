export const SITE_URL = "https://www.eezycycle.com";
export const SITE_NAME = "EezyCycle";
export const SUPPORT_EMAIL = "info@eezycycle.com";

/** Google Play — fill when listing is live; until then CTAs go to /download */
export const PLAY_STORE_URL = "";

export const NAV_LINKS = [
  { href: "/features", label: "Features" },
  { href: "/blog", label: "Articles" },
  { href: "/how-it-works", label: "How it works" },
  { href: "/faq", label: "FAQ" },
  { href: "/privacy", label: "Privacy" },
] as const;

export type FeatureSlug =
  | "period-tracker"
  | "ovulation-fertility"
  | "pregnancy"
  | "perimenopause"
  | "partner"
  | "secret-chat";

export const FEATURES: {
  slug: FeatureSlug;
  href: `/features/${FeatureSlug}`;
  title: string;
  navLabel: string;
  short: string;
  imageKey:
    | "period"
    | "fertility"
    | "pregnancy"
    | "perimenopause"
    | "partner"
    | "community";
  colorToken:
    | "period"
    | "ovulation"
    | "fertility"
    | "pregnancy"
    | "perimenopause"
    | "primary";
}[] = [
  {
    slug: "period-tracker",
    href: "/features/period-tracker",
    title: "Period tracker",
    navLabel: "Period",
    short: "Log periods, symptoms, and see what’s coming next.",
    imageKey: "period",
    colorToken: "period",
  },
  {
    slug: "ovulation-fertility",
    href: "/features/ovulation-fertility",
    title: "Ovulation & fertility",
    navLabel: "Fertility",
    short: "Fertile-window and ovulation estimates from your history.",
    imageKey: "fertility",
    colorToken: "fertility",
  },
  {
    slug: "pregnancy",
    href: "/features/pregnancy",
    title: "Pregnancy mode",
    navLabel: "Pregnancy",
    short: "Week-by-week baby and body insights when you’re ready.",
    imageKey: "pregnancy",
    colorToken: "pregnancy",
  },
  {
    slug: "perimenopause",
    href: "/features/perimenopause",
    title: "Perimenopause",
    navLabel: "Perimenopause",
    short: "Track changing cycles with calm, practical guidance.",
    imageKey: "perimenopause",
    colorToken: "perimenopause",
  },
  {
    slug: "partner",
    href: "/features/partner",
    title: "Partner Space",
    navLabel: "Partner",
    short: "Invite your partner — support without exposing private logs.",
    imageKey: "partner",
    colorToken: "primary",
  },
  {
    slug: "secret-chat",
    href: "/features/secret-chat",
    title: "Secret Chat",
    navLabel: "Community",
    short: "Ask anonymously. Share only what you’re comfortable with.",
    imageKey: "community",
    colorToken: "ovulation",
  },
];
