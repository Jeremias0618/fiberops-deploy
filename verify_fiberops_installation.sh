#!/bin/bash
# ================================================
#   Sistema FiberOps 2025 - Verificación de Instalación
#   Autor: Yeremi Tantaraico
#   Email: yeremitantaraico@gmail.com
#   Ubuntu Server 22.04
#   Versión: 2.0 (Corregida)
#   Verifica toda la instalación del sistema FiberOps
# ================================================

# --- Funciones para mostrar mensajes ---
function success_msg() {
    echo -e "\033[1;32m[✔]\033[0m $1"
}

function error_msg() {
    echo -e "\033[1;31m[✗]\033[0m $1"
}

function warning_msg() {
    echo -e "\033[1;33m[⚠]\033[0m $1"
}

function info_msg() {
    echo -e "\033[1;34m[ℹ]\033[0m $1"
}

function section_header() {
    echo -e "\n\033[1;36m═══════════════════════════════════════════════════════════════\033[0m"
    echo -e "\033[1;36m  $1\033[0m"
    echo -e "\033[1;36m═══════════════════════════════════════════════════════════════\033[0m"
}

# --- Variables globales ---
ERRORS=0
WARNINGS=0
TOTAL_CHECKS=0

function check_item() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if eval "$2" > /dev/null 2>&1; then
        success_msg "$1"
        return 0
    else
        error_msg "$1"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

function check_version() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    RESULT=$(eval "$2" 2>/dev/null)
    if [ $? -eq 0 ] && [ ! -z "$RESULT" ]; then
        success_msg "$1: $RESULT"
        return 0
    else
        error_msg "$1: No disponible"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

function check_service() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if systemctl is-active --quiet "$2"; then
        success_msg "$1 está ejecutándose"
        return 0
    else
        error_msg "$1 no está ejecutándose"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

# === INICIO DE VERIFICACIÓN ===
echo -e "\033[1;35m"
echo "  ███████╗██╗██████╗ ███████╗██████╗  ██████╗ ██████╗ ███████╗"
echo "  ██╔════╝██║██╔══██╗██╔════╝██╔══██╗██╔═══██╗██╔══██╗██╔════╝"
echo "  █████╗  ██║██████╔╝█████╗  ██████╔╝██║   ██║██████╔╝███████╗"
echo "  ██╔══╝  ██║██╔══██╗██╔══╝  ██╔══██╗██║   ██║██╔═══╝ ╚════██║"
echo "  ██║     ██║██████╔╝███████╗██║  ██║╚██████╔╝██║     ███████║"
echo "  ╚═╝     ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚══════╝"
echo "                    VERIFICACIÓN DE INSTALACIÓN 2025"
echo -e "\033[0m"

# === 1. VERIFICAR SERVICIOS DEL SISTEMA ===
section_header "1. SERVICIOS DEL SISTEMA"
check_service "Apache2" "apache2"
check_service "PostgreSQL" "postgresql"

# === 2. VERIFICAR VERSIONES DE SOFTWARE ===
section_header "2. VERSIONES DE SOFTWARE INSTALADO"
check_version "PHP" "php -v | head -n1"
check_version "Apache" "apache2 -v | head -n1"
check_version "PostgreSQL" "su - postgres -c 'psql -c \"SELECT version();\"' 2>/dev/null | head -n3 | tail -n1 | xargs"
check_version "Composer" "/usr/local/bin/composer --version 2>/dev/null"

# === 3. VERIFICAR EXTENSIONES PHP ===
section_header "3. EXTENSIONES PHP REQUERIDAS"
REQUIRED_EXTENSIONS=("ssh2" "snmp" "pgsql" "gd" "mbstring" "curl" "xml" "intl" "pdo" "bcmath" "zip" "readline")

for ext in "${REQUIRED_EXTENSIONS[@]}"; do
    check_item "Extensión PHP: $ext" "php -m | grep -q '^$ext$'"
done

