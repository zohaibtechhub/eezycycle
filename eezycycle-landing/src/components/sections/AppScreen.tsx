"use client";

import { useReducedMotion } from "@/hooks/useReducedMotion";

export type ScreenVariant =
  | "home"
  | "calendar"
  | "fertility"
  | "pregnancy"
  | "perimenopause"
  | "partner"
  | "community";

type DayTone = "period" | "fertility" | "ovulation" | "neutral" | "selected";

const stripDays: { letter: string; n: number; tone: DayTone; today?: boolean }[] =
  [
    { letter: "M", n: 3, tone: "period" },
    { letter: "T", n: 4, tone: "period" },
    { letter: "W", n: 5, tone: "period" },
    { letter: "T", n: 6, tone: "period" },
    { letter: "F", n: 7, tone: "neutral" },
    { letter: "S", n: 8, tone: "neutral" },
    { letter: "S", n: 9, tone: "selected", today: true },
    { letter: "M", n: 10, tone: "neutral" },
    { letter: "T", n: 11, tone: "fertility" },
    { letter: "W", n: 12, tone: "fertility" },
    { letter: "T", n: 13, tone: "ovulation" },
    { letter: "F", n: 14, tone: "fertility" },
  ];

const toneCircle: Record<DayTone, string> = {
  period: "bg-period text-white",
  fertility: "bg-fertility/15 text-fertility ring-1 ring-fertility/50",
  ovulation: "bg-ovulation text-white",
  neutral: "bg-surface/70 text-text-primary border border-border",
  selected: "bg-border text-text-primary border-2 border-white",
};

const copy: Record<
  ScreenVariant,
  { headline: string; highlight: string; subtitle: string; chip: string }
> = {
  home: {
    headline: "Medium chance of getting pregnant",
    highlight: "Day 9",
    subtitle: "Follicular phase · Log how you feel",
    chip: "Track cycle",
  },
  calendar: {
    headline: "Your cycle calendar",
    highlight: "October",
    subtitle: "Period · Fertile · Ovulation estimates",
    chip: "Calendar",
  },
  fertility: {
    headline: "High chance of getting pregnant",
    highlight: "Fertile window",
    subtitle: "Ovulation estimate · Day 13",
    chip: "Get pregnant",
  },
  pregnancy: {
    headline: "You’re in week 12",
    highlight: "Second trimester soon",
    subtitle: "Baby is about the size of a lime",
    chip: "Pregnancy",
  },
  perimenopause: {
    headline: "Track your transition",
    highlight: "Symptoms logged",
    subtitle: "Sleep · Mood · Cycle changes",
    chip: "Perimenopause",
  },
  partner: {
    headline: "She’s in follicular phase",
    highlight: "Day 9",
    subtitle: "Support tips for today",
    chip: "Partner",
  },
  community: {
    headline: "Secret Chat",
    highlight: "Anonymous",
    subtitle: "Ask what you can’t ask elsewhere",
    chip: "Community",
  },
};

