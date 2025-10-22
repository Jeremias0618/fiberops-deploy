#!/bin/bash
# ================================================
#   Sistema FiberOps 2025 - Configuración .htaccess
#   Autor: Yeremi Tantaraico
#   Email: yeremitantaraico@gmail.com
#   Ubuntu Server 22.04
#   Versión: 2.0 (Corregida)
#   Configura automáticamente el archivo .htaccess de seguridad
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
echo "                    CONFIGURACIÓN APACHE .HTACCESS 2025"
echo -e "\033[0m"

msg "🔒 Configurando Apache para usar archivo .htaccess existente en FiberOps..."

# Verificar que se ejecute como root
if [[ $EUID -ne 0 ]]; then
   error_msg "Este script debe ejecutarse como root. Usa: sudo ./fiberops_htaccess.sh"
   exit 1
fi

# Directorio del proyecto
PROJECT_DIR="/var/www/html"
HTACCESS_FILE="$PROJECT_DIR/.htaccess"

# Verificar que Apache esté instalado
if ! command -v apache2 &> /dev/null; then
    error_msg "Apache2 no está instalado"
    exit 1
fi

# Verificar que el directorio del proyecto existe
if [ ! -d "$PROJECT_DIR" ]; then
    error_msg "Directorio del proyecto no encontrado: $PROJECT_DIR"
    exit 1
fi

# Verificar que existe el archivo .htaccess
if [ -f "$HTACCESS_FILE" ]; then
    success_msg "Archivo .htaccess encontrado: $HTACCESS_FILE"
    info_msg "Configurando Apache para usar el .htaccess existente..."
else
    warning_msg "No se encontró archivo .htaccess en $PROJECT_DIR"
    info_msg "El script configurará Apache para permitir .htaccess cuando se cree"
fi

info_msg "Configurando Apache para usar archivo .htaccess..."

info_msg "Configurando módulos de Apache necesarios..."

# Habilitar módulos necesarios
a2enmod rewrite
a2enmod headers
a2enmod deflate
a2enmod expires

info_msg "Configurando Apache para permitir .htaccess..."

# Crear configuración de sitio si no existe
SITE_CONFIG="/etc/apache2/sites-available/000-default.conf"

if [ -f "$SITE_CONFIG" ]; then
    # Hacer backup de la configuración actual
    cp "$SITE_CONFIG" "$SITE_CONFIG.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Verificar si ya existe la configuración del directorio
    if ! grep -q "<Directory $PROJECT_DIR/>" "$SITE_CONFIG"; then
        info_msg "Agregando configuración de directorio a Apache..."
        
        # Agregar configuración al final del archivo
        cat >> "$SITE_CONFIG" << EOF

# Configuración para FiberOps
<Directory $PROJECT_DIR/>
    Options -Indexes
    AllowOverride All
    Require all granted
</Directory>
EOF
        msg "Configuración de directorio agregada"
    else
        info_msg "Configuración de directorio ya existe"
    fi
else
    error_msg "Archivo de configuración de Apache no encontrado: $SITE_CONFIG"
    exit 1
fi

info_msg "Reiniciando Apache..."
systemctl restart apache2

if systemctl is-active --quiet apache2; then
    success_msg "Apache reiniciado correctamente"
else
    error_msg "Error reiniciando Apache"
    exit 1
fi

# Verificar que los módulos estén habilitados
info_msg "Verificando módulos de Apache..."
REWRITE_STATUS=$(apache2ctl -M 2>/dev/null | grep rewrite | wc -l)
HEADERS_STATUS=$(apache2ctl -M 2>/dev/null | grep headers | wc -l)
DEFLATE_STATUS=$(apache2ctl -M 2>/dev/null | grep deflate | wc -l)
EXPIRES_STATUS=$(apache2ctl -M 2>/dev/null | grep expires | wc -l)

echo -e "\n📊 \033[1;33mVERIFICACIÓN DE MÓDULOS APACHE:\033[0m"
if [ "$REWRITE_STATUS" -gt 0 ]; then
    success_msg "Módulo mod_rewrite: Habilitado"
else
    error_msg "Módulo mod_rewrite: No habilitado"
fi

if [ "$HEADERS_STATUS" -gt 0 ]; then
    success_msg "Módulo mod_headers: Habilitado"
else
    error_msg "Módulo mod_headers: No habilitado"
fi

if [ "$DEFLATE_STATUS" -gt 0 ]; then
    success_msg "Módulo mod_deflate: Habilitado"
else
    warning_msg "Módulo mod_deflate: No habilitado (opcional)"
fi

if [ "$EXPIRES_STATUS" -gt 0 ]; then
    success_msg "Módulo mod_expires: Habilitado"
else
    warning_msg "Módulo mod_expires: No habilitado (opcional)"
fi

# Mostrar resumen de configuración
echo -e "\n📋 \033[1;33mRESUMEN DE CONFIGURACIÓN:\033[0m"
echo "   Directorio del proyecto: $PROJECT_DIR"
echo "   Archivo .htaccess: $HTACCESS_FILE"
echo "   Configuración Apache: $SITE_CONFIG"
echo "   Módulos habilitados: rewrite, headers, deflate, expires"

echo -e "\n🔒 \033[1;33mCONFIGURACIONES APLICADAS:\033[0m"
echo "   • Apache configurado para usar .htaccess"
echo "   • Módulos necesarios habilitados"
echo "   • Configuración de directorio actualizada"
echo "   • Servicio Apache reiniciado"

echo -e "\n🔍 \033[1;33mCOMANDOS DE VERIFICACIÓN:\033[0m"
echo "   Verificar .htaccess: ls -la $HTACCESS_FILE"
echo "   Ver logs de Apache: tail -f /var/log/apache2/error.log"
echo "   Probar acceso: curl -I http://localhost/"
echo "   Ver módulos: apache2ctl -M | grep -E '(rewrite|headers)'"

echo -e "\n⚠️ \033[1;33mPRUEBAS DE VERIFICACIÓN:\033[0m"
echo "   Verificar .htaccess funciona: curl -I http://localhost/"
echo "   Ver logs de Apache: tail -f /var/log/apache2/error.log"
echo "   Verificar módulos: apache2ctl -M | grep -E '(rewrite|headers)'"

# Mostrar estado final
echo -e "\n🎉 \033[1;32mCONFIGURACIÓN DE APACHE PARA .HTACCESS COMPLETADA EXITOSAMENTE\033[0m"
echo -e "\n📧 \033[1;36mSOPORTE:\033[0m yeremitantaraico@gmail.com"
echo -e "🔗 \033[1;36mDOCUMENTACIÓN:\033[0m https://cybercodelabs.com.pe"
echo -e "👨‍💻 \033[1;36mGITHUB:\033[0m https://github.com/Jeremias0618"
