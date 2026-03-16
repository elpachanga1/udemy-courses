# Usar la imagen oficial de Loki
FROM grafana/loki:latest

# Copiar archivo de configuración personalizado
COPY loki-config.yml /etc/loki/local-config.yaml

# Exponer el puerto de Loki
EXPOSE 3100

# El comando por defecto de Loki
CMD ["-config.file=/etc/loki/local-config.yaml"]
