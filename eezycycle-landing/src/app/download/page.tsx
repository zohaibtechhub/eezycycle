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
      <section className="relative min-h-[85svh] overflow-hidden pt-28 pb-20">
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
                "linear-gradient(115deg, rgba(250,247,248,0.95) 0%, rgba(253,240,243,0.88) 48%, rgba(250,247,248,0.45) 100%)",
            }}
          />
        </div>

        <Container className="relative">
          <div className="grid items-center gap-14 lg:grid-cols-2">
            <div>
              <div className="mb-6 flex items-center gap-3">
                <Image
                  src={LOGO_SRC}
                  alt={`${SITE_NAME} logo`}
                  width={56}
                  height={56}
                  className="h-14 w-14 rounded-2xl object-contain shadow-md shadow-primary/20"
                  priority
                />
                <span className="font-display text-2xl font-semibold text-primary">
                  {SITE_NAME}
                </span>
              </div>
              <p className="text-sm font-medium text-text-secondary">
                <Link href="/" className="hover:text-primary">
                  Home
                </Link>{" "}
                / Download
              </p>
              <h1 className="mt-4 font-display text-4xl font-semibold tracking-tight text-text-primary sm:text-5xl">
                Download the app
              </h1>
              <p className="mt-5 max-w-md text-lg leading-relaxed text-text-secondary">
                Get EezyCycle on your phone. Free to start, guest mode
                available, and we never sell your health data.
              </p>

              <div className="mt-8">
                <DownloadButtons />
              </div>

              {!storeReady ? (
                <p className="mt-5 rounded-2xl border border-border bg-surface/90 px-4 py-3 text-sm text-text-secondary">
                  Play Store link will appear here when the listing is live.
                  Questions?{" "}
                  <a
                    href={`mailto:${SUPPORT_EMAIL}`}
                    className="font-medium text-primary hover:underline"
                  >
                    {SUPPORT_EMAIL}
                  </a>
                </p>
              ) : null}
            </div>

            <div className="relative mx-auto aspect-[4/5] w-full max-w-md overflow-hidden rounded-[1.75rem] border border-white/70 shadow-2xl shadow-primary/25">
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
    </PageShell>
  );
}
