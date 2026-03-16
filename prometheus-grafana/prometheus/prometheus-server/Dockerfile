# Usar la imagen oficial de Prometheus
FROM prom/prometheus:latest

# Copiar el archivo de configuración
COPY prometheus.yml /etc/prometheus/prometheus.yml

# Copiar reglas de alertas
COPY rule/ /etc/prometheus/rule/

# Exponer el puerto de Prometheus
EXPOSE 9090

# El comando por defecto ya está configurado en la imagen base
