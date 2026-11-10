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

