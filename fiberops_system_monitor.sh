#!/bin/bash
# ================================================
#   Sistema FiberOps 2025 - Monitor del Sistema
#   Autor: Yeremi Tantaraico
#   Email: yeremitantaraico@gmail.com
#   Ubuntu Server 22.04
#   Versión: 2.0 (Corregida)
#   Monitoriza recursos del sistema y rendimiento
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

function progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r["
    printf "%*s" $filled | tr ' ' '█'
    printf "%*s" $empty | tr ' ' '░'
    printf "] %d%%" $percentage
}

# --- Variables globales ---
LOG_FILE="/var/log/fiberops_monitor.log"
ALERT_THRESHOLD_CPU=80
ALERT_THRESHOLD_MEMORY=85
ALERT_THRESHOLD_DISK=90
ALERT_THRESHOLD_NETWORK=1000

# --- Función para obtener información del sistema ---
function get_system_info() {
    echo -e "\n🖥️  \033[1;35mINFORMACIÓN DEL SISTEMA\033[0m"
    echo "   Hostname: $(hostname)"
    echo "   OS: $(lsb_release -d | cut -f2)"
    echo "   Kernel: $(uname -r)"
    echo "   Uptime: $(uptime -p)"
    echo "   Load Average: $(uptime | awk -F'load average:' '{print $2}')"
    echo "   Date: $(date)"
}

# --- Función para obtener información de hardware ---
function get_hardware_info() {
    section_header "HARDWARE DEL SISTEMA"
    
    echo -e "\n🔧 \033[1;33mPROCESADOR:\033[0m"
    echo "   Modelo: $(lscpu | grep "Model name" | cut -d: -f2 | xargs)"
    echo "   Arquitectura: $(lscpu | grep "Architecture" | cut -d: -f2 | xargs)"
    echo "   Cores: $(nproc)"
    echo "   Threads: $(lscpu | grep "^CPU(s):" | cut -d: -f2 | xargs)"
    echo "   Frecuencia: $(lscpu | grep "CPU MHz" | cut -d: -f2 | xargs) MHz"
    
    echo -e "\n💾 \033[1;33mMEMORIA RAM:\033[0m"
    local total_mem=$(free -h | grep "Mem:" | awk '{print $2}')
    local used_mem=$(free -h | grep "Mem:" | awk '{print $3}')
    local free_mem=$(free -h | grep "Mem:" | awk '{print $4}')
    local available_mem=$(free -h | grep "Mem:" | awk '{print $7}')
    
    echo "   Total: $total_mem"
    echo "   Usada: $used_mem"
    echo "   Libre: $free_mem"
    echo "   Disponible: $available_mem"
    
    # Calcular porcentaje de uso
    local mem_percent=$(free | grep "Mem:" | awk '{printf "%.1f", ($3/$2) * 100.0}')
    echo "   Uso: $mem_percent%"
    
    if (( $(echo "$mem_percent > $ALERT_THRESHOLD_MEMORY" | bc -l) )); then
        warning_msg "Memoria RAM con uso alto: $mem_percent%"
    else
        success_msg "Uso de memoria RAM normal: $mem_percent%"
    fi
    
    echo -e "\n💿 \033[1;33mALMACENAMIENTO:\033[0m"
    df -h | grep -E '^/dev/' | while read line; do
        local device=$(echo $line | awk '{print $1}')
        local size=$(echo $line | awk '{print $2}')
        local used=$(echo $line | awk '{print $3}')
        local available=$(echo $line | awk '{print $4}')
        local percent=$(echo $line | awk '{print $5}' | sed 's/%//')
        local mount=$(echo $line | awk '{print $6}')
        
        echo "   $device ($mount):"
        echo "     Tamaño: $size | Usado: $used | Disponible: $available"
        echo "     Uso: $percent%"
        
        if [ "$percent" -gt "$ALERT_THRESHOLD_DISK" ]; then
            warning_msg "Disco $device con uso crítico: $percent%"
        elif [ "$percent" -gt 75 ]; then
            info_msg "Disco $device con uso moderado: $percent%"
        else
            success_msg "Disco $device con uso normal: $percent%"
        fi
    done
}

