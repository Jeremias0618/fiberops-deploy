#!/bin/bash
# ================================================
#   Sistema FiberOps 2025 - Configuración Crontab Zabbix
#   Autor: Yeremi Tantaraico
#   Email: yeremitantaraico@gmail.com
#   Ubuntu Server 22.04
#   Versión: 2.0 (Corregida)
#   Configura automáticamente tareas programadas para Zabbix
# ================================================

# --- Función para mostrar mensajes bonitos ---
function msg() {
    echo -e "\n\033[1;32m[✔]\033[0m $1\n"
}

function error_msg() {
    echo -e "\n\033[1;31m[✗]\033[0m $1\n"
}

function warning_msg() {
    echo -e "\n\033[1;33m[⚠]\033[0m $1\n"
}

function info_msg() {
    echo -e "\n\033[1;34m[ℹ]\033[0m $1\n"
}

# === INICIO DE CONFIGURACIÓN ===
echo -e "\033[1;35m"
echo "  ███████╗██╗██████╗ ███████╗██████╗  ██████╗ ██████╗ ███████╗"
echo "  ██╔════╝██║██╔══██╗██╔════╝██╔══██╗██╔═══██╗██╔══██╗██╔════╝"
echo "  █████╗  ██║██████╔╝█████╗  ██████╔╝██║   ██║██████╔╝███████╗"
echo "  ██╔══╝  ██║██╔══██╗██╔══╝  ██╔══██╗██║   ██║██╔═══╝ ╚════██║"
echo "  ██║     ██║██████╔╝███████╗██║  ██║╚██████╔╝██║     ███████║"
echo "  ╚═╝     ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚══════╝"
echo "                    CONFIGURACIÓN CRONTAB ZABBIX 2025"
echo -e "\033[0m"

msg "🕒 Configurando crontab para sistema Zabbix FiberOps..."

# Verificar que se ejecute como root
if [[ $EUID -ne 0 ]]; then
   error_msg "Este script debe ejecutarse como root. Usa: sudo ./fiberops_setup_zabbix_cron.sh"
   exit 1
fi

# Directorio del sistema Zabbix
ZABBIX_DIR="/var/www/html/zabbix"
PHP_BIN="/usr/bin/php"
PHP_SCRIPT="$ZABBIX_DIR/get_events_data.php"

# Verificar que PHP esté disponible
if ! command -v $PHP_BIN &> /dev/null; then
    error_msg "PHP no encontrado en $PHP_BIN"
    exit 1
fi

# Verificar que el directorio Zabbix existe
if [ ! -d "$ZABBIX_DIR" ]; then
    warning_msg "Directorio Zabbix no encontrado: $ZABBIX_DIR"
    info_msg "Creando directorio Zabbix..."
    mkdir -p "$ZABBIX_DIR"
    mkdir -p "$ZABBIX_DIR/statistics"
    chown -R www-data:www-data "$ZABBIX_DIR"
    chmod -R 755 "$ZABBIX_DIR"
    msg "Directorio Zabbix creado exitosamente"
fi

# Verificar que el archivo PHP existe
if [ ! -f "$PHP_SCRIPT" ]; then
    error_msg "No se encontró el archivo get_events_data.php en $ZABBIX_DIR"
    info_msg "Asegúrate de que el archivo get_events_data.php esté en el directorio correcto"
    exit 1
fi

# Crear backup del crontab actual
info_msg "Creando backup del crontab actual..."
BACKUP_FILE="/tmp/zabbix_crontab_backup_$(date +%Y%m%d_%H%M%S)"
crontab -l > "$BACKUP_FILE" 2>/dev/null
if [ $? -eq 0 ]; then
    msg "Backup creado: $BACKUP_FILE"
else
    info_msg "No hay crontab existente, se creará uno nuevo"
fi

# Definir tareas cron para Zabbix
CRON_JOBS=(
    # Recopilación de estadísticas Zabbix cada minuto (ejecuta cada 3 segundos durante 1 minuto)
    "*/1 * * * * cd $ZABBIX_DIR && timeout 60 bash -c 'while true; do $PHP_BIN get_events_data.php >> $ZABBIX_DIR/statistics/zabbix_collection.log 2>&1; sleep 3; done'"
    
    # Optimización de archivos estadísticos diaria a las 02:00
    "0 2 * * * cd $ZABBIX_DIR && $PHP_BIN fix_current_stats.php >> $ZABBIX_DIR/statistics/optimization.log 2>&1"
    
    # Limpieza de archivos obsoletos semanal (domingos 03:00)
    "0 3 * * 0 cd $ZABBIX_DIR && $PHP_BIN cleanup_large_files.php >> $ZABBIX_DIR/statistics/cleanup.log 2>&1"
    
    # Verificación de salud del sistema Zabbix cada 6 horas
    "0 */6 * * * cd $ZABBIX_DIR && $PHP_BIN health_check.php >> $ZABBIX_DIR/statistics/health.log 2>&1"
)

