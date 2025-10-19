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

# Dar permisos de ejecución
chmod +x fiberops_deploy.sh verify_fiberops_installation.sh

# Ejecutar instalación como root
sudo ./fiberops_deploy.sh

# Después de la instalación, verificar el sistema
sudo ./verify_fiberops_installation.sh
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
