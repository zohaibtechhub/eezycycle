import Image from "next/image";
import Link from "next/link";
import { Container } from "@/components/ui/Container";
import { FEATURES, SITE_NAME, SUPPORT_EMAIL } from "@/lib/constants";
import { disclaimer } from "@/lib/copy";
import { LOGO_SRC } from "@/lib/images";

export function Footer() {
  const year = new Date().getFullYear();

  return (
    <footer className="border-t border-border bg-background pb-10 pt-14">
      <Container>
        <div className="grid gap-10 sm:grid-cols-2 lg:grid-cols-4">
          <div className="sm:col-span-2 lg:col-span-1">
            <Link href="/" className="inline-flex items-center gap-2.5">
              <Image
                src={LOGO_SRC}
                alt={`${SITE_NAME} logo`}
                width={40}
                height={40}
                className="h-10 w-10 rounded-xl object-contain"
              />
              <span className="font-display text-lg font-semibold text-primary">
                {SITE_NAME}
              </span>
            </Link>
            <p className="mt-3 max-w-xs text-sm text-text-secondary">
              Period & ovulation tracking. Download free — privacy first.
            </p>
            <Link
              href="/download"
              className="mt-4 inline-flex rounded-xl bg-primary px-4 py-2.5 text-sm font-semibold text-white hover:bg-accent"
            >
              Download the app
            </Link>
          </div>

          <div>
            <p className="text-xs font-semibold uppercase tracking-wider text-text-secondary">
              Features
            </p>
            <ul className="mt-3 space-y-2">
              {FEATURES.map((f) => (
                <li key={f.slug}>
                  <Link
                    href={f.href}
                    className="text-sm text-text-secondary hover:text-text-primary"
                  >
                    {f.title}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <p className="text-xs font-semibold uppercase tracking-wider text-text-secondary">
              Company
            </p>
            <ul className="mt-3 space-y-2 text-sm text-text-secondary">
              <li>
                <Link href="/how-it-works" className="hover:text-text-primary">
                  How it works
                </Link>
              </li>
              <li>
                <Link href="/faq" className="hover:text-text-primary">
                  FAQ
                </Link>
              </li>
              <li>
                <Link href="/privacy" className="hover:text-text-primary">
                  Privacy Policy
                </Link>
              </li>
              <li>
                <Link href="/download" className="hover:text-text-primary">
                  Download
                </Link>
              </li>
              <li>
                <a
                  href={`mailto:${SUPPORT_EMAIL}`}
                  className="hover:text-text-primary"
                >
                  Contact
                </a>
              </li>
            </ul>
          </div>
        </div>

        <p className="mt-12 max-w-3xl text-xs leading-relaxed text-text-secondary">
          {disclaimer}
        </p>
        <p className="mt-6 text-xs text-text-secondary">
          © {year} {SITE_NAME}. All rights reserved.
        </p>
      </Container>
    </footer>
  );
}
