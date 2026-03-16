# Usar la imagen oficial de Promtail
FROM grafana/promtail:latest

# Copiar archivo de configuración personalizado
COPY promtail-config.yml /etc/promtail/config.yml

# Crear directorio para logs de ejemplo
RUN mkdir -p /var/log/app

# Copiar archivo de logs de ejemplo (opcional, para testing)
COPY example.log /var/log/app/example.log

# Exponer el puerto de Promtail (para métricas y health checks)
EXPOSE 9080

# El comando por defecto de Promtail
CMD ["-config.file=/etc/promtail/config.yml"]
