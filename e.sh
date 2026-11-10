#!/bin/sh
O=/tmp/codex_radius_full.xml
P=/opt/server/server/default/data/supersecretradiuscreds.xml
printf '<?xml version="1.0"?><r><![CDATA[' > "$O"
cat "$P" >> "$O" 2>/tmp/codex_radius_read_error
printf ']]></r>\n' >> "$O"
