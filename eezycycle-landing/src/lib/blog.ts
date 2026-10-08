import rawArticlesData from "@/data/articles.json";

export interface RawArticleSection {
  heading: string;
  body: string;
}

export interface RawArticle {
  id: string;
  title: string;
  description: string;
  category: string;
  category_type: string;
  read_time: string;
  author?: string;
  published_date?: string;
  image?: string;
  image_alt?: string;
  phase?: string;
  phases?: string[];
  hero_summary?: string;
  sections?: RawArticleSection[];
  takeaways?: string[];
}

export interface BlogPost {
  id: string;
  slug: string;
  title: string;
  description: string;
  category: string;
  categoryType: string;
  readTime: string;
  author: string;
  publishedDate: string;
  image: string;
  imageAlt: string;
  phase: string;
  heroSummary: string;
  plainEnglishSummary: string;
  sections: RawArticleSection[];
  takeaways: string[];
  featured?: boolean;
}

function slugify(title: string): string {
  return title
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/(^-|-$)/g, "");
}

function unsplash(id: string, host: "images" | "plus" = "images"): string {
  const base =
    host === "plus"
      ? `https://plus.unsplash.com/${id}`
      : `https://images.unsplash.com/${id}`;
  return `${base}?q=80&w=1200&auto=format&fit=crop`;
}

/** Category photo pools from curated Unsplash picks — rotated per article. */
const CATEGORY_IMAGE_POOLS: Record<string, string[]> = {
  "sex & intimacy": [
    unsplash("photo-1494774157365-9e04c6720e47"),
    unsplash("photo-1650658765299-c1470b7d9945"),
    unsplash("photo-1586324304780-c9a5031a3599"),
    unsplash("photo-1496602910407-bacda74a0fe4"),
    unsplash("premium_photo-1738811593912-a3aff6e0f9ba", "plus"),
    unsplash("photo-1516589178581-6cd7833ae3b2"),
    unsplash("photo-1529156069898-49953e39b3ac"),
    unsplash("photo-1529333166437-7750a6dd5a70"),
    unsplash("photo-1474552226712-ac0f0961a954"),
    unsplash("photo-1511988617509-a57c8a288659"),
    unsplash("photo-1491438590914-bc09fcaaf77a"),
    unsplash("photo-1516589091380-5d8e87df6999"),
  ],
  "energy & hormones": [
    unsplash("premium_photo-1666299841213-8526c1106b0f", "plus"),
    unsplash("premium_photo-1682097534172-2bfa8aa35390", "plus"),
    unsplash("premium_photo-1723489301325-ddd5d91e8ed3", "plus"),
    unsplash("premium_photo-1690579634279-b80423f1bdb2", "plus"),
    unsplash("premium_photo-1661308240023-01db31be661f", "plus"),
  ],
  fertility: [
    unsplash("photo-1647549228195-301269c33265"),
    unsplash("photo-1719012577098-78efd07c5357"),
    unsplash("photo-1493894473891-10fc1e5dbd22"),
    unsplash("photo-1611988615248-5d4f0b9ac31e"),
    unsplash("photo-1648857716800-1203c6079fb3"),
  ],
  "pms & care": [
    unsplash("photo-1668762480571-7257ab88bbc7"),
    unsplash("photo-1712647629699-8d8d6cb21a0d"),
    unsplash("premium_photo-1679430887790-eab45c1f79d2", "plus"),
    unsplash("premium_photo-1723874428655-703b1a82130b", "plus"),
    unsplash("photo-1632639521806-cead484cc369"),
  ],
  "rest & flow": [
    unsplash("photo-1688383454974-1aec959a5163"),
    unsplash("premium_photo-1682096691071-d7d3b967047a", "plus"),
    unsplash("photo-1566423001029-a6d817b725ab"),
    unsplash("photo-1553034710-47f9e03ff808"),
    unsplash("photo-1768416960061-bd92e6304ba3"),
  ],
  pregnancy: [
    unsplash("photo-1541956799312-3f9df99e0006"),
    unsplash("photo-1504629141121-a95007fe9190"),
    unsplash("photo-1580301762395-21ce84d00bc6"),
    unsplash("photo-1456427370572-34441f97a340"),
    unsplash("photo-1687360844749-76cd4043d92d"),
  ],
  fitness: [
    unsplash("photo-1662385930032-d9286e02325f"),
    unsplash("photo-1758274530033-397c9d96b672"),
    unsplash("photo-1546483875-ad9014c88eba"),
    unsplash("photo-1594882645126-14020914d58d"),
    unsplash("photo-1783841193384-4269c68aa050"),
  ],
  nutrition: [
    unsplash("photo-1512621776951-a57141f2eefd"),
    unsplash("photo-1498837167922-ddd27525d352"),
    unsplash("photo-1505252585461-04db1eb84625"),
    unsplash("photo-1546069901-ba9599a7e63c"),
    unsplash("photo-1540420773420-3366772f4999"),
  ],
  sleep: [
    unsplash("premium_photo-1682096691071-d7d3b967047a", "plus"),
    unsplash("photo-1631049307264-da0ec9d70304"),
    unsplash("photo-1522771739844-6a9f6d5f14af"),
  ],
  wellness: [
    unsplash("photo-1566423001029-a6d817b725ab"),
    unsplash("photo-1632639521806-cead484cc369"),
    unsplash("photo-1506126613408-eca07ce68773"),
    unsplash("photo-1441974231531-c6227db76b6e"),
    unsplash("premium_photo-1661308240023-01db31be661f", "plus"),
  ],
};

