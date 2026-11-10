#!/bin/sh
O=/tmp/rce.xml
printf "<?xml version=\"1.0\"?>\n<r>\n" > "$O"
P=/opt/out/instance/server/default
for d in $P/conf $P/conf/META-INF $P/conf/data-default $P/conf/data-default/config-store $P/conf/template $P/conf/template/connections $P/conf/template/ws-policy $P/conf/template/wsdl $P/data $P/data/config-store $P/data/adapter-config $P/data/drop-in-deployer $P/data/connection-deployer $P/data/local $P/data/module $P/data/hypersonic $P/conf/provisioner; do
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
