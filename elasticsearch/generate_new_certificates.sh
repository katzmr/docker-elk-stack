#!/bin/bash

CERT_DIR="/usr/share/elasticsearch/config/certs"

CA_KEY="$CERT_DIR/ca.key"
CA_CERT="$CERT_DIR/ca.crt"
ES_KEY="$CERT_DIR/elasticsearch.key"
ES_CERT="$CERT_DIR/elasticsearch.crt"
ES_CSR="$CERT_DIR/elasticsearch.csr"

# Removing old certificates if they exist
echo "[INFO] Deleting old certificates..."
rm -f "$CA_KEY" "$CA_CERT" "$ES_KEY" "$ES_CERT" "$ES_CSR"

# Generating new certificates
echo "[INFO] Generating new certificates..."

# Generating a new CA (Certificate Authority)
openssl genrsa -out "$CA_KEY" 4096
openssl req -x509 -new -nodes -key "$CA_KEY" -sha256 -days 365 \
  -subj "/C=US/ST=ELK/L=Stack/O=DevOps/CN=Elasticsearch Root CA" \
  -out "$CA_CERT"

# Generating a new key for Elasticsearch
openssl genrsa -out "$ES_KEY" 2048

# Generating a new CSR (Certificate Signing Request) for Elasticsearch
openssl req -new -key "$ES_KEY" \
  -subj "/C=US/ST=ELK/L=Stack/O=DevOps/CN=elasticsearch" \
  -out "$ES_CSR"

# igning the new Elasticsearch certificate using the CA
openssl x509 -req -in "$ES_CSR" -CA "$CA_CERT" -CAkey "$CA_KEY" \
  -CAcreateserial -out "$ES_CERT" -days 365 -sha256

echo "[INFO] New certificates generated successfully."

# Checking the success of certificate generation
if [[ -f "$CA_KEY" && -f "$CA_CERT" && -f "$ES_KEY" && -f "$ES_CERT" ]]; then
  echo "[OK] New certificates are ready."
else
  echo "[ERROR] Certificate generation failed."
  exit 1
fi