# The palette model

Bright Future is one instance of a repeatable colour-role system: dark-space
dual-accent neon duotone with chromatic edge-lighting. The two accents are not
used equally and are never blended everywhere. They have jobs.

## Roles

**GROUND** — near-black, very low chroma, may carry a faint tint of one accent.
Target 2–8% perceptual lightness. It should visually disappear.

**MATERIAL** — the dark, desaturated body colour large shapes are made of: a
shadow-side relative of accent B, never a neutral mid-grey. Selections, muted
lines, inactive borders.

**ACCENT A — SIGNAL** — highly saturated, high perceived brightness. The
active colour: prompts, accents, active borders, the strongest rim light, the
major glow. Visually dominant.

**ACCENT B — DEPTH** — highly saturated, similar or slightly lower perceived
brightness. Secondary edges, body tint, particles. It gives A something to be
bright against.

## The relationship

- 80–170° of hue separation between A and B; both stay high-chroma.
- One reads warmer or more energetic, the other cooler or deeper.
- The pair must read instantly as TWO colours, never as a rainbow.
- Avoid adjacent analogous pairs unless their lightness differs strongly.

## The budget

Roughly 90% of any canvas is dark neutral. Roughly 10% carries almost all the
chroma. Inside that 10%: 65–80% accent A, 20–35% accent B. Colour lives on
edges, highlights, text and symbols — never as a fill across large surfaces.

## Cross-pollination

Important objects carry a little of both accents — 10–30% of the minority hue,
via edge pixels, fringe, or a counter-glow. Never isolate the accents into
fully separate regions; the contamination is what makes two hues read as one
palette.

## Glow

Glow uses the hue of the emitting element. Bright core, saturated halo, rapid
falloff. No broad foggy bloom. White appears only in cores, sparingly.

## Cutting a sibling palette

Specify three hues and re-derive everything else:

- `material_hue` — the deep mass colour
- `signal_hue` — the emissive contrast (accent A)
- `secondary_emission_hue` — usually a lighter, chromatic relative of the
  material (accent B)

Pairs known to work under these rules: deep violet material + acid green
emission; deep violet + amber; cobalt + gold; deep blue material + cyan
primary + magenta secondary — which is this theme.

## The Bright Future instance

| Role | Value |
|---|---|
| Ground | `#0b0c19` (shades `#04040b`, `#070811`, `#151735`) |
| Material | `#221f4e` raise, `#414780` line, `rgba(221f4eaa)` inactive border |
| Signal A | `#ff4fd1`, bright `#ff8ae2` (hue ≈ 316°) |
| Depth B | `#45e5ff`, family `#38d2f5` / `#7deeff` (hue ≈ 192°) |
| Hue separation | ≈ 124° — inside the 80–170° window |
| Where they meet | `hyprland_active_border = "#ff4fd1 #45e5ff 45deg"` |

The ANSI colours keep their semantic hues (red warns, green passes) but are
tuned to the palette's temperature: pink-leaning red `#ff5c7a`, mint green
`#43e8ac`, indigo blue `#6f8dff`, warm sand yellow `#ffce73`.
