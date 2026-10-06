# EezyCycle Landing Page Guide

Build guide for the promotional site in `eezycycle-landing/` (Next.js).  
Align branding with the Flutter app (`AppColors`) and tokens in `src/app/globals.css`.  
Predictions are **estimates only** — never claim medical diagnosis, contraception, or guaranteed fertility.

---

## 1. Product snapshot (source of truth)

| Item | Value |
|------|--------|
| **Brand** | EezyCycle |
| **Tagline direction** | Know your cycle. Feel ready for what’s next. |
| **What it is** | Period, ovulation & fertility estimates · pregnancy-mode insights · partner support · private community · education |
| **What it is not** | Medical device · contraception · diagnosis · guaranteed ovulation/due date |
| **Privacy contact** | info@eezycycle.com |
| **Stack** | Flutter app · Node.js + MySQL API · Next.js landing |

### Experience modes (from the app)

1. **Track cycle** — period & ovulation awareness, symptoms, daily insights  
2. **Get pregnant** — fertile-window timing, conception education  
3. **Track pregnancy** — week/day insights, due-date support, pregnancy mode  
4. **Track perimenopause** — transition symptoms, cycle changes, trusted tips  

### Supporting pillars

- **Partner Space** — invite via code; read-only cycle calendar & support tips  
- **Secret Chat** — anonymous community posts & comments  
- **Articles & insights** — phase-aware education (cycle, fertility, pregnancy, intimacy, wellness)  
- **Graphs & reports** — cycle / ovulation history  
- **Guest-first** — use core tracking without an account; upgrade to keep data across devices  
- **Privacy** — no selling health data; encryption; delete anytime  

### Prediction engine (marketing-safe language)

Backend engine: `ecc_prediction_v4_1`. For the landing page, say:

> Predictions improve as you log cycles. We estimate period timing, ovulation, and fertile windows from your history — always estimates, never a medical guarantee.

Do **not** expose internal engine IDs, Flo comparisons, or “confirmed ovulation” wording on marketing pages.

---

## 2. Color system (mandatory)

Use **only** tokens from `src/app/globals.css`. Do not invent hex in components.

### Brand

| Token | Hex (light) | Use |
|-------|-------------|-----|
| `primary` | `#E85078` | CTAs, brand mark, key accents |
| `primary-light` | `#FDF0F3` | Soft washes, hover fills |
| `secondary` | `#F07293` | Badges, secondary highlights |
| `accent` | `#E03856` | High-emphasis coral (CTA hover / strong accents) |

### Surfaces & text

| Token | Hex (light) | Use |
|-------|-------------|-----|
| `background` | `#FAF7F8` | Page canvas |
| `surface` | `#FFFFFF` | Elevated panels when interaction needs a container |
| `text-primary` / `foreground` | `#1E1719` | Headlines, body |
| `text-secondary` | `#6B5E63` | Supporting copy |
| `border` | `#EEDFE3` | Dividers, subtle outlines |

### Cycle state colors (feature storytelling)

| Token | Hex | Meaning |
|-------|-----|---------|
| `period` | `#E53958` | Menstrual / period |
| `ovulation` | `#F59E0B` | Peak / ovulation |
| `fertility` | `#8B5CF6` | Fertile window |
| `pregnancy` | `#10B981` | Pregnancy mode |
| `perimenopause` | `#A85597` | Perimenopause |

### Gradients (CSS variables)

```css
var(--gradient-app)        /* primary → accent — CTAs, brand moments */
var(--gradient-soft)       /* soft rose wash — hero atmosphere */
var(--gradient-period)
var(--gradient-fertility)
var(--gradient-ovulation)
var(--gradient-pregnancy)
```

### Tailwind usage

```tsx
// ✅
className="bg-primary text-text-primary border-border bg-background"
style={{ background: "var(--gradient-soft)" }}

// ❌ never
className="bg-[#E85078]"
```

