import type { MetadataRoute } from "next";
import { FEATURES, SITE_URL } from "@/lib/constants";

export default function sitemap(): MetadataRoute.Sitemap {
  const staticRoutes = [
    "",
    "/download",
    "/features",
    "/how-it-works",
    "/faq",
    "/privacy",
  ];

  const featureRoutes = FEATURES.map((f) => f.href);

  return [...staticRoutes, ...featureRoutes].map((route) => ({
    url: `${SITE_URL}${route}`,
    lastModified: new Date(),
    changeFrequency: route === "" || route === "/download" ? "weekly" : "monthly",
    priority:
      route === "" ? 1 : route === "/download" ? 0.95 : route.startsWith("/features") ? 0.8 : 0.7,
  }));
}
