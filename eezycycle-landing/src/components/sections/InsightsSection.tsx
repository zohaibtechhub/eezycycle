import { Reveal } from "@/components/ui/Reveal";
import { Section, SectionHeading } from "@/components/ui/Section";
import { homeInsights } from "@/lib/copy";

export function InsightsSection() {
  return (
    <Section className="bg-background">
      <SectionHeading title={homeInsights.title} support={homeInsights.support} />
      <div className="grid gap-8 sm:grid-cols-2">
        {homeInsights.items.map((item, i) => (
          <Reveal key={item.title} delayMs={i * 60}>
            <article className="rounded-2xl border border-border bg-surface px-6 py-6">
              <h3 className="font-display text-lg font-semibold text-text-primary">
                {item.title}
              </h3>
              <p className="mt-2 text-sm leading-relaxed text-text-secondary sm:text-base">
                {item.detail}
              </p>
            </article>
          </Reveal>
        ))}
      </div>
    </Section>
  );
}
