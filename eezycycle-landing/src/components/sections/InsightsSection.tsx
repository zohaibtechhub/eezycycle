import Link from "next/link";
import { Reveal } from "@/components/ui/Reveal";
import { Section, SectionHeading } from "@/components/ui/Section";
import { homeInsights } from "@/lib/copy";

const INSIGHT_ICONS: Record<string, string> = {
  "Daily cycle insights": "🌸",
  "Health articles": "🩺",
  "Symptom logging": "📝",
  "Optional reminders": "🔔",
};

export function InsightsSection() {
  return (
    <Section className="bg-background relative">
      <SectionHeading
        title="More Than A Calendar: Daily Whole-Body Insights"
        support={homeInsights.support}
      />
      <div className="grid gap-6 sm:grid-cols-2">
        {homeInsights.items.map((item, i) => (
          <Reveal key={item.title} delayMs={i * 60}>
            <article className="group relative flex h-full flex-col justify-between overflow-hidden rounded-3xl border border-border bg-surface p-7 sm:p-8 transition-all duration-300 hover:-translate-y-1 hover:border-primary/40 hover:shadow-xl hover:shadow-primary/10">
              <div>
                <div className="flex items-center gap-3">
                  <span className="flex h-11 w-11 items-center justify-center rounded-2xl bg-primary-light border border-primary/20 text-xl shadow-xs">
                    {INSIGHT_ICONS[item.title] || "✨"}
                  </span>
                  <h3 className="font-display text-lg font-bold text-text-primary group-hover:text-primary transition-colors sm:text-xl">
                    {item.title}
                  </h3>
                </div>
                <p className="mt-4 text-sm leading-relaxed text-text-secondary sm:text-base">
                  {item.detail}
                </p>
              </div>

              {item.title === "Health articles" ? (
                <div className="mt-6 border-t border-border pt-4">
                  <Link
                    href="/blog"
                    className="inline-flex items-center gap-1.5 text-xs font-bold text-primary hover:underline"
                  >
                    <span>Browse doctor health articles</span>
                    <span>→</span>
                  </Link>
                </div>
              ) : (
                <div className="mt-6 border-t border-border/60 pt-4 flex items-center justify-between text-xs text-text-secondary">
                  <span>Available on iOS & Android</span>
                  <span className="font-semibold text-primary">Guest Friendly</span>
                </div>
              )}
            </article>
          </Reveal>
        ))}
      </div>
    </Section>
  );
}
