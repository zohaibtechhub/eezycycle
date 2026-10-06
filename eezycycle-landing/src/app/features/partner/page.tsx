import type { Metadata } from "next";
import {
  FeatureBullets,
  FeatureHero,
  FeaturePageEnd,
} from "@/components/sections/FeaturePage";
import { PageShell } from "@/components/ui/PageShell";
import { featurePages } from "@/lib/copy";

const content = featurePages.partner;

export const metadata: Metadata = {
  title: "Partner Cycle Support",
  description: content.description,
  alternates: { canonical: "/features/partner" },
};

export default function PartnerPage() {
  return (
    <PageShell>
      <FeatureHero content={content} accent="primary" />
      <FeatureBullets bullets={[...content.bullets]} />
      <FeaturePageEnd />
    </PageShell>
  );
}
