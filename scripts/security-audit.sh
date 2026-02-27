#!/bin/bash
# ============================================================
# Elham Progress — Quick Security Audit Script
# File: scripts/security-audit.sh
# Run monthly to check basic security hygiene
# Usage: bash security-audit.sh elhamco.com
# ============================================================

TARGET=${1:-"elhamco.com"}
TARGET_URL="https://$TARGET"
PASS="✅"
FAIL="❌"
WARN="⚠️ "
INFO="ℹ️ "

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║    ELHAM PROGRESS SECURITY AUDIT REPORT      ║"
echo "║    Target: $TARGET"
echo "║    Date: $(date +"%Y-%m-%d %H:%M")"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ── 1. SSL CERTIFICATE CHECK ───────────────────────────────
echo "── 1. SSL CERTIFICATE ─────────────────────────"

EXPIRY=$(echo | openssl s_client -servername "$TARGET" -connect "$TARGET:443" 2>/dev/null | \
         openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)

if [ -n "$EXPIRY" ]; then
  EXPIRY_DATE=$(date -d "$EXPIRY" +%s 2>/dev/null || date -jf "%b %d %H:%M:%S %Y %Z" "$EXPIRY" +%s 2>/dev/null)
  NOW=$(date +%s)
  DAYS_LEFT=$(( (EXPIRY_DATE - NOW) / 86400 ))

  if [ "$DAYS_LEFT" -gt 30 ]; then
    echo "$PASS SSL Certificate valid — $DAYS_LEFT days remaining"
  elif [ "$DAYS_LEFT" -gt 7 ]; then
    echo "$WARN SSL Certificate expires in $DAYS_LEFT days — RENEW SOON"
  else
    echo "$FAIL SSL Certificate expires in $DAYS_LEFT days — URGENT RENEWAL NEEDED"
  fi
else
  echo "$FAIL Could not retrieve SSL certificate info"
fi

# TLS Version Check
TLS12=$(echo | openssl s_client -connect "$TARGET:443" -tls1_2 2>&1 | grep "Protocol")
TLS13=$(echo | openssl s_client -connect "$TARGET:443" -tls1_3 2>&1 | grep "Protocol")
TLS10=$(echo | openssl s_client -connect "$TARGET:443" -tls1 2>&1 | grep "Cipher")

[ -n "$TLS12" ] && echo "$PASS TLS 1.2 supported"
[ -n "$TLS13" ] && echo "$PASS TLS 1.3 supported"
if [ -n "$TLS10" ]; then
  echo "$FAIL TLS 1.0 is enabled — must be disabled"
else
  echo "$PASS TLS 1.0 is disabled"
fi

echo ""

# ── 2. HTTP SECURITY HEADERS ──────────────────────────────
echo "── 2. HTTP SECURITY HEADERS ───────────────────"

HEADERS=$(curl -sI "$TARGET_URL" 2>/dev/null)

check_header() {
  local header_name="$1"
  local display_name="$2"
  if echo "$HEADERS" | grep -qi "$header_name"; then
    echo "$PASS $display_name present"
  else
    echo "$FAIL $display_name MISSING"
  fi
}

check_header "x-frame-options" "X-Frame-Options"
check_header "x-content-type-options" "X-Content-Type-Options"
check_header "strict-transport-security" "Strict-Transport-Security (HSTS)"
check_header "content-security-policy" "Content-Security-Policy"
check_header "referrer-policy" "Referrer-Policy"
check_header "permissions-policy" "Permissions-Policy"

# Check for info-leaking headers
if echo "$HEADERS" | grep -qi "^Server: Apache\|^Server: nginx\|^X-Powered-By"; then
  echo "$WARN Server version exposed in headers — should be removed"
else
  echo "$PASS Server version header is hidden"
fi

echo ""

# ── 3. HTTP → HTTPS REDIRECT ──────────────────────────────
echo "── 3. HTTPS REDIRECT ──────────────────────────"
HTTP_REDIRECT=$(curl -sI "http://$TARGET" 2>/dev/null | grep -i "location")
if echo "$HTTP_REDIRECT" | grep -q "https://"; then
  echo "$PASS HTTP redirects to HTTPS"
else
  echo "$FAIL HTTP does NOT redirect to HTTPS"
fi

echo ""

# ── 4. SENSITIVE FILES EXPOSED ─────────────────────────────
echo "── 4. SENSITIVE FILES EXPOSURE ─────────────────"

sensitive_files=(
  "/.env"
  "/.git/config"
  "/wp-config.php"
  "/phpinfo.php"
  "/info.php"
  "/backup.zip"
  "/backup.sql"
  "/admin"
  "/.htaccess"
)

for file in "${sensitive_files[@]}"; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET_URL$file")
  if [ "$STATUS" = "200" ]; then
    echo "$FAIL $file is publicly accessible (HTTP $STATUS) — BLOCK IMMEDIATELY"
  elif [ "$STATUS" = "403" ]; then
    echo "$WARN $file returns 403 — file exists but access is blocked (OK)"
  else
    echo "$PASS $file returns $STATUS — not accessible"
  fi
done

echo ""

# ── 5. UPTIME CHECK ────────────────────────────────────────
echo "── 5. SITE AVAILABILITY ────────────────────────"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET_URL")
RESPONSE_TIME=$(curl -s -o /dev/null -w "%{time_total}" "$TARGET_URL")

if [ "$HTTP_STATUS" = "200" ]; then
  echo "$PASS Site is UP (HTTP $HTTP_STATUS)"
  echo "$INFO Response time: ${RESPONSE_TIME}s"
  if (( $(echo "$RESPONSE_TIME > 3" | bc -l) )); then
    echo "$WARN Response time > 3s — page speed optimization needed"
  fi
else
  echo "$FAIL Site returned HTTP $HTTP_STATUS"
fi

echo ""

# ── SUMMARY ────────────────────────────────────────────────
echo "╔══════════════════════════════════════════════╗"
echo "║  Audit complete. Review FAIL items above.    ║"
echo "║  Run monthly. Save output for audit trail.  ║"
echo "║  Full test: https://securityheaders.com     ║"
echo "║  SSL test:  https://www.ssllabs.com/ssltest ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
