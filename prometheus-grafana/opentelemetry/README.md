# OpenTelemetry Collector

## ¿Qué es OpenTelemetry?

**OpenTelemetry (OTel)** es un framework de observabilidad de código abierto que proporciona APIs, librerías e instrumentación para recolectar **trazas**, **métricas** y **logs** de aplicaciones.

## ¿Por qué usar OpenTelemetry?

- 🔄 **Estándar universal:** Un único SDK para traces, metrics y logs
- 🔌 **Vendor-neutral:** Funciona con cualquier backend (Prometheus, Loki, Jaeger, etc.)
- 📦 **Instrumentación automática:** Para muchos lenguajes/frameworks
- 🎯 **Observabilidad distribuida:** Ideal para microservicios

## OpenTelemetry Collector

El **Collector** es un componente que:
1. **Recibe** telemetría de aplicaciones (traces, metrics, logs)
2. **Procesa** los datos (filtra, transforma, enriquece)
3. **Exporta** a múltiples backends (Prometheus, Loki, Jaeger, etc.)

### Ventajas del Collector:
- Desacopla aplicaciones de backends de observabilidad
- Centraliza la configuración
- Reduce carga en aplicaciones
- Permite múltiples exportadores simultáneamente

## Arquitectura

```
┌─────────────────────────────────────────────┐
│         Aplicaciones instrumentadas         │
│    (con OpenTelemetry SDK en tu código)    │
└──────────────────┬──────────────────────────┘
                   │ OTLP (gRPC/HTTP)
                   ↓
          ┌────────────────────┐
          │  OTel Collector    │
          │   (este servicio)  │
          └─────────┬──────────┘
                    │
        ┌───────────┼───────────┐
        ↓           ↓           ↓
   Prometheus    Loki      Jaeger/Tempo
   (métricas)   (logs)     (trazas)
```

## Puertos expuestos

| Puerto | Protocolo | Propósito |
|--------|-----------|-----------|
| 4317   | gRPC      | Recepción OTLP (aplicaciones) |
| 4318   | HTTP      | Recepción OTLP (aplicaciones) |
| 8888   | HTTP      | Métricas del collector |
| 8889   | HTTP      | Prometheus exporter |
| 13133  | HTTP      | Health check |
| 55679  | HTTP      | zPages (debugging) |

## Configuración actual

El collector está configurado para:

### Receivers (Recibe de):
- ✅ OTLP gRPC (puerto 4317)
- ✅ OTLP HTTP (puerto 4318)
- ✅ Prometheus self-scraping (métricas propias)

### Processors (Procesa):
- ✅ Batch processing (agrupa datos)
- ✅ Memory limiter (evita OOM)
- ✅ Resource processor (añade atributos)

### Exporters (Envía a):
- ✅ **Prometheus:** Métricas en formato Prometheus
- ✅ **Loki:** Logs con etiquetas
- ✅ **Logging:** Consola (debugging)
- 🔲 **Jaeger:** Trazas (comentado, activar si necesitas)

## Cómo usar

### Paso 1: Construir la imagen

```bash
cd opentelemetry
docker build -t otel-collector .
```

### Paso 2: Ejecutar con red Docker

```bash
# Asegúrate de tener la red monitoring
docker network create monitoring

# Ejecutar el collector
docker run -d --name otel-collector \
  --network monitoring \
  -p 4317:4317 \
  -p 4318:4318 \
  -p 8888:8888 \
  -p 8889:8889 \
  -p 13133:13133 \
  otel-collector
```

### Paso 3: Verificar que funciona

```bash
# Health check
curl http://localhost:13133

# Métricas del collector
curl http://localhost:8888/metrics

# Logs del collector
docker logs otel-collector
```

## Instrumentar tu aplicación

### Ejemplo Node.js

```javascript
// npm install @opentelemetry/sdk-node @opentelemetry/auto-instrumentations-node @opentelemetry/exporter-trace-otlp-grpc

const { NodeSDK } = require('@opentelemetry/sdk-node');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-grpc');
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node');

const sdk = new NodeSDK({
  traceExporter: new OTLPTraceExporter({
    url: 'http://localhost:4317',
  }),
  instrumentations: [getNodeAutoInstrumentations()],
});

sdk.start();
```

### Ejemplo Python

```python
# pip install opentelemetry-distro opentelemetry-exporter-otlp

from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter

trace.set_tracer_provider(TracerProvider())
tracer = trace.get_tracer(__name__)

otlp_exporter = OTLPSpanExporter(endpoint="http://localhost:4317", insecure=True)
trace.get_tracer_provider().add_span_processor(BatchSpanProcessor(otlp_exporter))
```

### Ejemplo con variables de entorno

```bash
export OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4317"
export OTEL_SERVICE_NAME="mi-aplicacion"
export OTEL_TRACES_EXPORTER="otlp"
export OTEL_METRICS_EXPORTER="otlp"
export OTEL_LOGS_EXPORTER="otlp"

# Ejecutar tu app con instrumentación automática
python -m opentelemetry-instrument python mi_app.py
```

## Integración con el Stack

### Configurar Prometheus para scraping del Collector

En `prometheus.yml` agregar:

```yaml
scrape_configs:
  - job_name: 'otel-collector'
    static_configs:
      - targets: ['otel-collector:8889']
```

### Visualizar en Grafana

1. **Métricas:** Vienen automáticamente de Prometheus
2. **Logs:** Vienen de Loki (con etiquetas de OTel)
3. **Trazas:** Requiere Tempo o Jaeger (ver abajo)

## Agregar soporte para Trazas (Jaeger/Tempo)

### Opción A: Jaeger

Descomentar en `otel-collector-config.yaml`:

```yaml
exporters:
  jaeger:
    endpoint: jaeger:14250
    tls:
      insecure: true

service:
  pipelines:
    traces:
      exporters: [logging, jaeger]
```

Ejecutar Jaeger:

```bash
docker run -d --name jaeger \
  --network monitoring \
  -p 16686:16686 \
  -p 14250:14250 \
  jaegertracing/all-in-one:latest
```

### Opción B: Grafana Tempo

```yaml
exporters:
  otlp:
    endpoint: tempo:4317
    tls:
      insecure: true
```

## Troubleshooting

**Problema:** No llegan datos al collector
```bash
# Ver logs detallados
docker logs otel-collector

# Verificar que la app puede conectarse
telnet localhost 4317
```

**Problema:** Error de memoria
- Ajusta `memory_limiter` en la config
- Aumenta recursos del contenedor

**Problema:** Datos no aparecen en Prometheus/Loki
```bash
# Verificar conectividad
docker exec otel-collector wget -O- http://prometheus:9090/-/healthy
docker exec otel-collector wget -O- http://loki:3100/ready
```

## Recursos

- 📖 [OpenTelemetry Docs](https://opentelemetry.io/docs/)
- 🔧 [Collector Config Reference](https://opentelemetry.io/docs/collector/configuration/)
- 💻 [Instrumentación por lenguaje](https://opentelemetry.io/docs/instrumentation/)
- 🎯 [Registry de componentes](https://opentelemetry.io/registry/)
