# 📊 Stack de Monitoreo: Prometheus, Grafana, Loki y OpenTelemetry

> **Language / Idioma:** [🇬🇧 English](../docs/en/prometheus-grafana.md) | 🇪🇸 **Español** (actual)
>
> ← [Volver al README principal](../README.md) · [Docs detallados ES](../docs/es/prometheus-grafana.md) · [Detailed EN docs](../docs/en/prometheus-grafana.md)

## 🎯 ¿Qué es cada herramienta?

### Prometheus
**Sistema de monitoreo y alertas para métricas en tiempo real**

- 📈 **Función:** Recolecta y almacena métricas numéricas (CPU, RAM, requests/segundo, etc.)
- 🔍 **Cómo funciona:** Hace "scraping" de endpoints `/metrics` cada X segundos
- 💾 **Almacenamiento:** Time-series database (TSDB)
- 📡 **Puerto por defecto:** 9090
- **Ejemplo de uso:** Monitorear uso de CPU, memoria, tiempo de respuesta de APIs

### Grafana
**Plataforma de visualización y dashboards**

- 📊 **Función:** Crea dashboards hermosos para visualizar datos de múltiples fuentes
- 🔌 **Datasources:** Prometheus, Loki, MySQL, PostgreSQL, InfluxDB, etc.
- 🎨 **Características:** Gráficas, alertas, paneles personalizables
- 📡 **Puerto por defecto:** 3000 (modificado a 3030 en este proyecto)
- **Ejemplo de uso:** Dashboard con gráficas de métricas de Prometheus y logs de Loki

### Loki
**Sistema de agregación de logs**

- 📝 **Función:** Recolecta, almacena y permite buscar logs (registros de aplicaciones)
- 🎯 **Filosofía:** "Como Prometheus, pero para logs"
- 🏷️ **Indexación:** Solo indexa labels (etiquetas), no el contenido completo del log
- 📡 **Puerto por defecto:** 3100
- **Ejemplo de uso:** Ver logs de errores de una aplicación cuando las métricas muestran un problema

### Promtail
**Agente para recolección de logs**

- 📂 **Función:** Lee logs de archivos/sistemas y los envía a Loki
- 🔄 **Cómo funciona:** Monitorea archivos de log, los parsea y envía a Loki
- 🏷️ **Labels:** Agrega etiquetas (metadata) a los logs para identificarlos
- 📡 **Puerto por defecto:** 9080 (métricas y health checks)
- **Ejemplo de uso:** Leer logs de `/var/log/*.log` y enviarlos a Loki

### OpenTelemetry
**Framework de observabilidad y colector de telemetría**

- 🔄 **Función:** Recolecta trazas (traces), métricas y logs de aplicaciones instrumentadas
- 🌐 **Estándar:** Vendor-neutral, funciona con cualquier backend
- 📦 **Collector:** Recibe, procesa y exporta telemetría a múltiples destinos
- 📡 **Puertos:** 4317 (gRPC), 4318 (HTTP), 8888-8889 (métricas), 13133 (health)
- **Ejemplo de uso:** Instrumentar microservicios para observabilidad distribuida

---

## 🏗️ Arquitectura del Stack

```
              ┌─────────────────────────────────────────┐
              │            Grafana (3030)               │
              │      Visualización + Dashboards        │
              └──────┬──────────────┬─────────┬────────┘
                     │              │         │
        ┌────────────▼─────┐  ┌────▼─────┐  │
        │   Prometheus     │  │   Loki   │  │
        │     (9090)       │  │  (3100)  │  │
        │    Métricas      │  │   Logs   │  │
        └──────▲───────────┘  └────▲─────┘  │
               │                   │         │
               │              ┌────┴─────┐  │
               │              │Promtail  │  │
               │              │ (9080)   │  │
               │              └────▲─────┘  │
               │                   │         │
               │          [Archivos de log] │
               │          /var/log/*.log    │
               │                            │
        ┌──────┴────────────────────────────▼──────┐
        │      OpenTelemetry Collector             │
        │  (4317/4318) Traces/Metrics/Logs         │
        └───────────────▲──────────────────────────┘
                        │
                        │ OTLP Protocol
                        │
          ┌─────────────┴─────────────┐
          │  Aplicaciones             │
          │  (instrumentadas con      │
          │   OpenTelemetry SDK)      │
          └───────────────────────────┘
```

### Flujo de datos:

