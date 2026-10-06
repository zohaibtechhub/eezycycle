import type { Metadata } from "next";
import {
  FeatureBullets,
  FeatureHero,
  FeaturePageEnd,
} from "@/components/sections/FeaturePage";
import { PageShell } from "@/components/ui/PageShell";
import { featurePages } from "@/lib/copy";

const content = featurePages["period-tracker"];

export const metadata: Metadata = {
  title: "Period Tracker App",
  description: content.description,
  alternates: { canonical: "/features/period-tracker" },
};

export default function PeriodTrackerPage() {
  return (
    <PageShell>
      <FeatureHero content={content} accent="period" />
      <FeatureBullets bullets={[...content.bullets]} />
      <FeaturePageEnd />
    </PageShell>
  );
}
