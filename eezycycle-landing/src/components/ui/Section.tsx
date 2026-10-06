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
    <section id={id} className={`py-20 sm:py-28 ${className}`}>
      <Container className={containerClassName}>{children}</Container>
    </section>
  );
}

export function SectionHeading({
  title,
  support,
  align = "left",
}: {
  title: string;
  support: string;
  align?: "left" | "center";
}) {
  const alignClass = align === "center" ? "mx-auto text-center" : "";
  return (
    <div className={`mb-12 max-w-2xl ${alignClass}`}>
      <h2 className="font-display text-3xl font-semibold tracking-tight text-text-primary sm:text-4xl">
        {title}
      </h2>
      <p className="mt-4 text-base leading-relaxed text-text-secondary sm:text-lg">
        {support}
      </p>
    </div>
  );
}
