import type { Metadata } from "next";
import Image from "next/image";
import Link from "next/link";
import { PageShell } from "@/components/ui/PageShell";
import { Container } from "@/components/ui/Container";
import { DownloadBand } from "@/components/ui/DownloadButtons";
import { FEATURES } from "@/lib/constants";
import { finalCta, homeFeaturesIntro } from "@/lib/copy";
import { MARKETING_IMAGES } from "@/lib/images";

export const metadata: Metadata = {
  title: "Features",
  description:
    "Explore EezyCycle features: period tracker, ovulation & fertility, pregnancy mode, perimenopause, Partner Space, and Secret Chat.",
  alternates: { canonical: "/features" },
};

export default function FeaturesHubPage() {
  return (
    <PageShell>
      <section className="relative overflow-hidden pt-28 pb-14">
        <div className="absolute inset-0">
          <Image
            src={MARKETING_IMAGES.wellness.src}
            alt=""
            fill
            className="object-cover opacity-50"
            sizes="100vw"
          />
          <div
            className="absolute inset-0"
            style={{
              background:
                "linear-gradient(to bottom, rgba(250,247,248,0.9), var(--background))",
            }}
          />
        </div>
        <Container className="relative max-w-3xl">
          <p className="text-sm font-medium text-text-secondary">
            <Link href="/" className="hover:text-primary">
              Home
            </Link>{" "}
            / Features
          </p>
          <h1 className="mt-4 font-display text-4xl font-semibold tracking-tight text-text-primary sm:text-5xl">
            {homeFeaturesIntro.title}
          </h1>
          <p className="mt-4 text-lg text-text-secondary">
            {homeFeaturesIntro.support}
          </p>
        </Container>
      </section>

      <section className="bg-background py-10 sm:py-16">
        <Container>
          <div className="grid gap-5 sm:grid-cols-2">
            {FEATURES.map((feature) => {
              const img = MARKETING_IMAGES[feature.imageKey];
              return (
                <Link
                  key={feature.slug}
                  href={feature.href}
                  className="group overflow-hidden rounded-2xl border border-border bg-surface transition hover:shadow-xl hover:shadow-primary/10"
                >
                  <div className="relative aspect-[16/9] bg-primary-light">
                    <Image
                      src={img.src}
                      alt={img.alt}
                      fill
                      className="object-cover transition duration-500 group-hover:scale-105"
                      sizes="(max-width: 640px) 100vw, 50vw"
                    />
                  </div>
                  <div className="p-6">
                    <h2 className="font-display text-xl font-semibold text-text-primary group-hover:text-primary">
                      {feature.title}
                    </h2>
                    <p className="mt-2 text-sm leading-relaxed text-text-secondary sm:text-base">
                      {feature.short}
                    </p>
                    <span className="mt-4 inline-block text-sm font-semibold text-primary">
                      Open page →
                    </span>
                  </div>
                </Link>
              );
            })}
          </div>
        </Container>
      </section>

      <DownloadBand title={finalCta.title} support={finalCta.support} />
    </PageShell>
  );
}
