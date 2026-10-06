import type { Metadata } from "next";
import type { ReactNode } from "react";
import Link from "next/link";
import { Container } from "@/components/ui/Container";
import { PageShell } from "@/components/ui/PageShell";
import { SUPPORT_EMAIL } from "@/lib/constants";

export const metadata: Metadata = {
  title: "Privacy Policy",
  description:
    "How EezyCycle collects, uses, stores, and shares information. We do not sell reproductive health data.",
  alternates: { canonical: "/privacy" },
};

function H2({ children }: { children: ReactNode }) {
  return (
    <h2 className="mt-10 font-display text-xl font-semibold text-text-primary">
      {children}
    </h2>
  );
}

function P({ children }: { children: ReactNode }) {
  return (
    <p className="mt-3 text-sm leading-relaxed text-text-secondary sm:text-base">
      {children}
    </p>
  );
}

export default function PrivacyPage() {
  return (
    <PageShell>
      <section className="bg-background pt-28 pb-16">
        <Container className="max-w-3xl">
          <p className="text-sm font-medium text-text-secondary">
            <Link href="/" className="hover:text-primary">
              Home
            </Link>{" "}
            / Privacy
          </p>
          <h1 className="mt-4 font-display text-4xl font-semibold tracking-tight text-text-primary">
            Privacy Policy
          </h1>
          <p className="mt-2 text-sm text-text-secondary">
            Last updated: October 1, 2026
          </p>

          <P>
            This Privacy Policy explains how <strong>EezyCycle</strong> (“we”,
            “us”, or “our”) collects, uses, stores, and shares information when
            you use the EezyCycle mobile application and related services (the
            “App”).
          </P>
          <P>
            EezyCycle is a personal wellness tool for period tracking, ovulation
            and fertility estimates, pregnancy-mode insights, education, and
            optional partner or community features. It is <strong>not</strong> a
            medical device and does <strong>not</strong> diagnose, treat, or
            prevent disease. Predictions are estimates. Always consult a
            qualified healthcare professional for medical decisions.
          </P>
          <P>
            For privacy requests, contact:{" "}
            <a
              href={`mailto:${SUPPORT_EMAIL}`}
              className="font-medium text-primary hover:underline"
            >
              {SUPPORT_EMAIL}
            </a>
          </P>

          <H2>1. Who we are</H2>
          <P>
            EezyCycle provides reproductive and cycle-related tracking and
            educational content. This policy applies to guest users and
            registered accounts. If you do not agree with this policy, do not
            use the App or provide health information.
          </P>

          <H2>2. Information we collect</H2>
          <P>
            We collect only what is needed to run App features you choose to
            use: account and profile details, health and fitness logs you enter
            (periods, symptoms, pregnancy mode, goals), community content you
            post, and device/push identifiers for delivery and security.
          </P>
          <P>
            We do <strong>not</strong> sell your personal or reproductive health
            data to advertisers.
          </P>

          <H2>3. Why we use your information</H2>
          <P>
            We use information for App functionality (calendar, predictions,
            reminders), personalization, account management, optional partner
            features, community publishing you choose, notifications, and
            security. We do not use your health information for third-party
            advertising.
          </P>

          <H2>4. Guest vs registered account</H2>
          <P>
            Guest users can use core tracking with a device-linked session after
            accepting this policy. Registered accounts (email/password or Google
            Sign-In) support recovery, partner linking, and sync across devices.
            Consent is required before health features sync to our servers.
          </P>

          <H2>5. Partner sharing (opt-in)</H2>
          <P>
            Partner linking is optional. A linked partner may see high-level
            cycle phase and predicted fertile/period days, limited profile
            information you choose to share, and relationship tips. They cannot
            see sex logs, detailed symptoms, test results, or private notes. You
            can disconnect anytime in the App.
          </P>

          <H2>6. Secret Chat (community)</H2>
          <P>
            Secret Chat is a community surface. Posts, comments, and images you
            publish can be seen by other App users. Do not post information you
            are not comfortable sharing within the App.
          </P>

          <H2>7. Third parties and service providers</H2>
          <P>
            We use processors that help operate the App (hosting/database,
            Google Sign-In, email, OneSignal / FCM / APNs, device OS services).
            They are not authorized to sell your health data.
          </P>

          <H2>8. Encryption and security</H2>
          <P>
            Data in transit uses HTTPS / TLS. Passwords are stored as secure
            hashes. Health and account records sit on secured servers with
            access controls. No method of transmission or storage is 100%
            secure.
          </P>

          <H2>9. Retention</H2>
          <P>
            We keep your information while your guest session or account is
            active and as needed to provide the App. Inactive guests may be
            deleted after prolonged inactivity. Backups may persist briefly
            after deletion.
          </P>

          <H2>10. Your choices: access, export, and deletion</H2>
          <P>
            Subject to applicable law, you may access or correct logs in the
            App, export data where available, delete your account via in-App
            controls or by emailing {SUPPORT_EMAIL}, revoke partner sharing and
            notification preferences, and withdraw consent by deleting data and
            stopping use.
          </P>

          <H2>11. Children’s privacy</H2>
          <P>
            EezyCycle is intended for users who meet the age requirements shown
            in the App. We do not knowingly collect reproductive health data from
            children below the age we allow.
          </P>

          <H2>12. International users and privacy rights</H2>
          <P>
            If you are in the EEA, UK, or a similar jurisdiction, you may have
            rights to access, rectify, erase, restrict, or port your personal
            data, and to object to certain processing. Legal bases may include
            consent, contract, and legitimate interests.
          </P>

          <H2>13. Medical and wellness disclaimer</H2>
          <P>
            EezyCycle is for personal wellness tracking and education. It is not
            a certified contraceptive method, diagnostic tool, or substitute for
            professional care. Cycle and pregnancy-related estimates can be
            inaccurate.
          </P>

          <H2>14. Changes to this policy</H2>
          <P>
            We may update this Privacy Policy from time to time. We will revise
            the “Last updated” date and, when changes are material, provide
            notice in the App or by other reasonable means.
          </P>

          <H2>15. Contact</H2>
          <P>
            Privacy / data requests:{" "}
            <a
              href={`mailto:${SUPPORT_EMAIL}`}
              className="font-medium text-primary hover:underline"
            >
              {SUPPORT_EMAIL}
            </a>
          </P>
        </Container>
      </section>
    </PageShell>
  );
}
