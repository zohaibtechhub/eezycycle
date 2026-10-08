import { SITE_NAME, SITE_URL, SUPPORT_EMAIL } from "./constants";
import { faqItems } from "./copy";
import type { BlogPost } from "./blog";

export function organizationJsonLd() {
  return {
    "@context": "https://schema.org",
    "@type": "Organization",
    name: SITE_NAME,
    url: SITE_URL,
    email: SUPPORT_EMAIL,
    logo: `${SITE_URL}/logo.png`,
    sameAs: [
      "https://twitter.com/eezycycle",
      "https://instagram.com/eezycycle",
    ],
  };
}

export function softwareApplicationJsonLd() {
  return {
    "@context": "https://schema.org",
    "@type": "SoftwareApplication",
    name: SITE_NAME,
    applicationCategory: "HealthApplication",
    operatingSystem: "Android, iOS",
    description:
      "EezyCycle provides gentle period and ovulation tracking, fertile window calculations, week-by-week pregnancy tracking, and doctor-reviewed health insights with guest mode and zero health data sold.",
    offers: {
      "@type": "Offer",
      price: "0",
      priceCurrency: "USD",
    },
    aggregateRating: {
      "@type": "AggregateRating",
      ratingValue: "4.9",
      ratingCount: "1280",
      bestRating: "5",
      worstRating: "1",
    },
    featureList: [
      "Period & cycle flow tracking",
      "Ovulation and fertile window prediction",
      "Pregnancy week by week milestone tracker",
      "Perimenopause symptom and mood tracking",
      "Read-only partner support space",
      "Doctor-reviewed health guides",
      "Guest mode with no account required",
      "100% private with no health data sold",
    ],
  };
}

export function faqPageJsonLd(items = faqItems) {
  return {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: items.map((item) => ({
      "@type": "Question",
      name: item.question,
      acceptedAnswer: {
        "@type": "Answer",
        text: item.answer,
      },
    })),
  };
}

export function websiteJsonLd() {
  return {
    "@context": "https://schema.org",
    "@type": "WebSite",
    name: SITE_NAME,
    url: SITE_URL,
    potentialAction: {
      "@type": "SearchAction",
      target: `${SITE_URL}/blog?q={search_term_string}`,
      "query-input": "required name=search_term_string",
    },
  };
}

export function breadcrumbJsonLd(
  items: { name: string; url: string }[]
) {
  return {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    itemListElement: items.map((item, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: item.name,
      item: item.url.startsWith("http") ? item.url : `${SITE_URL}${item.url}`,
    })),
  };
}

export function blogPostingJsonLd(post: BlogPost) {
  return {
    "@context": "https://schema.org",
    "@type": "BlogPosting",
    headline: post.title,
    description: post.description,
    image: [post.image],
    datePublished: post.publishedDate,
    dateModified: "2026-10-01",
    author: {
      "@type": "Organization",
      name: "EezyCycle Editorial",
      url: `${SITE_URL}/blog`,
    },
    publisher: {
      "@type": "Organization",
      name: SITE_NAME,
      logo: {
        "@type": "ImageObject",
        url: `${SITE_URL}/logo.png`,
      },
    },
    mainEntityOfPage: {
      "@type": "WebPage",
      "@id": `${SITE_URL}/blog/${post.slug}`,
    },
  };
}
