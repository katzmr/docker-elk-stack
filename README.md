# 🚀 ELK Stack (Elasticsearch, Logstash, Kibana) v9.0.1
> 🔐 Configured with self-signed SSL/TLS certificates

## ⚠️ Requirements

- Docker: https://docs.docker.com/get-docker/
- Docker Compose: https://docs.docker.com/compose/install/
- CPU with support for x86-64-v2 architecture

---
## 🚀 Getting Started
### 📦 1. Clone the Repository

```bash
git clone https://github.com/katzmr/docker-elk-stack.git
cd docker-elk-stack
```
### ⚙️ 2. Configure Environment Variables
Rename the example environment file:
```bash
mv .env.example .env
```
Edit the .env file with your preferred editor:
```bash
nano .env
```
> ✏️ _Update values like ELASTIC_PASSWORD, KIBANA_PASSWORD, LOGSTASH_USER, LOGSTASH_PASSWORD, ELASTICSEARCH_HOST, KIBANA_URL, KIBANA_SECRET, KIBANA_USER._

### 🛠️ 3. Build and Start the Stack
Use Docker Compose to build and run the containers:
```bash
docker compose up --build -d
```
> 🐳 _This command will build all necessary images and run them in detached mode._

### ✅ 4. Access the Services
Once everything is up and running, you can access the services at:

- Elasticsearch: https://localhost:9200
- Kibana: https://localhost:5601
> ⚠️ _Since the certificates are self-signed, your browser may show a security warning when accessing Kibana. You can safely proceed after confirming the exception._
---
## 🧩 Environment Variables Overview (.env)
| Variable             | Description                 | Default                             |
|----------------------|-----------------------------|-------------------------------------|
| `ELASTIC_PASSWORD`   | Password for `elastic` user | `ElasticPassword1`                  |
| `KIBANA_USER`        | Kibana internal user        | `kibana_elk`                        |
| `KIBANA_PASSWORD`    | Kibana user password        | `KibanaPassword1`                   |
| `LOGSTASH_USER`      | Logstash internal user      | `logstash_elk`                      |
| `LOGSTASH_PASSWORD`  | Logstash user password      | `LogstashPassword1`                 |
| `ELASTICSEARCH_HOST` | Host URL for Elasticsearch  | `https://elasticsearch:9200`        |
| `KIBANA_URL`         | Kibana base URL             | `https://localhost:5601`            |
| `KIBANA_SECRET`      | Kibana secret key           | `k9P3v6sFz2LmX8Wa0YeTqGhJb7CrNuDi`  |
| `VERSION`            | Version                     | `9.0.1`                             |
---
## ✨ Updating the Certificates
```bash
docker exec -it elasticsearch bash /usr/local/bin/generate_new_certificates.sh
```
This script will:
- Remove old certificates (if they exist).
- Generate new CA (Certificate Authority).
- Generate a new private key for Elasticsearch.
- Create a new Certificate Signing Request (CSR) for Elasticsearch.
- Sign the new Elasticsearch certificate with the newly generated CA.

> ⚠️ _After the new certificates are generated, restart the Docker Compose to apply the new certificates:_
> ```bash
> docker compose restart
> ```