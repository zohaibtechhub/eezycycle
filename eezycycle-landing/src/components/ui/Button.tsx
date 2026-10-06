import type { ComponentPropsWithoutRef, ReactNode } from "react";

type Variant = "primary" | "secondary" | "ghost";

type ButtonProps = {
  children: ReactNode;
  variant?: Variant;
  href?: string;
  className?: string;
} & Omit<ComponentPropsWithoutRef<"a">, "href" | "className" | "children"> &
  Omit<ComponentPropsWithoutRef<"button">, "className" | "children">;

const variants: Record<Variant, string> = {
  primary:
    "bg-primary text-white hover:bg-accent shadow-sm shadow-primary/20",
  secondary:
    "bg-surface text-text-primary border border-border hover:bg-primary-light",
  ghost: "bg-transparent text-text-primary hover:bg-primary-light",
};

export function Button({
  children,
  variant = "primary",
  href,
  className = "",
  ...props
}: ButtonProps) {
  const classes = [
    "inline-flex items-center justify-center gap-2 rounded-xl px-5 py-3 text-sm font-semibold tracking-tight transition-transform duration-200 hover:scale-[1.02] focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary",
    variants[variant],
    className,
  ].join(" ");

  if (href) {
    return (
      <a href={href} className={classes} {...(props as ComponentPropsWithoutRef<"a">)}>
        {children}
      </a>
    );
  }

  return (
    <button type="button" className={classes} {...(props as ComponentPropsWithoutRef<"button">)}>
      {children}
    </button>
  );
}