# === 4. VERIFICAR CONFIGURACIÓN PHP ===
section_header "4. CONFIGURACIÓN PHP"
check_item "Zona horaria configurada (America/Lima)" "php -r 'echo date_default_timezone_get();' | grep -q 'America/Lima'"
check_item "Memory limit >= 512M" "php -r 'echo ini_get(\"memory_limit\");' | grep -qE '(512M|1G|2G|-1)'"
check_item "Max execution time >= 300" "php -r 'echo ini_get(\"max_execution_time\");' | grep -qE '(300|600|0)'"
check_item "Upload max filesize >= 100M" "php -r 'echo ini_get(\"upload_max_filesize\");' | grep -qE '[1-9][0-9][0-9]M'"

# === 5. VERIFICAR MÓDULOS APACHE ===
section_header "5. MÓDULOS APACHE HABILITADOS"
check_item "Módulo Rewrite" "apache2ctl -M | grep -q rewrite"
check_item "Módulo Headers" "apache2ctl -M | grep -q headers"
check_item "Módulo PHP 8.1" "apache2ctl -M | grep -q php8"

# === 6. VERIFICAR DIRECTORIOS Y PERMISOS ===
section_header "6. DIRECTORIOS Y PERMISOS"
check_item "Directorio /var/www/html/ existe" "[ -d '/var/www/html/' ]"
check_item "Directorio logs existe" "[ -d '/var/www/html/logs' ]"
check_item "Permisos de escritura en /var/www/html/" "[ -w '/var/www/html/' ]"
check_item "Propietario www-data en /var/www/html/" "[ \$(stat -c '%U' /var/www/html/) = 'www-data' ]"

# === 7. VERIFICAR HERRAMIENTAS SNMP ===
section_header "7. HERRAMIENTAS SNMP"
check_item "SNMP tools instalados" "which snmpget"
check_item "SNMPD daemon" "which snmpd"
check_item "Python3 y pip3" "which python3 && which pip3"
check_item "Psycopg2 para Python" "python3 -c 'import psycopg2' 2>/dev/null"

# === 8. VERIFICAR COMPOSER Y DEPENDENCIAS ===
section_header "8. COMPOSER Y DEPENDENCIAS"
check_item "Composer ejecutable" "[ -x '/usr/local/bin/composer' ]"

# Verificar vendor_global si existe
if [ -d "/var/www/html/vendor_global" ]; then
    info_msg "Directorio vendor_global encontrado, verificando dependencias..."
    
    # Cambiar al directorio vendor_global
    cd /var/www/html/vendor_global 2>/dev/null || cd /var/www/html/
    
    if [ -f "composer.json" ]; then
        success_msg "Archivo composer.json encontrado"
        
        # Verificar si las dependencias están instaladas
        if [ -d "vendor" ]; then
            success_msg "Directorio vendor existe"
            
            # Verificar dependencias específicas del composer.json
            DEPENDENCIES=(
                "phpoffice/phpspreadsheet"
                "openspout/openspout" 
                "guzzlehttp/guzzle"
                "monolog/monolog"
                "vlucas/phpdotenv"
                "ramsey/uuid"
                "nesbot/carbon"
                "league/csv"
                "symfony/console"
                "phpmailer/phpmailer"
                "firebase/php-jwt"
                "respect/validation"
            )
            
            for dep in "${DEPENDENCIES[@]}"; do
                check_item "Dependencia: $dep" "[ -d \"vendor/$dep\" ] || grep -q \"$dep\" vendor/composer/installed.json"
            done
            
            # Verificar autoloader
            check_item "Autoloader de Composer" "[ -f 'vendor/autoload.php' ]"
            check_item "Autoloader personalizado" "[ -f 'autoload_global.php' ]"
        else
            warning_msg "Directorio vendor no existe - ejecutar: cd vendor_global && composer install"
            WARNINGS=$((WARNINGS + 1))
        fi
    else
        error_msg "composer.json no encontrado en vendor_global"
        ERRORS=$((ERRORS + 1))
    fi
else
    warning_msg "Directorio vendor_global no encontrado"
    WARNINGS=$((WARNINGS + 1))
fi

# === 9. VERIFICAR CONECTIVIDAD ===
section_header "9. CONECTIVIDAD Y PUERTOS"
check_item "Puerto 80 (HTTP) abierto" "netstat -tuln | grep -q ':80 '"
check_item "Puerto 5432 (PostgreSQL) abierto" "netstat -tuln | grep -q ':5432 '"

