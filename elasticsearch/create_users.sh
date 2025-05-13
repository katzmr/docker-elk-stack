#!/bin/bash

set -e

AUTH="elastic:${ELASTIC_PASSWORD}"
HEADERS=(-H "Content-Type: application/json")

# Check if user exists
user_exists() {
  local user=$1
  local code=$(curl -u "${AUTH}" -s -o /dev/null -w "%{http_code}" "${ELASTICSEARCH_HOST}/_security/user/${user}")
  [[ "$code" -eq 200 ]]
}

# Create user
create_user() {
  local user=$1
  local pass=$2
  local role=$3

  echo "[INFO] Create user '${user}' with role '${role}'..."

  curl -u "${AUTH}" -s "${ELASTICSEARCH_HOST}/_security/user/${user}" \
    -X POST "${HEADERS[@]}" \
    -d '{
      "password": "'"${pass}"'",
      "roles": ["'"${role}"'"],
      "full_name": "'"${user}"'",
      "enabled": true
    }'
}

# Create role logstash_writer
create_logstash_writer_role() {
  echo "[INFO] Create role 'logstash_writer'..."
  curl -u "${AUTH}" -s -X POST "${ELASTICSEARCH_HOST}/_security/role/logstash_writer" \
    "${HEADERS[@]}" \
    -d '{
      "cluster": ["manage_index_templates", "monitor"],
      "indices": [
        {
          "names": ["*"],
          "privileges": ["read", "write", "create_index", "delete"]
        }
      ]
    }'
}

# === MAIN  ===

# Check/create KIBANA_USER
if user_exists "${KIBANA_USER}"; then
  echo "[INFO] User '${KIBANA_USER}' is already exists. Skipping..."
else
  echo "[INFO] User '${KIBANA_USER}' not found. Creating..."
  create_user "${KIBANA_USER}" "${KIBANA_PASSWORD}" "kibana_system"
fi

# Check/create LOGSTASH_USER
if user_exists "${LOGSTASH_USER}"; then
  echo "[INFO] User '${LOGSTASH_USER}' is already exists. Skipping..."
else
  echo "[INFO] User '${LOGSTASH_USER}' not found. Creating..."
  create_logstash_writer_role
  create_user "${LOGSTASH_USER}" "${LOGSTASH_PASSWORD}" "logstash_writer"
fi