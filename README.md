# FiberOps Deploy 🚀

Repositorio de despliegue automatizado para el sistema **FiberOps 2025**, un sistema de gestión de infraestructura de fibra óptica desarrollado por Yeremi Tantaraico.

## 📋 Descripción del Proyecto

Este repositorio contiene los scripts de shell y la documentación necesaria para desplegar automáticamente el sistema FiberOps en servidores Ubuntu Server 22.04. El depliegue incluye toda la configuración del entorno, dependencias y optimizaciones necesarias para el funcionamiento óptimo del sistema.

## 🛠️ Tecnologías del Proyecto

### Backend
- **PHP 8.1** - Lenguaje principal del sistema
- **Apache 2.4** - Servidor web
- **PostgreSQL** - Base de datos principal
- **Composer** - Gestor de dependencias PHP

### Extensiones PHP Críticas
- `php8.1-mysql` - Conectividad MySQL
- `php8.1-pgsql` - Conectividad PostgreSQL
- `php8.1-ssh2` - Protocolo SSH para gestión remota
- `php8.1-snmp` - Protocolo SNMP para monitoreo de equipos
- `php8.1-gd` - Manipulación de imágenes
- `php8.1-mbstring` - Soporte multibyte
- `php8.1-curl` - Cliente HTTP
- `php8.1-xml` - Procesamiento XML
- `php8.1-intl` - Internacionalización
- `php8.1-zip` - Compresión de archivos
- `php8.1-bcmath` - Matemáticas de precisión

### Dependencias del Sistema
- **SNMP** - Monitoreo de equipos de red
- **PostgreSQL** - Base de datos
- **Python 3** - Scripts auxiliares
- **psycopg2** - Conector PostgreSQL para Python

## 📦 Requisitos del Sistema

### Hardware Mínimo
- **CPU**: 2 cores
- **RAM**: 4GB mínimo, 8GB recomendado
- **Disco**: 20GB libres
- **Red**: Conexión estable a internet

### Software Base
- **Sistema Operativo**: Ubuntu Server 22.04 LTS
- **Usuario**: Ejecutar como root o con permisos sudo
- **Acceso**: SSH habilitado

## 🚀 Scripts de Despliegue

### Archivo: `fiberops_deploy.sh`

Script automatizado que instala y configura todo el entorno necesario para FiberOps.

### Archivo: `verify_fiberops_installation.sh`

Script de verificación completo que valida toda la instalación del sistema FiberOps, incluyendo servicios, extensiones PHP, configuraciones y dependencias.

### Archivo: `fiberops_system_monitor.sh`

Script de monitoreo en tiempo real del sistema que verifica el rendimiento, uso de recursos, estado de servicios y características del hardware del servidor.

### Archivo: `fiberops_removing_notifications.sh`

Script de configuración automática de crontab para el sistema SMS de FiberOps, que programa tareas automáticas para el procesamiento de notificaciones, limpieza de logs y mantenimiento del sistema.

#### Características del Script de Instalación
- ✅ Instalación automática de todas las dependencias
- ✅ Configuración optimizada de PHP y Apache
- ✅ Configuración de zona horaria (Perú)
- ✅ Verificación automática de instalaciones
- ✅ Configuración de permisos y seguridad
- ✅ Mensajes informativos durante el proceso

#### Características del Script de Verificación
- ✅ Verificación completa de servicios del sistema
- ✅ Validación de versiones de software instalado
- ✅ Comprobación de extensiones PHP requeridas
- ✅ Verificación de configuraciones PHP
- ✅ Validación de módulos Apache habilitados
- ✅ Comprobación de directorios y permisos
- ✅ Verificación de herramientas SNMP
- ✅ Validación de dependencias Composer
- ✅ Comprobación de conectividad y puertos
- ✅ Configuración automática de crontab
- ✅ Resumen estadístico detallado

#### Características del Script de Monitoreo
- ✅ Información detallada del hardware del sistema
- ✅ Monitoreo de CPU con barras de progreso por core
- ✅ Análisis de memoria RAM y swap en tiempo real
- ✅ Estadísticas de almacenamiento y uso de disco
- ✅ Monitoreo de interfaces de red y conectividad
- ✅ Estado de servicios FiberOps (Apache, PostgreSQL, etc.)
- ✅ Análisis de procesos con mayor consumo de recursos
- ✅ Verificación de puertos y conexiones activas
- ✅ Alertas automáticas por umbrales de uso
- ✅ Monitoreo continuo con actualización automática
- ✅ Logging automático de métricas del sistema
- ✅ Reportes de rendimiento y salud del sistema

