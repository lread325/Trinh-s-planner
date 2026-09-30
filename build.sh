#!/usr/bin/env bash
# Regenerates index.html from meal-planner.tsx.
# Usage: ./build.sh [source] [output]   (defaults: meal-planner.tsx -> index.html)
#
# index.html is a zero-tooling build: CDN React + in-browser Babel, with the
# React import stripped and window.storage swapped for localStorage.
set -euo pipefail
cd "$(dirname "$0")"

SRC="${1:-meal-planner.tsx}"
OUT="${2:-index.html}"

{
cat <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, viewport-fit=cover" />
<title>Trinh's Planner</title>
<meta name="theme-color" content="#C9A788" />
<meta name="apple-mobile-web-app-capable" content="yes" />
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />
<meta name="apple-mobile-web-app-title" content="Trinh's Planner" />
<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Expires" content="0" />
<link rel="manifest" href="manifest.json" />
<link rel="apple-touch-icon" href="apple-touch-icon.png" />
<link rel="icon" type="image/png" sizes="32x32" href="favicon-32.png" />
<link rel="icon" type="image/png" sizes="192x192" href="icon-192.png" />
<style>
  html, body { margin: 0; padding: 0; background: #F3E7D6; -webkit-tap-highlight-color: transparent; }
  * { -webkit-text-size-adjust: 100%; }
  input, select, textarea, button { font-size: 16px; } /* prevents iOS zoom-on-focus */
</style>
<script src="https://cdnjs.cloudflare.com/ajax/libs/react/18.2.0/umd/react.production.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/react-dom/18.2.0/umd/react-dom.production.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/babel-standalone/7.23.5/babel.min.js"></script>
</head>
<body>
<div id="root"></div>
<script type="text/babel" data-presets="react">
HTML

sed -E \
  -e 's#^import React, \{ (.*) \} from "react";$#const { \1 } = React;\n#' \
  -e 's#^// ---------- storage helpers ----------$#// ---------- storage helpers (plain browser localStorage - private to this device) ----------\nconst STORAGE_PREFIX = "trinhs-planner:";#' \
  -e 's#^( *)const res = await window\.storage\.get\(key, false\);$#\1const raw = localStorage.getItem(STORAGE_PREFIX + key);#' \
  -e 's#^( *)return res \? JSON\.parse\(res\.value\) : fallback;$#\1return raw != null ? JSON.parse(raw) : fallback;#' \
  -e 's#^( *)await window\.storage\.set\(key, JSON\.stringify\(value\), false\);$#\1localStorage.setItem(STORAGE_PREFIX + key, JSON.stringify(value));#' \
  -e 's#^export default function MealPlanner\(\)#function MealPlanner()#' \
  "$SRC" | tr -d '\r'

cat <<'HTML'


const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(<MealPlanner />);
</script>
</body>
</html>
HTML
} > "$OUT"

if grep -qE 'window\.storage|^import |^export ' "$OUT"; then
  echo "build.sh: leftover window.storage/import/export in $OUT; the source changed shape, update build.sh" >&2
  exit 1
fi
echo "Built $OUT from $SRC"