Dark mode tokens already exist in `globals.css` — prefer light marketing first; dark is optional.

---

## 3. Design principles (landing)

1. **Brand first** — “EezyCycle” is a hero-level signal, not only nav text.  
2. **One composition** — first viewport = one scene, not a dashboard.  
3. **Hero budget** — brand + one headline + one short sentence + one CTA group + one dominant visual. No stats strips, chip clusters, or cards in the hero.  
4. **Full-bleed hero** — edge-to-edge visual plane (soft gradient + product UI mock), not inset cards.  
5. **No hero overlays** — no floating badges/stickers on the hero media.  
6. **One job per section** — one purpose, one H2, one short support line.  
7. **Cards sparingly** — only when they hold interaction (FAQ accordion, download buttons). Prefer open layout.  
8. **Real visual anchor** — real app screens / cycle calendar / pregnancy week UI — not abstract purple blobs.  
9. **Motion with purpose** — 2–3 intentional motions (see §7), not noise.  
10. **Mobile first** — same story on phone; CTA always reachable.

Typography: keep Geist for now (already wired) *or* introduce one expressive display font in `layout.tsx` + `globals.css` — avoid Inter/Roboto/Arial as the brand face.

---

## 4. SEO architecture

### 4.1 Routes (App Router)

```
eezycycle-landing/src/app/
├── layout.tsx                 # root metadata, fonts, JSON-LD org
├── page.tsx                   # homepage (compose sections)
├── sitemap.ts
├── robots.ts
├── opengraph-image.tsx        # or static /public/og.png
├── privacy/page.tsx           # host Privacy Policy (Play / App Store URL)
├── terms/page.tsx             # if you publish Terms
├── features/
│   ├── page.tsx               # features hub
│   ├── period-tracker/page.tsx
│   ├── ovulation-fertility/page.tsx
│   ├── pregnancy/page.tsx
│   ├── perimenopause/page.tsx
│   └── partner/page.tsx
├── how-it-works/page.tsx
└── faq/page.tsx
```

Homepage ranks for brand + primary keywords. Feature pages deepen long-tail SEO without stuffing the hero.

### 4.2 Primary keyword clusters

| Page | Primary intent | Example title |
|------|----------------|---------------|
| `/` | Brand + period tracker | EezyCycle — Period & Ovulation Tracker |
| `/features/period-tracker` | period tracker app | Period Tracker App \| EezyCycle |
| `/features/ovulation-fertility` | ovulation / fertile window | Ovulation & Fertile Window Estimates \| EezyCycle |
| `/features/pregnancy` | pregnancy tracker | Pregnancy Week Insights \| EezyCycle |
| `/features/perimenopause` | perimenopause tracking | Perimenopause Tracker \| EezyCycle |
| `/features/partner` | partner cycle app | Partner Cycle Support \| EezyCycle |
| `/how-it-works` | how predictions work | How EezyCycle Predictions Work |
| `/faq` | FAQ | Help & FAQ \| EezyCycle |
| `/privacy` | legal / trust | Privacy Policy \| EezyCycle |

### 4.3 Metadata pattern (`layout.tsx` / per-page)

```ts
export const metadata: Metadata = {
  metadataBase: new URL("https://eezycycle.eezybooking.com"), // confirm real domain
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
  openGraph: {
    type: "website",
    siteName: "EezyCycle",
    title: "EezyCycle — Period & Ovulation Tracker",
    description:
      "Know your cycle with gentle predictions, daily insights, partner support, and privacy-first design.",
    images: ["/og.png"],
  },
  twitter: {
    card: "summary_large_image",
    title: "EezyCycle — Period & Ovulation Tracker",
    description:
      "Period, ovulation, pregnancy & partner support — private by design.",
    images: ["/og.png"],
  },
  robots: { index: true, follow: true },
  alternates: { canonical: "/" },
};
```

Every route: unique `title`, `description`, `canonical`. Feature pages get their own OG image when possible.

