import type { Metadata } from "next";
import Image from "next/image";
import Link from "next/link";
import { PageShell } from "@/components/ui/PageShell";
import { Container } from "@/components/ui/Container";
import { DownloadButtons } from "@/components/ui/DownloadButtons";
import { PLAY_STORE_URL, SITE_NAME, SUPPORT_EMAIL } from "@/lib/constants";
import { LOGO_SRC, MARKETING_IMAGES } from "@/lib/images";

export const metadata: Metadata = {
  title: "Download",
  description:
    "Download the EezyCycle app. Free to start, guest mode available, privacy first.",
  alternates: { canonical: "/download" },
};

export default function DownloadPage() {
  const storeReady = Boolean(PLAY_STORE_URL);
  const img = MARKETING_IMAGES.download;

  return (
    <PageShell>
      <section className="relative overflow-hidden pt-20 pb-12 sm:pt-28 sm:pb-20">
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
                "linear-gradient(115deg, rgba(250,247,248,0.95) 0%, rgba(253,240,243,0.9) 55%, rgba(250,247,248,0.55) 100%)",
            }}
          />
        </div>

        <Container className="relative">
          <div className="grid items-center gap-8 sm:gap-12 lg:grid-cols-2 lg:gap-14">
            <div className="order-2 min-w-0 lg:order-1">
              <div className="mb-4 flex items-center gap-2.5 sm:mb-6 sm:gap-3">
                <Image
                  src={LOGO_SRC}
                  alt={`${SITE_NAME} logo`}
                  width={56}
                  height={56}
                  className="h-11 w-11 rounded-2xl object-contain shadow-md shadow-primary/20 sm:h-14 sm:w-14"
                  priority
                  unoptimized
                />
                <span className="font-display text-xl font-semibold text-primary sm:text-2xl">
                  {SITE_NAME}
                </span>
              </div>
              <p className="text-xs font-medium text-text-secondary sm:text-sm">
                <Link href="/" className="hover:text-primary">
                  Home
                </Link>{" "}
                / Download
              </p>
              <h1 className="mt-3 font-display text-3xl font-semibold tracking-tight text-text-primary sm:mt-4 sm:text-4xl md:text-5xl">
                Download the app
              </h1>
              <p className="mt-4 max-w-md text-sm leading-relaxed text-text-secondary sm:mt-5 sm:text-base md:text-lg">
                Get EezyCycle on your phone. Free to start, guest mode
                available, and we never sell your health data.
              </p>

              <div className="mt-6 w-full sm:mt-8 sm:w-auto">
                <DownloadButtons />
              </div>

              {!storeReady ? (
                <p className="mt-4 rounded-2xl border border-border bg-surface/90 px-4 py-3 text-xs text-text-secondary sm:mt-5 sm:text-sm">
                  Play Store link will appear here when the listing is live.
                  Questions?{" "}
                  <a
                    href={`mailto:${SUPPORT_EMAIL}`}
                    className="font-medium text-primary hover:underline break-all"
                  >
                    {SUPPORT_EMAIL}
                  </a>
                </p>
              ) : null}
            </div>

            <div className="relative order-1 mx-auto aspect-[4/3] w-full max-w-md overflow-hidden rounded-2xl border border-white/70 shadow-xl shadow-primary/20 sm:aspect-[4/5] sm:rounded-[1.75rem] lg:order-2 lg:max-w-none">
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
    </PageShell>
  );
}
