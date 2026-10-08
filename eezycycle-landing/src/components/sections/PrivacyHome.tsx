import Link from "next/link";
import { Reveal } from "@/components/ui/Reveal";
import { Section } from "@/components/ui/Section";
import { privacy } from "@/lib/copy";

export function PrivacyHome() {
  return (
    <Section id="privacy-home" className="bg-surface relative overflow-hidden">
      <Reveal>
        <div className="mx-auto max-w-4xl rounded-3xl border border-primary/25 bg-gradient-to-br from-primary-light via-white to-primary-light/30 p-8 sm:p-10 lg:p-12 shadow-sm">
          <div className="flex items-center gap-3">
            <span className="flex h-12 w-12 items-center justify-center rounded-2xl bg-white border border-primary/25 text-2xl shadow-xs text-primary">
              🔒
            </span>
            <div>
              <span className="text-xs font-bold uppercase tracking-wider text-primary">
                Uncompromising Data Ethics
              </span>
              <h2 className="font-display text-2xl sm:text-3xl font-extrabold text-text-primary">
                {privacy.title}
              </h2>
            </div>
          </div>

          <p className="mt-4 text-sm sm:text-base leading-relaxed text-text-secondary">
            {privacy.support}
          </p>

          <div className="mt-8 grid gap-4 sm:grid-cols-2">
            {privacy.bullets.map((bullet) => (
              <div
                key={bullet}
                className="flex items-center gap-3 rounded-2xl border border-primary/15 bg-white/90 p-4 shadow-xs"
              >
                <span className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-emerald-100 text-emerald-800 text-xs font-bold">
                  ✓
                </span>
                <span className="text-sm font-medium text-text-primary">
                  {bullet}
                </span>
              </div>
            ))}
          </div>

          <div className="mt-8 flex flex-wrap items-center justify-between gap-4 border-t border-primary/15 pt-6 text-xs sm:text-sm text-text-secondary">
            <p>
              Have privacy questions or request data deletion? Contact{" "}
              <a
                href="mailto:info@eezycycle.com"
                className="font-bold text-primary hover:underline"
              >
                info@eezycycle.com
              </a>
            </p>
            <Link
              href="/privacy"
              className="font-bold text-primary underline-offset-4 hover:underline"
            >
              Read Full Privacy Policy →
            </Link>
          </div>
        </div>
      </Reveal>
    </Section>
  );
}
