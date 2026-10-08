"use client";

import { useState, useMemo } from "react";
import Image from "next/image";
import Link from "next/link";
import type { BlogPost } from "@/lib/blog";

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

export function BlogHubClient({
  posts,
  categories,
}: {
  posts: BlogPost[];
  categories: string[];
}) {
  const [selectedCategory, setSelectedCategory] = useState("All");
  const [searchQuery, setSearchQuery] = useState("");

  const filteredPosts = useMemo(() => {
    return posts.filter((post) => {
      const matchesCategory =
        selectedCategory === "All" ||
        post.category.toLowerCase() === selectedCategory.toLowerCase();
      const query = searchQuery.toLowerCase().trim();
      const matchesSearch =
        !query ||
        post.title.toLowerCase().includes(query) ||
        post.description.toLowerCase().includes(query) ||
        post.category.toLowerCase().includes(query);
      return matchesCategory && matchesSearch;
    });
  }, [posts, selectedCategory, searchQuery]);

  return (
    <div>
      {/* Search and Category Filter Controls */}
      <div className="mb-8 flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
        {/* Category Pills */}
        <div className="flex flex-wrap items-center gap-1.5 sm:gap-2">
          {categories.map((cat) => {
            const active = selectedCategory.toLowerCase() === cat.toLowerCase();
            return (
              <button
                key={cat}
                type="button"
                onClick={() => setSelectedCategory(cat)}
                className={`rounded-full px-4 py-2 text-xs sm:text-sm font-semibold transition-all duration-200 cursor-pointer ${
                  active
                    ? "bg-primary text-white shadow-md shadow-primary/25 scale-[1.02]"
                    : "border border-border bg-surface text-text-secondary hover:border-primary/40 hover:text-text-primary hover:bg-primary-light/30"
                }`}
              >
                {cat}
              </button>
            );
          })}
        </div>

        {/* Search Bar */}
        <div className="relative min-w-[260px] sm:min-w-[300px]">
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search topics, symptoms, phases..."
            className="w-full rounded-full border border-border bg-surface py-2.5 pl-10 pr-4 text-xs sm:text-sm text-text-primary placeholder:text-text-secondary/70 focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/20 shadow-xs"
          />
          <svg
            className="absolute left-3.5 top-3 h-4 w-4 text-text-secondary/60"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
            strokeWidth="2"
            aria-hidden="true"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
            />
          </svg>
          {searchQuery && (
            <button
              type="button"
              onClick={() => setSearchQuery("")}
              className="absolute right-3.5 top-2.5 text-xs text-text-secondary hover:text-text-primary"
            >
              Clear
            </button>
          )}
        </div>
      </div>

      {/* Result Count */}
      <div className="mb-6 flex items-center justify-between text-xs text-text-secondary">
        <p>
          Showing <span className="font-semibold text-text-primary">{filteredPosts.length}</span>{" "}
          articles {selectedCategory !== "All" && `in ${selectedCategory}`}
        </p>
      </div>

      {/* Article Cards Grid */}
      {filteredPosts.length === 0 ? (
        <div className="rounded-3xl border border-dashed border-border bg-surface p-12 text-center">
          <p className="font-display text-lg font-semibold text-text-primary">
            No articles found matching &ldquo;{searchQuery}&rdquo;
          </p>
          <p className="mt-1 text-sm text-text-secondary">
            Try checking for spelling or choose another category above.
          </p>
          <button
            type="button"
            onClick={() => {
              setSearchQuery("");
              setSelectedCategory("All");
            }}
            className="mt-4 rounded-full bg-primary px-5 py-2 text-xs font-semibold text-white shadow-sm hover:bg-accent cursor-pointer"
          >
            Reset Filters
          </button>
        </div>
      ) : (
        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {filteredPosts.map((post) => {
            const phaseStyle =
              PHASE_COLORS[post.phase.toLowerCase()] || PHASE_COLORS.general;

            return (
              <article
                key={post.id}
                className="group flex flex-col overflow-hidden rounded-3xl border border-border bg-surface transition-all duration-300 hover:-translate-y-1 hover:border-primary/40 hover:shadow-xl hover:shadow-primary/10"
              >
                {/* Cover Image */}
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
                  <div className="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent opacity-60" />
                  
                  {/* Category Pill Over Image */}
                  <div className="absolute left-3.5 top-3.5 flex items-center gap-2">
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

                {/* Content */}
                <div className="flex flex-1 flex-col p-5 sm:p-6">
                  <h3 className="font-display text-lg font-bold leading-snug text-text-primary group-hover:text-primary transition-colors">
                    <Link href={`/blog/${post.slug}`}>
                      {post.title}
                    </Link>
                  </h3>

                  <p className="mt-2.5 flex-1 text-sm leading-relaxed text-text-secondary line-clamp-3">
                    {post.heroSummary}
                  </p>

                  {/* Article Card Footer */}
                  <div className="mt-5 border-t border-border/80 pt-4 flex items-center justify-between">
                    <span className="text-xs text-text-secondary">
                      {post.readTime}
                    </span>

                    <Link
                      href={`/blog/${post.slug}`}
                      className="inline-flex items-center gap-1 text-xs font-semibold text-primary group-hover:translate-x-1 transition-transform"
                    >
                      <span>Read Guide</span>
                      <span>→</span>
                    </Link>
                  </div>
                </div>
              </article>
            );
          })}
        </div>
      )}
    </div>
  );
}
