import type { Metadata } from "next";
import {
  FeatureBullets,
  FeatureHero,
  FeaturePageEnd,
} from "@/components/sections/FeaturePage";
import { PageShell } from "@/components/ui/PageShell";
import { featurePages } from "@/lib/copy";

const content = featurePages.perimenopause;

export const metadata: Metadata = {
  title: "Perimenopause Tracker",
  description: content.description,
  alternates: { canonical: "/features/perimenopause" },
};

export default function PerimenopausePage() {
  return (
    <PageShell>
      <FeatureHero content={content} accent="perimenopause" />
      <FeatureBullets bullets={[...content.bullets]} />
      <FeaturePageEnd />
    </PageShell>
  );
}
