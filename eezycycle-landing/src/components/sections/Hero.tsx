import Image from "next/image";
import Link from "next/link";
import { Container } from "@/components/ui/Container";
import { DownloadButtons } from "@/components/ui/DownloadButtons";
import { hero } from "@/lib/copy";
import { LOGO_SRC, MARKETING_IMAGES } from "@/lib/images";

export function Hero() {
  const img = MARKETING_IMAGES.hero;

  return (
    <section className="relative overflow-hidden pt-[4.25rem] sm:pt-[4.75rem]">
      <div
        className="pointer-events-none absolute inset-0"
        style={{ background: "var(--gradient-hero)" }}
        aria-hidden
      />
      <div
        className="pointer-events-none absolute -left-20 top-32 h-80 w-80 rounded-full bg-primary/10 blur-3xl"
        aria-hidden
      />
      <div
        className="pointer-events-none absolute bottom-0 left-1/3 h-56 w-56 rounded-full bg-hero-mint/35 blur-3xl"
        aria-hidden
      />

      <Container className="relative grid items-center gap-10 py-12 sm:py-16 lg:grid-cols-12 lg:gap-10 lg:py-20 xl:gap-14">
        <div className="order-2 animate-fade-up min-w-0 lg:order-1 lg:col-span-6 xl:col-span-5">
          <div className="mb-6 flex items-center gap-3 sm:gap-4">
            <Image
              src={LOGO_SRC}
              alt={`${hero.brand} logo`}
              width={72}
              height={72}
              className="h-14 w-14 rounded-2xl object-contain shadow-lg shadow-primary/25 sm:h-16 sm:w-16"
              priority
              unoptimized
            />
            <div>
              <p className="font-display text-4xl font-extrabold tracking-tight text-primary sm:text-5xl lg:text-[3.4rem] lg:leading-none">
                {hero.brand}
              </p>
              <p className="mt-1 text-xs font-semibold tracking-wide text-text-secondary sm:text-sm">
                Period · Ovulation · Pregnancy
              </p>
            </div>
          </div>

          <h1 className="font-display text-3xl font-bold leading-[1.12] tracking-tight text-text-primary sm:text-4xl lg:text-[2.75rem]">
            {hero.headline}
          </h1>

          <p className="mt-4 max-w-md text-base leading-relaxed text-text-secondary sm:text-lg">
            {hero.support}
          </p>

          <div className="mt-8">
            <DownloadButtons />
          </div>

          <p className="mt-4 text-sm text-text-secondary">
            Free to start · No health data sold
          </p>

          <Link
            href="/features"
            className="mt-5 inline-flex items-center gap-1.5 text-sm font-semibold text-primary transition-colors hover:text-accent"
          >
            {hero.secondaryCta}
            <span aria-hidden>→</span>
          </Link>
        </div>

        <div className="order-1 min-w-0 lg:order-2 lg:col-span-6 xl:col-span-7">
          <div className="relative mx-auto w-full max-w-xl lg:mx-0 lg:max-w-none">
            <div
              className="pointer-events-none absolute -inset-3 rounded-[2rem] bg-primary/10 blur-xl sm:-inset-4 sm:rounded-[2.5rem]"
              aria-hidden
            />
            <div className="relative aspect-[4/3] overflow-hidden rounded-[1.75rem] shadow-xl shadow-primary/15 ring-1 ring-border/60 sm:aspect-[5/4] lg:aspect-[4/3]">
              <Image
                src={img.src}
                alt={img.alt}
                fill
                priority
                className="object-cover object-center"
                sizes="(max-width: 1024px) 100vw, 55vw"
              />
            </div>
          </div>
        </div>
      </Container>
    </section>
  );
}