### 4.4 Heading hierarchy (homepage)

```
h1  EezyCycle (or brand + short promise — only one H1)
h2  Track every chapter of your cycle
h2  Predictions that learn from your logs
h2  Modes for every journey
h2  Built for partners, too
h2  Insights & community
h2  Your body, your data
h2  Frequently asked questions
h2  Start tracking today
```

Use one `h1`. Section titles are `h2`. Feature names inside a section are `h3`.

### 4.5 Structured data (JSON-LD)

In root `layout.tsx` or homepage:

1. **Organization** — name, url, logo, contact  
2. **SoftwareApplication** — name, applicationCategory `HealthApplication`, operatingSystem `iOS, Android`, offers (free / price TBD)  
3. **FAQPage** — mirror visible FAQ questions/answers  
4. **WebSite** — `url` + optional `SearchAction` if you add site search later  

Keep FAQ answers identical in HTML and JSON-LD.

### 4.6 Technical SEO checklist

- [ ] `sitemap.ts` lists all public routes  
- [ ] `robots.ts` allows crawl; points to sitemap  
- [ ] Semantic HTML: `header`, `main`, `section`, `footer`, `nav`  
- [ ] Images: `next/image`, width/height, descriptive `alt`  
- [ ] LCP: hero image or CSS gradient + optimized mock prioritized  
- [ ] No client-only critical content for SEO (sections should SSR)  
- [ ] Privacy & Terms linked in footer (Play Console / App Store)  
- [ ] Medical disclaimer in footer + How it works  
- [ ] `lang="en"` on `<html>`  

---

## 5. Page structure & copy direction

### Homepage section map

| # | Section ID | Job | Visual idea |
|---|------------|-----|-------------|
| 0 | `nav` | Brand + Features + How it works + FAQ + Download | Sticky translucent bar on `background` |
| 1 | `hero` | Brand + promise + primary CTA | Full-bleed soft gradient + phone mock (home / calendar) |
| 2 | `journey` | Four experience modes | Horizontal or stacked mode storytelling with cycle colors |
| 3 | `predictions` | How estimates work (trust) | Simple pipeline: log → profile → estimate → calendar |
| 4 | `daily` | Insights, articles, logging | App home insights / article cards as screenshots |
| 5 | `partner` | Partner Space | Dual-device or invite-code moment |
| 6 | `community` | Secret Chat (tasteful) | Soft, private, anonymous framing — no salacious tone |
| 7 | `privacy` | Trust | Lock / encryption messaging; link Privacy Policy |
| 8 | `faq` | SEO + objections | Accordion (`h3` questions) |
| 9 | `final-cta` | Download | Gradient band + store buttons |
| 10 | `footer` | Legal, links, contact | Minimal |

### Hero copy (starter)

- **Brand:** EezyCycle  
- **Headline:** Your cycle, clearly mapped  
- **Support:** Period timing, ovulation estimates, pregnancy insights, and partner support — private, guest-friendly, and designed for real life.  
- **Primary CTA:** Download the app  
- **Secondary CTA:** See how it works  

### Mode blurbs (use cycle tokens as accents, not rainbow chaos)

| Mode | Color token | One-liner |
|------|-------------|-----------|
| Track cycle | `period` | Log periods & symptoms; see what’s ahead. |
| Get pregnant | `fertility` / `ovulation` | Spot your fertile window with clearer timing cues. |
| Track pregnancy | `pregnancy` | Week-by-week baby & body insights after you switch modes. |
| Track perimenopause | `perimenopause` | Navigate changing cycles with calm, practical guidance. |

### Privacy bullets (from onboarding / policy)

- We never sell your data  
- You can delete your data anytime  
- Your data is encrypted  
- Guest mode available; create an account when you want sync  

### FAQ seeds (align with in-app FAQ)

Pull from `HelpFaqController` categories: Getting Started · Cycle & Health · Partner Sync · Secret Chat · Privacy & Data · Account.

