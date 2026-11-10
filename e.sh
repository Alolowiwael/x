#!/bin/sh
for name in secret radius; do
  if [ "$name" = secret ]; then
    P=/secrets.xml
  else
    P=/opt/server/server/default/data/supersecretradiuscreds.xml
  fi
  O="/tmp/codex_${name}_full.xml"
  printf '<?xml version="1.0"?><r><![CDATA[' > "$O"
  cat "$P" >> "$O"
  printf ']]></r>\n' >> "$O"
done
