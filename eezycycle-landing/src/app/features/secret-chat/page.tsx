import type { Metadata } from "next";
import {
  FeatureBullets,
  FeatureHero,
  FeaturePageEnd,
} from "@/components/sections/FeaturePage";
import { PageShell } from "@/components/ui/PageShell";
import { featurePages } from "@/lib/copy";

const content = featurePages["secret-chat"];

export const metadata: Metadata = {
  title: "Secret Chat Community",
  description: content.description,
  alternates: { canonical: "/features/secret-chat" },
};

export default function SecretChatPage() {
  return (
    <PageShell>
      <FeatureHero content={content} accent="ovulation" />
      <FeatureBullets bullets={[...content.bullets]} />
      <FeaturePageEnd />
    </PageShell>
  );
}