**Stack tradicional:**
1. **Promtail** lee archivos de log del sistema/aplicaciones
2. **Promtail** envía logs a **Loki**
3. **Prometheus** recolecta métricas de aplicaciones/exportadores
4. **Grafana** consulta tanto **Prometheus** como **Loki** para visualizar datos

**Con OpenTelemetry:**
1. **Aplicaciones** instrumentadas envían traces/metrics/logs a **OTel Collector**
2. **OTel Collector** exporta métricas a **Prometheus**
3. **OTel Collector** exporta logs a **Loki**
4. **OTel Collector** (opcionalmente) exporta traces a Jaeger/Tempo
5. **Grafana** visualiza todo desde un solo lugar

---

## 🐳 Comandos Docker

### 🚀 Inicio rápido con Docker Compose (RECOMENDADO)

**Prerequisito:** Construir todas las imágenes primero

```bash
# Construir todas las imágenes
cd grafana && docker build -t grafana-custom . && cd ..
cd loki && docker build -t loki-custom . && cd ..
cd promtail && docker build -t promtail-custom . && cd ..
cd opentelemetry && docker build -t otel-collector . && cd ..
# Prometheus (opcional si ya lo tienes corriendo local)
cd prometheus/prometheus-server && docker build -t prometheus-custom . && cd ../..

# Levantar todo el stack con un solo comando
docker-compose up -d

# Ver logs de todos los servicios
docker-compose logs -f

# Detener todo el stack
docker-compose down

# Detener y eliminar volúmenes
docker-compose down -v
```

**Accesos después de `docker-compose up`:**
- Grafana: http://localhost:3030
- Prometheus: http://localhost:9090
- Loki: http://localhost:3100
- OTel Collector Health: http://localhost:13133

---

### 📦 Comandos individuales por servicio

### Grafana
```bash
# Build de la imagen
docker build -t grafana-custom .

# Ejecutar contenedor
docker run -d --name grafana -p 3030:3030 grafana-custom

# Ver logs del contenedor
docker logs grafana

# Detener y eliminar
docker stop grafana
docker rm grafana
```

**Acceso:** http://localhost:3030  
**Credenciales:**
- Usuario: `admin`
- Password: `admin123`

### Loki
```bash
# Build de la imagen
cd loki
docker build -t loki-custom .

# Ejecutar contenedor
docker run -d --name loki -p 3100:3100 loki-custom

# Ver logs del contenedor
docker logs loki

# Detener y eliminar
docker stop loki
docker rm loki
```

### Promtail
```bash
# Build de la imagen
cd promtail
docker build -t promtail-custom .

# Ejecutar contenedor (montando directorios de logs)
docker run -d --name promtail \
  -v /var/log:/var/log \
  -p 9080:9080 \
  promtail-custom

# Ver logs del contenedor
docker logs promtail

# Detener y eliminar
docker stop promtail
docker rm promtail
```

### Prometheus
```bash
# Si decides dockerizarlo
cd prometheus/prometheus-server
docker build -t prometheus-custom .

# Ejecutar contenedor
docker run -d --name prometheus -p 9090:9090 prometheus-custom
```

### OpenTelemetry
```bash
# Build de la imagen
cd opentelemetry
docker build -t otel-collector .

# Ejecutar contenedor
docker run -d --name otel-collector \
  -p 4317:4317 \
  -p 4318:4318 \
  -p 8888:8888 \
  -p 8889:8889 \
  -p 13133:13133 \
  otel-collector

# Ver logs del contenedor
docker logs otel-collector

# Health check
curl http://localhost:13133

# Detener y eliminar
docker stop otel-collector
docker rm otel-collector
```

---

## 🔗 Conexión entre servicios

### Prometheus corriendo local → Grafana en Docker
Usar en Grafana datasource:
```
http://host.docker.internal:9090
```

### Loki corriendo local → Grafana en Docker
Usar en Grafana datasource:
```
http://host.docker.internal:3100
```

### Todos en Docker (Red personalizada - RECOMENDADO)
```bash
# Crear red Docker
docker network create monitoring

# Ejecutar servicios conectados a la red
docker run -d --name prometheus --network monitoring -p 9090:9090 prometheus-custom

docker run -d --name loki --network monitoring -p 3100:3100 loki-custom

docker run -d --name promtail --network monitoring \
  -v /var/log:/var/log \
  -p 9080:9080 \
  promtail-custom

docker run -d --name otel-collector --network monitoring \
  -p 4317:4317 \
  -p 4318:4318 \
  -p 8888:8888 \
  -p 8889:8889 \
  -p 13133:13133 \
  otel-collector

docker run -d --name grafana --network monitoring -p 3030:3030 grafana-custom
```