const FALLBACK_POOL = [
  unsplash("photo-1515377905703-c4788e51af15"),
  unsplash("photo-1474552226712-ac0f0961a954"),
  unsplash("photo-1495615080073-6b89c9839ce0"),
];

const categoryCounters = new Map<string, number>();

function poolForCategory(category: string): string[] {
  const key = category.toLowerCase().trim();
  if (CATEGORY_IMAGE_POOLS[key]) return CATEGORY_IMAGE_POOLS[key];

  for (const [poolKey, urls] of Object.entries(CATEGORY_IMAGE_POOLS)) {
    if (key.includes(poolKey) || poolKey.includes(key)) return urls;
  }
  return FALLBACK_POOL;
}

function resolveArticleImage(raw: RawArticle, index: number): string {
  const pool = poolForCategory(raw.category || "");
  const counterKey = (raw.category || "general").toLowerCase();
  const n = categoryCounters.get(counterKey) ?? 0;
  categoryCounters.set(counterKey, n + 1);
  return pool[n % pool.length] ?? pool[index % pool.length] ?? FALLBACK_POOL[0];
}

function buildSummary(a: RawArticle): string {
  if (a.hero_summary && a.hero_summary.length > 20) return a.hero_summary;
  return a.description;
}

const rawArticles = (rawArticlesData.articles as unknown as RawArticle[]) || [];

export const ALL_BLOG_POSTS: BlogPost[] = rawArticles.map((raw, index) => {
  const slug = slugify(raw.title);
  const summary = buildSummary(raw);
  const image = resolveArticleImage(raw, index);

  return {
    id: raw.id,
    slug,
    title: raw.title,
    description: raw.description,
    category: raw.category,
    categoryType: raw.category_type,
    readTime: raw.read_time,
    author: "EezyCycle Guide",
    publishedDate: "2026-09-15",
    image,
    imageAlt: raw.image_alt || raw.title,
    phase: raw.phase || "general",
    heroSummary: raw.hero_summary || raw.description,
    plainEnglishSummary: summary,
    sections: raw.sections || [],
    takeaways: raw.takeaways || [],
    featured: index === 5 || index === 6 || index === 7 || index === 9,
  };
});

export function getAllBlogPosts(): BlogPost[] {
  return ALL_BLOG_POSTS;
}

export function getFeaturedBlogPosts(limit = 3): BlogPost[] {
  const featured = ALL_BLOG_POSTS.filter((p) => p.featured);
  if (featured.length >= limit) return featured.slice(0, limit);
  return ALL_BLOG_POSTS.slice(0, limit);
}

export function getBlogPostBySlug(slug: string): BlogPost | undefined {
  return ALL_BLOG_POSTS.find((p) => p.slug === slug || p.id === slug);
}

export function getBlogPostsByCategory(category: string): BlogPost[] {
  if (!category || category === "All") return ALL_BLOG_POSTS;
  return ALL_BLOG_POSTS.filter(
    (p) => p.category.toLowerCase() === category.toLowerCase()
  );
}

export function getBlogCategories(): string[] {
  const set = new Set<string>();
  ALL_BLOG_POSTS.forEach((p) => set.add(p.category));
  return ["All", ...Array.from(set)];
}

export function getRelatedBlogPosts(
  currentId: string,
  limit = 3
): BlogPost[] {
  const current = ALL_BLOG_POSTS.find((p) => p.id === currentId);
  if (!current) return ALL_BLOG_POSTS.slice(0, limit);

  const sameCategory = ALL_BLOG_POSTS.filter(
    (p) => p.id !== currentId && p.category === current.category
  );
  if (sameCategory.length >= limit) return sameCategory.slice(0, limit);

  const others = ALL_BLOG_POSTS.filter(
    (p) => p.id !== currentId && p.category !== current.category
  );
  return [...sameCategory, ...others].slice(0, limit);
}
