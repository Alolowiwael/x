#!/bin/sh
O=/tmp/codex_flag_search.xml
P=/opt/out/instance/server/default
printf '<?xml version="1.0"?><r>\n' > "$O"
find "$P/conf" "$P/data" -type f -name '*.xml' 2>/dev/null | while IFS= read -r f; do
  if grep -q 'CLF{' "$f" 2>/dev/null; then
    printf '<f>%s</f>\n' "$f" >> "$O"
  fi
done
printf '</r>\n' >> "$O"
