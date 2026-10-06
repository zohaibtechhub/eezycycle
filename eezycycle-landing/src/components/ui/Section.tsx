import type { ReactNode } from "react";
import { Container } from "./Container";

export function Section({
  id,
  children,
  className = "",
  containerClassName = "",
}: {
  id?: string;
  children: ReactNode;
  className?: string;
  containerClassName?: string;
}) {
  return (
    <section id={id} className={`py-12 sm:py-16 md:py-20 lg:py-24 ${className}`}>
      <Container className={containerClassName}>{children}</Container>
    </section>
  );
}

export function SectionHeading({
  title,
  support,
  align = "left",
  className = "",
}: {
  title: string;
  support: string;
  align?: "left" | "center";
  className?: string;
}) {
  const alignClass = align === "center" ? "mx-auto text-center" : "";
  return (
    <div className={`mb-8 max-w-2xl sm:mb-10 md:mb-12 ${alignClass} ${className}`}>
      <h2 className="font-display text-2xl font-semibold tracking-tight text-text-primary sm:text-3xl md:text-4xl">
        {title}
      </h2>
      <p className="mt-3 text-sm leading-relaxed text-text-secondary sm:mt-4 sm:text-base md:text-lg">
        {support}
      </p>
    </div>
  );
}
