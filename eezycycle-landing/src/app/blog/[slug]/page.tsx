import type { Metadata } from "next";
import { notFound } from "next/navigation";
import Image from "next/image";
import Link from "next/link";
import { Container } from "@/components/ui/Container";
import { PageShell } from "@/components/ui/PageShell";
import { DownloadButtons } from "@/components/ui/DownloadButtons";
import {
  getAllBlogPosts,
  getBlogPostBySlug,
  getRelatedBlogPosts,
} from "@/lib/blog";
import { blogPostingJsonLd, breadcrumbJsonLd } from "@/lib/seo";
import { SITE_NAME, SITE_URL } from "@/lib/constants";

type PageProps = {
  params: Promise<{ slug: string }>;
};

export async function generateStaticParams() {
  const posts = getAllBlogPosts();
  return posts.map((post) => ({
    slug: post.slug,
  }));
}

export async function generateMetadata({
  params,
}: PageProps): Promise<Metadata> {
  const { slug } = await params;
  const post = getBlogPostBySlug(slug);

  if (!post) {
    return {
      title: "Article Not Found | EezyCycle",
    };
  }

  const title = `${post.title} | EezyCycle Guide`;
  const description = post.plainEnglishSummary;

  return {
    title,
    description,
    keywords: [
      post.title.toLowerCase(),
      post.category.toLowerCase(),
      "plain english cycle health",
      "period tracker guide",
      "EezyCycle",
    ],
    alternates: {
      canonical: `/blog/${post.slug}`,
    },
    openGraph: {
      title,
      description,
      url: `${SITE_URL}/blog/${post.slug}`,
      siteName: SITE_NAME,
      type: "article",
      publishedTime: post.publishedDate,
      authors: [post.author],
      images: [
        {
          url: post.image,
          width: 1200,
          height: 630,
          alt: post.imageAlt,
        },
      ],
    },
    twitter: {
      card: "summary_large_image",
      title,
      description,
      images: [post.image],
    },
  };
}

const PHASE_COLORS: Record<string, { bg: string; text: string; border: string }> = {
  menstrual: { bg: "bg-period/10", text: "text-period", border: "border-period/30" },
  period: { bg: "bg-period/10", text: "text-period", border: "border-period/30" },
  follicular: { bg: "bg-primary/10", text: "text-primary", border: "border-primary/30" },
  ovulation: { bg: "bg-ovulation/15", text: "text-ovulation", border: "border-ovulation/30" },
  fertility: { bg: "bg-fertility/10", text: "text-fertility", border: "border-fertility/30" },
  pregnancy: { bg: "bg-pregnancy/10", text: "text-pregnancy", border: "border-pregnancy/30" },
  perimenopause: { bg: "bg-perimenopause/10", text: "text-perimenopause", border: "border-perimenopause/30" },
  general: { bg: "bg-primary-light", text: "text-primary", border: "border-primary/20" },
};

