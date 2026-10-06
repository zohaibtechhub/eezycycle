import type { Metadata } from "next";
import {
  FeatureBullets,
  FeatureHero,
  FeaturePageEnd,
} from "@/components/sections/FeaturePage";
import { PageShell } from "@/components/ui/PageShell";
import { featurePages } from "@/lib/copy";

const content = featurePages.pregnancy;

export const metadata: Metadata = {
  title: "Pregnancy Week Insights",
  description: content.description,
  alternates: { canonical: "/features/pregnancy" },
};

export default function PregnancyPage() {
  return (
    <PageShell>
      <FeatureHero content={content} accent="pregnancy" />
      <FeatureBullets bullets={[...content.bullets]} />
      <FeaturePageEnd />
    </PageShell>
  );
}
