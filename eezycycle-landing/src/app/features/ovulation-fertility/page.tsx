import type { Metadata } from "next";
import {
  FeatureBullets,
  FeatureHero,
  FeaturePageEnd,
} from "@/components/sections/FeaturePage";
import { PageShell } from "@/components/ui/PageShell";
import { featurePages } from "@/lib/copy";

const content = featurePages["ovulation-fertility"];

export const metadata: Metadata = {
  title: "Ovulation & Fertile Window Estimates",
  description: content.description,
  alternates: { canonical: "/features/ovulation-fertility" },
};

export default function OvulationFertilityPage() {
  return (
    <PageShell>
      <FeatureHero content={content} accent="fertility" />
      <FeatureBullets bullets={[...content.bullets]} />
      <FeaturePageEnd />
    </PageShell>
  );
}
