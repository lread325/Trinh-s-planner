# Trinh's Planner

Meal-planning PWA served by GitHub Pages from `main` (root) at https://lread325.github.io/Trinh-s-planner/.

- Edit `meal-planner.tsx` (the source; plain JSX despite the extension).
- Then run `bash build.sh` to regenerate `index.html`, and commit both. Never hand-edit `index.html`.
- No Node/Python on this machine; `build.sh` is pure bash/sed.
- User data lives only in the browser's localStorage under the `trinhs-planner:` prefix. Don't rename storage keys or change data shapes without a migration, or her saved data is lost.
- Files are stored with LF line endings; keep it that way to avoid whole-file diffs.