export default async function BlogPostPage({ params }: PageProps) {
  const { slug } = await params;
  const post = getBlogPostBySlug(slug);

  if (!post) {
    notFound();
  }

  const related = getRelatedBlogPosts(post.id, 3);
  const phaseStyle =
    PHASE_COLORS[post.phase.toLowerCase()] || PHASE_COLORS.general;

  const jsonLd = [
    blogPostingJsonLd(post),
    breadcrumbJsonLd([
      { name: "Home", url: "/" },
      { name: "Articles", url: "/blog" },
      { name: post.title, url: `/blog/${post.slug}` },
    ]),
  ];

  return (
    <PageShell>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />

      <article className="relative overflow-hidden pt-10 pb-20 sm:pt-14 sm:pb-28">
        {/* Soft background glow */}
        <div
          className="pointer-events-none absolute inset-x-0 top-0 h-96 opacity-40"
          style={{ background: "var(--gradient-soft)" }}
          aria-hidden
        />

        <Container className="relative max-w-4xl">
          {/* Breadcrumb Navigation */}
          <nav
            aria-label="Breadcrumb"
            className="mb-6 flex flex-wrap items-center gap-2 text-xs text-text-secondary"
          >
            <Link href="/" className="hover:text-primary transition-colors">
              Home
            </Link>
            <span>/</span>
            <Link href="/blog" className="hover:text-primary transition-colors">
              Articles
            </Link>
            <span>/</span>
            <span className="truncate max-w-[200px] sm:max-w-xs text-text-primary font-medium">
              {post.category}
            </span>
          </nav>

          {/* Category Pill and Read Time */}
          <div className="flex flex-wrap items-center gap-2.5">
            <span
              className={`rounded-full border px-3 py-1 text-xs font-semibold ${phaseStyle.bg} ${phaseStyle.text} ${phaseStyle.border}`}
            >
              {post.category}
            </span>
            <span className="rounded-full bg-surface border border-border px-3 py-1 text-xs font-medium text-text-secondary">
              ⏱ {post.readTime}
            </span>
            <span className="rounded-full bg-primary-light border border-primary/20 px-3 py-1 text-xs font-semibold text-primary">
              EezyCycle Guide
            </span>
          </div>

          {/* Title */}
          <h1 className="mt-5 font-display text-3xl font-extrabold tracking-tight text-text-primary sm:text-4xl lg:text-5xl lg:leading-[1.18]">
            {post.title}
          </h1>

          {/* Hero Cover Image */}
          <div className="relative mt-8 aspect-[16/9] w-full overflow-hidden rounded-3xl border border-border shadow-md">
            <Image
              src={post.image}
              alt={post.imageAlt}
              fill
              priority
              sizes="(max-width: 1024px) 100vw, 896px"
              className="object-cover"
            />
          </div>

          <div className="mt-10 overflow-hidden rounded-3xl border border-primary/25 bg-primary-light p-6 sm:p-8 shadow-xs">
            <div className="flex items-center gap-2 text-primary font-display font-bold text-base sm:text-lg">
              <span className="flex h-7 w-7 items-center justify-center rounded-full bg-primary text-white text-xs">
                💡
              </span>
              At a glance
            </div>
            <p className="mt-3 text-base leading-relaxed text-text-primary sm:text-lg">
              {post.plainEnglishSummary}
            </p>
          </div>

          {/* Key Takeaways */}
          {post.takeaways && post.takeaways.length > 0 && (
            <div className="mt-8 rounded-3xl border border-border bg-surface p-6 sm:p-8">
              <h2 className="font-display text-lg font-bold text-text-primary sm:text-xl">
                ✨ Key Takeaways for Today
              </h2>
              <ul className="mt-4 space-y-3">
                {post.takeaways.map((takeaway, idx) => (
                  <li
                    key={idx}
                    className="flex items-start gap-3 text-sm sm:text-base text-text-secondary"
                  >
                    <span className="mt-1 flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-primary/10 text-primary text-xs font-bold">
                      ✓
                    </span>
                    <span className="leading-relaxed">{takeaway}</span>
                  </li>
                ))}
              </ul>
            </div>
          )}

          {/* Body Sections */}
          <div className="mt-10 space-y-8 text-text-primary">
            {post.sections.map((section, idx) => (
              <section key={idx} className="rounded-2xl">
                <h2 className="font-display text-xl font-bold tracking-tight text-text-primary sm:text-2xl">
                  {section.heading}
                </h2>
                <div className="mt-3 text-base leading-relaxed text-text-secondary sm:text-lg">
                  {section.body}
                </div>
              </section>
            ))}
          </div>

          {/* Disclaimer */}
          <div className="mt-12 rounded-2xl border border-border bg-background p-5 text-xs leading-relaxed text-text-secondary">
            <p className="font-semibold text-text-primary">Wellness Note</p>
            <p className="mt-1">
              This guide is created for educational and personal wellness purposes. EezyCycle predictions and articles are estimates and do not provide medical diagnosis or individual clinical advice. Always consult a qualified healthcare provider for personal health concerns or severe pain.
            </p>
          </div>

          {/* In-article App Download CTA */}
          <div className="mt-12 overflow-hidden rounded-3xl border border-primary/30 bg-gradient-to-br from-primary via-secondary to-accent p-8 text-center text-white shadow-xl shadow-primary/25">
            <p className="text-xs font-bold uppercase tracking-wider text-white/90">
              Track Your Body With Confidence
            </p>
            <h2 className="mt-2 font-display text-2xl font-bold sm:text-3xl">
              Track this phase effortlessly in EezyCycle
            </h2>
            <p className="mx-auto mt-2 max-w-xl text-sm leading-relaxed text-white/90 sm:text-base">
              Get personalized daily insights, fertile-window timing cues, and symptoms logging right on your phone. Completely private, free to start as a guest.
            </p>
            <div className="mt-6 flex justify-center">
              <DownloadButtons />
            </div>
          </div>

          {/* Related Articles */}
          {related.length > 0 && (
            <div className="mt-16 border-t border-border pt-12">
              <div className="flex items-center justify-between mb-8">
                <div>
                  <h2 className="font-display text-2xl font-bold text-text-primary">
                    Related Articles
                  </h2>
                  <p className="text-sm text-text-secondary">
                    More simple-English guides you might like
                  </p>
                </div>
                <Link
                  href="/blog"
                  className="text-sm font-semibold text-primary hover:underline"
                >
                  View all guides →
                </Link>
              </div>

              <div className="grid gap-6 sm:grid-cols-3">
                {related.map((rel) => (
                  <Link
                    key={rel.id}
                    href={`/blog/${rel.slug}`}
                    className="group flex flex-col overflow-hidden rounded-2xl border border-border bg-surface transition hover:-translate-y-1 hover:border-primary/40 hover:shadow-lg hover:shadow-primary/10"
                  >
                    <div className="relative aspect-[16/10] w-full overflow-hidden bg-primary-light">
                      <Image
                        src={rel.image}
                        alt={rel.imageAlt}
                        fill
                        sizes="(max-width: 640px) 100vw, 33vw"
                        className="object-cover transition-transform group-hover:scale-105"
                      />
                    </div>
                    <div className="flex flex-1 flex-col p-4">
                      <span className="text-[10px] font-semibold text-primary uppercase tracking-wider">
                        {rel.category}
                      </span>
                      <h3 className="mt-1 font-display text-sm font-bold text-text-primary group-hover:text-primary transition-colors line-clamp-2">
                        {rel.title}
                      </h3>
                      <p className="mt-2 text-xs text-text-secondary line-clamp-2">
                        {rel.heroSummary}
                      </p>
                    </div>
                  </Link>
                ))}
              </div>
            </div>
          )}
        </Container>
      </article>
    </PageShell>
  );
}
