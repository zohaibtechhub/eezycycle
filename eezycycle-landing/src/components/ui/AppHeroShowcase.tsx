"use client";

import { useState } from "react";

type ModeKey = "cycle" | "conception" | "pregnancy" | "partner";

export function AppHeroShowcase() {
  const [activeMode, setActiveMode] = useState<ModeKey>("cycle");

  return (
    <div className="relative mx-auto w-full max-w-sm sm:max-w-md lg:max-w-lg">
      {/* Ambient gradient glow behind the phone */}
      <div
        className="pointer-events-none absolute -inset-6 rounded-full opacity-60 blur-3xl animate-gradient-drift"
        style={{
          background:
            "radial-gradient(circle, rgba(232,80,120,0.3) 0%, rgba(240,114,147,0.2) 40%, rgba(253,240,243,0.5) 70%, transparent 100%)",
        }}
        aria-hidden
      />

      {/* Floating Trust Badge 1 (Top Left) */}
      <div className="hidden sm:flex absolute -top-4 -left-6 z-30 items-center gap-2 rounded-full border border-primary/20 bg-white/95 px-3.5 py-1.5 shadow-lg shadow-primary/10 backdrop-blur-md">
        <span className="flex h-2 w-2 rounded-full bg-emerald-500 animate-pulse" />
        <span className="text-xs font-bold text-text-primary">100% Private · Guest Mode</span>
      </div>

      {/* Floating Trust Badge 2 (Bottom Right) */}
      <div className="hidden sm:flex absolute -bottom-5 -right-4 z-30 items-center gap-2 rounded-2xl border border-primary/20 bg-white/95 px-3.5 py-2 shadow-lg shadow-primary/10 backdrop-blur-md">
        <span className="flex h-7 w-7 items-center justify-center rounded-xl bg-primary-light text-primary text-sm font-bold">
          🌸
        </span>
        <div className="text-left">
          <p className="text-[11px] font-bold text-text-primary">Accurate Estimates</p>
          <p className="text-[10px] text-text-secondary">Learns from your history</p>
        </div>
      </div>

      {/* Interactive Mode Tabs above phone */}
      <div className="mb-4 flex items-center justify-center gap-1.5 rounded-full border border-border bg-white/80 p-1 shadow-xs backdrop-blur-md">
        <button
          type="button"
          onClick={() => setActiveMode("cycle")}
          className={`rounded-full px-3 py-1 text-xs font-semibold transition-all cursor-pointer ${
            activeMode === "cycle"
              ? "bg-primary text-white shadow-xs"
              : "text-text-secondary hover:text-text-primary"
          }`}
        >
          🌸 Track Cycle
        </button>
        <button
          type="button"
          onClick={() => setActiveMode("conception")}
          className={`rounded-full px-3 py-1 text-xs font-semibold transition-all cursor-pointer ${
            activeMode === "conception"
              ? "bg-ovulation text-white shadow-xs"
              : "text-text-secondary hover:text-text-primary"
          }`}
        >
          🎯 Conceive
        </button>
        <button
          type="button"
          onClick={() => setActiveMode("pregnancy")}
          className={`rounded-full px-3 py-1 text-xs font-semibold transition-all cursor-pointer ${
            activeMode === "pregnancy"
              ? "bg-pregnancy text-white shadow-xs"
              : "text-text-secondary hover:text-text-primary"
          }`}
        >
          🤰 Pregnancy
        </button>
        <button
          type="button"
          onClick={() => setActiveMode("partner")}
          className={`rounded-full px-3 py-1 text-xs font-semibold transition-all cursor-pointer ${
            activeMode === "partner"
              ? "bg-fertility text-white shadow-xs"
              : "text-text-secondary hover:text-text-primary"
          }`}
        >
          🤝 Partner
        </button>
      </div>

      {/* Phone Mockup Frame */}
      <div className="relative mx-auto overflow-hidden rounded-[2.5rem] border-[8px] border-text-primary/90 bg-background shadow-[0_25px_60px_-15px_rgba(232,80,120,0.35)] transition-all duration-300">
        {/* Phone Notch */}
        <div className="absolute inset-x-0 top-0 z-30 flex justify-center pt-2">
          <div className="h-4 w-28 rounded-full bg-text-primary/90" />
        </div>

        {/* Screen Header */}
        <div className="pt-8 px-4 pb-2 flex items-center justify-between border-b border-border/60 bg-white/60">
          <div className="flex items-center gap-1.5">
            <div className="h-6 w-6 rounded-lg bg-primary/10 flex items-center justify-center text-xs font-bold text-primary">
              EC
            </div>
            <span className="font-display text-xs font-bold text-text-primary">
              EezyCycle
            </span>
          </div>
          <span className="rounded-full bg-primary-light px-2.5 py-0.5 text-[10px] font-bold text-primary">
            {activeMode === "cycle" && "Cycle Day 9"}
            {activeMode === "conception" && "Fertile Day 13"}
            {activeMode === "pregnancy" && "Week 12 · Day 3"}
            {activeMode === "partner" && "Partner View"}
          </span>
        </div>

        {/* Dynamic Mode Screens */}
        <div className="p-4 sm:p-5">
          {activeMode === "cycle" && (
            <div className="space-y-4">
              {/* Date Strip */}
              <div className="flex items-center justify-between gap-1 overflow-hidden rounded-2xl bg-white p-2.5 shadow-xs border border-border/80">
                {[
                  { d: "M", n: "5", t: "period" },
                  { d: "T", n: "6", t: "period" },
                  { d: "W", n: "7", t: "neutral" },
                  { d: "T", n: "8", t: "neutral" },
                  { d: "F", n: "9", t: "today" },
                  { d: "S", n: "10", t: "neutral" },
                  { d: "S", n: "11", t: "fertile" },
                ].map((item, i) => (
                  <div key={i} className="flex flex-col items-center">
                    <span className="text-[9px] font-bold text-text-secondary">{item.d}</span>
                    <span
                      className={`mt-1 flex h-7 w-7 items-center justify-center rounded-full text-[10px] font-bold ${
                        item.t === "period"
                          ? "bg-period text-white"
                          : item.t === "today"
                          ? "bg-primary text-white ring-2 ring-primary/40 ring-offset-1"
                          : item.t === "fertile"
                          ? "bg-fertility/20 text-fertility"
                          : "text-text-primary"
                      }`}
                    >
                      {item.n}
                    </span>
                  </div>
                ))}
              </div>

              {/* Cycle Dial Card */}
              <div className="relative overflow-hidden rounded-3xl border border-primary/20 bg-gradient-to-b from-primary-light via-white to-primary-light/30 p-5 text-center shadow-xs">
                <div className="mx-auto flex h-36 w-36 items-center justify-center rounded-full border-4 border-dashed border-primary/30 bg-white shadow-inner">
                  <div className="flex flex-col items-center">
                    <span className="text-[10px] font-bold uppercase tracking-wider text-primary">
                      Follicular Phase
                    </span>
                    <span className="font-display text-2xl font-black text-text-primary">
                      Day 9
                    </span>
                    <span className="text-[10px] text-text-secondary">
                      Medium conception
                    </span>
                  </div>
                </div>

                <div className="mt-4 flex items-center justify-center gap-2">
                  <button
                    type="button"
                    className="rounded-full bg-primary px-3 py-1.5 text-[11px] font-semibold text-white shadow-xs"
                  >
                    + Log Period
                  </button>
                  <button
                    type="button"
                    className="rounded-full border border-border bg-white px-3 py-1.5 text-[11px] font-semibold text-text-primary shadow-xs"
                  >
                    + Symptoms
                  </button>
                </div>
              </div>

              {/* Daily Insight Card */}
              <div className="rounded-2xl border border-primary/15 bg-white p-3 shadow-xs">
                <div className="flex items-center gap-2">
                  <span className="flex h-5 w-5 items-center justify-center rounded-full bg-primary-light text-primary text-xs">
                    💡
                  </span>
                  <p className="text-[11px] font-bold text-text-primary">
                    Daily Cycle Note
                  </p>
                </div>
                <p className="mt-1 text-[11px] leading-relaxed text-text-secondary">
                  Estrogen is rising. Expect higher physical energy and clearer focus today.
                </p>
              </div>
            </div>
          )}

          {activeMode === "conception" && (
            <div className="space-y-4">
              <div className="rounded-3xl border border-ovulation/30 bg-gradient-to-b from-amber-50 via-white to-amber-50/40 p-5 text-center shadow-xs">
                <div className="mx-auto flex h-36 w-36 items-center justify-center rounded-full border-4 border-ovulation bg-white shadow-inner">
                  <div className="flex flex-col items-center">
                    <span className="text-[10px] font-bold uppercase tracking-wider text-ovulation">
                      Fertile Window
                    </span>
                    <span className="font-display text-2xl font-black text-text-primary">
                      Peak Chance
                    </span>
                    <span className="text-[10px] text-text-secondary">
                      Ovulation in ~24h
                    </span>
                  </div>
                </div>
                <p className="mt-4 text-xs font-semibold text-text-primary">
                  Optimal timing for conception
                </p>
                <div className="mt-3 flex justify-center gap-2">
                  <span className="rounded-full bg-ovulation px-3 py-1 text-[10px] font-bold text-white">
                    + Log LH Test
                  </span>
                  <span className="rounded-full border border-ovulation/30 bg-white px-3 py-1 text-[10px] font-semibold text-text-primary">
                    + Cervical Fluid
                  </span>
                </div>
              </div>

              <div className="rounded-2xl border border-border bg-white p-3 shadow-xs">
                <p className="text-[11px] font-bold text-ovulation">
                  💡 Fertile Window Fact:
                </p>
                <p className="mt-0.5 text-[11px] text-text-secondary">
                  Sperm can survive up to 5 days. Intercourse leading up to ovulation offers the highest chances.
                </p>
              </div>
            </div>
          )}

          {activeMode === "pregnancy" && (
            <div className="space-y-4">
              <div className="rounded-3xl border border-pregnancy/30 bg-gradient-to-b from-emerald-50 via-white to-emerald-50/40 p-5 text-center shadow-xs">
                <div className="mx-auto flex h-36 w-36 items-center justify-center rounded-full border-4 border-pregnancy bg-white shadow-inner">
                  <div className="flex flex-col items-center">
                    <span className="text-[10px] font-bold uppercase tracking-wider text-pregnancy">
                      Week 12 · Day 3
                    </span>
                    <span className="font-display text-2xl font-black text-text-primary">
                      Lime Size
                    </span>
                    <span className="text-[10px] text-text-secondary">
                      Trimester 1 Ending
                    </span>
                  </div>
                </div>
                <p className="mt-4 text-xs font-semibold text-text-primary">
                  Baby&apos;s tiny fingers and toes are fully formed
                </p>
                <div className="mt-3 flex justify-center gap-2">
                  <span className="rounded-full bg-pregnancy px-3 py-1 text-[10px] font-bold text-white">
                    Week 12 Guide
                  </span>
                  <span className="rounded-full border border-pregnancy/30 bg-white px-3 py-1 text-[10px] font-semibold text-text-primary">
                    Kick Counter
                  </span>
                </div>
              </div>

              <div className="rounded-2xl border border-border bg-white p-3 shadow-xs">
                <p className="text-[11px] font-bold text-pregnancy">
                  💡 Tip for Week 12:
                </p>
                <p className="mt-0.5 text-[11px] text-text-secondary">
                  Morning sickness often begins easing as hormone levels stabilize.
                </p>
              </div>
            </div>
          )}

          {activeMode === "partner" && (
            <div className="space-y-4">
              <div className="rounded-3xl border border-fertility/30 bg-gradient-to-b from-purple-50 via-white to-purple-50/40 p-5 text-center shadow-xs">
                <div className="mx-auto flex h-36 w-36 items-center justify-center rounded-full border-4 border-fertility bg-white shadow-inner">
                  <div className="flex flex-col items-center">
                    <span className="text-[10px] font-bold uppercase tracking-wider text-fertility">
                      Partner Space
                    </span>
                    <span className="font-display text-xl font-black text-text-primary">
                      Follicular
                    </span>
                    <span className="text-[10px] text-text-secondary">
                      High energy phase
                    </span>
                  </div>
                </div>
                <p className="mt-4 text-xs font-semibold text-text-primary">
                  Read-only cycle calendar connection
                </p>
                <p className="mt-1 text-[10px] text-text-secondary">
                  Private symptoms & notes remain 100% private.
                </p>
              </div>

              <div className="rounded-2xl border border-border bg-white p-3 shadow-xs">
                <p className="text-[11px] font-bold text-fertility">
                  🤝 How to Support Today:
                </p>
                <p className="mt-0.5 text-[11px] text-text-secondary">
                  Great day to plan social outings or shared activities together.
                </p>
              </div>
            </div>
          )}
        </div>

        {/* Bottom App Bar Navigation */}
        <div className="flex items-center justify-around border-t border-border bg-white py-2.5 px-3">
          <span className="text-[10px] font-bold text-primary">● Today</span>
          <span className="text-[10px] font-medium text-text-secondary">Calendar</span>
          <span className="text-[10px] font-medium text-text-secondary">Insights</span>
          <span className="text-[10px] font-medium text-text-secondary">You</span>
        </div>
      </div>
    </div>
  );
}
