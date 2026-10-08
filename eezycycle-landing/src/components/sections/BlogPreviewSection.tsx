import Image from "next/image";
import Link from "next/link";
import { Container } from "@/components/ui/Container";
import { Reveal } from "@/components/ui/Reveal";
import { getFeaturedBlogPosts } from "@/lib/blog";

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

export function BlogPreviewSection() {
  const posts = getFeaturedBlogPosts(3);

  return (
    <section id="articles" className="relative overflow-hidden py-16 sm:py-24 bg-surface">
      {/* Soft background accents */}
      <div
        className="pointer-events-none absolute left-1/2 top-0 -translate-x-1/2 h-72 w-full max-w-7xl opacity-50 blur-3xl"
        style={{
          background:
            "radial-gradient(circle, rgba(232,80,120,0.12) 0%, rgba(253,240,243,0.3) 50%, transparent 80%)",
        }}
        aria-hidden
      />

      <Container className="relative">
        <div className="flex flex-col items-center justify-between gap-4 text-center sm:flex-row sm:text-left mb-10 sm:mb-12">
          <div>
            <div className="inline-flex items-center gap-2 rounded-full border border-primary/25 bg-primary-light px-3.5 py-1 text-xs font-semibold text-primary">
              <span className="flex h-2 w-2 rounded-full bg-primary" />
              Cycle & Health Guides
            </div>
            <h2 className="mt-3 font-display text-2xl font-extrabold tracking-tight text-text-primary sm:text-3xl lg:text-4xl">
              Guides for every{" "}
              <span className="text-primary">phase</span>
            </h2>
            <p className="mt-2 max-w-2xl text-sm leading-relaxed text-text-secondary sm:text-base">
              Period care, fertility timing, pregnancy milestones, and daily wellness — written for real life.
            </p>
          </div>

          <Link
            href="/blog"
            className="inline-flex shrink-0 items-center gap-2 rounded-full border border-primary/30 bg-primary-light px-5 py-2.5 text-xs sm:text-sm font-semibold text-primary transition hover:bg-primary hover:text-white shadow-xs"
          >
            Explore All Guides →
          </Link>
        </div>

        {/* Featured 3 Articles */}
        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {posts.map((post, index) => {
            const phaseStyle =
              PHASE_COLORS[post.phase.toLowerCase()] || PHASE_COLORS.general;

            return (
              <Reveal key={post.id} delayMs={index * 80}>
                <article className="group flex h-full flex-col overflow-hidden rounded-3xl border border-border bg-background transition-all duration-300 hover:-translate-y-1.5 hover:border-primary/40 hover:shadow-xl hover:shadow-primary/10">
                  {/* Card Image */}
                  <Link
                    href={`/blog/${post.slug}`}
                    className="relative aspect-[16/10] w-full overflow-hidden bg-primary-light"
                  >
                    <Image
                      src={post.image}
                      alt={post.imageAlt}
                      fill
                      sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
                      className="object-cover transition-transform duration-500 group-hover:scale-105"
                    />
                    <div className="absolute inset-0 bg-gradient-to-t from-black/55 via-transparent to-transparent opacity-60" />

                    {/* Category pill */}
                    <div className="absolute left-3.5 top-3.5">
                      <span
                        className={`rounded-full border px-2.5 py-1 text-[11px] font-semibold backdrop-blur-md ${phaseStyle.bg} ${phaseStyle.text} ${phaseStyle.border} bg-white/90`}
                      >
                        {post.category}
                      </span>
                    </div>

                    <div className="absolute bottom-3 right-3 rounded-full bg-black/60 px-2.5 py-0.5 text-[10px] font-medium text-white backdrop-blur-xs">
                      {post.readTime}
                    </div>
                  </Link>

                  {/* Card Details */}
                  <div className="flex flex-1 flex-col p-5 sm:p-6">
                    <h3 className="font-display text-lg font-bold leading-snug text-text-primary group-hover:text-primary transition-colors">
                      <Link href={`/blog/${post.slug}`}>
                        {post.title}
                      </Link>
                    </h3>

                    <p className="mt-2.5 flex-1 text-sm leading-relaxed text-text-secondary line-clamp-3">
                      {post.heroSummary}
                    </p>

                    {/* Article Footer */}
                    <div className="mt-5 border-t border-border/70 pt-4 flex items-center justify-between">
                      <span className="text-xs font-medium text-text-secondary">
                        Cycle guide
                      </span>

                      <Link
                        href={`/blog/${post.slug}`}
                        className="inline-flex items-center gap-1 text-xs font-semibold text-primary group-hover:translate-x-1 transition-transform"
                      >
                        <span>Read Article</span>
                        <span>→</span>
                      </Link>
                    </div>
                  </div>
                </article>
              </Reveal>
            );
          })}
        </div>

        {/* Callout */}
        <div className="mt-12 rounded-2xl border border-primary/20 bg-gradient-to-r from-primary-light via-white to-primary-light/40 p-5 text-center sm:text-left sm:flex sm:items-center sm:justify-between">
          <div className="flex items-center gap-3 justify-center sm:justify-start">
            <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-2xl bg-primary text-white text-lg shadow-sm shadow-primary/30">
              💡
            </span>
            <div>
              <p className="font-display text-sm font-bold text-text-primary">
                Have questions about your cycle or symptoms?
              </p>
              <p className="text-xs text-text-secondary">
                Explore guides covering energy shifts, ovulation signs, luteal mood patterns, and early pregnancy weeks.
              </p>
            </div>
          </div>
          <Link
            href="/blog"
            className="mt-4 inline-block sm:mt-0 font-semibold text-xs text-primary underline-offset-4 hover:underline"
          >
            Browse All Guides →
          </Link>
        </div>
      </Container>
    </section>
  );
}
