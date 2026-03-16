# Usar la imagen oficial del OpenTelemetry Collector
FROM otel/opentelemetry-collector-contrib:latest

# Copiar archivo de configuración personalizado
COPY otel-collector-config.yaml /etc/otelcol-contrib/config.yaml

# Exponer puertos necesarios
# 4317 - gRPC receiver
# 4318 - HTTP receiver
# 8888 - Prometheus metrics
# 8889 - Prometheus exporter
# 13133 - Health check
EXPOSE 4317 4318 8888 8889 13133

# El comando por defecto ejecuta el collector con la configuración
CMD ["--config=/etc/otelcol-contrib/config.yaml"]
