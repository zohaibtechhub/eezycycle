import Image from "next/image";
import Link from "next/link";
import { Reveal } from "@/components/ui/Reveal";
import { Section, SectionHeading } from "@/components/ui/Section";
import { FEATURES } from "@/lib/constants";
import { homeFeaturesIntro } from "@/lib/copy";
import { MARKETING_IMAGES } from "@/lib/images";

const BADGE_MAP: Record<string, { label: string; style: string }> = {
  "period-tracker": {
    label: "Menstrual Phase",
    style: "bg-period/15 text-period border-period/30",
  },
  "ovulation-fertility": {
    label: "Fertile Window & Ovulation",
    style: "bg-ovulation/15 text-ovulation border-ovulation/30",
  },
  pregnancy: {
    label: "Pregnancy Mode",
    style: "bg-pregnancy/15 text-pregnancy border-pregnancy/30",
  },
  perimenopause: {
    label: "Transition Guidance",
    style: "bg-perimenopause/15 text-perimenopause border-perimenopause/30",
  },
  partner: {
    label: "Partner Space",
    style: "bg-fertility/15 text-fertility border-fertility/30",
  },
  "secret-chat": {
    label: "Anonymous Community",
    style: "bg-primary/15 text-primary border-primary/30",
  },
};

export function FeatureGrid() {
  return (
    <Section id="features" className="bg-surface relative overflow-hidden">
      {/* Background soft glow */}
      <div
        className="pointer-events-none absolute -left-24 bottom-0 h-96 w-96 rounded-full bg-primary/5 blur-3xl"
        aria-hidden
      />

      <SectionHeading
        title={homeFeaturesIntro.title}
        support={homeFeaturesIntro.support}
      />
      <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
        {FEATURES.map((feature, i) => {
          const img = MARKETING_IMAGES[feature.imageKey] || MARKETING_IMAGES.hero;
          const badge = BADGE_MAP[feature.slug] || {
            label: "Core Feature",
            style: "bg-primary/10 text-primary border-primary/20",
          };

          return (
            <Reveal key={feature.slug} delayMs={i * 60}>
              <Link
                href={feature.href}
                className="group flex h-full flex-col overflow-hidden rounded-3xl border border-border bg-background transition-all duration-300 hover:-translate-y-1.5 hover:border-primary/40 hover:shadow-xl hover:shadow-primary/10"
              >
                {/* Image Container with Aspect Ratio */}
                <div className="relative aspect-[16/10] overflow-hidden bg-primary-light">
                  <Image
                    src={img.src}
                    alt={img.alt}
                    fill
                    className="object-cover transition duration-500 group-hover:scale-105"
                    sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent opacity-60" />

                  {/* Badge */}
                  <div className="absolute left-3.5 top-3.5">
                    <span
                      className={`rounded-full border px-2.5 py-1 text-[11px] font-semibold backdrop-blur-md bg-white/90 ${badge.style}`}
                    >
                      {badge.label}
                    </span>
                  </div>
                </div>

                <div className="flex flex-1 flex-col p-6">
                  <h3 className="font-display text-lg font-bold text-text-primary group-hover:text-primary transition-colors sm:text-xl">
                    {feature.title}
                  </h3>
                  <p className="mt-2.5 flex-1 text-sm leading-relaxed text-text-secondary">
                    {feature.short}
                  </p>
                  <div className="mt-5 flex items-center gap-1.5 text-xs font-semibold text-primary">
                    <span>Learn how it works</span>
                    <span className="transition-transform group-hover:translate-x-1">→</span>
                  </div>
                </div>
              </Link>
            </Reveal>
          );
        })}
      </div>
    </Section>
  );
}
