#!/usr/bin/env bash
# Seeds a single admin Auth user + Firestore profile for Pakola Waters.
# Prerequisites: firestore rules that allow users/{uid} self write (already deployed).
set -euo pipefail

API_KEY="${FIREBASE_WEB_API_KEY:-AIzaSyDjvndKlPwnN4egPh4a0QSyK5P20TzZlnE}"
PROJECT_ID="${FIREBASE_PROJECT_ID:-pakoola-waters}"
EMAIL="${ADMIN_EMAIL:-admin@pakolawaters.com}"
PASSWORD="${ADMIN_PASSWORD:-Admin@123456}"
DISPLAY_NAME="${ADMIN_DISPLAY_NAME:-Pakola Admin}"

parse_json() {
  local json="$1"
  local key="$2"
  # Prefer node if available
  if command -v node >/dev/null 2>&1; then
    node -e "const d=JSON.parse(process.argv[1]); const v=d$3; if(v==null) process.exit(2); process.stdout.write(String(v));" "$json" 2>/dev/null && return 0
  fi
  printf '%s' "$json" | sed -n "s/.*\"${key}\":\"\\([^\"]*\\)\".*/\\1/p" | head -1
}

echo "Seeding admin ${EMAIL} on ${PROJECT_ID}..."

SIGNUP=$(curl -s -X POST \
  "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${EMAIL}\",\"password\":\"${PASSWORD}\",\"returnSecureToken\":true}")

UID=""
TOKEN=""
if command -v node >/dev/null 2>&1; then
  UID=$(node -e "const d=JSON.parse(process.argv[1]); if(d.localId) process.stdout.write(d.localId);" "$SIGNUP" || true)
  TOKEN=$(node -e "const d=JSON.parse(process.argv[1]); if(d.idToken) process.stdout.write(d.idToken);" "$SIGNUP" || true)
  ERR=$(node -e "const d=JSON.parse(process.argv[1]); if(d.error&&d.error.message) process.stdout.write(d.error.message);" "$SIGNUP" || true)
else
  UID=$(printf '%s' "$SIGNUP" | sed -n 's/.*"localId":"\([^"]*\)".*/\1/p' | head -1)
  TOKEN=$(printf '%s' "$SIGNUP" | sed -n 's/.*"idToken":"\([^"]*\)".*/\1/p' | head -1)
  ERR=$(printf '%s' "$SIGNUP" | sed -n 's/.*"message":"\([^"]*\)".*/\1/p' | head -1)
fi

if [ -z "$TOKEN" ]; then
  echo "Signup did not return token (${ERR:-unknown}); trying sign-in..."
  SIGNIN=$(curl -s -X POST \
    "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${API_KEY}" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"${EMAIL}\",\"password\":\"${PASSWORD}\",\"returnSecureToken\":true}")
  if command -v node >/dev/null 2>&1; then
    UID=$(node -e "const d=JSON.parse(process.argv[1]); if(d.localId) process.stdout.write(d.localId);" "$SIGNIN" || true)
    TOKEN=$(node -e "const d=JSON.parse(process.argv[1]); if(d.idToken) process.stdout.write(d.idToken);" "$SIGNIN" || true)
    ERR=$(node -e "const d=JSON.parse(process.argv[1]); if(d.error&&d.error.message) process.stdout.write(d.error.message);" "$SIGNIN" || true)
  else
    UID=$(printf '%s' "$SIGNIN" | sed -n 's/.*"localId":"\([^"]*\)".*/\1/p' | head -1)
    TOKEN=$(printf '%s' "$SIGNIN" | sed -n 's/.*"idToken":"\([^"]*\)".*/\1/p' | head -1)
    ERR=$(printf '%s' "$SIGNIN" | sed -n 's/.*"message":"\([^"]*\)".*/\1/p' | head -1)
  fi
fi

if [ -z "$UID" ] || [ -z "$TOKEN" ]; then
  echo "Auth failed: ${ERR:-unknown}"
  exit 1
fi

echo "Auth OK (uid=${UID})"

HTTP=$(curl -s -o /tmp/pakola_fs.json -w "%{http_code}" -X PATCH \
  "https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/users/${UID}?updateMask.fieldPaths=email&updateMask.fieldPaths=displayName&updateMask.fieldPaths=role&updateMask.fieldPaths=status&updateMask.fieldPaths=branchIds" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"fields\":{\"email\":{\"stringValue\":\"${EMAIL}\"},\"displayName\":{\"stringValue\":\"${DISPLAY_NAME}\"},\"role\":{\"stringValue\":\"admin\"},\"status\":{\"stringValue\":\"active\"},\"branchIds\":{\"arrayValue\":{\"values\":[]}}}}")

if [ "$HTTP" != "200" ]; then
  echo "Firestore write failed (HTTP ${HTTP})."
  if command -v node >/dev/null 2>&1; then
    node -e "const d=JSON.parse(require('fs').readFileSync('/tmp/pakola_fs.json','utf8')); console.log(d.error&&d.error.message||d);" || cat /tmp/pakola_fs.json
  else
    cat /tmp/pakola_fs.json
  fi
  rm -f /tmp/pakola_fs.json
  exit 1
fi

rm -f /tmp/pakola_fs.json
echo "Admin ready."
echo "  Email:    ${EMAIL}"
echo "  Password: ${PASSWORD}"
echo "  Role:     admin"
echo "  Doc:      users/${UID}"
