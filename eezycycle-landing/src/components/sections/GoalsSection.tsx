import { Reveal } from "@/components/ui/Reveal";
import { Section, SectionHeading } from "@/components/ui/Section";
import { homeGoals } from "@/lib/copy";

export function GoalsSection() {
  return (
    <Section className="bg-background">
      <SectionHeading title={homeGoals.title} support={homeGoals.support} />
      <div className="grid gap-8 sm:grid-cols-2 lg:grid-cols-3">
        {homeGoals.items.map((item, i) => (
          <Reveal key={item.title} delayMs={i * 50}>
            <div className="border-l-4 border-l-primary pl-4">
              <h3 className="font-display text-lg font-semibold text-text-primary">
                {item.title}
              </h3>
              <p className="mt-2 text-sm leading-relaxed text-text-secondary sm:text-base">
                {item.detail}
              </p>
            </div>
          </Reveal>
        ))}
      </div>
    </Section>
  );
}