#### Características del Script de Crontab SMS
- ✅ Configuración automática de tareas programadas
- ✅ Backup automático del crontab existente
- ✅ Verificación de directorios SMS y creación si no existen
- ✅ Programación de limpieza automática de notificaciones
- ✅ Procesamiento automático de cola SMS
- ✅ Reintento automático de SMS fallidos
- ✅ Generación automática de estadísticas
- ✅ Limpieza automática de logs antiguos
- ✅ Verificación de salud del sistema SMS
- ✅ Respaldo automático de configuraciones
- ✅ Creación automática de archivos de log
- ✅ Verificación y configuración del servicio cron

#### Funcionalidades Principales

1. **Pre-requisitos del Sistema**
   - Deshabilitación de IPv6 para evitar problemas de descarga
   - Actualización completa del sistema

2. **Instalación de Servicios**
   - Apache 2.4 con módulos necesarios
   - PHP 8.1 con todas las extensiones requeridas
   - PostgreSQL con extensiones

3. **Configuración de Extensiones Especializadas**
   - SSH2 para gestión remota de equipos
   - SNMP para monitoreo de infraestructura
   - Extensiones de base de datos

4. **Optimización del Entorno**
   - Configuración PHP optimizada para FiberOps
   - Zona horaria configurada a América/Lima
   - Permisos de directorios configurados

5. **Verificación y Validación**
   - Estado de servicios
   - Versiones instaladas
   - Extensiones PHP activas
   - Permisos de directorios

## 📖 Cómo Usar el Script

### 1. Preparación del Servidor
```bash
# Conectar por SSH al servidor Ubuntu 22.04
ssh usuario@tu-servidor-ip

# Actualizar el sistema (opcional, el script lo hace automáticamente)
sudo apt update && sudo apt upgrade -y
```

### 2. Descarga y Ejecución
```bash
# Descargar el script de instalación
wget https://raw.githubusercontent.com/Jeremias0618/fiberops-deploy/main/fiberops_deploy.sh

# Descargar el script de verificación
wget https://raw.githubusercontent.com/Jeremias0618/fiberops-deploy/main/verify_fiberops_installation.sh

# Descargar el script de monitoreo
wget https://raw.githubusercontent.com/Jeremias0618/fiberops-deploy/main/fiberops_system_monitor.sh

# Descargar el script de configuración crontab SMS
wget https://raw.githubusercontent.com/Jeremias0618/fiberops-deploy/main/fiberops_removing_notifications.sh

# Dar permisos de ejecución
chmod +x fiberops_deploy.sh verify_fiberops_installation.sh fiberops_system_monitor.sh fiberops_removing_notifications.sh

# Ejecutar instalación como root
sudo ./fiberops_deploy.sh

# Después de la instalación, verificar el sistema
sudo ./verify_fiberops_installation.sh

# Monitorear el sistema en tiempo real
sudo ./fiberops_system_monitor.sh

# Configurar tareas automáticas para SMS
sudo ./fiberops_removing_notifications.sh
```

### 3. Proceso de Instalación
El script ejecutará automáticamente:
- Instalación de Apache, PHP 8.1, PostgreSQL
- Configuración de extensiones PHP especializadas
- Instalación de Composer
- Configuración de zona horaria
- Optimización de PHP.ini
- Verificación final del sistema

**Tiempo estimado**: 15-20 minutos dependiendo de la velocidad de internet.

## 📊 Resultados de la Instalación

### Servicios Instalados y Configurados
- ✅ **Apache 2.4** - Servidor web activo y configurado
- ✅ **PHP 8.1** - Con todas las extensiones necesarias
- ✅ **PostgreSQL** - Base de datos lista para usar
- ✅ **Composer** - Gestor de dependencias PHP
- ✅ **SNMP** - Para monitoreo de equipos
- ✅ **SSH2** - Para gestión remota

### Directorios Creados
```
/var/www/html/          # Directorio principal del proyecto
/var/www/html/logs/     # Directorio de logs (permisos 777)
```

### Configuraciones Aplicadas
- **Zona horaria**: America/Lima (Perú)
- **PHP.ini optimizado**:
  - `max_execution_time = 300`
  - `memory_limit = 512M`
  - `upload_max_filesize = 100M`
  - `post_max_size = 100M`
- **Permisos**: 777 para /var/www/html/

