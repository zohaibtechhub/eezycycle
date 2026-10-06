import Link from "next/link";
import { Reveal } from "@/components/ui/Reveal";
import { Section, SectionHeading } from "@/components/ui/Section";
import { privacy } from "@/lib/copy";

export function PrivacyHome() {
  return (
    <Section id="privacy-home" className="bg-primary-light/40">
      <Reveal>
        <SectionHeading title={privacy.title} support={privacy.support} />
        <ul className="grid gap-4 sm:grid-cols-2">
          {privacy.bullets.map((bullet) => (
            <li
              key={bullet}
              className="flex gap-3 text-sm text-text-primary sm:text-base"
            >
              <span
                className="mt-1.5 h-2 w-2 shrink-0 rounded-full bg-success"
                aria-hidden
              />
              {bullet}
            </li>
          ))}
        </ul>
        <p className="mt-8 text-sm text-text-secondary">
          Read the full{" "}
          <Link
            href="/privacy"
            className="font-semibold text-primary underline-offset-2 hover:underline"
          >
            Privacy Policy
          </Link>
          .
        </p>
      </Reveal>
    </Section>
  );
}
