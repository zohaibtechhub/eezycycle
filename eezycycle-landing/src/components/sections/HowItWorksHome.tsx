import Link from "next/link";
import { Reveal } from "@/components/ui/Reveal";
import { Section, SectionHeading } from "@/components/ui/Section";
import { predictions } from "@/lib/copy";

export function HowItWorksHome() {
  return (
    <Section id="how-it-works-home" className="bg-primary-light/45">
      <SectionHeading title={predictions.title} support={predictions.support} />
      <ol className="grid gap-8 sm:grid-cols-3 sm:gap-10">
        {predictions.steps.map((step, i) => (
          <Reveal key={step.label} delayMs={i * 80}>
            <li className="min-w-0">
              <span className="font-display text-4xl font-semibold text-primary/25 sm:text-5xl">
                {String(i + 1).padStart(2, "0")}
              </span>
              <h3 className="mt-2 font-display text-lg font-semibold text-text-primary sm:text-xl">
                {step.label}
              </h3>
              <p className="mt-2 text-sm leading-relaxed text-text-secondary sm:text-base">
                {step.detail}
              </p>
            </li>
          </Reveal>
        ))}
      </ol>
      <p className="mt-10 text-sm text-text-secondary">
        Want the longer explanation?{" "}
        <Link
          href="/how-it-works"
          className="font-semibold text-primary underline-offset-2 hover:underline"
        >
          Read how it works →
        </Link>
      </p>
    </Section>
  );
}
