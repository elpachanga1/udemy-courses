# 🔒 Instalación Segura de Node Exporter como Servicio

## ¿Por qué es seguro?

### El usuario `prometheus` ES SEGURO porque:

✅ **No puede iniciar sesión** (`-s /sbin/nologin`)
- No tiene shell interactivo
- Nadie puede hacer `su prometheus` o login directo

✅ **Usuario de sistema** (`--system`)
- UID bajo (< 1000)
- No tiene directorio home
- No aparece en login screens

✅ **Permisos mínimos**
- Solo puede ejecutar node_exporter
- No puede modificar archivos del sistema
- No puede escalar privilegios

### Protecciones adicionales de systemd:

```
NoNewPrivileges=true          → No puede obtener más privilegios
ProtectSystem=strict          → No puede escribir en /usr, /boot, /efi
ProtectHome=true             → No puede acceder a /home
ProtectKernelTunables=true   → No puede modificar kernel
PrivateTmp=true              → Directorio /tmp aislado
```

## 📋 Pasos de Instalación

### 1. Dale permisos de ejecución al script

```bash
cd /home/fai-instance/node_exporter-1.10.2.linux-amd64
chmod +x setup_node_exporter_service.sh
```

### 2. Ejecuta el script como root

```bash
sudo ./setup_node_exporter_service.sh
```

El script hará automáticamente:
1. ✅ Crear grupo `prometheus`
2. ✅ Crear usuario `prometheus` (SIN login)
3. ✅ Copiar binario a `/usr/local/bin/`
4. ✅ Configurar permisos correctos
5. ✅ Crear servicio systemd con protecciones de seguridad
6. ✅ Habilitar e iniciar el servicio

### 3. Verificar que funciona

```bash
# Ver estado del servicio
sudo systemctl status node_exporter

# Ver métricas
curl http://localhost:9100/metrics

# Ver logs en tiempo real
sudo journalctl -u node_exporter -f
```

## 🛠️ Comandos Útiles

```bash
# Iniciar servicio
sudo systemctl start node_exporter

# Detener servicio
sudo systemctl stop node_exporter

# Reiniciar servicio
sudo systemctl restart node_exporter

# Ver estado
sudo systemctl status node_exporter

# Ver logs
sudo journalctl -u node_exporter -n 50

# Ver logs en tiempo real
sudo journalctl -u node_exporter -f

# Deshabilitar inicio automático
sudo systemctl disable node_exporter

# Habilitar inicio automático
sudo systemctl enable node_exporter
```

## 🔍 Verificar Seguridad

```bash
# Verificar que el usuario NO puede hacer login
sudo su - prometheus
# Debe fallar con "This account is currently not available"

# Ver información del usuario
id prometheus
# Debe mostrar UID bajo y grupo prometheus

# Ver permisos del binario
ls -l /usr/local/bin/node_exporter
# Debe mostrar: -rwxr-xr-x prometheus prometheus

# Ver configuración de seguridad del servicio
systemctl show node_exporter | grep -i protect
```

## 🔥 Configurar Firewall (Opcional)

Si quieres que Prometheus desde otra máquina pueda acceder:

```bash
# UFW (Ubuntu/Debian)
sudo ufw allow 9100/tcp

# Firewalld (CentOS/RHEL)
sudo firewall-cmd --permanent --add-port=9100/tcp
sudo firewall-cmd --reload
```

## 🔗 Integrar con Prometheus

Edita tu archivo `prometheus.yml` y agrega:

```yaml
scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']
        labels:
          alias: 'server-local'
```

Luego reinicia Prometheus:
```bash
sudo systemctl restart prometheus
```

## ❌ Desinstalar

Si necesitas desinstalar node_exporter:

```bash
# Detener y deshabilitar servicio
sudo systemctl stop node_exporter
sudo systemctl disable node_exporter

# Eliminar archivos
sudo rm /etc/systemd/system/node_exporter.service
sudo rm /usr/local/bin/node_exporter

# Recargar systemd
sudo systemctl daemon-reload

# (Opcional) Eliminar usuario y grupo
sudo userdel prometheus
sudo groupdel prometheus
```

## 📚 Más Información

- Documentación oficial: https://prometheus.io/docs/guides/node-exporter/
- GitHub: https://github.com/prometheus/node_exporter
- Métricas disponibles: http://localhost:9100/metrics
