#!/usr/bin/env bash
# Seeds a single admin Auth user + Firestore profile for Pakola Waters.
# Prerequisites: firestore rules that allow users/{uid} self write (already deployed).
set -euo pipefail

API_KEY="${FIREBASE_WEB_API_KEY:-AIzaSyDjvndKlPwnN4egPh4a0QSyK5P20TzZlnE}"
PROJECT_ID="${FIREBASE_PROJECT_ID:-pakoola-waters}"
EMAIL="${ADMIN_EMAIL:-admin@pakolawaters.com}"
PASSWORD="${ADMIN_PASSWORD:-Admin@123456}"
DISPLAY_NAME="${ADMIN_DISPLAY_NAME:-Pakola Admin}"

echo "Seeding admin ${EMAIL} on ${PROJECT_ID}..."

SIGNUP=$(curl -s -X POST \
  "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${EMAIL}\",\"password\":\"${PASSWORD}\",\"returnSecureToken\":true}")

USER_ID=""
ID_TOKEN=""
ERR=""
if command -v node >/dev/null 2>&1; then
  USER_ID=$(node -e "const d=JSON.parse(process.argv[1]); if(d.localId) process.stdout.write(d.localId);" "$SIGNUP" || true)
  ID_TOKEN=$(node -e "const d=JSON.parse(process.argv[1]); if(d.idToken) process.stdout.write(d.idToken);" "$SIGNUP" || true)
  ERR=$(node -e "const d=JSON.parse(process.argv[1]); if(d.error&&d.error.message) process.stdout.write(d.error.message);" "$SIGNUP" || true)
else
  USER_ID=$(printf '%s' "$SIGNUP" | sed -n 's/.*"localId":"\([^"]*\)".*/\1/p' | head -1)
  ID_TOKEN=$(printf '%s' "$SIGNUP" | sed -n 's/.*"idToken":"\([^"]*\)".*/\1/p' | head -1)
  ERR=$(printf '%s' "$SIGNUP" | sed -n 's/.*"message":"\([^"]*\)".*/\1/p' | head -1)
fi

if [ -z "$ID_TOKEN" ]; then
  echo "Signup did not return token (${ERR:-unknown}); trying sign-in..."
  SIGNIN=$(curl -s -X POST \
    "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${API_KEY}" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"${EMAIL}\",\"password\":\"${PASSWORD}\",\"returnSecureToken\":true}")
  if command -v node >/dev/null 2>&1; then
    USER_ID=$(node -e "const d=JSON.parse(process.argv[1]); if(d.localId) process.stdout.write(d.localId);" "$SIGNIN" || true)
    ID_TOKEN=$(node -e "const d=JSON.parse(process.argv[1]); if(d.idToken) process.stdout.write(d.idToken);" "$SIGNIN" || true)
    ERR=$(node -e "const d=JSON.parse(process.argv[1]); if(d.error&&d.error.message) process.stdout.write(d.error.message);" "$SIGNIN" || true)
  else
    USER_ID=$(printf '%s' "$SIGNIN" | sed -n 's/.*"localId":"\([^"]*\)".*/\1/p' | head -1)
    ID_TOKEN=$(printf '%s' "$SIGNIN" | sed -n 's/.*"idToken":"\([^"]*\)".*/\1/p' | head -1)
    ERR=$(printf '%s' "$SIGNIN" | sed -n 's/.*"message":"\([^"]*\)".*/\1/p' | head -1)
  fi
fi

if [ -z "$USER_ID" ] || [ -z "$ID_TOKEN" ]; then
  echo "Auth failed: ${ERR:-unknown}"
  exit 1
fi

echo "Auth OK (uid=${USER_ID})"

