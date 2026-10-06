import Link from "next/link";
import { Accordion } from "@/components/ui/Accordion";
import { Reveal } from "@/components/ui/Reveal";
import { Section, SectionHeading } from "@/components/ui/Section";
import { faqItems } from "@/lib/copy";

export function HomeFaq() {
  return (
    <Section id="faq-home" className="bg-background">
      <Reveal>
        <SectionHeading
          title="Frequently asked questions"
          support="Answers pulled from the in-app Help & FAQ — getting started, cycle health, partner sync, Secret Chat, privacy, and account."
        />
        <Accordion items={faqItems} />
        <p className="mt-6 text-sm text-text-secondary">
          More help on the{" "}
          <Link
            href="/faq"
            className="font-semibold text-primary underline-offset-2 hover:underline"
          >
            full FAQ page
          </Link>
          .
        </p>
      </Reveal>
    </Section>
  );
}