### Acceso al Sistema
- **URL**: `http://tu-servidor-ip/`
- **Directorio**: `/var/www/html/`

## 🔧 Próximos Pasos Después de la Instalación

1. **Subir el código de FiberOps**
   ```bash
   # Copiar archivos del proyecto a /var/www/html/
   cp -r /ruta/al/codigo/fiberops/* /var/www/html/
   ```

2. **Configurar base de datos PostgreSQL**
   ```bash
   # Crear usuario y base de datos
   sudo -u postgres createuser --interactive
   sudo -u postgres createdb fiberops_db
   ```

3. **Configurar archivos de entorno**
   - Configurar `.env` con datos de conexión
   - Ajustar `config.php` según necesidades

4. **Instalar dependencias del proyecto**
   ```bash
   cd /var/www/html/
   composer install
   ```

5. **Verificar permisos finales**
   ```bash
   chown -R www-data:www-data /var/www/html/
   chmod -R 755 /var/www/html/
   ```

## 🔍 Verificación del Sistema

### Script de Verificación Automática
```bash
# Ejecutar verificación completa del sistema
sudo ./verify_fiberops_installation.sh
```

El script de verificación realizará **11 categorías de verificación**:

1. **Servicios del Sistema** - Apache2 y PostgreSQL
2. **Versiones de Software** - PHP, Apache, PostgreSQL, Composer
3. **Extensiones PHP Requeridas** - SSH2, SNMP, PostgreSQL, GD, etc.
4. **Configuración PHP** - Zona horaria, memory limit, execution time
5. **Módulos Apache** - Rewrite, Headers, PHP 8.1
6. **Directorios y Permisos** - /var/www/html/, logs, permisos
7. **Herramientas SNMP** - SNMP tools, Python3, psycopg2
8. **Composer y Dependencias** - Autoloader, dependencias del proyecto
9. **Conectividad y Puertos** - Puerto 80 (HTTP), 5432 (PostgreSQL)
10. **Configuración del Sistema** - Zona horaria, IPv6
11. **Configuración de Crontab** - Configuración automática de tareas programadas

### Comandos de Verificación Manual
```bash
# Estado de servicios
systemctl status apache2
systemctl status postgresql

# Versiones instaladas
php -v
composer --version
apache2 -v

# Extensiones PHP activas
php -m | grep -E "(ssh2|snmp|pgsql|gd|mbstring)"

# Verificar permisos
ls -la /var/www/html/
```

### Resultados de la Verificación
El script proporciona un **resumen estadístico** con:
- Total de verificaciones realizadas
- Número de verificaciones exitosas
- Advertencias encontradas
- Errores detectados
- Estado general del sistema

## 📊 Monitoreo del Sistema

### Script de Monitoreo en Tiempo Real
```bash
# Monitoreo completo una vez
sudo ./fiberops_system_monitor.sh

# Monitoreo continuo (cada 5 segundos)
sudo ./fiberops_system_monitor.sh -c 5

# Mostrar ayuda
sudo ./fiberops_system_monitor.sh -h
```

### Características del Monitoreo
El script `fiberops_system_monitor.sh` proporciona:

#### 🖥️ **Información del Sistema**
- Hostname, OS, Kernel, Uptime
- Load Average y fecha actual
- Información detallada del hardware

#### 🔧 **Monitoreo de Hardware**
- **Procesador**: Modelo, arquitectura, cores, frecuencia
- **Memoria RAM**: Total, usada, libre, disponible, porcentaje de uso
- **Almacenamiento**: Tamaño, uso, disponible por dispositivo

#### 📊 **Análisis de Rendimiento**
- **CPU**: Uso actual con barras de progreso por core
- **Memoria**: Detalles de RAM y swap
- **Procesos**: Top 10 procesos por CPU y memoria
- **Temperatura**: Monitoreo de temperatura del CPU

#### 🌐 **Red y Conectividad**
- Interfaces de red activas
- Estadísticas de tráfico (RX/TX)
- Conexiones activas (establecidas, escuchando)
- Top 5 IPs con más conexiones

#### 🔧 **Servicios FiberOps**
- Estado de Apache2, PostgreSQL, Cron, SSH
- Verificación de puertos (80, 443, 5432, 22)
- Uso de memoria por servicio

#### ⚠️ **Alertas Automáticas**
- **CPU**: Alerta si uso > 80%
- **Memoria**: Alerta si uso > 85%
- **Disco**: Alerta si uso > 90%
- **Temperatura**: Alerta si > 80°C