info_msg "Configurando tareas cron para Zabbix..."

# Obtener crontab actual
CURRENT_CRON=$(crontab -l 2>/dev/null)

# Agregar nuevas tareas si no existen
UPDATED_CRON="$CURRENT_CRON"
ADDED_JOBS=0
EXISTING_JOBS=0

for job in "${CRON_JOBS[@]}"; do
    # Extraer el comando de la tarea
    JOB_COMMAND=$(echo "$job" | sed 's/.*\(\/usr\/bin\/php.*\)/\1/')
    JOB_NAME=$(basename $(echo $JOB_COMMAND | awk '{print $2}'))
    
    # Verificar si la tarea ya existe
    if echo "$CURRENT_CRON" | grep -q "$JOB_COMMAND"; then
        success_msg "Tarea ya existe: $JOB_NAME"
        EXISTING_JOBS=$((EXISTING_JOBS + 1))
    else
        info_msg "Agregando tarea: $JOB_NAME"
        UPDATED_CRON="$UPDATED_CRON"$'\n'"$job"
        ADDED_JOBS=$((ADDED_JOBS + 1))
    fi
done

# Aplicar crontab actualizado
echo "$UPDATED_CRON" | crontab -

# Verificar que crontab se aplicó correctamente
if [ $? -eq 0 ]; then
    msg "Crontab configurado exitosamente"
    
    echo -e "\n📊 \033[1;33mRESUMEN SOBRE LA CONFIGURACIÓN:\033[0m"
    echo "   Tareas agregadas: $ADDED_JOBS"
    echo "   Tareas existentes: $EXISTING_JOBS"
    echo "   Total de tareas Zabbix: $((ADDED_JOBS + EXISTING_JOBS))"
    
    echo -e "\n📋 \033[1;33mTAREAS PROGRAMADAS:\033[0m"
    echo "   • Recopilación estadísticas: Cada minuto (cada 3 segundos)"
    echo "   • Optimización archivos: Diaria 02:00"
    echo "   • Limpieza archivos obsoletos: Domingos 03:00"
    echo "   • Verificación salud sistema: Cada 6 horas"
    
    echo -e "\n🔍 \033[1;33mCOMANDOS ÚTILES:\033[0m"
    echo "   Ver crontab actual: crontab -l"
    echo "   Editar crontab: crontab -e"
    echo "   Estado del servicio cron: systemctl status cron"
    
    echo -e "\n📝 \033[1;33mLOGS DISPONIBLES EN:\033[0m"
    echo "   $ZABBIX_DIR/statistics/"
    
    echo -e "\n📊 \033[1;33mVERIFICACIÓN:\033[0m"
    echo "   Para ver logs en tiempo real:"
    echo "   tail -f $ZABBIX_DIR/statistics/events_log_\$(date +%Y-%m-%d).txt"
    echo ""
    echo "   Para verificar archivos generados:"
    echo "   ls -la $ZABBIX_DIR/statistics/"
else
    error_msg "Error configurando crontab"
    exit 1
fi

# Crear directorios de logs si no existen
info_msg "Verificando directorios de logs..."
mkdir -p "$ZABBIX_DIR/statistics"
chmod 755 "$ZABBIX_DIR/statistics"

# Crear archivos de log iniciales
LOG_FILES=("zabbix_collection.log" "optimization.log" "cleanup.log" "health.log")

for log_file in "${LOG_FILES[@]}"; do
    LOG_PATH="$ZABBIX_DIR/statistics/$log_file"
    if [ ! -f "$LOG_PATH" ]; then
        touch "$LOG_PATH"
        chmod 644 "$LOG_PATH"
        chown www-data:www-data "$LOG_PATH"
        info_msg "Creado archivo de log: $log_file"
    fi
done

# Verificar que el servicio cron esté ejecutándose
info_msg "Verificando servicio cron..."
if systemctl is-active --quiet cron; then
    success_msg "Servicio cron está ejecutándose"
else
    warning_msg "Servicio cron no está ejecutándose"
    info_msg "Iniciando servicio cron..."
    systemctl start cron
    systemctl enable cron
    if systemctl is-active --quiet cron; then
        success_msg "Servicio cron iniciado correctamente"
    else
        error_msg "Error iniciando servicio cron"
    fi
fi

# Mostrar estado final
echo -e "\n🎉 \033[1;32mCONFIGURACIÓN COMPLETADA EXITOSAMENTE\033[0m"
echo -e "\n📧 \033[1;36mSOPORTE:\033[0m yeremitantaraico@gmail.com"
echo -e "🔗 \033[1;36mDOCUMENTACIÓN:\033[0m https://cybercodelabs.com.pe"
echo -e "👨‍💻 \033[1;36mGITHUB:\033[0m https://github.com/Jeremias0618"
