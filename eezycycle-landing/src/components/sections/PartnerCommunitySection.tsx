import Image from "next/image";
import Link from "next/link";
import { Reveal } from "@/components/ui/Reveal";
import { Section } from "@/components/ui/Section";
import { homeCommunity, homePartner } from "@/lib/copy";
import { MARKETING_IMAGES } from "@/lib/images";

export function PartnerCommunitySection() {
  return (
    <Section className="bg-background">
      <div className="grid gap-12 md:gap-14 lg:grid-cols-2 lg:gap-12">
        <Reveal>
          <div className="relative mb-5 aspect-[16/10] overflow-hidden rounded-2xl sm:mb-6">
            <Image
              src={MARKETING_IMAGES.partner.src}
              alt={MARKETING_IMAGES.partner.alt}
              fill
              className="object-cover"
              sizes="(max-width: 1024px) 100vw, 50vw"
            />
          </div>
          <h2 className="font-display text-2xl font-semibold tracking-tight text-text-primary sm:text-3xl">
            {homePartner.title}
          </h2>
          <p className="mt-3 text-sm leading-relaxed text-text-secondary sm:text-base">
            {homePartner.support}
          </p>
          <ul className="mt-5 space-y-3">
            {homePartner.bullets.map((b) => (
              <li
                key={b}
                className="flex gap-3 text-sm text-text-secondary sm:text-base"
              >
                <span className="mt-2 h-1.5 w-1.5 shrink-0 rounded-full bg-primary" />
                <span className="min-w-0">{b}</span>
              </li>
            ))}
          </ul>
          <Link
            href="/features/partner"
            className="mt-5 inline-flex text-sm font-semibold text-primary underline-offset-2 hover:underline sm:mt-6"
          >
            Partner Space details →
          </Link>
        </Reveal>

        <Reveal delayMs={100}>
          <div className="relative mb-5 aspect-[16/10] overflow-hidden rounded-2xl sm:mb-6">
            <Image
              src={MARKETING_IMAGES.community.src}
              alt={MARKETING_IMAGES.community.alt}
              fill
              className="object-cover"
              sizes="(max-width: 1024px) 100vw, 50vw"
            />
          </div>
          <h2 className="font-display text-2xl font-semibold tracking-tight text-text-primary sm:text-3xl">
            {homeCommunity.title}
          </h2>
          <p className="mt-3 text-sm leading-relaxed text-text-secondary sm:text-base">
            {homeCommunity.support}
          </p>
          <Link
            href="/features/secret-chat"
            className="mt-5 inline-flex text-sm font-semibold text-primary underline-offset-2 hover:underline"
          >
            Secret Chat details →
          </Link>
        </Reveal>
      </div>
    </Section>
  );
}
