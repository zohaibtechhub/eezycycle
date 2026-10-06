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
  const pad = size === "lg" ? "px-7 py-3.5 text-base" : "px-5 py-2.5 text-sm";
  const iconSize = size === "lg" ? 20 : 16;
  const wrap = align === "center" ? "justify-center" : "justify-start";

  const styles = light
    ? "bg-white text-primary hover:bg-primary-light shadow-lg shadow-black/10"
    : "bg-primary text-white hover:bg-accent shadow-lg shadow-primary/30";

  return (
    <div className={`flex ${wrap}`}>
      <Link
        href={href}
        className={`inline-flex items-center justify-center gap-2.5 rounded-full font-semibold tracking-tight transition-transform duration-200 hover:scale-[1.03] focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary ${pad} ${styles}`}
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
    <section className="py-16 sm:py-24">
      <div className="mx-auto max-w-6xl px-5 sm:px-8">
        <div
          className="relative overflow-hidden rounded-[2rem] px-8 py-14 text-center sm:px-16 sm:py-16"
          style={{ background: "var(--gradient-app)" }}
        >
          <div
            className="pointer-events-none absolute -right-16 -top-16 h-56 w-56 rounded-full bg-white/10 blur-2xl"
            aria-hidden
          />
          <h2 className="relative font-display text-3xl font-semibold tracking-tight text-white sm:text-4xl">
            {title}
          </h2>
          <p className="relative mx-auto mt-4 max-w-md text-base text-white/90">
            {support}
          </p>
          <div className="relative mt-8">
            <DownloadButtons align="center" light />
          </div>
        </div>
      </div>
    </section>
  );
}

/** Clean download arrow — not a store brand mark */
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
