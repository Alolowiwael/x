#!/bin/sh
O=/tmp/codex_term_scan.xml
find / \( -path /proc -o -path /sys -o -path /dev \) -prune -o -type f -iname '*.xml' -print 2>/dev/null |
  while IFS= read -r f; do
    if grep -Eiq 'challenge|ex1|calif' "$f" 2>/dev/null; then
      printf '%s\n' "$f"
    fi
  done | awk 'BEGIN { print "<?xml version=\"1.0\"?><r><f>" }
       NR > 1 && (NR - 1) % 20 == 0 { print "</f><f>" }
       { print $0 }
       END { print "</f></r>" }' > "$O"
