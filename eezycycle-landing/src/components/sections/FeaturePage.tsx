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
    <section className="relative overflow-hidden pt-28 pb-16 sm:pt-32 sm:pb-20">
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
              "linear-gradient(to bottom, rgba(250,247,248,0.88), rgba(253,240,243,0.92) 50%, var(--background))",
          }}
        />
      </div>

      <Container className="relative">
        <p className="text-sm font-medium text-text-secondary">
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

        <div className="mt-8 grid items-center gap-12 lg:grid-cols-[1.05fr_0.95fr]">
          <div>
            <p
              className={`font-display text-sm font-semibold uppercase tracking-wider ${accentMap[accent]}`}
            >
              {content.eyebrow}
            </p>
            <h1 className="mt-3 max-w-xl font-display text-4xl font-semibold tracking-tight text-text-primary sm:text-5xl">
              {content.title}
            </h1>
            <p className="mt-5 max-w-lg text-lg leading-relaxed text-text-secondary">
              {content.description}
            </p>
            <div className="mt-8">
              <DownloadButtons />
            </div>
            <p className="mt-4 text-sm text-text-secondary">{content.ctaNote}</p>
          </div>

          <div className="relative mx-auto aspect-[4/5] w-full max-w-md overflow-hidden rounded-[1.75rem] border border-white/70 shadow-2xl shadow-primary/20">
            <Image
              src={img.src}
              alt={img.alt}
              fill
              className="object-cover"
              sizes="(max-width: 1024px) 90vw, 420px"
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
    <section className="bg-background py-16 sm:py-20">
      <Container className="max-w-3xl">
        <h2 className="font-display text-2xl font-semibold text-text-primary sm:text-3xl">
          What you get
        </h2>
        <ul className="mt-8 space-y-4">
          {bullets.map((b) => (
            <li key={b} className="flex gap-3 text-base text-text-primary">
              <span className="mt-2 h-2 w-2 shrink-0 rounded-full bg-primary" />
              {b}
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
