import Image from "next/image";
import Link from "next/link";
import { Reveal } from "@/components/ui/Reveal";
import { Section, SectionHeading } from "@/components/ui/Section";
import { FEATURES } from "@/lib/constants";
import { homeFeaturesIntro } from "@/lib/copy";
import { MARKETING_IMAGES } from "@/lib/images";

export function FeatureGrid() {
  return (
    <Section id="features" className="bg-background">
      <SectionHeading
        title={homeFeaturesIntro.title}
        support={homeFeaturesIntro.support}
      />
      <div className="grid gap-4 sm:grid-cols-2 sm:gap-5 lg:grid-cols-3">
        {FEATURES.map((feature, i) => {
          const img = MARKETING_IMAGES[feature.imageKey];
          return (
            <Reveal key={feature.slug} delayMs={i * 60}>
              <Link
                href={feature.href}
                className="group flex h-full flex-col overflow-hidden rounded-2xl border border-border bg-surface transition hover:-translate-y-0.5 hover:shadow-xl hover:shadow-primary/10"
              >
                <div className="relative aspect-[16/10] overflow-hidden bg-primary-light">
                  <Image
                    src={img.src}
                    alt={img.alt}
                    fill
                    className="object-cover transition duration-500 group-hover:scale-105"
                    sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-text-primary/40 to-transparent" />
                </div>
                <div className="flex flex-1 flex-col p-4 sm:p-5">
                  <h3 className="font-display text-base font-semibold text-text-primary group-hover:text-primary sm:text-lg">
                    {feature.title}
                  </h3>
                  <p className="mt-2 flex-1 text-sm leading-relaxed text-text-secondary">
                    {feature.short}
                  </p>
                  <span className="mt-3 inline-block text-sm font-semibold text-primary">
                    Learn more →
                  </span>
                </div>
              </Link>
            </Reveal>
          );
        })}
      </div>
    </Section>
  );
}
