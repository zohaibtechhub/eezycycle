"use client";

import { useState, useMemo } from "react";
import Link from "next/link";
import { Accordion } from "@/components/ui/Accordion";
import { Reveal } from "@/components/ui/Reveal";
import { Section } from "@/components/ui/Section";
import { faqItems } from "@/lib/copy";

type FaqCategory = {
  id: string;
  label: string;
  itemIds: string[];
};

const CATEGORIES: FaqCategory[] = [
  {
    id: "popular",
    label: "🔥 Top Questions",
    itemIds: ["accuracy", "account", "modes", "privacy", "partner", "medical"],
  },
  {
    id: "cycle",
    label: "🌸 Cycle & Predictions",
    itemIds: [
      "accuracy",
      "fertile-window",
      "irregular",
      "log-period-prompt",
      "predictions-change",
      "luteal",
    ],
  },
  {
    id: "privacy",
    label: "🔒 Privacy & Guest Mode",
    itemIds: [
      "account",
      "privacy",
      "privacy-secure",
      "privacy-partner-symptoms",
      "guest-end",
    ],
  },
  {
    id: "partner",
    label: "👥 Partner & Community",
    itemIds: [
      "partner",
      "partner-sees",
      "partner-code",
      "secret-chat",
      "secret-anonymous",
    ],
  },
  {
    id: "modes",
    label: "🤰 Pregnancy & Modes",
    itemIds: ["modes", "pregnancy-mode", "lh-tests", "patterns", "graphs"],
  },
];

export function HomeFaq() {
  const [activeCategory, setActiveCategory] = useState("popular");

  const displayedItems = useMemo(() => {
    const cat = CATEGORIES.find((c) => c.id === activeCategory);
    if (!cat) return faqItems.slice(0, 6);
    return faqItems.filter((item) => cat.itemIds.includes(item.id));
  }, [activeCategory]);

  return (
    <Section id="faq-home" className="bg-background relative overflow-hidden">
      {/* Background glow */}
      <div
        className="pointer-events-none absolute -right-20 top-1/3 h-80 w-80 rounded-full bg-primary/10 blur-3xl"
        aria-hidden
      />

      <Reveal>
        <div className="mx-auto max-w-3xl text-center">
          <span className="inline-flex items-center gap-1.5 rounded-full border border-primary/25 bg-primary-light px-3.5 py-1 text-xs font-semibold text-primary">
            💬 Got Questions? We Have Answers.
          </span>
          <h2 className="mt-4 font-display text-3xl font-extrabold tracking-tight text-text-primary sm:text-4xl">
            Frequently Asked Questions
          </h2>
          <p className="mt-3 text-sm leading-relaxed text-text-secondary sm:text-base">
            Everything you need to know about EezyCycle predictions, guest mode, privacy protection, and partner sharing.
          </p>

          {/* Interactive Category Selector Pills */}
          <div className="mt-8 flex flex-wrap items-center justify-center gap-2">
            {CATEGORIES.map((cat) => {
              const active = activeCategory === cat.id;
              return (
                <button
                  key={cat.id}
                  type="button"
                  onClick={() => setActiveCategory(cat.id)}
                  className={`rounded-full px-4 py-2 text-xs sm:text-sm font-semibold transition-all duration-200 cursor-pointer ${
                    active
                      ? "bg-primary text-white shadow-md shadow-primary/25 scale-[1.02]"
                      : "border border-border bg-surface text-text-secondary hover:border-primary/40 hover:text-text-primary hover:bg-primary-light/30"
                  }`}
                >
                  {cat.label}
                </button>
              );
            })}
          </div>
        </div>

        {/* Accordion Component */}
        <div className="mx-auto mt-10 max-w-3xl">
          <Accordion items={displayedItems} />

          {/* More Questions Footer Bar */}
          <div className="mt-8 rounded-2xl border border-primary/15 bg-surface/80 p-5 text-center shadow-xs">
            <p className="text-sm text-text-secondary">
              Looking for something specific? We have 35+ in-depth answers.{" "}
              <Link
                href="/faq"
                className="font-bold text-primary underline-offset-4 hover:underline"
              >
                Browse the complete FAQ knowledge base →
              </Link>
            </p>
          </div>
        </div>
      </Reveal>
    </Section>
  );
}
