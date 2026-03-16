# 📊 Prometheus + Grafana — Detailed Documentation

> **Language / Idioma:** 🇬🇧 **English** (current) | [🇪🇸 Español](../es/prometheus-grafana.md)
>
> ← [Back to main README](../../README.md) | [Folder README](../../prometheus-grafana/README.md)

---

## 📖 Overview

A full **observability stack** deployed with Docker Compose. Observability has three pillars:

| Pillar | Tool | What it tracks |
|--------|------|---------------|
| Metrics | **Prometheus** + **Grafana** | Numeric time-series (CPU, RAM, requests/s) |
| Logs | **Loki** + **Promtail** | Application and system log lines |
| Traces | **OpenTelemetry** | Request spans across distributed services |

Plus **Alert Manager** for routing alerts via email, Slack, PagerDuty, etc.

---

## 🏗️ Architecture

```
         Your Application / System
                   │
         ┌─────────┼─────────┐
         │         │         │
      Metrics    Logs     Traces
         │         │         │
    Prometheus  Promtail  OpenTelemetry
    (scrapes    (ships     Collector
   /metrics)   to Loki)  (receives spans)
         │         │         │
         └────┬────┘         │
              │              │
           Grafana ──────────┘
         (visualizes all three)
              │
        Alert Manager
     (routes alerts → email/Slack/PagerDuty)
```

---

## 🚀 Quick Start

```bash
# Clone / navigate to the folder
cd prometheus-grafana/

# Start the entire stack
docker compose up -d

# Check all services are running
docker compose ps
```

### Service URLs

| Service | URL | Default Credentials |
|---------|-----|---------------------|
| Grafana | http://localhost:3030 | admin / admin |
| Prometheus | http://localhost:9090 | — |
| Alert Manager | http://localhost:9093 | — |
| Loki | http://localhost:3100 | — |
| OTel Collector | http://localhost:8888/metrics | — |

---

## 🛠️ Component Deep Dives

### Prometheus
**Role:** Collects and stores metrics as time-series data.

**How it works:**
1. Applications expose a `/metrics` endpoint (HTTP)
2. Prometheus **pulls (scrapes)** those endpoints on a schedule
3. Data is stored in its built-in TSDB (Time-Series Database)
4. Query with **PromQL**

**Configuration (`prometheus-server/prometheus.yml`):**
```yaml
global:
  scrape_interval: 15s       # how often to scrape
  evaluation_interval: 15s   # how often to evaluate rules

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

rule_files:
  - "alert-rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets: ['alertmanager:9093']
```

**PromQL examples:**
```promql
# CPU usage percentage
100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# HTTP requests per second
rate(http_requests_total[5m])

# Memory used in bytes
node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes

# Alert: disk space > 80%
(node_filesystem_size_bytes - node_filesystem_free_bytes) / node_filesystem_size_bytes > 0.8
```

---

### Grafana
**Role:** Visualization platform — turns raw metrics and logs into dashboards.

**Key features:**
- Connect to multiple data sources (Prometheus, Loki, MySQL, etc.)
- Pre-built community dashboards (import by ID)
- Custom dashboards with drag-and-drop panels
- Create and manage alerts with notification channels

**Configuration (`grafana/grafana.ini`):**
```ini
[server]
http_port = 3030

[security]
admin_user = admin
admin_password = admin

[users]
allow_sign_up = false
```

**Adding datasources:**
1. Open http://localhost:3030
2. Configuration → Data Sources → Add data source
3. Select Prometheus → URL: `http://prometheus:9090`
4. Select Loki → URL: `http://loki:3100`

**Useful community dashboard IDs (import from grafana.com):**
| Dashboard | Import ID |
|-----------|-----------|
| Node Exporter Full | 1860 |
| Docker & System | 893 |
| Loki Dashboard | 13639 |

---

### Loki
**Role:** Log aggregation system — "like Prometheus, but for logs."

