"use client";

import { useId, useState } from "react";

export type AccordionItem = {
  id: string;
  question: string;
  answer: string;
};

export function Accordion({ items }: { items: readonly AccordionItem[] }) {
  const [openId, setOpenId] = useState<string | null>(items[0]?.id ?? null);
  const baseId = useId();

  return (
    <div className="divide-y divide-border border-y border-border">
      {items.map((item) => {
        const isOpen = openId === item.id;
        const panelId = `${baseId}-${item.id}-panel`;
        const buttonId = `${baseId}-${item.id}-button`;

        return (
          <div key={item.id} className="min-w-0">
            <h3>
              <button
                id={buttonId}
                type="button"
                aria-expanded={isOpen}
                aria-controls={panelId}
                onClick={() => setOpenId(isOpen ? null : item.id)}
                className="flex w-full items-start justify-between gap-3 py-4 text-left focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary sm:gap-4 sm:py-5"
              >
                <span className="min-w-0 flex-1 font-display text-sm font-semibold leading-snug text-text-primary sm:text-base md:text-lg">
                  {item.question}
                </span>
                <span
                  aria-hidden
                  className={`mt-0.5 shrink-0 text-lg leading-none text-primary transition-transform duration-200 ${isOpen ? "rotate-45" : ""}`}
                >
                  +
                </span>
              </button>
            </h3>
            <div
              id={panelId}
              role="region"
              aria-labelledby={buttonId}
              hidden={!isOpen}
              className="pb-4 pr-2 text-sm leading-relaxed text-text-secondary sm:pb-5 sm:pr-8 sm:text-base"
            >
              {isOpen ? item.answer : null}
            </div>
          </div>
        );
      })}
    </div>
  );
}
