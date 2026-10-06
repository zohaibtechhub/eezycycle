import type { ReactNode } from "react";
import { Footer } from "@/components/sections/Footer";
import { Nav } from "@/components/sections/Nav";

export function PageShell({ children }: { children: ReactNode }) {
  return (
    <>
      <Nav />
      <main className="flex-1">{children}</main>
      <Footer />
    </>
  );
}
