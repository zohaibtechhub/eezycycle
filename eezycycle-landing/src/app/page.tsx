import { FeatureGrid } from "@/components/sections/FeatureGrid";
import { Hero } from "@/components/sections/Hero";
import { TrustStrip } from "@/components/sections/TrustStrip";
import { DownloadBand } from "@/components/ui/DownloadButtons";
import { PageShell } from "@/components/ui/PageShell";
import { finalCta } from "@/lib/copy";

export default function HomePage() {
  return (
    <PageShell>
      <Hero />
      <FeatureGrid />
      <TrustStrip />
      <DownloadBand title={finalCta.title} support={finalCta.support} />
    </PageShell>
  );
}