# First write is a create under Firestore rules. Client SDK cannot create role=admin
# (only customer self-signup or existing admin). Prefer Firebase CLI / Admin SDK.
# Fallback: attempt REST upsert; if rules block create, print clear instructions.
HTTP=$(curl -s -o /tmp/pakola_fs.json -w "%{http_code}" -X PATCH \
  "https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/users/${USER_ID}?updateMask.fieldPaths=email&updateMask.fieldPaths=displayName&updateMask.fieldPaths=role&updateMask.fieldPaths=status&updateMask.fieldPaths=branchIds" \
  -H "Authorization: Bearer ${ID_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"fields\":{\"email\":{\"stringValue\":\"${EMAIL}\"},\"displayName\":{\"stringValue\":\"${DISPLAY_NAME}\"},\"role\":{\"stringValue\":\"admin\"},\"status\":{\"stringValue\":\"active\"},\"branchIds\":{\"arrayValue\":{\"values\":[]}}}}")

if [ "$HTTP" = "200" ]; then
  rm -f /tmp/pakola_fs.json
  echo "Admin ready."
  echo "  Email:    ${EMAIL}"
  echo "  Password: ${PASSWORD}"
  echo "  Role:     admin"
  echo "  Doc:      users/${USER_ID}"
  exit 0
fi

echo "Client Firestore write failed (HTTP ${HTTP}) — expected if profile is missing (rules block creating role=admin)."
if command -v node >/dev/null 2>&1; then
  node -e "const d=JSON.parse(require('fs').readFileSync('/tmp/pakola_fs.json','utf8')); console.log(d.error&&d.error.message||d);" || cat /tmp/pakola_fs.json
else
  cat /tmp/pakola_fs.json
fi
rm -f /tmp/pakola_fs.json

if command -v firebase >/dev/null 2>&1; then
  echo "Writing profile via Firebase CLI..."
  TMP_JSON=$(mktemp)
  cat >"$TMP_JSON" <<JSON
{
  "email": "${EMAIL}",
  "displayName": "${DISPLAY_NAME}",
  "role": "admin",
  "status": "active",
  "branchIds": []
}
JSON
  if firebase firestore:delete "users/${USER_ID}" --project "${PROJECT_ID}" --force >/dev/null 2>&1; then
    true
  fi
  # firebase tools has no simple set; use REST with gcloud identity token if available
fi

if command -v gcloud >/dev/null 2>&1; then
  echo "Writing profile via gcloud access token (Admin bypass)..."
  GTOKEN=$(gcloud auth print-access-token 2>/dev/null || true)
  if [ -n "$GTOKEN" ]; then
    HTTP2=$(curl -s -o /tmp/pakola_fs2.json -w "%{http_code}" -X PATCH \
      "https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/users/${USER_ID}?updateMask.fieldPaths=email&updateMask.fieldPaths=displayName&updateMask.fieldPaths=role&updateMask.fieldPaths=status&updateMask.fieldPaths=branchIds" \
      -H "Authorization: Bearer ${GTOKEN}" \
      -H "Content-Type: application/json" \
      -d "{\"fields\":{\"email\":{\"stringValue\":\"${EMAIL}\"},\"displayName\":{\"stringValue\":\"${DISPLAY_NAME}\"},\"role\":{\"stringValue\":\"admin\"},\"status\":{\"stringValue\":\"active\"},\"branchIds\":{\"arrayValue\":{\"values\":[]}}}}")
    if [ "$HTTP2" = "200" ]; then
      rm -f /tmp/pakola_fs2.json
      echo "Admin ready (via gcloud)."
      echo "  Email:    ${EMAIL}"
      echo "  Password: ${PASSWORD}"
      echo "  Role:     admin"
      echo "  Doc:      users/${USER_ID}"
      exit 0
    fi
    echo "gcloud write failed (HTTP ${HTTP2}):"
    cat /tmp/pakola_fs2.json || true
    rm -f /tmp/pakola_fs2.json
  fi
fi

echo ""
echo "Manual fix in Firebase Console:"
echo "  1. Firestore → users → add document with ID: ${USER_ID}"
echo "  2. Fields:"
echo "       email (string):        ${EMAIL}"
echo "       displayName (string):  ${DISPLAY_NAME}"
echo "       role (string):         admin"
echo "       status (string):       active"
echo "       branchIds (array):     []"
exit 1
