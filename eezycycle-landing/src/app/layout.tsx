import type { Metadata } from "next";
import {
  faqPageJsonLd,
  organizationJsonLd,
  softwareApplicationJsonLd,
  websiteJsonLd,
} from "@/lib/seo";
import { SITE_NAME, SITE_URL, SUPPORT_EMAIL } from "@/lib/constants";
import "./globals.css";

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: {
    default: "EezyCycle — Period & Ovulation Tracker App | Private, Free & Doctor-Reviewed",
    template: "%s | EezyCycle",
  },
  description:
    "Track your period, predict fertile windows, follow pregnancy week-by-week, and explore doctor-reviewed health articles. 100% private & guest-friendly.",
  keywords: [
    "period tracker",
    "ovulation calculator",
    "fertile window tracker",
    "pregnancy week by week",
    "cycle calendar",
    "doctor reviewed women health",
    "PMS symptom tracker",
    "EezyCycle",
  ],
  authors: [{ name: SITE_NAME }],
  creator: SITE_NAME,
  icons: {
    icon: [
      { url: "/logo.png", type: "image/png", sizes: "500x500" },
      { url: "/app/logo.png", type: "image/png", sizes: "500x500" },
    ],
    apple: [{ url: "/logo.png", type: "image/png" }],
    shortcut: "/logo.png",
  },
  openGraph: {
    type: "website",
    siteName: SITE_NAME,
    title: "EezyCycle — Free Period & Ovulation Tracker App",
    description:
      "Know your cycle with gentle predictions, doctor-reviewed insights, partner support, and privacy-first design.",
    url: SITE_URL,
    images: [
      {
        url: "/logo.png",
        width: 512,
        height: 512,
        alt: "EezyCycle - Period & Ovulation Tracker",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "EezyCycle — Period & Ovulation Tracker",
    description:
      "Period, ovulation, pregnancy & partner support — private by design.",
    images: ["/logo.png"],
  },
  robots: { index: true, follow: true },
  alternates: { canonical: "/" },
  other: {
    "contact:email": SUPPORT_EMAIL,
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const jsonLd = [
    organizationJsonLd(),
    softwareApplicationJsonLd(),
    websiteJsonLd(),
    faqPageJsonLd(),
  ];

  return (
    <html lang="en" className="h-full antialiased">
      <body className="flex min-h-full flex-col bg-background text-text-primary">
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />
        {children}
      </body>
    </html>
  );
}
