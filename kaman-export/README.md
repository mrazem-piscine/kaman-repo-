# Kaman — exported prototype

Three self-contained HTML files. No server, no build step, no internet needed
after the first load. Fonts, the Organic design-system stylesheet, the runtime
and all JavaScript are inlined into each file.

## Files

| File | What it is |
| --- | --- |
| `kaman-prototype.html` | **The main deliverable.** The full motion prototype: dish-first Home, Explore, Restaurant with collapsing hero, item customization sheet, cart, checkout, order handover + tracking, story viewer, states gallery, motion-language notes. |
| `kaman-layout-options.html` | The four layout directions (1a/1b Home, 1c/1d Restaurant) shown side by side. |
| `kaman-screens-v1.html` | The earlier 15-screen static pass — broader screen coverage (favorites, addresses, payment methods, notifications, order detail, filters), no motion work. Keep as a screen inventory. |
| `source/` | The editable Design Component sources these were compiled from. |

## How to run

Double-click any `.html` file. That is it — it opens in Chrome, Safari, Firefox
or Edge and runs.

If double-clicking fails on your machine, drag the file onto an open browser
window instead. On first open the page shows a brief splash while it unpacks
itself; that happens once per file.

To serve them instead (optional, and only if your browser is locked down):

```
cd kaman-export
python3 -m http.server 8000
# then open http://localhost:8000/kaman-prototype.html
```

## Using the prototype

The tweak controls that existed inside Claude Design are not in the exported
file. To change those three settings, open `kaman-prototype.html` in a text
editor and search for `renderVals()`:

- **Platform chrome** — `const ios = (p.platform || 'iPhone') === 'iPhone';`
  change `'iPhone'` to `'Android'`.
- **RTL** — `const isRTL = (p.direction || 'LTR') === 'RTL';`
  change `'LTR'` to `'RTL'`. Everything is built on logical properties, so the
  whole layout mirrors; directional icons flip and stars, hearts and prices
  do not.
- **Motion annotations** — `const annotate = !!p.annotations;`
  change to `const annotate = true;` to pin the motion spec onto the live
  screens (Home, Restaurant and Tracking carry notes).

Flow to walk for the interactions: Home → tap a story ring → close → tap a
restaurant → scroll the menu (hero collapses, rail follows) → tap a dish photo
→ pick options → Add to cart (flight + cart bar) → View order → Go to checkout
→ Place order (handover into tracking).

## For the Flutter build

The **Motion** tab inside `kaman-prototype.html` is the written spec: the three
duration tiers with their Flutter widget equivalents, the easing and
shared-element rules, the three signature interactions with their backend
requirements, and the haptics table. Read that first — the CSS is only its
demonstration.

Two conventions worth carrying over verbatim:

- One curve for everything entering or growing: `cubic-bezier(.2,.8,.2,1)`
  (`Curves.easeOutCubic` is the closest stock match). Linear for opacity only.
- Shared elements own their transitions. A tap flies the tapped thing into its
  destination; the destination only fades its text in behind the arriving
  element. In Flutter that is `Hero` + a `PageRouteBuilder`, not two separate
  page animations.

## For the Figma import

Design tokens live at the top of the inlined stylesheet — search for `:root {`
in any of the files. That block holds the full palette (`--color-bg`,
`--color-text`, `--color-accent`, `--color-accent-2` plus 100–900 ramps for
neutral, accent and accent-2), the type variables and the spacing and radius
scales. Those ramp steps are the exact values used across every screen, so
they map one-to-one onto Figma variables.

Typography: Caprasimo for display, Figtree for UI text, IBM Plex Sans Arabic
for Arabic and Heebo for Hebrew. All four are Google Fonts and free.

## Known gaps

- **Every image is a labelled striped placeholder.** No photography was ever
  supplied, and this design leans on food photos more than most. Each
  placeholder states its aspect ratio and role.
- **Two of the three signature interactions need backend support** — dish-level
  craving tagging with a freshness signal, and per-stage order timestamps.
  Both are flagged in the Motion tab.
- **The order-placed celebration was deliberately left unbuilt.** The handover
  transition sets up the motion language for it.
- Copy is English throughout, with a true RTL layout mirror rather than
  translated strings.
