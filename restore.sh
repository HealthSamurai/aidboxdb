#!/usr/bin/env bash
set -Eeo pipefail

source /usr/local/bin/docker-entrypoint.sh

docker_setup_env

if [ -n "$DATABASE_ALREADY_EXISTS" ]; then
  if [ -z "${FORCE_RESTORE:-}" ]; then
    cat >&2 <<-'EOF'
      Error: Database is initialized. Please make sure $PGDATA is empty.

             Set FORCE_RESTORE env to remove the data from $PGDATA before restore from backup.
EOF
    exit 1
  else
    echo "Removing existing data and creating cluster from backup"
    find $PGDATA -mindepth 1 -delete
  fi
fi

docker_create_db_directories
gosu postgres wal-g backup-fetch ${PGDATA} ${RESTORE_BACKUP_NAME:-LATEST}
gosu postgres touch $PGDATA/recovery.signal

echo "Disable $0 command in docker/k8s"
echo "Still running to prevent possible pod recreation issue"
echo "Feel free to stop/terminate in any time"

trap : TERM INT
sleep infinity &
wait