# --- Función para monitorear CPU ---
function monitor_cpu() {
    section_header "MONITOREO DE CPU"
    
    echo -e "\n🔄 \033[1;33mUSO DE CPU:\033[0m"
    
    # Obtener información detallada del CPU
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    echo "   Uso actual: ${cpu_usage}%"
    
    # Mostrar barras de progreso para cada core
    local cores=$(nproc)
    echo -e "\n   Uso por core:"
    for ((i=0; i<cores; i++)); do
        local core_usage=$(top -bn1 | grep "Cpu$i" | awk '{print $2}' | sed 's/%us,//')
        if [ -z "$core_usage" ]; then
            core_usage="0"
        fi
        echo -n "   Core $i: "
        progress_bar ${core_usage%.*} 100
        echo ""
    done
    
    # Verificar temperatura si está disponible
    if [ -f "/sys/class/thermal/thermal_zone0/temp" ]; then
        local temp=$(cat /sys/class/thermal/thermal_zone0/temp)
        local temp_celsius=$((temp/1000))
        echo "   Temperatura: ${temp_celsius}°C"
        
        if [ "$temp_celsius" -gt 80 ]; then
            warning_msg "Temperatura del CPU alta: ${temp_celsius}°C"
        else
            success_msg "Temperatura del CPU normal: ${temp_celsius}°C"
        fi
    fi
    
    # Alertas de CPU
    if (( $(echo "$cpu_usage > $ALERT_THRESHOLD_CPU" | bc -l) )); then
        warning_msg "CPU con uso alto: $cpu_usage%"
    else
        success_msg "Uso de CPU normal: $cpu_usage%"
    fi
}

# --- Función para monitorear memoria ---
function monitor_memory() {
    section_header "MONITOREO DE MEMORIA"
    
    echo -e "\n💾 \033[1;33mDETALLES DE MEMORIA:\033[0m"
    
    # Información detallada de memoria
    free -h | while read line; do
        if [[ $line == Mem:* ]]; then
            echo "   $line"
        elif [[ $line == Swap:* ]]; then
            echo "   $line"
        fi
    done
    
    # Procesos que más memoria consumen
    echo -e "\n📊 \033[1;33mTOP 5 PROCESOS CON MÁS MEMORIA:\033[0m"
    ps aux --sort=-%mem | head -6 | tail -5 | while read line; do
        local pid=$(echo $line | awk '{print $2}')
        local user=$(echo $line | awk '{print $1}')
        local mem_percent=$(echo $line | awk '{print $4}')
        local command=$(echo $line | awk '{for(i=11;i<=NF;i++) printf "%s ", $i}')
        echo "   PID: $pid | Usuario: $user | Memoria: $mem_percent% | Comando: ${command:0:50}..."
    done
    
    # Verificar memoria swap
    local swap_used=$(free | grep "Swap:" | awk '{print $3}')
    local swap_total=$(free | grep "Swap:" | awk '{print $2}')
    
    if [ "$swap_total" -gt 0 ]; then
        local swap_percent=$(free | grep "Swap:" | awk '{printf "%.1f", ($3/$2) * 100.0}')
        echo -e "\n🔄 \033[1;33mSWAP:\033[0m"
        echo "   Uso: $swap_percent%"
        
        if (( $(echo "$swap_percent > 50" | bc -l) )); then
            warning_msg "Uso alto de swap: $swap_percent%"
        else
            success_msg "Uso normal de swap: $swap_percent%"
        fi
    fi
}

# --- Función para monitorear red ---
function monitor_network() {
    section_header "MONITOREO DE RED"
    
    echo -e "\n🌐 \033[1;33mINTERFACES DE RED:\033[0m"
    
    # Información de interfaces de red
    ip addr show | grep -E "^[0-9]+:|inet " | while read line; do
        if [[ $line =~ ^[0-9]+: ]]; then
            local interface=$(echo $line | awk '{print $2}' | sed 's/://')
            echo "   Interfaz: $interface"
        elif [[ $line =~ inet ]]; then
            local ip=$(echo $line | awk '{print $2}')
            echo "     IP: $ip"
        fi
    done
    
    # Estadísticas de red
    echo -e "\n📊 \033[1;33mESTADÍSTICAS DE RED:\033[0m"
    cat /proc/net/dev | grep -v "lo:" | head -5 | while read line; do
        local interface=$(echo $line | awk '{print $1}' | sed 's/://')
        local rx_bytes=$(echo $line | awk '{print $2}')
        local tx_bytes=$(echo $line | awk '{print $10}')
        local rx_packets=$(echo $line | awk '{print $3}')
        local tx_packets=$(echo $line | awk '{print $11}')
        
        if [ "$interface" != "lo" ] && [ "$interface" != "Inter-" ]; then
            echo "   $interface:"
            echo "     RX: $(numfmt --to=iec $rx_bytes) ($rx_packets paquetes)"
            echo "     TX: $(numfmt --to=iec $tx_bytes) ($tx_packets paquetes)"
        fi
    done
    
    # Conexiones activas
    echo - audio "\n🔗 \033[1;33mCONEXIONES ACTIVAS:\033[0m"
    local established=$(netstat -an | grep ESTABLISHED | wc -l)
    local listening=$(netstat -an | grep LISTEN | wc -l)
    local time_wait=$(netstat -an | grep TIME_WAIT | wc -l)
    
    echo "   Establecidas: $established"
    echo "   Escuchando: $listening"
    echo "   Time Wait: $time_wait"
    
    # Top conexiones por IP
    echo -e "\n📈 \033[1;33mTOP 5 IPs CON MÁS CONEXIONES:\033[0m"
    netstat -an | grep ESTABLISHED | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -nr | head -5 | while read count ip; do
        echo "   $ip: $count conexiones"
    done
}

