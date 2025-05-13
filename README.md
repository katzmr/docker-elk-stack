# 🚀 ELK Stack (Elasticsearch, Logstash, Kibana) v9.0.1

Deploy a ELK stack using Docker Compose.

## ⚠️ Requirements

- Docker: https://docs.docker.com/get-docker/
- Docker Compose: https://docs.docker.com/compose/install/
- CPU with support for x86-64-v2 architecture

---
## 📦 1. Clone the Repository

```bash
git clone https://github.com/katzmr/docker-elk-stack.git
cd docker-elk-stack
```
## ⚙️ 2. Configure Environment Variables
Rename the example environment file:
```bash
mv .env.example .env
```
Edit the .env file with your preferred editor:
```bash
nano .env
```
> ✏️ Tip: Update values like _ELASTIC_PASSWORD_, _KIBANA_PASSWORD_, _LOGSTASH_PASSWORD_, _ELASTICSEARCH_HOST_, _KIBANA_URL_.

## 🛠️ 3. Build and Start the Stack
Use Docker Compose to build and run the containers:
```bash
docker compose up --build -d
```
> 🐳 This command will build all necessary images and run them in detached mode.

## ✅ 4. Access the Services
Once everything is up and running, you can access the services at:

- Elasticsearch: http://localhost:9200
- Kibana: http://localhost:5601

## 🧩 Environment Variables Overview (.env)
| Variable             | Description                 | Default                     |
|----------------------|-----------------------------|-----------------------------|
| `ELASTIC_PASSWORD`   | Password for `elastic` user | `ElasticPassword1`          |
| `KIBANA_USER`        | Kibana internal user        | `kibana_elk`                |
| `KIBANA_PASSWORD`    | Kibana user password        | `KibanaPassword1`           |
| `LOGSTASH_USER`      | Logstash internal user      | `logstash_elk`              |
| `LOGSTASH_PASSWORD`  | Logstash user password      | `LogstashPassword1`         |
| `ELASTICSEARCH_HOST` | Host URL for Elasticsearch  | `http://elasticsearch:9200` |
| `KIBANA_URL`         | Kibana base URL             | `http://localhost:5601`     |
| `VERSION`            | Version                     | `9.0.1`                     |