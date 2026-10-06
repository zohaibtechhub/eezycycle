import type { Metadata } from "next";
import Link from "next/link";
import { Container } from "@/components/ui/Container";
import { DownloadBand, DownloadButtons } from "@/components/ui/DownloadButtons";
import { PageShell } from "@/components/ui/PageShell";
import { disclaimer, finalCta, predictions } from "@/lib/copy";

export const metadata: Metadata = {
  title: "How EezyCycle Predictions Work",
  description:
    "Learn how EezyCycle estimates period timing, ovulation, and fertile windows from your logged cycles.",
  alternates: { canonical: "/how-it-works" },
};

export default function HowItWorksPage() {
  return (
    <PageShell>
      <section
        className="pt-28 pb-12"
        style={{ background: "var(--gradient-soft)" }}
      >
        <Container className="max-w-3xl">
          <p className="text-sm font-medium text-text-secondary">
            <Link href="/" className="hover:text-primary">
              Home
            </Link>{" "}
            / How it works
          </p>
          <h1 className="mt-4 font-display text-4xl font-semibold tracking-tight text-text-primary sm:text-5xl">
            {predictions.title}
          </h1>
          <p className="mt-4 text-lg leading-relaxed text-text-secondary">
            {predictions.support}
          </p>
          <div className="mt-8">
            <DownloadButtons size="md" />
          </div>
        </Container>
      </section>

      <section className="bg-background py-16">
        <Container className="max-w-3xl">
          <ol className="space-y-12">
            {predictions.steps.map((step, i) => (
              <li key={step.label}>
                <span className="font-display text-sm font-semibold uppercase tracking-wider text-primary">
                  Step {i + 1}
                </span>
                <h2 className="mt-1 font-display text-2xl font-semibold text-text-primary">
                  {step.label}
                </h2>
                <p className="mt-2 text-text-secondary">{step.detail}</p>
              </li>
            ))}
          </ol>
          <p className="mt-12 rounded-2xl border border-border bg-surface p-5 text-sm leading-relaxed text-text-secondary">
            {disclaimer}
          </p>
        </Container>
      </section>

      <DownloadBand title={finalCta.title} support={finalCta.support} />
    </PageShell>
  );
}