# --- Función para monitorear servicios ---
function monitor_services() {
    section_header "MONITOREO DE SERVICIOS FIBEROPS"
    
    echo -e "\n🔧 \033[1;33mESTADO DE SERVICIOS:\033[0m"
    
    local services=("apache2" "postgresql" "cron" "ssh")
    
    for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service"; then
            success_msg "$service está ejecutándose"
            
            # Obtener información adicional del servicio
            local memory_usage=$(ps aux | grep "$service" | grep -v grep | awk '{sum+=$6} END {printf "%.1f", sum/1024}')
            if [ ! -z "$memory_usage" ] && [ "$memory_usage" != "0.0" ]; then
                echo "     Memoria: ${memory_usage}MB"
            fi
        else
            error_msg "$service no está ejecutándose"
        fi
    done
    
    # Verificar puertos específicos
    echo -e "\n🔌 \033[1;33mPUERTOS ABIERTOS:\033[0m"
    local ports=("80:HTTP" "443:HTTPS" "5432:PostgreSQL" "22:SSH")
    
    for port_info in "${ports[@]}"; do
        local port=$(echo $port_info | cut -d: -f1)
        local service_name=$(echo $port_info | cut -d: -f2)
        
        if netstat -tuln | grep -q ":$port "; then
            success_msg "Puerto $port ($service_name) está abierto"
        else
            error_msg "Puerto $port ($service_name) está cerrado"
        fi
    done
}

# --- Función para monitorear procesos ---
function monitor_processes() {
    section_header "MONITOREO DE PROCESOS"
    
    echo -e "\n📊 \033[1;33mTOP 10 PROCESOS POR CPU:\033[0m"
    ps aux --sort=-%cpu | head -11 | tail -10 | while read line; do
        local pid=$(echo $line | awk '{print $2}')
        local user=$(echo $line | awk '{print $1}')
        local cpu_percent=$(echo $line | awk '{print $3}')
        local mem_percent=$(echo $line | awk '{print $4}')
        local command=$(echo $line | awk '{for(i=11;i<=NF;i++) printf "%s ", $i}')
        echo "   PID: $pid | Usuario: $user | CPU: $cpu_percent% | Mem: $mem_percent% | ${command:0:40}..."
    done
    
    echo -e "\n🔄 \033[1;33mPROCESOS PHP:\033[0m"
    local php_processes=$(ps aux | grep php | grep -v grep | wc -l)
    echo "   Procesos PHP activos: $php_processes"
    
    if [ "$php_processes" -gt 0 ]; then
        ps aux | grep php | grep -v grep | while read line; do
            local pid=$(echo $line | awk '{print $2}')
            local mem_percent=$(echo $line | awk '{print $4}')
            local command=$(echo $line | awk '{for(i=11;i<=NF;i++) printf "%s ", $i}')
            echo "     PID: $pid | Mem: $mem_percent% | ${command:0:50}..."
        done
    fi
}

# --- Función para generar reporte ---
function generate_report() {
    section_header "REPORTE DE RENDIMIENTO"
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "\n📋 \033[1;33mRESUMEN DEL SISTEMA:\033[0m"
    echo "   Fecha: $timestamp"
    echo "   Hostname: $(hostname)"
    echo "   Uptime: $(uptime -p)"
    
    # Resumen de recursos
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    local mem_percent=$(free | grep "Mem:" | awk '{printf "%.1f", ($3/$2) * 100.0}')
    local disk_usage=$(df -h / | awk 'NR==2{print $5}' | sed 's/%//')
    
    echo -e "\n📊 \033[1;33mUSO DE RECURSOS:\033[0m"
    echo "   CPU: ${cpu_usage}%"
    echo "   Memoria: ${mem_percent}%"
    echo "   Disco (/): ${disk_usage}%"
    
    # Estado general
    echo -e "\n🎯 \033[1;33mESTADO GENERAL:\033[0m"
    local alerts=0
    
    if (( $(echo "$cpu_usage > $ALERT_THRESHOLD_CPU" | bc -l) )); then
        warning_msg "CPU con uso alto: $cpu_usage%"
        alerts=$((alerts + 1))
    fi
    
    if (( $(echo "$mem_percent > $ALERT_THRESHOLD_MEMORY" | bc -l) )); then
        warning_msg "Memoria con uso alto: $mem_percent%"
        alerts=$((alerts + 1))
    fi
    
    if [ "$disk_usage" -gt "$ALERT_THRESHOLD_DISK" ]; then
        warning_msg "Disco con uso crítico: $disk_usage%"
        alerts=$((alerts + 1))
    fi
    
    if [ "$alerts" -eq 0 ]; then
        success_msg "Sistema funcionando normalmente"
    else
        warning_msg "Se detectaron $alerts alertas en el sistema"
    fi
    
    # Guardar en log
    echo "[$timestamp] CPU:${cpu_usage}% MEM:${mem_percent}% DISK:${disk_usage}% ALERTS:$alerts" >> "$LOG_FILE"
}

