#!/bin/sh
O=/tmp/codex_radius_b64.xml
P=/opt/server/server/default/data/supersecretradiuscreds.xml
printf '<?xml version="1.0"?><r>' > "$O"
base64 "$P" | tr -d '\n' >> "$O"
printf '</r>\n' >> "$O"
