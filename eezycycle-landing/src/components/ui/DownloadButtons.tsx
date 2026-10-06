"use client";

import Link from "next/link";
import { PLAY_STORE_URL } from "@/lib/constants";

type Size = "md" | "lg";

export function DownloadButtons({
  size = "lg",
  align = "start",
  light = false,
}: {
  size?: Size;
  align?: "start" | "center";
  light?: boolean;
}) {
  const href = PLAY_STORE_URL || "/download";
  const pad =
    size === "lg"
      ? "px-6 py-3.5 text-sm sm:px-7 sm:text-base"
      : "px-5 py-2.5 text-sm";
  const iconSize = size === "lg" ? 20 : 16;
  const wrap =
    align === "center" ? "justify-center" : "justify-start";

  const styles = light
    ? "bg-white text-primary hover:bg-primary-light shadow-lg shadow-black/10"
    : "bg-primary text-white hover:bg-accent shadow-lg shadow-primary/30";

  return (
    <div className={`flex w-full sm:w-auto ${wrap}`}>
      <Link
        href={href}
        className={`inline-flex w-full items-center justify-center gap-2.5 rounded-full font-semibold tracking-tight transition-transform duration-200 hover:scale-[1.02] focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary sm:w-auto ${pad} ${styles}`}
      >
        <DownloadIcon size={iconSize} />
        Download the app
      </Link>
    </div>
  );
}

export function DownloadBand({
  title,
  support,
}: {
  title: string;
  support: string;
}) {
  return (
    <section className="py-12 sm:py-16 md:py-24">
      <div className="mx-auto w-full max-w-6xl px-4 sm:px-6 md:px-8">
        <div
          className="relative overflow-hidden rounded-2xl px-5 py-10 text-center sm:rounded-[2rem] sm:px-10 sm:py-14 md:px-16 md:py-16"
          style={{ background: "var(--gradient-app)" }}
        >
          <div
            className="pointer-events-none absolute -right-16 -top-16 hidden h-56 w-56 rounded-full bg-white/10 blur-2xl sm:block"
            aria-hidden
          />
          <h2 className="relative font-display text-2xl font-semibold tracking-tight text-white sm:text-3xl md:text-4xl">
            {title}
          </h2>
          <p className="relative mx-auto mt-3 max-w-md text-sm text-white/90 sm:mt-4 sm:text-base">
            {support}
          </p>
          <div className="relative mx-auto mt-6 max-w-xs sm:mt-8 sm:max-w-none">
            <DownloadButtons align="center" light />
          </div>
        </div>
      </div>
    </section>
  );
}

function DownloadIcon({ size = 20 }: { size?: number }) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2.25"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden
    >
      <path d="M12 3v12" />
      <path d="m7 10 5 5 5-5" />
      <path d="M5 19h14" />
    </svg>
  );
}
