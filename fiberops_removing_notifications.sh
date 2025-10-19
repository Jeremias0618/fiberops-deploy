#!/bin/bash
# ================================================
#   Configuración Automática Crontab para SMS
#   Autor: Yeremi Tantaraico
#   Email: yeremitantaraico@gmail.com
# ================================================

echo "🕒 Configurando crontab para sistema SMS FiberOps..."

# Directorio del sistema SMS
SMS_DIR="/var/www/html/sms"
PHP_BIN="/usr/bin/php"

# Verificar que PHP esté disponible
if ! command -v $PHP_BIN &> /dev/null; then
    echo "❌ PHP no encontrado en $PHP_BIN"
    exit 1
fi

# Verificar que el directorio SMS existe
if [ ! -d "$SMS_DIR" ]; then
    echo "❌ Directorio SMS no encontrado: $SMS_DIR"
    exit 1
fi

# Crear backup del crontab actual
echo "💾 Creando backup del crontab actual..."
crontab -l > /tmp/crontab_backup_$(date +%Y%m%d_%H%M%S) 2>/dev/null

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
)

echo "📋 Configurando tareas cron para SMS..."

# Obtener crontab actual
CURRENT_CRON=$(crontab -l 2>/dev/null)

# Agregar nuevas tareas si no existen
UPDATED_CRON="$CURRENT_CRON"

for job in "${CRON_JOBS[@]}"; do
    # Extraer el comando de la tarea
    JOB_COMMAND=$(echo "$job" | sed 's/.*\(\/usr\/bin\/php.*\)/\1/')
    
    # Verificar si la tarea ya existe
    if echo "$CURRENT_CRON" | grep -q "$JOB_COMMAND"; then
        echo "✅ Tarea ya existe: $(basename $(echo $JOB_COMMAND | awk '{print $2}'))"
    else
        echo "➕ Agregando tarea: $(basename $(echo $JOB_COMMAND | awk '{print $2}'))"
        UPDATED_CRON="$UPDATED_CRON"$'\n'"$job"
    fi
done

# Aplicar crontab actualizado
echo "$UPDATED_CRON" | crontab -

# Verificar que crontab se aplicó correctamente
if [ $? -eq 0 ]; then
    echo "✅ Crontab configurado exitosamente"
    echo ""
    echo "📋 Tareas programadas:"
    echo "   • Limpieza notificaciones: Diaria 23:59"
    echo "   • Procesamiento cola SMS: Cada 5 minutos"
    echo "   • Reintento SMS fallidos: Cada 30 minutos"
    echo "   • Estadísticas diarias: 06:00"
    echo "   • Limpieza logs: Domingos 02:00"
    echo ""
    echo "🔍 Para ver el crontab actual:"
    echo "   crontab -l"
    echo ""
    echo "📝 Logs disponibles en:"
    echo "   $SMS_DIR/logs/"
else
    echo "❌ Error configurando crontab"
    exit 1
fi

# Crear directorios de logs si no existen
echo "📁 Verificando directorios de logs..."
mkdir -p "$SMS_DIR/logs"
chmod 755 "$SMS_DIR/logs"

# Crear archivos de log iniciales
LOG_FILES=("cleanup.log" "queue.log" "retry.log" "stats.log" "maintenance.log")

for log_file in "${LOG_FILES[@]}"; do
    LOG_PATH="$SMS_DIR/logs/$log_file"
    if [ ! -f "$LOG_PATH" ]; then
        touch "$LOG_PATH"
        chmod 644 "$LOG_PATH"
        echo "📄 Creado: $log_file"
    fi
done

echo ""
echo "🎉 Configuración de crontab SMS completada exitosamente"
echo "📧 Soporte: yeremitantaraico@gmail.com"