export function AppScreen({
  variant = "home",
  className = "",
  float = true,
}: {
  variant?: ScreenVariant;
  className?: string;
  float?: boolean;
}) {
  const reduced = useReducedMotion();
  const c = copy[variant];

  return (
    <div
      className={`relative mx-auto w-[270px] sm:w-[300px] ${className}`}
      aria-hidden
    >
      <div
        className={`absolute -inset-8 rounded-full bg-primary/15 blur-3xl ${reduced ? "" : "animate-gradient-drift"}`}
      />
      <div
        className={`relative overflow-hidden rounded-[2.35rem] border-[7px] border-text-primary/90 bg-background shadow-[0_40px_80px_-24px_rgba(232,80,120,0.4)] ${float && !reduced ? "animate-float" : ""}`}
      >
        {/* Notch */}
        <div className="absolute inset-x-0 top-0 z-20 flex justify-center pt-2">
          <div className="h-5 w-28 rounded-full bg-text-primary/90" />
        </div>

        {/* App home hero — matches Flutter HomeCycleHero */}
        <div
          className="relative px-3.5 pb-5 pt-10"
          style={{
            background:
              variant === "pregnancy"
                ? "var(--gradient-pregnancy)"
                : variant === "fertility"
                  ? "linear-gradient(to bottom right, #fdf0f3, #f3e8ff, #ffffff)"
                  : variant === "perimenopause"
                    ? "linear-gradient(to bottom right, #fdf0f3, #f5e6f3, #ffffff)"
                    : "var(--gradient-soft)",
          }}
        >
          <div className="mb-3 flex items-center justify-between px-1">
            <span className="rounded-full bg-surface/80 px-2.5 py-1 text-[10px] font-semibold text-primary">
              {c.chip}
            </span>
            <span className="text-[10px] font-medium text-text-secondary">
              Oct 2026
            </span>
          </div>

          {/* Date strip */}
          {(variant === "home" ||
            variant === "fertility" ||
            variant === "partner" ||
            variant === "perimenopause") && (
            <div className="mb-3 flex gap-1.5 overflow-hidden px-0.5">
              {stripDays.map((d) => (
                <div
                  key={`${d.letter}-${d.n}`}
                  className="flex w-9 shrink-0 flex-col items-center"
                >
                  <span className="h-3 text-[8px] font-bold text-text-primary">
                    {d.today ? "TODAY" : ""}
                  </span>
                  <span className="text-[10px] text-text-secondary">
                    {d.letter}
                  </span>
                  <span
                    className={`mt-1 flex h-8 w-8 items-center justify-center rounded-full text-[11px] font-bold ${toneCircle[d.tone]}`}
                  >
                    {d.n}
                  </span>
                </div>
              ))}
            </div>
          )}

          {variant === "calendar" && <MonthGrid />}
          {variant === "pregnancy" && <PregnancyCard />}
          {variant === "community" && <CommunityFeed />}

          {(variant === "home" ||
            variant === "fertility" ||
            variant === "partner" ||
            variant === "perimenopause") && (
            <div className="px-1 pt-1 text-center">
              <p className="text-[11px] font-medium text-text-secondary">
                {c.headline}
              </p>
              <p className="mt-1 font-display text-xl font-semibold text-text-primary">
                {c.highlight}
              </p>
              <p className="mt-1 text-[11px] text-text-secondary">{c.subtitle}</p>

              {(variant === "home" || variant === "fertility") && (
                <div className="mt-4 flex justify-center gap-2">
                  <span className="rounded-full bg-primary px-3 py-1.5 text-[10px] font-semibold text-white">
                    Log period
                  </span>
                  <span className="rounded-full border border-border bg-surface px-3 py-1.5 text-[10px] font-semibold text-text-primary">
                    Log symptoms
                  </span>
                </div>
              )}
              {variant === "partner" && (
                <div className="mt-4 rounded-xl bg-surface/90 px-3 py-2 text-left text-[10px] text-text-secondary">
                  Tip: A little extra patience goes a long way today.
                </div>
              )}
            </div>
          )}
        </div>

        {/* Bottom nav hint */}
        <div className="flex items-center justify-around border-t border-border bg-surface px-2 py-3">
          {["Home", "Calendar", "Chat", "You"].map((tab, i) => (
            <span
              key={tab}
              className={`text-[9px] font-semibold ${i === 0 ? "text-primary" : "text-text-secondary"}`}
            >
              {tab}
            </span>
          ))}
        </div>
      </div>
    </div>
  );
}

function MonthGrid() {
  const cells = Array.from({ length: 28 }, (_, i) => {
    const n = i + 1;
    let tone: DayTone = "neutral";
    if (n >= 3 && n <= 6) tone = "period";
    if (n >= 11 && n <= 14) tone = n === 13 ? "ovulation" : "fertility";
    return { n, tone };
  });

  return (
    <div className="mb-2 rounded-2xl bg-surface/85 p-2.5">
      <div className="mb-2 grid grid-cols-7 gap-1 text-center text-[9px] font-medium text-text-secondary">
        {["S", "M", "T", "W", "T", "F", "S"].map((d, i) => (
          <span key={`${d}-${i}`}>{d}</span>
        ))}
      </div>
      <div className="grid grid-cols-7 gap-1">
        {cells.map((c) => (
          <span
            key={c.n}
            className={`flex h-6 items-center justify-center rounded-full text-[10px] font-semibold ${toneCircle[c.tone]}`}
          >
            {c.n}
          </span>
        ))}
      </div>
    </div>
  );
}

function PregnancyCard() {
  return (
    <div className="mb-3 rounded-2xl bg-white/90 p-4 text-center shadow-sm">
      <p className="text-[10px] font-semibold uppercase tracking-wide text-pregnancy">
        Week 12 · Day 3
      </p>
      <p className="mt-2 font-display text-2xl font-semibold text-text-primary">
        Lime-sized
      </p>
      <p className="mt-1 text-[11px] text-text-secondary">
        Baby & body insights for today
      </p>
      <div className="mx-auto mt-3 h-16 w-16 rounded-full bg-pregnancy/15 ring-4 ring-pregnancy/20" />
    </div>
  );
}

function CommunityFeed() {
  return (
    <div className="mb-2 space-y-2">
      {["Is late ovulation common?", "Partner support tips", "First cycle logging"].map(
        (q) => (
          <div
            key={q}
            className="rounded-xl bg-surface/90 px-3 py-2.5 text-left shadow-sm"
          >
            <p className="text-[10px] font-semibold text-text-primary">{q}</p>
            <p className="mt-0.5 text-[9px] text-text-secondary">
              Anonymous · 12 replies
            </p>
          </div>
        ),
      )}
    </div>
  );
}

/** Back-compat alias */
export function PhoneMock(props: {
  className?: string;
  phaseLabel?: string;
  subLabel?: string;
}) {
  return <AppScreen variant="home" className={props.className} />;
}
