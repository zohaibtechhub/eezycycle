import type { Metadata } from "next";
import Link from "next/link";
import { Accordion } from "@/components/ui/Accordion";
import { Container } from "@/components/ui/Container";
import { DownloadBand } from "@/components/ui/DownloadButtons";
import { PageShell } from "@/components/ui/PageShell";
import { SUPPORT_EMAIL } from "@/lib/constants";
import { faqItems, finalCta } from "@/lib/copy";

export const metadata: Metadata = {
  title: "Help & FAQ",
  description:
    "Answers about downloading EezyCycle, accounts, cycle predictions, partner sync, and privacy.",
  alternates: { canonical: "/faq" },
};

export default function FaqPage() {
  return (
    <PageShell>
      <section className="bg-background pt-28 pb-16">
        <Container className="max-w-3xl">
          <p className="text-sm font-medium text-text-secondary">
            <Link href="/" className="hover:text-primary">
              Home
            </Link>{" "}
            / FAQ
          </p>
          <h1 className="mt-4 font-display text-4xl font-semibold tracking-tight text-text-primary">
            Help & FAQ
          </h1>
          <p className="mt-4 text-text-secondary">
            Still stuck? Email{" "}
            <a
              href={`mailto:${SUPPORT_EMAIL}`}
              className="font-medium text-primary hover:underline"
            >
              {SUPPORT_EMAIL}
            </a>
            . Ready to try the app?{" "}
            <Link href="/download" className="font-medium text-primary hover:underline">
              Download here
            </Link>
            .
          </p>
          <div className="mt-10">
            <Accordion items={faqItems} />
          </div>
        </Container>
      </section>
      <DownloadBand title={finalCta.title} support={finalCta.support} />
    </PageShell>
  );
}
