import type { Metadata } from "next";
import { Geist, Geist_Mono, Outfit } from "next/font/google";
import {
  faqPageJsonLd,
  organizationJsonLd,
  softwareApplicationJsonLd,
  websiteJsonLd,
} from "@/lib/seo";
import { SITE_NAME, SITE_URL, SUPPORT_EMAIL } from "@/lib/constants";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

const outfit = Outfit({
  variable: "--font-outfit",
  subsets: ["latin"],
  weight: ["400", "500", "600", "700"],
});

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: {
    default: "EezyCycle — Period & Ovulation Tracker",
    template: "%s | EezyCycle",
  },
  description:
    "Track your period, estimate ovulation and fertile days, explore pregnancy insights, and stay private. Guest-friendly. Estimates only — not medical advice.",
  keywords: [
    "period tracker",
    "ovulation tracker",
    "fertile window",
    "pregnancy tracker",
    "cycle calendar",
    "EezyCycle",
  ],
  authors: [{ name: SITE_NAME }],
  creator: SITE_NAME,
  icons: {
    icon: [{ url: "/app/logo.png", type: "image/png" }],
    apple: "/app/logo.png",
  },
  openGraph: {
    type: "website",
    siteName: SITE_NAME,
    title: "EezyCycle — Period & Ovulation Tracker",
    description:
      "Know your cycle with gentle predictions, daily insights, partner support, and privacy-first design.",
    url: SITE_URL,
  },
  twitter: {
    card: "summary_large_image",
    title: "EezyCycle — Period & Ovulation Tracker",
    description:
      "Period, ovulation, pregnancy & partner support — private by design.",
  },
  robots: { index: true, follow: true },
  alternates: { canonical: "/" },
  other: {
    "contact:email": SUPPORT_EMAIL,
  },
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  const jsonLd = [
    organizationJsonLd(),
    softwareApplicationJsonLd(),
    websiteJsonLd(),
    faqPageJsonLd(),
  ];

  return (
    <html
      lang="en"
      className={`${geistSans.variable} ${geistMono.variable} ${outfit.variable} h-full antialiased`}
    >
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
