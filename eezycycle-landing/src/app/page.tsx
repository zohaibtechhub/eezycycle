import { BlogPreviewSection } from "@/components/sections/BlogPreviewSection";
import { FeatureGrid } from "@/components/sections/FeatureGrid";
import { GoalsSection } from "@/components/sections/GoalsSection";
import { Hero } from "@/components/sections/Hero";
import { HomeFaq } from "@/components/sections/HomeFaq";
import { HowItWorksHome } from "@/components/sections/HowItWorksHome";
import { InsightsSection } from "@/components/sections/InsightsSection";
import { PartnerCommunitySection } from "@/components/sections/PartnerCommunitySection";
import { PrivacyHome } from "@/components/sections/PrivacyHome";
import { TrustStrip } from "@/components/sections/TrustStrip";
import { DownloadBand } from "@/components/ui/DownloadButtons";
import { PageShell } from "@/components/ui/PageShell";
import { finalCta } from "@/lib/copy";

export default function HomePage() {
  return (
    <PageShell>
      <Hero />
      <GoalsSection />
      <FeatureGrid />
      <BlogPreviewSection />
      <HowItWorksHome />
      <InsightsSection />
      <PartnerCommunitySection />
      <TrustStrip />
      <PrivacyHome />
      <HomeFaq />
      <DownloadBand title={finalCta.title} support={finalCta.support} />
    </PageShell>
  );
}
