ARG PG_VERSION=18
ARG WALG_IMAGE=healthsamurai/wal-g:v3.0.5

FROM ${WALG_IMAGE} AS walg
FROM postgres:${PG_VERSION}

ARG POSTGIS_MAJOR=3

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      ca-certificates \
      postgresql-${PG_MAJOR}-postgis-${POSTGIS_MAJOR} \
      postgresql-${PG_MAJOR}-repack \
      postgresql-${PG_MAJOR}-wal2json

COPY --from=walg --chmod=755 /usr/bin/wal-g /usr/local/bin/wal-g
COPY --chmod=755 aidboxdb-docker-entrypoint.sh restore.sh /usr/local/bin/

ENTRYPOINT ["aidboxdb-docker-entrypoint.sh"]
CMD ["postgres"]
