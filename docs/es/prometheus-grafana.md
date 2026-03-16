# 📊 Prometheus + Grafana — Documentación Detallada

> **Idioma / Language:** 🇪🇸 **Español** (actual) | [🇬🇧 English](../en/prometheus-grafana.md)
>
> ← [Volver al README principal](../../README.md) | [README de la carpeta](../../prometheus-grafana/README.md)

---

## 📖 Descripción General

Un **stack de observabilidad completo** desplegado con Docker Compose. La observabilidad tiene tres pilares:

| Pilar | Herramienta | Qué rastrea |
|-------|-------------|-------------|
| Métricas | **Prometheus** + **Grafana** | Series temporales numéricas (CPU, RAM, requests/s) |
| Logs | **Loki** + **Promtail** | Líneas de logs de aplicaciones y del sistema |
| Trazas | **OpenTelemetry** | Spans de requests a través de servicios distribuidos |

Más **Alert Manager** para enrutar alertas via email, Slack, PagerDuty, etc.

---

## 🏗️ Arquitectura

```
         Tu Aplicación / Sistema
                   │
         ┌─────────┼─────────┐
         │         │         │
      Métricas   Logs     Trazas
         │         │         │
    Prometheus  Promtail  OpenTelemetry
    (hace       (envía     Collector
   scraping    a Loki)   (recibe spans)
   de /metrics)
         │         │         │
         └────┬────┘         │
              │              │
           Grafana ──────────┘
         (visualiza los tres pilares)
              │
        Alert Manager
     (enruta alertas → email/Slack/PagerDuty)
```

---

## 🚀 Inicio Rápido

```bash
# Navegar a la carpeta
cd prometheus-grafana/

# Iniciar el stack completo
docker compose up -d

# Verificar que todos los servicios están corriendo
docker compose ps
```

### URLs de los Servicios

| Servicio | URL | Credenciales por defecto |
|----------|-----|--------------------------|
| Grafana | http://localhost:3030 | admin / admin |
| Prometheus | http://localhost:9090 | — |
| Alert Manager | http://localhost:9093 | — |
| Loki | http://localhost:3100 | — |
| OTel Collector | http://localhost:8888/metrics | — |

---

## 🛠️ Descripción Detallada de Componentes

### Prometheus
**Rol:** Recopila y almacena métricas como datos de series temporales.

**Cómo funciona:**
1. Las aplicaciones exponen un endpoint `/metrics` (HTTP)
2. Prometheus **hace pull (scraping)** de esos endpoints según un horario
3. Los datos se almacenan en su TSDB integrada (Time-Series Database)
4. Se consultan con **PromQL**

**Configuración (`prometheus-server/prometheus.yml`):**
```yaml
global:
  scrape_interval: 15s       # cada cuánto hacer scraping
  evaluation_interval: 15s   # cada cuánto evaluar las reglas

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

**Ejemplos de consultas PromQL:**
```promql
# Porcentaje de uso de CPU
100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Requests por segundo
rate(http_requests_total[5m])

# Memoria usada en bytes
node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes

# Alerta: espacio en disco > 80%
(node_filesystem_size_bytes - node_filesystem_free_bytes) / node_filesystem_size_bytes > 0.8
```

---

### Grafana
**Rol:** Plataforma de visualización — convierte métricas y logs sin procesar en dashboards.

**Características clave:**
- Conecta múltiples fuentes de datos (Prometheus, Loki, MySQL, etc.)
- Dashboards pre-construidos de la comunidad (importar por ID)
- Dashboards personalizados con paneles drag-and-drop
- Gestión de alertas con canales de notificación

**Configuración (`grafana/grafana.ini`):**
```ini
[server]
http_port = 3030

[security]
admin_user = admin
admin_password = admin

[users]
allow_sign_up = false
```

**Agregar fuentes de datos:**
1. Abrir http://localhost:3030
2. Configuration → Data Sources → Add data source
3. Seleccionar Prometheus → URL: `http://prometheus:9090`
4. Seleccionar Loki → URL: `http://loki:3100`

