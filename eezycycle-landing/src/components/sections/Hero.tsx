import Image from "next/image";
import Link from "next/link";
import { Container } from "@/components/ui/Container";
import { DownloadButtons } from "@/components/ui/DownloadButtons";
import { hero } from "@/lib/copy";
import { LOGO_SRC, MARKETING_IMAGES } from "@/lib/images";

export function Hero() {
  const img = MARKETING_IMAGES.hero;

  return (
    <section className="relative min-h-[100svh] overflow-hidden pt-[4.25rem] sm:pt-[4.75rem]">
      {/* Full-bleed graphic (same Unsplash source family as in-app articles) */}
      <div className="absolute inset-0">
        <Image
          src={img.src}
          alt={img.alt}
          fill
          priority
          className="object-cover object-center"
          sizes="100vw"
        />
        <div
          className="absolute inset-0"
          style={{
            background:
              "linear-gradient(105deg, rgba(250,247,248,0.94) 0%, rgba(253,240,243,0.82) 45%, rgba(250,247,248,0.25) 72%, rgba(232,80,120,0.22) 100%)",
          }}
        />
      </div>

      <Container className="relative flex min-h-[calc(100svh-4.75rem)] flex-col justify-center py-16 lg:max-w-3xl">
        <div className="animate-fade-up">
          <div className="mb-6 flex items-center gap-3">
            <Image
              src={LOGO_SRC}
              alt={`${hero.brand} logo`}
              width={64}
              height={64}
              className="h-14 w-14 rounded-2xl object-contain shadow-lg shadow-primary/20 sm:h-16 sm:w-16"
              priority
            />
            <p className="font-display text-4xl font-semibold tracking-tight text-primary sm:text-5xl lg:text-6xl">
              {hero.brand}
            </p>
          </div>
          <h1 className="max-w-xl font-display text-3xl font-semibold leading-[1.15] tracking-tight text-text-primary sm:text-4xl lg:text-[2.75rem]">
            {hero.headline}
          </h1>
          <p className="mt-5 max-w-md text-base leading-relaxed text-text-secondary sm:text-lg">
            {hero.support}
          </p>
          <div className="mt-8">
            <DownloadButtons />
          </div>
          <p className="mt-4 text-sm text-text-secondary">
            Free to start · Guest mode · No health data sold
          </p>
          <Link
            href="/features"
            className="mt-6 inline-flex text-sm font-semibold text-primary underline-offset-4 hover:underline"
          >
            {hero.secondaryCta} →
          </Link>
        </div>
      </Container>
    </section>
  );
}