**Key difference from Elasticsearch:** Loki only indexes labels (metadata), NOT the log content. This makes it far cheaper to operate.

**Configuration (`loki/loki-config.yml`):**
```yaml
auth_enabled: false

server:
  http_listen_port: 3100

ingester:
  chunk_idle_period: 1h
  max_chunk_age: 1h

storage_config:
  boltdb_shipper:
    active_index_directory: /loki/boltdb-shipper-active
  filesystem:
    directory: /loki/chunks
```

**LogQL query examples (in Grafana):**
```logql
# All logs from a container
{container="my-app"}

# Filter for ERROR lines
{container="my-app"} |= "ERROR"

# Count errors per minute
count_over_time({container="my-app"} |= "ERROR" [1m])

# Parse JSON logs
{container="my-api"} | json | status >= 500
```

---

### Promtail
**Role:** Agent that ships logs to Loki.

**How it works:**
- Runs on every server/container you want to collect logs from
- Watches log files (`/var/log/*.log`, Docker container logs, etc.)
- Adds labels (metadata) to each log line
- Ships labeled log streams to Loki

**Configuration (`promtail/promtail-config.yml`):**
```yaml
server:
  http_listen_port: 9080

clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
  - job_name: containers
    docker_sd_configs:
      - host: unix:///var/run/docker.sock
        refresh_interval: 5s
    relabel_configs:
      - source_labels: ['__meta_docker_container_name']
        target_label: container
```

---

### OpenTelemetry Collector
**Role:** Vendor-neutral telemetry pipeline — receives traces, metrics, and logs, then exports them to any backend.

**Ports:**
| Port | Protocol | Purpose |
|------|----------|---------|
| 4317 | gRPC | Receive OTLP traces/metrics/logs |
| 4318 | HTTP | Receive OTLP traces/metrics/logs |
| 8888 | HTTP | Collector's own metrics |
| 8889 | HTTP | Prometheus exporter |
| 13133 | HTTP | Health check |

**Configuration (`opentelemetry/otel-collector-config.yaml`):**
```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch: {}

exporters:
  prometheus:
    endpoint: "0.0.0.0:8889"
  loki:
    endpoint: http://loki:3100/loki/api/v1/push

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [logging]
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [prometheus]
```

---

### Alert Manager
**Role:** Handles alerts fired by Prometheus, deduplicates, silences, groups, and routes them to receivers.

**Configuration example:**
```yaml
route:
  receiver: 'slack'
  group_by: ['alertname', 'instance']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 3h

receivers:
  - name: 'slack'
    slack_configs:
      - api_url: 'https://hooks.slack.com/...'
        channel: '#alerts'
```

**Node Exporter** (runs on the target Linux server):
```bash
# Install as a systemd service (see prometheus/linux-target/INSTRUCCIONES_INSTALACION.md)
./node_exporter
# Exposes host metrics at :9100/metrics
```

---

## 📋 Commands Reference

```bash
# Start / stop stack
docker compose up -d
docker compose down
docker compose restart <service>
docker compose logs -f <service>

# Check service health
curl http://localhost:9090/-/healthy       # Prometheus
curl http://localhost:3100/ready           # Loki
curl http://localhost:13133/               # OTel Collector

# Prometheus targets (see scrape status)
# Open: http://localhost:9090/targets

# Reload Prometheus config without restart
curl -X POST http://localhost:9090/-/reload
```

---

## 🔗 References

- [Prometheus Docs](https://prometheus.io/docs/)
- [Grafana Docs](https://grafana.com/docs/grafana/latest/)
- [Loki Docs](https://grafana.com/docs/loki/latest/)
- [OpenTelemetry Docs](https://opentelemetry.io/docs/)
- [PromQL Cheat Sheet](https://promlabs.com/promql-cheat-sheet/)
- [LogQL Docs](https://grafana.com/docs/loki/latest/query/)