# === 10. VERIFICAR CONFIGURACIÓN DEL SISTEMA ===
section_header "10. CONFIGURACIÓN DEL SISTEMA"
check_item "Zona horaria del sistema (America/Lima)" "timedatectl | grep -q 'America/Lima'"
check_item "IPv6 deshabilitado" "[ -f '/etc/gai.conf' ] && grep -q 'precedence ::ffff:0:0/96 100' /etc/gai.conf"

# === 11. CONFIGURAR CRONTAB AUTOMÁTICAMENTE ===
section_header "11. CONFIGURACIÓN DE CRONTAB"

# Verificar si el archivo de notificaciones existe
if [ -f "/var/www/html/sms/clear_notifications.php" ]; then
    info_msg "Archivo clear_notifications.php encontrado, configurando crontab..."
    
    # Crear entrada de crontab para limpiar notificaciones
    CRON_ENTRY="59 23 * * * /usr/bin/php /var/www/html/sms/clear_notifications.php"
    
    # Verificar si ya existe la entrada en crontab
    if crontab -l 2>/dev/null | grep -q "clear_notifications.php"; then
        success_msg "Crontab ya configurado para clear_notifications.php"
    else
        # Agregar la entrada al crontab
        (crontab -l 2>/dev/null; echo "$CRON_ENTRY") | crontab -
        if [ $? -eq 0 ]; then
            success_msg "Crontab configurado: clear_notifications.php a las 23:59 diariamente"
        else
            error_msg "Error configurando crontab para clear_notifications.php"
            ERRORS=$((ERRORS + 1))
        fi
    fi
    
    # Verificar que el servicio cron esté ejecutándose
    check_service "Servicio Cron" "cron"
    
    # Mostrar las entradas actuales del crontab
    info_msg "Entradas actuales del crontab:"
    crontab -l 2>/dev/null | grep -v "^#" | while read line; do
        if [ ! -z "$line" ]; then
            echo "   📅 $line"
        fi
    done
    
else
    warning_msg "Archivo /var/www/html/sms/clear_notifications.php no encontrado"
    warning_msg "El crontab se configurará cuando se despliegue el código completo"
    WARNINGS=$((WARNINGS + 1))
fi

# Verificar otros posibles scripts que puedan necesitar cron
POSSIBLE_CRON_SCRIPTS=(
    "/var/www/html/sms/notification_handler.php"
    "/var/www/html/activaciones/clear_logs.php"
    "/var/www/html/facturacion/actualizar_estadisticas.php"
)

info_msg "Verificando otros posibles scripts para crontab..."
for script in "${POSSIBLE_CRON_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        info_msg "Encontrado: $script (considera agregarlo a crontab si es necesario)"
    fi
done

# === RESUMEN FINAL ===
section_header "RESUMEN DE VERIFICACIÓN"

echo -e "\n📊 \033[1;36mESTADÍSTICAS:\033[0m"
echo "   Total de verificaciones: $TOTAL_CHECKS"
echo "   ✅ Exitosas: $((TOTAL_CHECKS - ERRORS - WARNINGS))"
echo "   ⚠️  Advertencias: $WARNINGS"
echo "   ❌ Errores: $ERRORS"

echo -e "\n🎯 \033[1;36mESTADO GENERAL:\033[0m"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "   \033[1;32m✅ INSTALACIÓN PERFECTA - FiberOps listo para producción\033[0m"
    exit 0
elif [ $ERRORS -eq 0 ] && [ $WARNINGS -gt 0 ]; then
    echo -e "   \033[1;33m⚠️  INSTALACIÓN BUENA - Revisar advertencias\033[0m"
    exit 0
elif [ $ERRORS -le 3 ]; then
    echo -e "   \033[1;31m❌ INSTALACIÓN CON PROBLEMAS MENORES - Revisar errores\033[0m"
    exit 1
else
    echo -e "   \033[1;31m💥 INSTALACIÓN FALLIDA - Múltiples errores críticos\033[0m"
    exit 2
fi

echo -e "\n📧 \033[1;36mSOPORTE:\033[0m yeremitantaraico@gmail.com"
echo -e "🔗 \033[1;36mDOCUMENTACIÓN:\033[0m https://cybercodelabs.com.pe"
echo -e "👨‍💻 \033[1;36mGITHUB:\033[0m https://github.com/Jeremias0618"