Must-include answers:

1. Do I need an account? → Guest OK; account for sync/recovery  
2. How accurate are predictions? → Improve with logged cycles; estimates only  
3. Modes difference? → Track cycle / Get pregnant / Pregnancy / Perimenopause  
4. Partner? → Opt-in code; limited shared summary  
5. Medical? → Not a medical device; consult a clinician  

### Disclaimers (footer + How it works)

> EezyCycle is a personal wellness tool. Always consult a qualified healthcare professional for medical decisions.

---

## 6. Folder structure (implementation)

Match `.cursor/rules/landing/eezycycle-landing.mdc`:

```
eezycycle-landing/src/
├── app/                      # routes only
│   ├── globals.css           # single color source
│   ├── layout.tsx
│   ├── page.tsx              # compose <sections>
│   ├── sitemap.ts
│   ├── robots.ts
│   ├── privacy/
│   ├── faq/
│   └── features/...
├── components/
│   ├── ui/                   # Button, Section, Container, Accordion, StoreBadge
│   └── sections/             # Hero, JourneyModes, Predictions, Partner, Privacy, Faq, FinalCta, Footer, Nav
├── lib/
│   ├── seo.ts                # metadata helpers, JSON-LD builders
│   ├── copy.ts               # homepage strings (keep DRY)
│   └── constants.ts          # store URLs, support email, site URL
└── hooks/
    └── useReducedMotion.ts
```

`page.tsx` should stay thin:

```tsx
export default function HomePage() {
  return (
    <>
      <Nav />
      <main>
        <Hero />
        <JourneyModes />
        <Predictions />
        <DailyInsights />
        <Partner />
        <Community />
        <Privacy />
        <Faq />
        <FinalCta />
      </main>
      <Footer />
    </>
  );
}
```

---

## 7. Animations (intentional, not noisy)

Ship **2–3 signature motions** + light section reveals. Respect `prefers-reduced-motion`.

### Recommended stack

- **CSS** for simple fades / transforms (zero JS cost on SSR)  
- **Framer Motion** (`motion`) only for scroll-linked or staged sequences  
- Prefer `transform` + `opacity` (compositor-friendly)

### Signature motions

| # | Where | Motion | Purpose |
|---|-------|--------|---------|
| 1 | Hero | Brand wordmark / title fade-up + soft gradient drift | Presence |
| 2 | Hero phone mock | Slight float / parallax on scroll (subtle) | Depth |
| 3 | Journey modes | Staggered fade-in when section enters viewport | Hierarchy |

Optional extras (keep light):

- CTA hover: scale `1.02`, background `primary` → `accent`  
- FAQ accordion: height/opacity expand  
- Nav: blur + border appears after scroll  

### Reduced motion

```ts
const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
// if reduce → skip float/parallax; keep instant opacity swaps only
```

### What to avoid

- Endless particle systems  
- Auto-playing carousels with many slides  
- Glow / neon / purple-haze stock “AI SaaS” look  
- Motion that blocks LCP or CLS  

---

## 8. Assets to prepare

| Asset | Spec | Notes |
|-------|------|-------|
| Wordmark / logo | SVG | Use brand rose; high contrast on soft bg |
| App icon | 512+ PNG | Favicon + apple-touch |
| Hero phone mock | WebP/PNG, @2x | Home cycle hero or calendar |
| Mode screenshots | 4 frames | One per experience mode |
| Partner mock | Optional | Partner home / invite |
| OG image | 1200×630 | Brand + short promise on soft gradient |
| Store badges | Official Apple / Google assets | Link to live listings when ready |

Pull visuals from real Flutter screens when possible (consistent colors).

---

## 9. CTAs & conversion

| Placement | Label | Target |
|-----------|-------|--------|
| Nav | Download | `#download` or store URL |
| Hero primary | Download the app | Store URL(s) |
| Hero secondary | See how it works | `/how-it-works` |
| Final CTA | Get EezyCycle | Store URL(s) |
| Footer | Privacy · FAQ · Contact | Internal / mailto |

