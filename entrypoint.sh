#!/bin/bash

export APPLICATION_SECRET="${APPLICATION_SECRET:-$(date +%s | sha256sum | base64 | head -c 64 ; echo)}"
export HTTP_CONTEXT="${HTTP_CONTEXT:-/}"
export ZK_HOSTS="${ZK_HOSTS:-zookeeper:2181}"
export BASE_ZK_PATH="${BASE_ZK_PATH:-/kafka-manager}"
export KAFKA_MANAGER_AUTH_ENABLED="${KAFKA_MANAGER_AUTH_ENABLED:-false}"
export KAFKA_MANAGER_USERNAME="${KAFKA_MANAGER_USERNAME:-admin}"
export KAFKA_MANAGER_PASSWORD="${KAFKA_MANAGER_PASSWORD:-password}"
export KAFKA_MANAGER_AUTH_EXCLUDED_PATHS="${KAFKA_MANAGER_AUTH_EXCLUDED_PATHS:-/api/health}"
KAFKA_MANAGER_CONFIG="${KAFKA_MANAGER_CONFIG:-./conf/application.conf}"
HTTP_PORT="${HTTP_PORT:-9000}"

exec /app/bin/kafka-manager \
  -Dpidfile.path=/dev/null \
  -Dapplication.home=${MESOS_SANDBOX} \
  -Dconfig.file=${KAFKA_MANAGER_CONFIG} \
  -Dhttp.port=${HTTP_PORT} \
  -Djava.security.auth.login.config=${JAAS_CONFIG} \
  -Djava.security.krb5.conf=${KRB5_CONFIG} \
  "${KAFKA_MANAGER_ARGS}" \
  "${@}"
