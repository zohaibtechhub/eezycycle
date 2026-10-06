import Image from "next/image";
import Link from "next/link";
import { Container } from "@/components/ui/Container";
import { DownloadButtons } from "@/components/ui/DownloadButtons";
import { hero } from "@/lib/copy";
import { LOGO_SRC, MARKETING_IMAGES } from "@/lib/images";

export function Hero() {
  const img = MARKETING_IMAGES.hero;

  return (
    <section className="relative overflow-hidden pt-16 sm:pt-[4.75rem]">
      <div
        className="absolute inset-0"
        style={{ background: "var(--gradient-hero)" }}
      />
      <div
        className="pointer-events-none absolute -left-24 top-24 hidden h-72 w-72 rounded-full bg-primary/15 blur-3xl animate-gradient-drift sm:block"
        aria-hidden
      />
      <div
        className="pointer-events-none absolute -right-16 bottom-10 hidden h-80 w-80 rounded-full bg-hero-mint/35 blur-3xl md:block"
        aria-hidden
      />

      <Container className="relative grid items-center gap-8 py-8 sm:gap-10 sm:py-12 lg:grid-cols-2 lg:gap-12 lg:py-16 xl:gap-16">
        {/* Copy — first on mobile for readability */}
        <div className="animate-fade-up order-1 min-w-0">
          <div className="mb-4 flex items-center gap-2.5 sm:mb-6 sm:gap-3">
            <Image
              src={LOGO_SRC}
              alt={`${hero.brand} logo`}
              width={64}
              height={64}
              className="h-11 w-11 shrink-0 rounded-2xl object-contain shadow-lg shadow-primary/20 sm:h-14 sm:w-14 lg:h-16 lg:w-16"
              priority
              unoptimized
            />
            <p className="font-display text-3xl font-semibold tracking-tight text-primary sm:text-5xl lg:text-6xl">
              {hero.brand}
            </p>
          </div>
          <h1 className="max-w-xl font-display text-[1.65rem] font-semibold leading-tight tracking-tight text-text-primary sm:text-4xl lg:text-[2.75rem] lg:leading-[1.15]">
            {hero.headline}
          </h1>
          <p className="mt-3 max-w-md text-sm leading-relaxed text-text-secondary sm:mt-5 sm:text-base lg:text-lg">
            {hero.support}
          </p>
          <div className="mt-6 w-full sm:mt-8 sm:w-auto">
            <DownloadButtons />
          </div>
          <p className="mt-3 text-xs text-text-secondary sm:mt-4 sm:text-sm">
            Free to start · Guest mode · No health data sold
          </p>
          <Link
            href="/features"
            className="mt-4 inline-flex text-sm font-semibold text-primary underline-offset-4 hover:underline sm:mt-6"
          >
            {hero.secondaryCta} →
          </Link>
        </div>

        {/* Photo */}
        <div className="relative order-2 mx-auto w-full max-w-md min-w-0 pb-6 sm:max-w-lg sm:pb-8 lg:max-w-none lg:pb-4">
          <div
            className="absolute -inset-2 rounded-[1.5rem] opacity-60 blur-xl sm:-inset-4 sm:rounded-[2rem] sm:opacity-70 sm:blur-2xl"
            style={{
              background:
                "linear-gradient(145deg, color-mix(in srgb, var(--primary) 40%, transparent), color-mix(in srgb, var(--hero-mint) 55%, transparent), color-mix(in srgb, var(--secondary) 30%, transparent))",
            }}
            aria-hidden
          />
          <div className="relative overflow-hidden rounded-2xl border border-white/80 bg-surface shadow-[0_24px_48px_-12px_rgba(30,23,25,0.25)] sm:rounded-[1.75rem] sm:shadow-[0_32px_64px_-16px_rgba(30,23,25,0.28)] sm:animate-float">
            <div className="relative aspect-[4/3] w-full sm:aspect-[5/4] lg:aspect-square">
              <Image
                src={img.src}
                alt={img.alt}
                fill
                priority
                className="object-cover object-center"
                sizes="(max-width: 640px) 100vw, (max-width: 1024px) 80vw, 520px"
              />
            </div>
            <div
              className="pointer-events-none absolute inset-0 rounded-2xl ring-1 ring-inset ring-white/40 sm:rounded-[1.75rem]"
              aria-hidden
            />
          </div>

          <div className="absolute -bottom-1 left-3 rounded-full border border-border bg-surface/95 px-2.5 py-1.5 text-[10px] font-semibold text-text-primary shadow-md backdrop-blur-sm sm:-bottom-3 sm:left-6 sm:px-3.5 sm:py-2 sm:text-xs">
            Period · Fertile · Ovulation
          </div>
        </div>
      </Container>
    </section>
  );
}