Put store URLs in `lib/constants.ts`:

```ts
export const SITE_URL = "https://eezycycle.eezybooking.com"; // confirm
export const SUPPORT_EMAIL = "info@eezycycle.com";
export const PLAY_STORE_URL = ""; // fill when live
export const APP_STORE_URL = "";  // fill when live
```

Until stores are live, CTA can scroll to waitlist / “Coming soon” with email capture (optional).

---

## 10. Content you can reuse from the product

| Source | Landing use |
|--------|-------------|
| `AppColors` / `globals.css` | Full palette |
| Experience modes | Journey section |
| Onboarding privacy bullets | Privacy section |
| FAQ controller copy | `/faq` + homepage accordion + FAQPage schema |
| `PRIVACY_POLICY.md` | `/privacy` page (public HTTPS for stores) |
| Articles themes | “Insights” section topics (don’t dump full articles) |
| Prediction docs | Soft language on `/how-it-works` only |
| Partner onboarding | Partner section benefits |
| Guest vs account docs | Getting-started FAQ |

---

## 11. Accessibility & trust

- Contrast: `text-primary` on `background` / `surface` meets WCAG; never put pale rose text on white alone for body copy  
- Focus rings on interactive elements (`primary` outline)  
- Buttons: real `<a>` / `<button>`, not clickable `div`s  
- FAQ: keyboard-expandable  
- Medical disclaimer always visible in footer  
- Avoid fear-based or fertility-guarantee copy  

---

## 12. Build order (suggested)

1. Lock `globals.css` tokens (already done) + `lib/constants.ts`  
2. `layout.tsx` metadata + Organization JSON-LD  
3. `ui/` primitives: `Section`, `Button`, `Container`  
4. `Hero` + `Nav` + `Footer` (first viewport complete)  
5. `JourneyModes` + `Predictions` + `Privacy`  
6. `Faq` + FAQ JSON-LD  
7. `Partner` + `Community` + `FinalCta`  
8. Feature subpages + `sitemap` / `robots`  
9. Host `/privacy` from policy doc  
10. Wire store URLs + OG image + Lighthouse pass  

---

## 13. Do / Don’t

| Do | Don’t |
|----|--------|
| Use rose brand + soft gradient atmosphere | Flat generic purple SaaS theme |
| Say “estimates” / “predictions improve with logs” | Say “100% accurate ovulation” |
| One H1, clear section H2s | Keyword-stuffed paragraphs |
| Full-bleed hero with real app UI | Card grid in the first viewport |
| Link Privacy Policy | Hide data practices |
| Animate for hierarchy | Animate everything |

---

## 14. Definition of done

Landing is useful when:

- [ ] First viewport passes the brand test (remove nav → still clearly EezyCycle)  
- [ ] Colors only from tokens  
- [ ] SEO: unique metadata, sitemap, robots, FAQ schema, semantic headings  
- [ ] 2–3 intentional animations with reduced-motion support  
- [ ] Modes, partner, privacy, and disclaimer all represented  
- [ ] Privacy Policy live at a stable HTTPS URL  
- [ ] Mobile + desktop layouts verified  
- [ ] Store CTAs ready (or honest “coming soon”)  

---

## Related project files

- Colors: `eezycycle-landing/src/app/globals.css`  
- Flutter colors: `period_ovulation_tracker/lib/core/constants/app_colors.dart`  
- Privacy: `period_ovulation_tracker/docs/PRIVACY_POLICY.md`  
- Predictions (dev only): `period_ovulation_tracker/docs/backend/08-how-the-algorithm-works-now.md`  
- Landing conventions: `.cursor/rules/landing/eezycycle-landing.mdc`  
- In-app FAQ: `period_ovulation_tracker/lib/controllers/basic_need/faq_controller.dart`  
