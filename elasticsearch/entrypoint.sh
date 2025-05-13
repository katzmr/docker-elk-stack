#!/bin/bash

# Starting Elasticsearch
/usr/local/bin/docker-entrypoint.sh &
es_pid=$!

# Waiting for the cluster to become available
until curl -s -u elastic:${ELASTIC_PASSWORD} ${ELASTICSEARCH_HOST}/_cluster/health | grep -q '"status":"yellow"\|"status":"green"'; do
  echo "[WAIT] Waiting for Elasticsearch..."
  sleep 3
done

# Checking login as elastic user
until curl -s -u elastic:${ELASTIC_PASSWORD} ${ELASTICSEARCH_HOST}/_security/_authenticate | grep elastic; do
  echo "[WAIT] Elastic user not ready. Checking availability..."
  sleep 2
done

echo "[OK] Elasticsearch is available"

# Run user creation only once (on first initialization)
INIT_FILE="/usr/share/elasticsearch/data/init"

if [ ! -f "$INIT_FILE" ]; then
  echo "[INFO] Running user creation script..."
  /usr/local/bin/create_users.sh \
    "$KIBANA_USER" "$KIBANA_PASSWORD" \
    "$LOGSTASH_USER" "$LOGSTASH_PASSWORD" \
    "$ELASTIC_PASSWORD" "$ELASTICSEARCH_HOST"

  # Mark as initialized
  touch "$INIT_FILE"
  echo "[INFO] User creation complete. Initialization file created."
else
  echo "[OK] Already initialized"
fi

# Waiting for the main Elasticsearch process to finish
wait "$es_pid"