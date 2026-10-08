import Link from "next/link";
import { Reveal } from "@/components/ui/Reveal";
import { Section, SectionHeading } from "@/components/ui/Section";
import { predictions } from "@/lib/copy";

const STEP_ICONS = ["📅", "🧠", "✨"];

export function HowItWorksHome() {
  return (
    <Section id="how-it-works-home" className="bg-gradient-to-b from-primary-light/40 via-white to-primary-light/30 relative">
      <SectionHeading
        title="Predictions That Learn Your Rhythm"
        support={predictions.support}
      />
      
      <ol className="grid gap-6 sm:grid-cols-3 sm:gap-8 relative">
        {predictions.steps.map((step, i) => (
          <Reveal key={step.label} delayMs={i * 80}>
            <li className="group relative flex h-full flex-col rounded-3xl border border-primary/20 bg-white p-6 sm:p-8 shadow-xs transition-all duration-300 hover:-translate-y-1 hover:border-primary/40 hover:shadow-xl hover:shadow-primary/10">
              {/* Step Number & Icon */}
              <div className="flex items-center justify-between">
                <span className="flex h-12 w-12 items-center justify-center rounded-2xl bg-primary-light border border-primary/25 text-2xl shadow-xs">
                  {STEP_ICONS[i]}
                </span>
                <span className="font-display text-3xl font-extrabold text-primary/30">
                  {String(i + 1).padStart(2, "0")}
                </span>
              </div>

              <h3 className="mt-6 font-display text-lg font-bold text-text-primary group-hover:text-primary transition-colors sm:text-xl">
                {step.label}
              </h3>

              <p className="mt-3 flex-1 text-sm leading-relaxed text-text-secondary sm:text-base">
                {step.detail}
              </p>

              <div className="mt-6 h-1 w-12 rounded-full bg-primary/20 group-hover:w-full group-hover:bg-primary transition-all duration-300" />
            </li>
          </Reveal>
        ))}
      </ol>

      <div className="mt-12 rounded-2xl border border-primary/20 bg-white/80 p-5 text-center sm:flex sm:items-center sm:justify-between">
        <p className="text-sm text-text-secondary">
          Curious about our statistical cycle algorithms and cycle models?
        </p>
        <Link
          href="/how-it-works"
          className="mt-3 inline-block sm:mt-0 font-bold text-xs sm:text-sm text-primary underline-offset-4 hover:underline"
        >
          Read the full prediction methodology →
        </Link>
      </div>
    </Section>
  );
}
