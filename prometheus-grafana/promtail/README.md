# Promtail - Agente de recolección de logs

## ¿Qué hace Promtail?

Promtail lee archivos de log y los envía a Loki. Es el equivalente a Node Exporter pero para logs en lugar de métricas.

## Archivos en este directorio

- `Dockerfile` - Imagen Docker de Promtail
- `promtail-config.yml` - Configuración de Promtail (define qué logs leer y dónde enviarlos)
- `example.log` - Archivo de logs de ejemplo para testing

## Configuración actual

Promtail está configurado para leer logs de:

1. **Sistema:** `/var/log/*.log`
2. **Aplicación:** `/var/log/app/*.log`
3. **Docker containers:** `/var/lib/docker/containers/*/*.log`

Todos los logs se envían a Loki en: `http://loki:3100/loki/api/v1/push`

## Cómo usar

### Opción 1: Standalone (sin red Docker)

```bash
docker build -t promtail-custom .

docker run -d --name promtail \
  -v /var/log:/var/log:ro \
  -p 9080:9080 \
  promtail-custom
```

En `promtail-config.yml` cambiar la URL de Loki a:
```yaml
clients:
  - url: http://host.docker.internal:3100/loki/api/v1/push
```

### Opción 2: Con red Docker (RECOMENDADO)

```bash
# Crear red si no existe
docker network create monitoring

# Construir imagen
docker build -t promtail-custom .

# Ejecutar conectado a la red
docker run -d --name promtail \
  --network monitoring \
  -v /var/log:/var/log:ro \
  -p 9080:9080 \
  promtail-custom
```

## Verificar que funciona

```bash
# Ver logs de Promtail
docker logs promtail

# Verificar métricas/health
curl http://localhost:9080/metrics
curl http://localhost:9080/ready
```

## Personalización

### Agregar más fuentes de logs

Edita `promtail-config.yml` y agrega un nuevo `scrape_config`:

```yaml
scrape_configs:
  - job_name: mi_app
    static_configs:
      - targets:
          - localhost
        labels:
          job: mi_aplicacion
          environment: production
          __path__: /path/to/my/app/*.log
```

### Filtrar y transformar logs

Usa `pipeline_stages` para procesar logs:

```yaml
pipeline_stages:
  - json:
      expressions:
        level: level
        message: message
  - labels:
      level:
  - match:
      selector: '{level="ERROR"}'
      action: keep
```

## Troubleshooting

**Problema:** Promtail no encuentra los logs
- Verifica que el volumen está montado correctamente: `docker exec promtail ls /var/log`
- Revisa los permisos del directorio

**Problema:** No llegan logs a Loki
- Verifica la conectividad: `docker exec promtail wget -O- http://loki:3100/ready`
- Revisa los logs de Promtail: `docker logs promtail`

**Problema:** Promtail no parsea correctamente los logs
- Ajusta los `pipeline_stages` en la configuración
- Usa regex o json parsing según el formato de tus logs
