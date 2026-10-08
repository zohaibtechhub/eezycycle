import type { MetadataRoute } from "next";
import { FEATURES, SITE_URL } from "@/lib/constants";
import { getAllBlogPosts } from "@/lib/blog";

export const dynamic = "force-static";

export default function sitemap(): MetadataRoute.Sitemap {
  const staticRoutes = [
    "",
    "/download",
    "/features",
    "/how-it-works",
    "/faq",
    "/privacy",
    "/blog",
  ];

  const featureRoutes = FEATURES.map((f) => f.href);
  const blogRoutes = getAllBlogPosts().map((p) => `/blog/${p.slug}`);

  const allRoutes = [...staticRoutes, ...featureRoutes, ...blogRoutes];

  return allRoutes.map((route) => {
    let priority = 0.7;
    let changeFrequency: MetadataRoute.Sitemap[number]["changeFrequency"] = "monthly";

    if (route === "") {
      priority = 1.0;
      changeFrequency = "weekly";
    } else if (route === "/download") {
      priority = 0.95;
      changeFrequency = "weekly";
    } else if (route === "/blog") {
      priority = 0.9;
      changeFrequency = "weekly";
    } else if (route.startsWith("/blog/")) {
      priority = 0.85;
      changeFrequency = "monthly";
    } else if (route.startsWith("/features")) {
      priority = 0.8;
      changeFrequency = "monthly";
    }

    return {
      url: `${SITE_URL}${route}`,
      lastModified: new Date("2026-10-08"),
      changeFrequency,
      priority,
    };
  });
}