**URLs en Grafana cuando todos están en la misma red:**
- Prometheus: `http://prometheus:9090`
- Loki: `http://loki:3100`
- Tempo (si usas): `http://tempo:3200`

**URLs en Promtail config:**
- Loki: `http://loki:3100/loki/api/v1/push`

**URLs en OpenTelemetry Collector config:**
- Prometheus: `http://prometheus:9090/api/v1/write`
- Loki: `http://loki:3100/loki/api/v1/push`

**URLs para aplicaciones instrumentadas:**
- OpenTelemetry Collector: `http://otel-collector:4317` (gRPC) o `http://otel-collector:4318` (HTTP)

---

## 🚨 Recursos de Alertas

**Biblioteca de alertas listas para usar:**  
🔗 https://samber.github.io/awesome-prometheus-alerts/

Incluye alertas pre-configuradas para:
- Linux servers
- Docker containers
- Kubernetes
- Bases de datos (MySQL, PostgreSQL, MongoDB)
- Web servers (Nginx, Apache)
- Y muchos más...

---

## 📚 Casos de uso combinados

### Ejemplo 1: Monitoreo de aplicación web
1. **Prometheus:** Monitorea requests/segundo, latencia, errores HTTP
2. **Loki:** Captura logs de errores detallados
3. **Grafana:** Dashboard que muestra métricas + logs correlacionados

### Ejemplo 2: Depuración de incidentes
1. Ver en Grafana que el uso de CPU se disparó a las 14:30
2. Buscar en Loki los logs de esa hora exacta
3. Encontrar el error específico que causó el problema

### Ejemplo 3: Alertas proactivas
1. Prometheus detecta que el disco está al 90%
2. Envía alerta a Grafana/Alertmanager
3. Equipo recibe notificación antes de que falle

### Ejemplo 4: Observabilidad de microservicios con OpenTelemetry
1. **Aplicación** instrumentada con OTel SDK envía traces, metrics y logs
2. **OTel Collector** recibe telemetría y la distribuye:
   - Traces → Jaeger/Tempo (para visualizar flujos entre servicios)
   - Metrics → Prometheus
   - Logs → Loki
3. **Grafana** correlaciona todo: ves una métrica alta, saltas al trace, ves los logs del error
4. Identificas qué microservicio causó el problema y en qué punto exacto

---

## 🛠️ Estructura del proyecto

```
prometheus-grafana/
├── README.md                    # Este archivo
├── grafana/
│   ├── Dockerfile              # Imagen de Grafana customizada
│   └── grafana.ini             # Configuración personalizada
├── loki/
│   ├── Dockerfile              # Imagen de Loki
│   └── loki-config.yml         # Configuración de Loki
├── promtail/
│   ├── Dockerfile              # Imagen de Promtail
│   ├── promtail-config.yml     # Configuración de Promtail
│   ├── example.log             # Logs de ejemplo
│   └── README.md               # Guía de Promtail
├── opentelemetry/
│   ├── Dockerfile              # Imagen del OTel Collector
│   ├── otel-collector-config.yaml  # Configuración del Collector
│   └── README.md               # Guía de OpenTelemetry
└── prometheus/
    └── prometheus-server/
        ├── prometheus.yml      # Configuración de Prometheus
        └── rule/              # Reglas de alertas
```

---

## 💡 Tips

- **Grafana:** Explora los dashboards preconstruidos en https://grafana.com/grafana/dashboards/
- **Prometheus:** Usa PromQL para consultas potentes de métricas
- **Loki:** Usa LogQL (similar a PromQL) para buscar en logs
- **Performance:** Loki es más eficiente que ElasticSearch para logs porque no indexa todo el contenido
- **OpenTelemetry:** Instrumenta tus aplicaciones desde el inicio para tener observabilidad completa
- **Correlación:** La verdadera potencia viene de correlacionar traces → metrics → logs en Grafana
- **Estándar:** OpenTelemetry es vendor-neutral, si cambias de backend no necesitas reinstrumentar
- **Auto-instrumentación:** Muchos lenguajes tienen auto-instrumentación (Java, Python, Node.js, .NET)
