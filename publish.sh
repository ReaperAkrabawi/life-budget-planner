#!/usr/bin/env bash
set -euo pipefail

REPO_NAME="life-budget-planner"
ROOT="$(cd "$(dirname "$0")" && pwd)"

cd "$ROOT"

if ! command -v gh >/dev/null 2>&1; then
  echo "Install GitHub CLI: brew install gh"
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "Log in to GitHub first:"
  echo "  gh auth login"
  exit 1
fi

USERNAME="$(gh api user -q .login)"
echo "GitHub user: $USERNAME"

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  :
else
  git init
  git branch -M main
fi

git add .
git commit -m "Add legal pages for GitHub Pages" || true

if git remote get-url origin >/dev/null 2>&1; then
  git push -u origin main
else
  gh repo create "$REPO_NAME" --public --source=. --remote=origin --push --description "Privacy policy and terms for Life Budget Planner"
fi

gh api -X POST "repos/${USERNAME}/${REPO_NAME}/pages" \
  -f build_type=legacy \
  -f source[branch]=main \
  -f source[path]=/ 2>/dev/null || \
gh api -X PUT "repos/${USERNAME}/${REPO_NAME}/pages" \
  -f build_type=legacy \
  -f source[branch]=main \
  -f source[path]=/

echo ""
echo "Done. Pages will be live in 1–2 minutes at:"
echo "  https://${USERNAME}.github.io/${REPO_NAME}/privacy.html"
echo "  https://${USERNAME}.github.io/${REPO_NAME}/terms.html"
echo ""
echo "Update mobile/app.json extra.privacyPolicyUrl and termsOfServiceUrl with these URLs."
