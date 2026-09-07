#!/usr/bin/env bash
# Draws the Bright Future wallpapers from nothing: bash emits SVG, librsvg
# rasterises it, ImageMagick derives the theme's preview/unlock stills.
# Deps: librsvg (rsvg-convert), imagemagick (magick). The PNGs are committed,
# so this only runs again when the art changes.
#
# The art obeys the palette model in PALETTE.md: ~90% of the canvas is dark,
# glow is stepped (stacked ellipses, not fog), both accents appear in every
# major object, and the only smooth gradient is the near-invisible sky ramp.
set -euo pipefail

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
BG_DIR="$(dirname "$SRC_DIR")"
ROOT_DIR="$(dirname "$BG_DIR")"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

W=3840 H=2160 HORIZON=1560 VPX=1920

A="#ff4fd1"      # signal — hot magenta
A_HI="#ff8ae2"
B="#45e5ff"      # depth — electric cyan
B_HI="#7deeff"
CORE="#ffd9f4"   # near-white horizon core
STAR_DIM="#8b95d6"
STAR_HOT="#f2f4ff"

rect()    { printf '<rect x="%d" y="%d" width="%d" height="%d" fill="%s" opacity="%s"/>\n' "$@"; }
ellipse() { printf '<ellipse cx="%d" cy="%d" rx="%d" ry="%d" fill="%s" opacity="%s"/>\n' "$@"; }
line()    { printf '<line x1="%d" y1="%d" x2="%d" y2="%d" stroke="%s" stroke-width="%s" opacity="%s"/>\n' "$@"; }

svg_open()  { printf '<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d">\n' "$W" "$H" "$W" "$H"; }
svg_close() { printf '</svg>\n'; }

defs() {
  cat <<'DEFS'
<defs>
<pattern id="scan" width="4" height="4" patternUnits="userSpaceOnUse"><rect width="4" height="1" fill="#000000"/></pattern>
<radialGradient id="vig" cx="50%" cy="47%" r="72%"><stop offset="60%" stop-color="#000000" stop-opacity="0"/><stop offset="100%" stop-color="#000000" stop-opacity="0.40"/></radialGradient>
<filter id="soft" x="-60%" y="-60%" width="220%" height="220%"><feGaussianBlur stdDeviation="70"/></filter>
<filter id="soft2" x="-80%" y="-80%" width="260%" height="260%"><feGaussianBlur stdDeviation="150"/></filter>
<filter id="lineglow" x="-20%" y="-400%" width="140%" height="900%"><feGaussianBlur stdDeviation="7"/></filter>
</defs>
DEFS
}

overlay() {
  rect 0 0 "$W" "$H" 'url(#scan)' 0.12
  printf '<rect x="0" y="0" width="%d" height="%d" fill="url(#vig)"/>\n' "$W" "$H"
}

sparkle() { # x y halo-colour — plus-shaped pixel star with a tight square halo
  local x=$1 y=$2 halo=$3
  rect $((x - 9)) $((y - 9)) 18 18 "$halo" 0.12
  rect $((x - 7)) $((y - 2)) 14 4 "$STAR_HOT" 0.92
  rect $((x - 2)) $((y - 7)) 4 14 "$STAR_HOT" 0.92
}

fringe_sparkle() { # x y — same star, split by chromatic aberration
  local x=$1 y=$2
  rect $((x - 9)) $((y - 2)) 14 4 "$A" 0.45
  rect $((x - 5)) $((y - 2)) 14 4 "$B" 0.45
  rect $((x - 2)) $((y - 9)) 4 14 "$A" 0.45
  rect $((x - 2)) $((y - 5)) 4 14 "$B" 0.45
  rect $((x - 6)) $((y - 2)) 12 4 "$STAR_HOT" 0.90
  rect $((x - 2)) $((y - 6)) 4 12 "$STAR_HOT" 0.90
}

starfield() { # count ymin ymax — dim indigo mass, ~30% accent chroma, few sparkles
  local n=$1 ymin=$2 ymax=$3
  local i x y roll s
  local dims=("0.20" "0.30" "0.40" "0.50")
  for ((i = 0; i < n; i++)); do
    x=$((RANDOM * W / 32768))
    y=$((ymin + RANDOM * (ymax - ymin) / 32768))
    roll=$((RANDOM % 100))
    if ((roll < 62)); then
      s=$((1 + RANDOM % 3))
      rect "$x" "$y" "$s" "$s" "$STAR_DIM" "${dims[RANDOM % 4]}"
    elif ((roll < 78)); then
      s=$((2 + RANDOM % 2))
      rect "$x" "$y" "$s" "$s" "$B" 0.50
    elif ((roll < 88)); then
      s=$((2 + RANDOM % 2))
      rect "$x" "$y" "$s" "$s" "$A" 0.50
    elif ((roll < 96)); then
      if ((i % 2)); then sparkle "$x" "$y" "$A"; else sparkle "$x" "$y" "$B"; fi
    else
      fringe_sparkle "$x" "$y"
    fi
  done
}