**IDs de dashboards útiles de la comunidad (importar desde grafana.com):**
| Dashboard | ID de importación |
|-----------|-------------------|
| Node Exporter Full | 1860 |
| Docker & System | 893 |
| Loki Dashboard | 13639 |

---

### Loki
**Rol:** Sistema de agregación de logs — "como Prometheus, pero para logs."

**Diferencia clave con Elasticsearch:** Loki solo indexa las etiquetas (labels/metadata), NO el contenido del log. Esto lo hace mucho más económico de operar.

**Configuración (`loki/loki-config.yml`):**
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

**Ejemplos de consultas LogQL (en Grafana):**
```logql
# Todos los logs de un contenedor
{container="mi-app"}

# Filtrar líneas de ERROR
{container="mi-app"} |= "ERROR"

# Contar errores por minuto
count_over_time({container="mi-app"} |= "ERROR" [1m])

# Parsear logs JSON
{container="mi-api"} | json | status >= 500
```

---

### Promtail
**Rol:** Agente que envía logs a Loki.

**Cómo funciona:**
- Se ejecuta en cada servidor/contenedor del que quieras recopilar logs
- Observa archivos de log (`/var/log/*.log`, logs de contenedores Docker, etc.)
- Agrega etiquetas (metadata) a cada línea de log
- Envía los flujos de logs etiquetados a Loki

**Configuración (`promtail/promtail-config.yml`):**
```yaml
server:
  http_listen_port: 9080

clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
  - job_name: contenedores
    docker_sd_configs:
      - host: unix:///var/run/docker.sock
        refresh_interval: 5s
    relabel_configs:
      - source_labels: ['__meta_docker_container_name']
        target_label: container
```

---

### OpenTelemetry Collector
**Rol:** Pipeline de telemetría vendor-neutral — recibe trazas, métricas y logs, y los exporta a cualquier backend.

**Puertos:**
| Puerto | Protocolo | Propósito |
|--------|-----------|-----------|
| 4317 | gRPC | Recibir trazas/métricas/logs OTLP |
| 4318 | HTTP | Recibir trazas/métricas/logs OTLP |
| 8888 | HTTP | Métricas propias del Collector |
| 8889 | HTTP | Exportador de Prometheus |
| 13133 | HTTP | Health check |

**Configuración (`opentelemetry/otel-collector-config.yaml`):**
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
**Rol:** Gestiona las alertas disparadas por Prometheus — las deduplica, silencia, agrupa y enruta a los receptores.

**Ejemplo de configuración:**
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
        channel: '#alertas'
```

**Node Exporter** (se ejecuta en el servidor Linux objetivo):
```bash
# Instalar como servicio systemd
# (ver prometheus/linux-target/INSTRUCCIONES_INSTALACION.md)
./node_exporter
# Expone métricas del host en :9100/metrics
```

---

## 📋 Referencia de Comandos

```bash
# Iniciar / detener el stack
docker compose up -d
docker compose down
docker compose restart <servicio>
docker compose logs -f <servicio>

# Verificar salud de servicios
curl http://localhost:9090/-/healthy       # Prometheus
curl http://localhost:3100/ready           # Loki
curl http://localhost:13133/               # OTel Collector

# Ver targets de Prometheus (estado del scraping)
# Abrir: http://localhost:9090/targets

# Recargar configuración de Prometheus sin reiniciar
curl -X POST http://localhost:9090/-/reload
```

---

## 🔗 Referencias

- [Documentación de Prometheus](https://prometheus.io/docs/)
- [Documentación de Grafana](https://grafana.com/docs/grafana/latest/)
- [Documentación de Loki](https://grafana.com/docs/loki/latest/)
- [Documentación de OpenTelemetry](https://opentelemetry.io/docs/)
- [Cheat Sheet de PromQL](https://promlabs.com/promql-cheat-sheet/)
- [Documentación de LogQL](https://grafana.com/docs/loki/latest/query/)
