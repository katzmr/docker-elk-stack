#!/bin/bash

CERT_DIR="/usr/share/elasticsearch/config/certs"
INIT_FILE="/usr/share/elasticsearch/data/init"

CA_KEY="$CERT_DIR/ca.key"
CA_CERT="$CERT_DIR/ca.crt"
ES_KEY="$CERT_DIR/elasticsearch.key"
ES_CERT="$CERT_DIR/elasticsearch.crt"
ES_CSR="$CERT_DIR/elasticsearch.csr"

mkdir -p "$CERT_DIR"

# Generating certificates (if they do not exist)
if [[ ! -f "$CA_CERT" || ! -f "$ES_CERT" ]]; then
  echo "[INFO] Generating TLS certificates..."

  # Generating CA (Certificate Authority)
  openssl genrsa -out "$CA_KEY" 4096
  openssl req -x509 -new -nodes -key "$CA_KEY" -sha256 -days 365 \
    -subj "/C=US/ST=ELK/L=Stack/O=DevOps/CN=Elasticsearch Root CA" \
    -out "$CA_CERT"

  # Generating key and certificate signing request (CSR) for Elasticsearch
  openssl genrsa -out "$ES_KEY" 2048
  openssl req -new -key "$ES_KEY" \
    -subj "/C=US/ST=ELK/L=Stack/O=DevOps/CN=elasticsearch" \
    -out "$ES_CSR"

  # Signing the Elasticsearch certificate
  openssl x509 -req -in "$ES_CSR" -CA "$CA_CERT" -CAkey "$CA_KEY" \
    -CAcreateserial -out "$ES_CERT" -days 365 -sha256
  echo "[INFO] TLS certificates generated."
else
  echo "[OK] Certificates already exist."
fi

# Starting Elasticsearch
/usr/local/bin/docker-entrypoint.sh &
es_pid=$!

# Waiting for the cluster to become available
until curl -sk --cacert "$CA_CERT" -u elastic:${ELASTIC_PASSWORD} ${ELASTICSEARCH_HOST}/_cluster/health | grep -q '"status":"yellow"\|"status":"green"'; do
  echo "[WAIT] Waiting for Elasticsearch..."
  sleep 3
done

# Checking login as elastic user
until curl -sk --cacert "$CA_CERT" -u elastic:${ELASTIC_PASSWORD} ${ELASTICSEARCH_HOST}/_security/_authenticate | grep elastic; do
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