#### 📈 **Reportes y Logging**
- Resumen de rendimiento del sistema
- Logging automático en `/var/log/fiberops_monitor.log`
- Estado general con contador de alertas
- Métricas históricas para análisis

## ⏰ Configuración de Tareas Automáticas (Crontab SMS)

### Script de Configuración Automática
```bash
# Configurar tareas automáticas para sistema SMS
sudo ./fiberops_removing_notifications.sh
```

### ¿Qué hace el script?
El script `fiberops_removing_notifications.sh` configura automáticamente las tareas programadas (crontab) necesarias para el funcionamiento del sistema SMS de FiberOps.

### Funcionalidades del Script

#### 🕒 **Tareas Programadas Configuradas**
1. **Limpieza de Notificaciones** - Diaria a las 23:59
   - Ejecuta: `clear_notifications.php`
   - Log: `cleanup.log`

2. **Procesamiento de Cola SMS** - Cada 5 minutos
   - Ejecuta: `process_queue.php`
   - Log: `queue.log`

3. **Reintento de SMS Fallidos** - Cada 30 minutos
   - Ejecuta: `retry_failed.php`
   - Log: `retry.log`

4. **Generación de Estadísticas** - Diaria a las 06:00
   - Ejecuta: `stats_generator.php`
   - Log: `stats.log`

5. **Limpieza de Logs Antiguos** - Domingos a las 02:00
   - Ejecuta: `cleanup_old_logs.php`
   - Log: `maintenance.log`

6. **Verificación de Salud SMS** - Cada hora
   - Ejecuta: `health_check.php`
   - Log: `health.log`

7. **Respaldo de Configuraciones** - Diario a las 03:00
   - Ejecuta: `backup_config.php`
   - Log: `backup.log`

#### 🔧 **Características del Script**
- **Backup Automático**: Crea respaldo del crontab existente
- **Verificación de Directorios**: Crea directorios SMS si no existen
- **Creación de Logs**: Genera archivos de log automáticamente
- **Verificación de Servicios**: Asegura que el servicio cron esté activo
- **Validación de PHP**: Verifica que PHP esté disponible
- **Mensajes Informativos**: Proporciona feedback detallado del proceso

#### 📁 **Estructura de Directorios Creados**
```
/var/www/html/sms/
├── scripts/          # Scripts PHP para tareas automáticas
├── logs/            # Archivos de log de las tareas
│   ├── cleanup.log
│   ├── queue.log
│   ├── retry.log
│   ├── stats.log
│   ├── maintenance.log
│   ├── health.log
│   └── backup.log
└── clear_notifications.php  # Script principal de limpieza
```

#### 🎯 **Cómo Funciona**
1. **Verificación**: Comprueba permisos root y dependencias
2. **Backup**: Crea respaldo del crontab actual
3. **Configuración**: Agrega tareas SMS al crontab
4. **Validación**: Verifica que las tareas se agregaron correctamente
5. **Preparación**: Crea directorios y archivos de log necesarios
6. **Verificación Final**: Confirma que el servicio cron esté activo

#### 📋 **Comandos Útiles Después de la Configuración**
```bash
# Ver tareas programadas configuradas
crontab -l

# Editar tareas programadas manualmente
crontab -e

# Verificar estado del servicio cron
systemctl status cron

# Ver logs de las tareas automáticas
tail -f /var/www/html/sms/logs/cleanup.log
tail -f /var/www/html/sms/logs/queue.log

# Verificar ejecución de tareas
grep CRON /var/log/syslog | tail -10
```

#### ⚠️ **Requisitos**
- Ejecutar como root o con permisos sudo
- PHP instalado y disponible en `/usr/bin/php`
- Servicio cron instalado y activo
- Acceso de escritura a `/var/www/html/sms/`

## 📧 Soporte

- **Autor**: Yeremi Tantaraico
- **Email**: yeremitantaraico@gmail.com
- **Versión del Script**: 2.0 (Corregida)
- **Sistema Objetivo**: Ubuntu Server 22.04

## 📝 Notas Importantes

- El script debe ejecutarse como root o con permisos sudo
- Se requiere conexión a internet estable
- El proceso puede tomar 15-20 minutos
- Se crean respaldos automáticos de configuraciones originales
- Todos los servicios se configuran para iniciar automáticamente

---

**⚠️ Importante**: Este script está diseñado específicamente para Ubuntu Server 22.04. Para otras distribuciones, puede requerir modificaciones.
