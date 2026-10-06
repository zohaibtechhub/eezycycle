import { Reveal } from "@/components/ui/Reveal";
import { Section, SectionHeading } from "@/components/ui/Section";
import { homeTrust } from "@/lib/copy";

export function TrustStrip() {
  return (
    <Section className="bg-primary-light/50">
      <SectionHeading title={homeTrust.title} support="Privacy and clarity, baked in from day one." />
      <div className="grid gap-10 sm:grid-cols-3">
        {homeTrust.items.map((item, i) => (
          <Reveal key={item.title} delayMs={i * 80}>
            <div>
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