horizon_glow() { # stacked ellipses under blur: banded falloff, no ring artifacts
  printf '<g filter="url(#soft)">\n'
  ellipse "$VPX" "$HORIZON" 2100 560 "$A" 0.05
  ellipse "$VPX" "$HORIZON" 1500 380 "$A" 0.06
  ellipse "$VPX" "$HORIZON" 1020 250 "$A" 0.08
  ellipse "$VPX" "$HORIZON" 640 150 "$A" 0.11
  ellipse "$VPX" "$HORIZON" 360 80 "$A_HI" 0.14
  printf '</g>\n'
  printf '<g filter="url(#lineglow)">\n'
  rect 660 $((HORIZON - 16)) 2520 32 "$A" 0.10
  rect 760 $((HORIZON - 8)) 2320 16 "$A" 0.26
  rect 860 $((HORIZON + 2)) 2120 9 "$A" 0.22
  printf '</g>\n'
  rect 860 $((HORIZON - 3)) 2120 5 "$CORE" 0.92
}

counter_glow() { # cyan answer, top right — the 20-35% share of accent B
  printf '<g filter="url(#soft)">\n'
  ellipse 3350 160 1500 660 "$B" 0.040
  ellipse 3350 160 1000 430 "$B" 0.055
  ellipse 3350 160 620 250 "$B" 0.070
  printf '</g>\n'
}

grid() { # perspective floor; the outermost rays go cyan (cross-pollination)
  local i k xb y w c op
  for ((i = -14; i <= 14; i++)); do
    xb=$((VPX + i * 300))
    if ((i < -10 || i > 10)); then c="$B" op="0.14"; else c="$A" op="0.17"; fi
    ((i == 0)) && op="0.10"
    line "$VPX" "$HORIZON" "$xb" "$H" "$c" 3 "$op"
  done
  for ((k = 1; k <= 10; k++)); do
    y=$((HORIZON + 6 * k * k))
    w=$((2 + k / 4))
    op="0.$((10 + 2 * k))"
    line 0 "$y" "$W" "$y" "$A" "$w" "$op"
  done
}

bright_horizon() {
  RANDOM=20260906
  svg_open
  cat <<'SKY'
<defs>
<linearGradient id="sky" x1="0" y1="0" x2="0" y2="1">
<stop offset="0" stop-color="#04040c"/>
<stop offset="0.45" stop-color="#0b0c19"/>
<stop offset="0.70" stop-color="#160f33"/>
<stop offset="0.7205" stop-color="#0e0a22"/>
<stop offset="1" stop-color="#05050f"/>
</linearGradient>
</defs>
SKY
  defs
  printf '<rect x="0" y="0" width="%d" height="%d" fill="url(#sky)"/>\n' "$W" "$H"
  counter_glow
  starfield 115 40 1470
  horizon_glow
  grid
  overlay
  svg_close
}

deep_field() {
  RANDOM=19861219
  svg_open
  cat <<'SKY'
<defs>
<linearGradient id="sky" x1="0" y1="0" x2="0.2" y2="1">
<stop offset="0" stop-color="#04040c"/>
<stop offset="0.55" stop-color="#0b0c19"/>
<stop offset="1" stop-color="#100b24"/>
</linearGradient>
</defs>
SKY
  defs
  printf '<rect x="0" y="0" width="%d" height="%d" fill="url(#sky)"/>\n' "$W" "$H"
  printf '<g transform="rotate(-16 1300 720)" filter="url(#soft2)">\n'
  ellipse 1300 720 1700 520 "$B" 0.045
  ellipse 1300 720 1150 340 "$B" 0.055
  ellipse 1300 720 700 200 "$B" 0.070
  printf '</g>\n'
  printf '<g transform="rotate(-16 2900 1500)" filter="url(#soft2)">\n'
  ellipse 2900 1500 1200 400 "$A" 0.045
  ellipse 2900 1500 800 260 "$A" 0.060
  ellipse 2900 1500 480 150 "$A" 0.080
  printf '</g>\n'
  starfield 175 20 $((H - 40))
  printf '<g transform="rotate(14 2600 380)">\n'
  rect 2180 378 560 3 "$B_HI" 0.35
  rect 2560 377 240 4 "$A_HI" 0.45
  printf '</g>\n'
  sparkle 2860 445 "$A"
  overlay
  svg_close
}

bright_horizon >"$TMP_DIR/bright-horizon.svg"
deep_field >"$TMP_DIR/deep-field.svg"

rsvg-convert -w "$W" -h "$H" -o "$BG_DIR/1-bright-horizon.png" "$TMP_DIR/bright-horizon.svg"
rsvg-convert -w "$W" -h "$H" -o "$BG_DIR/2-deep-field.png" "$TMP_DIR/deep-field.svg"

magick "$BG_DIR/1-bright-horizon.png" -resize 1920x1080 "$ROOT_DIR/preview.png"
magick "$BG_DIR/2-deep-field.png" -resize 1920x1080 "$ROOT_DIR/unlock.png"
cp "$ROOT_DIR/unlock.png" "$ROOT_DIR/preview-unlock.png"

echo "Rendered: $BG_DIR/1-bright-horizon.png, $BG_DIR/2-deep-field.png"
echo "Derived:  $ROOT_DIR/preview.png, $ROOT_DIR/unlock.png, $ROOT_DIR/preview-unlock.png"
