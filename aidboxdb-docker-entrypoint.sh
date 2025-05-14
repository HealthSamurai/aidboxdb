#!/usr/bin/env bash

declare -A locales
for x in $LC_COLLATE $LC_CTYPE $LC_MESSAGES $LC_MONETARY $LC_NUMERIC $LC_TIME; do
  locales["${x}"]=1
done
while read x; do
  if [ ! -z "${x}" ]; then
    locales["${x}"]=1
  fi
done <<< "$(echo "$EXTRA_LOCALES" | sed -e 's/,/\n/g')"
if [ "${#locales[@]}" -gt 0 ]; then
  for x in "${!locales[@]}"; do
    echo "${x} UTF-8" >> /etc/locale.gen
  done
  locale-gen
fi

source /usr/local/bin/docker-entrypoint.sh

docker_setup_env

if [ -z "${DATABASE_ALREADY_EXISTS}" ]; then
  export POSTGRES_INITDB_ARGS="${POSTGRES_INITDB_ARGS} --lc-collate=${LC_COLLATE} --lc-ctype=${LC_CTYPE} --lc-messages=${LC_MESSAGES} --lc-monetary=${LC_MONETARY} --lc-numeric=${LC_NUMERIC} --lc-time=${LC_TIME}"
fi

_main "$@"
