import Image from "next/image";
import Link from "next/link";
import { Reveal } from "@/components/ui/Reveal";
import { Section } from "@/components/ui/Section";
import { homeCommunity, homePartner } from "@/lib/copy";
import { MARKETING_IMAGES } from "@/lib/images";

export function PartnerCommunitySection() {
  return (
    <Section className="bg-surface relative overflow-hidden">
      {/* Background ambient lighting */}
      <div
        className="pointer-events-none absolute -right-20 top-1/2 h-80 w-80 -translate-y-1/2 rounded-full bg-primary/5 blur-3xl"
        aria-hidden
      />

      <div className="grid gap-8 lg:grid-cols-2 lg:gap-10">
        {/* Partner Space Card */}
        <Reveal>
          <div className="flex h-full flex-col justify-between overflow-hidden rounded-3xl border border-border bg-background p-6 sm:p-8 transition-all duration-300 hover:border-primary/40 hover:shadow-xl hover:shadow-primary/10">
            <div>
              <div className="relative aspect-[16/10] w-full overflow-hidden rounded-2xl bg-primary-light shadow-xs">
                <Image
                  src={MARKETING_IMAGES.partner.src}
                  alt={MARKETING_IMAGES.partner.alt}
                  fill
                  className="object-cover transition-transform duration-500 hover:scale-105"
                  sizes="(max-width: 1024px) 100vw, 50vw"
                />
                <div className="absolute left-3.5 top-3.5">
                  <span className="rounded-full bg-white/95 border border-fertility/30 px-3 py-1 text-xs font-semibold text-fertility shadow-xs backdrop-blur-md">
                    🤝 Read-Only Partner Mode
                  </span>
                </div>
              </div>

              <h2 className="mt-6 font-display text-2xl font-bold tracking-tight text-text-primary sm:text-3xl">
                {homePartner.title}
              </h2>
              <p className="mt-3 text-sm leading-relaxed text-text-secondary sm:text-base">
                {homePartner.support}
              </p>

              <ul className="mt-5 space-y-3">
                {homePartner.bullets.map((b) => (
                  <li
                    key={b}
                    className="flex items-center gap-3 text-sm text-text-secondary sm:text-base"
                  >
                    <span className="flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-primary/10 text-primary text-xs font-bold">
                      ✓
                    </span>
                    <span className="min-w-0">{b}</span>
                  </li>
                ))}
              </ul>
            </div>

            <div className="mt-8 pt-4 border-t border-border">
              <Link
                href="/features/partner"
                className="inline-flex items-center gap-1.5 text-xs sm:text-sm font-bold text-primary hover:text-accent transition-colors"
              >
                <span>Learn how Partner Space works</span>
                <span>→</span>
              </Link>
            </div>
          </div>
        </Reveal>

        {/* Secret Chat Community Card */}
        <Reveal delayMs={100}>
          <div className="flex h-full flex-col justify-between overflow-hidden rounded-3xl border border-border bg-background p-6 sm:p-8 transition-all duration-300 hover:border-primary/40 hover:shadow-xl hover:shadow-primary/10">
            <div>
              <div className="relative aspect-[16/10] w-full overflow-hidden rounded-2xl bg-primary-light shadow-xs">
                <Image
                  src={MARKETING_IMAGES.community.src}
                  alt={MARKETING_IMAGES.community.alt}
                  fill
                  className="object-cover transition-transform duration-500 hover:scale-105"
                  sizes="(max-width: 1024px) 100vw, 50vw"
                />
                <div className="absolute left-3.5 top-3.5">
                  <span className="rounded-full bg-white/95 border border-primary/30 px-3 py-1 text-xs font-semibold text-primary shadow-xs backdrop-blur-md">
                    🤫 Anonymous Community
                  </span>
                </div>
              </div>

              <h2 className="mt-6 font-display text-2xl font-bold tracking-tight text-text-primary sm:text-3xl">
                {homeCommunity.title}
              </h2>
              <p className="mt-3 text-sm leading-relaxed text-text-secondary sm:text-base">
                {homeCommunity.support}
              </p>

              <div className="mt-5 space-y-2.5">
                {[
                  "Safe space for period, fertility, and PCOS questions",
                  "Pick any username — your real email is never shown",
                  "Encouraging, supportive discussions with other women",
                  "Separate from your personal cycle tracking logs",
                ].map((item, idx) => (
                  <div key={idx} className="flex items-center gap-3 text-sm text-text-secondary sm:text-base">
                    <span className="flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-primary/10 text-primary text-xs font-bold">
                      ✓
                    </span>
                    <span>{item}</span>
                  </div>
                ))}
              </div>
            </div>

            <div className="mt-8 pt-4 border-t border-border">
              <Link
                href="/features/secret-chat"
                className="inline-flex items-center gap-1.5 text-xs sm:text-sm font-bold text-primary hover:text-accent transition-colors"
              >
                <span>Learn more about Secret Chat</span>
                <span>→</span>
              </Link>
            </div>
          </div>
        </Reveal>
      </div>
    </Section>
  );
}
