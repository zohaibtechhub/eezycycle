import type { Metadata } from "next";
import { Container } from "@/components/ui/Container";
import { PageShell } from "@/components/ui/PageShell";
import { BlogHubClient } from "@/components/blog/BlogHubClient";
import { getAllBlogPosts, getBlogCategories } from "@/lib/blog";
import { SITE_NAME, SITE_URL } from "@/lib/constants";

export const metadata: Metadata = {
  title: "Cycle & Health Articles | EezyCycle",
  description:
    "Doctor-reviewed guides on periods, ovulation timing, fertile windows, pregnancy week-by-week, and daily wellness.",
  keywords: [
    "period tracker articles",
    "women cycle health guides",
    "ovulation signs",
    "luteal phase mood tips",
    "pregnancy week by week guide",
    "fertile window explanation",
    "EezyCycle",
  ],
  alternates: {
    canonical: "/blog",
  },
  openGraph: {
    title: "EezyCycle Cycle & Health Articles",
    description:
      "Guides on periods, ovulation, fertility, pregnancy, and wellness — written for real life.",
    url: `${SITE_URL}/blog`,
    siteName: SITE_NAME,
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "Cycle & Health Articles | EezyCycle",
    description:
      "Practical guidance for every phase of your cycle.",
  },
};

export default function BlogHubPage() {
  const posts = getAllBlogPosts();
  const categories = getBlogCategories();

  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    name: "EezyCycle Cycle & Health Guides",
    description:
      "A library of cycle and health articles on periods, ovulation, fertility, and pregnancy.",
    url: `${SITE_URL}/blog`,
    publisher: {
      "@type": "Organization",
      name: SITE_NAME,
      logo: `${SITE_URL}/logo.png`,
    },
  };

  return (
    <PageShell>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />
      <div className="relative overflow-hidden pt-12 pb-20 sm:pt-16 sm:pb-24">
        {/* Soft background ambient gradient */}
        <div
          className="pointer-events-none absolute inset-x-0 top-0 h-96 opacity-60"
          style={{ background: "var(--gradient-soft)" }}
          aria-hidden
        />

        <Container className="relative">
          {/* Header */}
          <div className="mx-auto mb-10 max-w-3xl text-center sm:mb-14">
            <span className="inline-flex items-center gap-1.5 rounded-full border border-primary/20 bg-primary-light px-3.5 py-1 text-xs font-semibold text-primary">
              🌸 EezyCycle Library
            </span>
            <h1 className="mt-4 font-display text-3xl font-extrabold tracking-tight text-text-primary sm:text-5xl lg:text-6xl">
              Cycle & Health{" "}
              <span className="text-primary">Guides</span>
            </h1>
            <p className="mt-4 text-base leading-relaxed text-text-secondary sm:text-lg">
              Practical answers for every phase — periods, fertility, pregnancy, energy, rest, and wellness.
            </p>
          </div>

          <BlogHubClient posts={posts} categories={categories} />
        </Container>
      </div>
    </PageShell>
  );
}