# --- Función para monitoreo continuo ---
function continuous_monitor() {
    local interval=${1:-5}
    
    section_header "MONITOREO CONTINUO (cada ${interval}s)"
    echo -e "\nPresiona Ctrl+C para detener el monitoreo\n"
    
    while true; do
        clear
        echo -e "\033[1;35m"
        echo "  ███████╗██╗██████╗ ███████╗██████╗  ██████╗ ██████╗ ███████╗"
        echo "  ██╔════╝██║██╔══██╗██╔════╝██╔══██╗██╔═══██╗██╔══██╗██╔════╝"
        echo "  █████╗  ██║██████╔╝█████╗  ██████╔╝██║   ██║██████╔╝███████╗"
        echo "  ██╔══╝  ██║██╔══██╗██╔══╝  ██╔══██╗██║   ██║██╔═══╝ ╚════██║"
        echo "  ██║     ██║██████╔╝███████╗██║  ██║╚██████╔╝██║     ███████║"
        echo "  ╚═╝     ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚══════╝"
        echo "                         MONITOR EN TIEMPO REAL"
        echo -e "\033[0m"
        
        get_system_info
        monitor_cpu
        monitor_memory
        
        echo -e "\n⏰ Próxima actualización en ${interval} segundos..."
        sleep "$interval"
    done
}

# === INICIO DEL SCRIPT ===
echo -e "\033[1;35m"
echo "  ███████╗██╗██████╗ ███████╗██████╗  ██████╗ ██████╗ ███████╗"
echo "  ██╔════╝██║██╔══██╗██╔════╝██╔══██╗██╔═══██╗██╔══██╗██╔════╝"
echo "  █████╗  ██║██████╔╝█████╗  ██████╔╝██║   ██║██████╔╝███████╗"
echo "  ██╔══╝  ██║██╔══██╗██╔══╝  ██╔══██╗██║   ██║██╔═══╝ ╚════██║"
echo "  ██║     ██║██████╔╝███████╗██║  ██║╚██████╔╝██║     ███████║"
echo "  ╚═╝     ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚══════╝"
echo "                         MONITOR DEL SISTEMA 2025"
echo -e "\033[0m"

# Verificar si se necesita bc para cálculos
if ! command -v bc &> /dev/null; then
    info_msg "Instalando bc para cálculos matemáticos..."
    apt install -y bc
fi

# Verificar argumentos
if [ "$1" = "continuous" ] || [ "$1" = "-c" ]; then
    continuous_monitor "${2:-5}"
elif [ "$1" = "help" ] || [ "$1" = "-h" ]; then
    echo -e "\n📖 \033[1;33mUSO DEL SCRIPT:\033[0m"
    echo "   ./fiberops_system_monitor.sh           - Monitoreo completo una vez"
    echo "   ./fiberops_system_monitor.sh -c [seg]  - Monitoreo continuo (default: 5s)"
    echo "   ./fiberops_system_monitor.sh -h        - Mostrar esta ayuda"
    echo ""
    echo "📋 \033[1;33mFUNCIONES:\033[0m"
    echo "   • Información del hardware y sistema"
    echo "   • Monitoreo de CPU, memoria y almacenamiento"
    echo "   • Estadísticas de red y conectividad"
    echo "   • Estado de servicios FiberOps"
    echo "   • Análisis de procesos y rendimiento"
    echo "   • Alertas automáticas por umbrales"
    echo "   • Logging automático de métricas"
    exit 0
else
    # Monitoreo completo una vez
    get_system_info
    get_hardware_info
    monitor_cpu
    monitor_memory
    monitor_network
    monitor_services
    monitor_processes
    generate_report
fi

echo -e "\n📧 \033[1;36mSOPORTE:\033[0m yeremitantaraico@gmail.com"
echo -e "🔗 \033[1;36mDOCUMENTACIÓN:\033[0m https://cybercodelabs.com"
echo -e "📁 \033[1;36mLOG:\033[0m $LOG_FILE"
