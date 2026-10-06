"use client";

import { useEffect, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { Container } from "@/components/ui/Container";
import { NAV_LINKS, SITE_NAME } from "@/lib/constants";
import { LOGO_SRC } from "@/lib/images";

export function Nav() {
  const [scrolled, setScrolled] = useState(false);
  const [open, setOpen] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 8);
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  useEffect(() => {
    document.body.style.overflow = open ? "hidden" : "";
    return () => {
      document.body.style.overflow = "";
    };
  }, [open]);

  return (
    <header
      className={`fixed inset-x-0 top-0 z-50 transition-all duration-300 ${
        scrolled || open
          ? "border-b border-border/80 bg-background/95 backdrop-blur-md shadow-sm shadow-primary/5"
          : "bg-background/80 backdrop-blur-sm"
      }`}
    >
      <Container className="flex h-16 items-center justify-between gap-3 sm:h-[4.75rem]">
        <Link
          href="/"
          className="flex min-w-0 items-center gap-2 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary sm:gap-3"
          aria-label={`${SITE_NAME} home`}
          onClick={() => setOpen(false)}
        >
          <Image
            src={LOGO_SRC}
            alt={`${SITE_NAME} logo`}
            width={48}
            height={48}
            className="h-9 w-9 shrink-0 rounded-xl object-contain sm:h-11 sm:w-11"
            priority
            unoptimized
          />
          <span className="truncate font-display text-lg font-semibold tracking-tight text-primary sm:text-xl md:text-2xl">
            {SITE_NAME}
          </span>
        </Link>

        <nav className="hidden items-center gap-6 xl:gap-7 lg:flex" aria-label="Primary">
          {NAV_LINKS.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className="whitespace-nowrap text-sm font-medium text-text-secondary transition-colors hover:text-text-primary"
            >
              {link.label}
            </Link>
          ))}
          <Link
            href="/download"
            className="inline-flex items-center gap-2 rounded-full bg-primary px-4 py-2.5 text-sm font-semibold text-white shadow-md shadow-primary/20 transition hover:bg-accent"
          >
            <DownloadArrow className="h-4 w-4" />
            Download
          </Link>
        </nav>

        <div className="flex shrink-0 items-center gap-1.5 sm:gap-2 lg:hidden">
          <Link
            href="/download"
            className="inline-flex items-center justify-center rounded-full bg-primary p-2.5 text-white sm:gap-1.5 sm:px-3 sm:py-2"
            aria-label="Download the app"
          >
            <DownloadArrow className="h-4 w-4" />
            <span className="hidden text-xs font-semibold sm:inline">Download</span>
          </Link>
          <button
            type="button"
            className="inline-flex h-10 w-10 items-center justify-center rounded-lg text-text-primary"
            aria-expanded={open}
            aria-label="Toggle menu"
            onClick={() => setOpen((v) => !v)}
          >
            <span className="flex flex-col gap-1.5">
              <span
                className={`block h-0.5 w-5 bg-text-primary transition ${open ? "translate-y-2 rotate-45" : ""}`}
              />
              <span
                className={`block h-0.5 w-5 bg-text-primary transition ${open ? "opacity-0" : ""}`}
              />
              <span
                className={`block h-0.5 w-5 bg-text-primary transition ${open ? "-translate-y-2 -rotate-45" : ""}`}
              />
            </span>
          </button>
        </div>
      </Container>

      {open ? (
        <div className="max-h-[calc(100svh-4rem)] overflow-y-auto border-t border-border bg-background lg:hidden">
          <Container className="flex flex-col gap-1 py-4">
            {NAV_LINKS.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                className="rounded-xl px-3 py-3 text-base font-medium text-text-primary hover:bg-primary-light"
                onClick={() => setOpen(false)}
              >
                {link.label}
              </Link>
            ))}
            <Link
              href="/download"
              className="mt-2 rounded-full bg-primary px-4 py-3.5 text-center text-sm font-semibold text-white"
              onClick={() => setOpen(false)}
            >
              Download the app
            </Link>
          </Container>
        </div>
      ) : null}
    </header>
  );
}

function DownloadArrow({ className = "" }: { className?: string }) {
  return (
    <svg
      className={className}
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
