#!/bin/bash
#
# Script para configurar Node Exporter como servicio de systemd de forma segura
# Autor: Script automatizado
# Fecha: 2026-03-03
#

set -e  # Salir si hay algún error
set -u  # Salir si se usa una variable no definida

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variables de configuración
NODE_EXPORTER_VERSION="1.10.2"
NODE_EXPORTER_USER="prometheus"
NODE_EXPORTER_GROUP="prometheus"
INSTALL_DIR="/usr/local/bin"
SERVICE_FILE="/etc/systemd/system/node_exporter.service"
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${GREEN}=== Instalación Segura de Node Exporter como Servicio ===${NC}\n"

# Verificar que se ejecuta como root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: Este script debe ejecutarse como root (sudo)${NC}"
   exit 1
fi

# Paso 1: Crear grupo prometheus si no existe
echo -e "${YELLOW}[1/6]${NC} Creando grupo ${NODE_EXPORTER_GROUP}..."
if getent group ${NODE_EXPORTER_GROUP} > /dev/null 2>&1; then
    echo -e "  ✓ El grupo ${NODE_EXPORTER_GROUP} ya existe"
else
    groupadd --system ${NODE_EXPORTER_GROUP}
    echo -e "  ${GREEN}✓${NC} Grupo ${NODE_EXPORTER_GROUP} creado"
fi

# Paso 2: Crear usuario prometheus de forma segura
echo -e "${YELLOW}[2/6]${NC} Creando usuario ${NODE_EXPORTER_USER} (sin login, sin shell)..."
if id ${NODE_EXPORTER_USER} > /dev/null 2>&1; then
    echo -e "  ✓ El usuario ${NODE_EXPORTER_USER} ya existe"
else
    # Opciones de seguridad:
    # -r / --system : Usuario de sistema (UID < 1000)
    # -s /sbin/nologin : Sin shell - NO puede iniciar sesión
    # -M : Sin directorio home
    # -g : Grupo primario
    # -d /nonexistent : Home directory que no existe (extra seguridad)
    useradd --system \
            --no-create-home \
            --shell /sbin/nologin \
            --gid ${NODE_EXPORTER_GROUP} \
            --home-dir /nonexistent \
            --comment "Prometheus Node Exporter User" \
            ${NODE_EXPORTER_USER}
    echo -e "  ${GREEN}✓${NC} Usuario ${NODE_EXPORTER_USER} creado de forma segura"
    echo -e "    - Sin capacidad de login"
    echo -e "    - Sin shell interactivo"
    echo -e "    - Sin directorio home"
fi

# Paso 3: Copiar binario a ubicación estándar del sistema
echo -e "${YELLOW}[3/6]${NC} Instalando binario node_exporter en ${INSTALL_DIR}..."
if [[ ! -f "${CURRENT_DIR}/node_exporter" ]]; then
    echo -e "${RED}Error: No se encuentra el binario node_exporter en ${CURRENT_DIR}${NC}"
    exit 1
fi

cp "${CURRENT_DIR}/node_exporter" "${INSTALL_DIR}/node_exporter"
chown ${NODE_EXPORTER_USER}:${NODE_EXPORTER_GROUP} "${INSTALL_DIR}/node_exporter"
chmod 755 "${INSTALL_DIR}/node_exporter"
echo -e "  ${GREEN}✓${NC} Binario instalado con permisos seguros (755)"
echo -e "    Owner: ${NODE_EXPORTER_USER}:${NODE_EXPORTER_GROUP}"

# Paso 4: Crear archivo de servicio systemd
echo -e "${YELLOW}[4/6]${NC} Creando archivo de servicio systemd..."
cat > ${SERVICE_FILE} << 'EOF'
[Unit]
Description=Prometheus Node Exporter
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecStart=/usr/local/bin/node_exporter

# Opciones de seguridad adicionales
# Evita que el servicio obtenga nuevos privilegios
NoNewPrivileges=true

# Protección del sistema de archivos
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/var/log

# Protección de red y kernel
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true

# Namespaces privados
PrivateTmp=true

# Restart automático
Restart=on-failure
RestartSec=5s

SyslogIdentifier=node_exporter

[Install]
WantedBy=multi-user.target
EOF

echo -e "  ${GREEN}✓${NC} Archivo de servicio creado: ${SERVICE_FILE}"
echo -e "    - Incluye protecciones de seguridad adicionales de systemd"

# Paso 5: Recargar systemd y habilitar servicio
echo -e "${YELLOW}[5/6]${NC} Configurando systemd..."
systemctl daemon-reload
systemctl enable node_exporter.service
echo -e "  ${GREEN}✓${NC} Servicio habilitado para iniciar en el arranque"

# Paso 6: Iniciar servicio
echo -e "${YELLOW}[6/6]${NC} Iniciando servicio node_exporter..."
systemctl start node_exporter.service
sleep 2

# Verificar estado
if systemctl is-active --quiet node_exporter.service; then
    echo -e "  ${GREEN}✓${NC} Servicio iniciado correctamente"
else
    echo -e "  ${RED}✗${NC} Error al iniciar el servicio"
    systemctl status node_exporter.service
    exit 1
fi

# Resumen final
echo -e "\n${GREEN}=== Instalación Completada Exitosamente ===${NC}\n"
echo -e "Node Exporter está ejecutándose de forma segura:"
echo -e "  • Usuario: ${NODE_EXPORTER_USER} (sin login)"
echo -e "  • Grupo: ${NODE_EXPORTER_GROUP}"
echo -e "  • Puerto: 9100 (por defecto)"
echo -e "  • Metrics: http://localhost:9100/metrics"
echo -e ""
echo -e "Comandos útiles:"
echo -e "  • Ver estado:    ${YELLOW}sudo systemctl status node_exporter${NC}"
echo -e "  • Ver logs:      ${YELLOW}sudo journalctl -u node_exporter -f${NC}"
echo -e "  • Detener:       ${YELLOW}sudo systemctl stop node_exporter${NC}"
echo -e "  • Reiniciar:     ${YELLOW}sudo systemctl restart node_exporter${NC}"
echo -e "  • Deshabilitar:  ${YELLOW}sudo systemctl disable node_exporter${NC}"
echo -e ""
echo -e "${GREEN}Protecciones de seguridad activas:${NC}"
echo -e "  ✓ Usuario sin privilegios de login"
echo -e "  ✓ NoNewPrivileges (no puede escalar privilegios)"
echo -e "  ✓ ProtectSystem (sistema de archivos protegido)"
echo -e "  ✓ ProtectHome (directorios home protegidos)"
echo -e "  ✓ ProtectKernelTunables (kernel protegido)"
echo -e "  ✓ PrivateTmp (directorio temporal privado)"
echo -e ""
