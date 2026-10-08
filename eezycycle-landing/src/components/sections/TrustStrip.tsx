import { Reveal } from "@/components/ui/Reveal";
import { Section, SectionHeading } from "@/components/ui/Section";
import { homeTrust } from "@/lib/copy";

const TRUST_ICONS = ["✨", "🔒", "📊"];

export function TrustStrip() {
  return (
    <Section className="bg-gradient-to-b from-primary-light/40 to-background border-y border-primary/15 relative">
      <SectionHeading
        title={homeTrust.title}
        support="Privacy and clinical clarity, engineered into the product from day one."
      />
      <div className="grid gap-6 sm:grid-cols-3">
        {homeTrust.items.map((item, i) => (
          <Reveal key={item.title} delayMs={i * 80}>
            <div className="flex h-full flex-col rounded-3xl border border-primary/20 bg-white p-6 sm:p-7 shadow-xs">
              <span className="flex h-12 w-12 items-center justify-center rounded-2xl bg-primary-light border border-primary/20 text-2xl shadow-xs">
                {TRUST_ICONS[i]}
              </span>
              <h3 className="mt-5 font-display text-lg font-bold text-text-primary sm:text-xl">
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
