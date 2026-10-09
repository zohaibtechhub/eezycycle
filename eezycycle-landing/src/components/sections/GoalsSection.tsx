import Link from "next/link";
import { AndroidLogo } from "@/components/ui/AndroidLogo";
import { Reveal } from "@/components/ui/Reveal";
import { Section, SectionHeading } from "@/components/ui/Section";
import { PLAY_STORE_URL } from "@/lib/constants";
import { homeGoals } from "@/lib/copy";

const GOAL_ICONS: Record<string, { icon: string; color: string; badgeBg: string }> = {
  "Track my period": {
    icon: "🌸",
    color: "text-period",
    badgeBg: "bg-period/10 border-period/30",
  },
  "Get pregnant": {
    icon: "🎯",
    color: "text-ovulation",
    badgeBg: "bg-ovulation/15 border-ovulation/30",
  },
  "Track my pregnancy": {
    icon: "🤰",
    color: "text-pregnancy",
    badgeBg: "bg-pregnancy/15 border-pregnancy/30",
  },
  "Take charge of well-being": {
    icon: "🧘‍♀️",
    color: "text-primary",
    badgeBg: "bg-primary-light border-primary/25",
  },
  "Understand symptoms": {
    icon: "📊",
    color: "text-fertility",
    badgeBg: "bg-fertility/10 border-fertility/30",
  },
  "Invite a partner": {
    icon: "🤝",
    color: "text-secondary",
    badgeBg: "bg-secondary/15 border-secondary/30",
  },
};

const storeHref = PLAY_STORE_URL || "/download";
const storeExternal = Boolean(PLAY_STORE_URL);

export function GoalsSection() {
  return (
    <Section className="bg-background relative">
      <SectionHeading
        title="Personalized For What You Need Today"
        support={homeGoals.support}
      />
      <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
        {homeGoals.items.map((item, i) => {
          const config = GOAL_ICONS[item.title] || {
            icon: "✨",
            color: "text-primary",
            badgeBg: "bg-primary-light border-primary/20",
          };

          return (
            <Reveal key={item.title} delayMs={i * 60}>
              <Link
                href={storeHref}
                {...(storeExternal
                  ? { target: "_blank", rel: "noopener noreferrer" }
                  : {})}
                className="group relative flex h-full flex-col justify-between overflow-hidden rounded-3xl border border-border bg-surface p-6 sm:p-7 transition-all duration-300 hover:-translate-y-1 hover:border-primary/40 hover:shadow-xl hover:shadow-primary/10"
              >
                {/* Ambient hover wash */}
                <div className="pointer-events-none absolute -right-12 -top-12 h-32 w-32 rounded-full bg-primary/5 blur-2xl group-hover:bg-primary/10 transition-colors" />

                <div>
                  <div className="flex items-center justify-between">
                    <span
                      className={`flex h-12 w-12 items-center justify-center rounded-2xl border text-2xl shadow-xs transition-transform duration-300 group-hover:scale-110 ${config.badgeBg}`}
                    >
                      {config.icon}
                    </span>
                    <span className="text-[11px] font-semibold tracking-wider uppercase text-text-secondary">
                      Goal 0{i + 1}
                    </span>
                  </div>

                  <h3 className="mt-5 font-display text-lg sm:text-xl font-bold text-text-primary group-hover:text-primary transition-colors">
                    {item.title}
                  </h3>

                  <p className="mt-2 text-sm leading-relaxed text-text-secondary sm:text-base">
                    {item.detail}
                  </p>
                </div>

                <div className="mt-6 flex items-center justify-between gap-3">
                  <div className="flex items-center gap-1.5 text-xs font-semibold text-primary">
                    <span>Customized insights in app</span>
                    <span className="transition-transform group-hover:translate-x-1">
                      →
                    </span>
                  </div>
                  <span
                    className="inline-flex items-center gap-1.5 rounded-full border border-border bg-background px-2.5 py-1 text-[11px] font-semibold text-text-secondary transition-colors group-hover:border-primary/30 group-hover:text-primary"
                    aria-hidden
                  >
                    <AndroidLogo size={14} />
                    Android
                  </span>
                </div>
              </Link>
            </Reveal>
          );
        })}
      </div>
    </Section>
  );
}
