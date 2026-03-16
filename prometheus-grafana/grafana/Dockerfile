# Usar la imagen oficial de Grafana
FROM grafana/grafana:latest

# Copiar el archivo de configuración personalizado
# Este archivo se obtuvo copiandose de la imagen de docker
# se editan algunas configuraciones y se envia a las nuevas imagenes Dockerfile
COPY grafana.ini /etc/grafana/grafana.ini

# Exponer el puerto personalizado de Grafana
EXPOSE 3030

# Variables de entorno para configuración inicial
ENV GF_SECURITY_ADMIN_USER=admin
ENV GF_SECURITY_ADMIN_PASSWORD=admin123
ENV GF_USERS_ALLOW_SIGN_UP=false
ENV GF_SERVER_HTTP_PORT=3030

# La imagen base ya tiene el CMD configurado correctamente