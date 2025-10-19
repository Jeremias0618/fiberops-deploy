#!/bin/bash
# ================================================
#   Sistema FiberOps 2025 - Configuración Crontab SMS
#   Autor: Yeremi Tantaraico
#   Email: yeremitantaraico@gmail.com
#   Ubuntu Server 22.04
#   Versión: 2.0 (Corregida)
#   Configura automáticamente tareas programadas para SMS
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
echo "                    CONFIGURACIÓN CRONTAB SMS 2025"
echo -e "\033[0m"

msg "🕒 Configurando crontab para sistema SMS FiberOps..."

# Directorio del sistema SMS
SMS_DIR="/var/www/html/sms"
PHP_BIN="/usr/bin/php"

# Verificar que se ejecute como root
if [[ $EUID -ne 0 ]]; then
   error_msg "Este script debe ejecutarse como root. Usa: sudo ./fiberops_removing_notifications.sh"
   exit 1
fi

# Verificar que PHP esté disponible
if ! command -v $PHP_BIN &> /dev/null; then
    error_msg "PHP no encontrado en $PHP_BIN"
    exit 1
fi

# Verificar que el directorio SMS existe
if [ ! -d "$SMS_DIR" ]; then
    warning_msg "Directorios SMS no encontrado: $SMS_DIR"
    info_msg "Creando directorio SMS..."
    mkdir -p "$SMS_DIR"
    mkdir -p "$SMS_DIR/scripts"
    mkdir -p "$SMS_DIR/logs"
    chown -R www-data:www-data "$SMS_DIR"
    chmod -R 755 "$SMS_DIR"
    msg "Directorio SMS creado exitosamente"
fi

# Crear backup del crontab actual
info_msg "Creando backup del crontab actual..."
BACKUP_FILE="/tmp/crontab_backup_$(date +%Y%m%d_%H%M%S)"
crontab -l > "$BACKUP_FILE" 2>/dev/null
if [ $? -eq 0 ]; then
    msg "Backup creado: $BACKUP_FILE"
else
    info_msg "No hay crontab existente, se creará uno nuevo"
fi

# Definir tareas cron para SMS
CRON_JOBS=(
    # Limpieza de notificaciones diaria a las 23:59
    "59 23 * * * $PHP_BIN $SMS_DIR/clear_notifications.php >> $SMS_DIR/logs/cleanup.log 2>&1"
    
    # Procesamiento de cola SMS cada 5 minutos
    "*/5 * * * * $PHP_BIN $SMS_DIR/scripts/process_queue.php >> $SMS_DIR/logs/queue.log 2>&1"
    
    # Reintento de SMS fallidos cada 30 minutos
    "*/30 * * * * $PHP_BIN $SMS_DIR/scripts/retry_failed.php >> $SMS_DIR/logs/retry.log 2>&1"
    
    # Generación de estadísticas diarias a las 06:00
    "0 6 * * * $PHP_BIN $SMS_DIR/scripts/stats_generator.php >> $SMS_DIR/logs/stats.log 2>&1"
    
    # Limpieza de logs antiguos semanal (domingos 02:00)
    "0 2 * * 0 $PHP_BIN $SMS_DIR/scripts/cleanup_old_logs.php >> $SMS_DIR/logs/maintenance.log 2>&1"
    
    # Verificación de salud del sistema SMS cada hora
    "0 * * * * $PHP_BIN $SMS_DIR/scripts/health_check.php >> $SMS_DIR/logs/health.log 2>&1"
    
    # Respaldo de configuraciones SMS diario a las 03:00
    "0 3 * * * $PHP_BIN $SMS_DIR/scripts/backup_config.php >> $SMS_DIR/logs/backup.log 2>&1"
)

info_msg "Configurando tareas cron para SMS..."

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
    echo "   Total de tareas SMS: $((ADDED_JOBS + EXISTING_JOBS))"
    
    echo -e "\n📋 \033[1;33mTAREAS PROGRAMADAS:\033[0m"
    echo "   • Limpieza notificaciones: Diaria 23:59"
    echo "   • Procesamiento cola SMS: Cada 5 minutos"
    echo "   • Reintento SMS fallidos: Cada 30 minutos"
    echo "   • Estadísticas diarias: 06:00"
    echo "   • Limpieza logs: Domingos 02:00"
    echo "   • Verificación salud SMS: Cada hora"
    echo "   • Respaldo configuraciones: Diario 03:00"
    
    echo -e "\n🔍 \033[1;33mCOMANDOS ÚTILES:\033[0m"
    echo "   Ver crontab actual: crontab -l"
    echo "   Editar crontab: crontab -e"
    echo "   Estado del servicio cron: systemctl status cron"
    
    echo -e "\n📝 \033[1;33mLOGS DISPONIBLES EN:\033[0m"
    echo "   $SMS_DIR/logs/"
else
    error_msg "Error configurando crontab"
    exit 1
fi

# Crear directorios de logs si no existen
info_msg "Verificando directorios de logs..."
mkdir -p "$SMS_DIR/logs"
mkdir -p "$SMS_DIR/scripts"
chmod 755 "$SMS_DIR/logs"
chmod 755 "$SMS_DIR/scripts"

# Crear archivos de log iniciales
LOG_FILES=("cleanup.log" "queue.log" "retry.log" "stats.log" "maintenance.log" "health.log" "backup.log")

for log_file in "${LOG_FILES[@]}"; do
    LOG_PATH="$SMS_DIR/logs/$log_file"
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