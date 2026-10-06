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
          <div key={item.id}>
            <h3>
              <button
                id={buttonId}
                type="button"
                aria-expanded={isOpen}
                aria-controls={panelId}
                onClick={() => setOpenId(isOpen ? null : item.id)}
                className="flex w-full items-center justify-between gap-4 py-5 text-left focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary"
              >
                <span className="font-display text-base font-semibold text-text-primary sm:text-lg">
                  {item.question}
                </span>
                <span
                  aria-hidden
                  className={`shrink-0 text-primary transition-transform duration-200 ${isOpen ? "rotate-45" : ""}`}
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
              className="pb-5 pr-8 text-sm leading-relaxed text-text-secondary sm:text-base"
            >
              {isOpen ? item.answer : null}
            </div>
          </div>
        );
      })}
    </div>
  );
}
