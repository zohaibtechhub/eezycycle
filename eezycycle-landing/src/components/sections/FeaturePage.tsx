import Image from "next/image";
import Link from "next/link";
import { DownloadBand, DownloadButtons } from "@/components/ui/DownloadButtons";
import { Container } from "@/components/ui/Container";
import type { FeaturePageContent } from "@/lib/copy";
import { finalCta } from "@/lib/copy";
import { FEATURES, type FeatureSlug } from "@/lib/constants";
import { MARKETING_IMAGES } from "@/lib/images";

const accentMap = {
  period: "text-period",
  ovulation: "text-ovulation",
  fertility: "text-fertility",
  pregnancy: "text-pregnancy",
  perimenopause: "text-perimenopause",
  primary: "text-primary",
} as const;

export function FeatureHero({
  content,
  accent = "primary",
}: {
  content: FeaturePageContent;
  accent?: keyof typeof accentMap;
}) {
  const feature = FEATURES.find((f) => f.slug === content.slug);
  const img =
    MARKETING_IMAGES[feature?.imageKey ?? "period"] ?? MARKETING_IMAGES.period;

  return (
    <section className="relative overflow-hidden pt-20 pb-10 sm:pt-28 sm:pb-16 md:pt-32 md:pb-20">
      <div className="absolute inset-0">
        <Image
          src={img.src}
          alt=""
          fill
          className="object-cover"
          sizes="100vw"
          priority
        />
        <div
          className="absolute inset-0"
          style={{
            background:
              "linear-gradient(to bottom, rgba(250,247,248,0.9), rgba(253,240,243,0.94) 50%, var(--background))",
          }}
        />
      </div>

      <Container className="relative">
        <p className="text-xs font-medium text-text-secondary sm:text-sm">
          <Link href="/" className="hover:text-primary">
            Home
          </Link>
          {" / "}
          <Link href="/features" className="hover:text-primary">
            Features
          </Link>
          {" / "}
          <span className="text-text-primary">{content.eyebrow}</span>
        </p>

        <div className="mt-6 grid items-center gap-8 sm:mt-8 sm:gap-10 lg:grid-cols-2 lg:gap-12">
          <div className="min-w-0 order-2 lg:order-1">
            <p
              className={`font-display text-xs font-semibold uppercase tracking-wider sm:text-sm ${accentMap[accent]}`}
            >
              {content.eyebrow}
            </p>
            <h1 className="mt-2 font-display text-3xl font-semibold tracking-tight text-text-primary sm:mt-3 sm:text-4xl md:text-5xl">
              {content.title}
            </h1>
            <p className="mt-4 max-w-lg text-sm leading-relaxed text-text-secondary sm:mt-5 sm:text-base md:text-lg">
              {content.description}
            </p>
            <div className="mt-6 w-full sm:mt-8 sm:w-auto">
              <DownloadButtons />
            </div>
            <p className="mt-3 text-xs text-text-secondary sm:mt-4 sm:text-sm">
              {content.ctaNote}
            </p>
          </div>

          <div className="relative order-1 mx-auto aspect-[4/3] w-full max-w-md overflow-hidden rounded-2xl border border-white/70 shadow-xl shadow-primary/15 sm:aspect-[5/4] sm:rounded-[1.75rem] lg:order-2 lg:aspect-[4/5] lg:max-w-none lg:shadow-2xl lg:shadow-primary/20">
            <Image
              src={img.src}
              alt={img.alt}
              fill
              className="object-cover"
              sizes="(max-width: 1024px) 100vw, 420px"
              priority
            />
          </div>
        </div>
      </Container>
    </section>
  );
}

export function FeatureBullets({ bullets }: { bullets: string[] }) {
  return (
    <section className="bg-background py-12 sm:py-16 md:py-20">
      <Container className="max-w-3xl">
        <h2 className="font-display text-xl font-semibold text-text-primary sm:text-2xl md:text-3xl">
          What you get
        </h2>
        <ul className="mt-6 space-y-3 sm:mt-8 sm:space-y-4">
          {bullets.map((b) => (
            <li
              key={b}
              className="flex gap-3 text-sm text-text-primary sm:text-base"
            >
              <span className="mt-1.5 h-2 w-2 shrink-0 rounded-full bg-primary" />
              <span className="min-w-0">{b}</span>
            </li>
          ))}
        </ul>
      </Container>
    </section>
  );
}

export function FeaturePageEnd() {
  return <DownloadBand title={finalCta.title} support={finalCta.support} />;
}

export type { FeatureSlug };
