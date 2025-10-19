#!/bin/bash
# ================================================
#   Sistema FiberOps 2025 - Instalación Automática
#   Autor: Yeremi Tantaraico
#   Email: yeremitantaraico@gmail.com
#   Ubuntu Server 22.04
#   Versión: 2.0 (Corregida)
#   Instala y configura todo el entorno necesario para FiberOps
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

# --- Verificar que se ejecute como root ---
if [[ $EUID -ne 0 ]]; then
   error_msg "Este script debe ejecutarse como root. Usa: sudo ./install_fiberops.sh"
   exit 1
fi

# === INICIO DE INSTALACIÓN ===
echo -e "\033[1;35m"
echo "  ███████╗██╗██████╗ ███████╗██████╗  ██████╗ ██████╗ ███████╗"
echo "  ██╔════╝██║██╔══██╗██╔════╝██╔══██╗██╔═══██╗██╔══██╗██╔════╝"
echo "  █████╗  ██║██████╔╝█████╗  ██████╔╝██║   ██║██████╔╝███████╗"
echo "  ██╔══╝  ██║██╔══██╗██╔══╝  ██╔══██╗██║   ██║██╔═══╝ ╚════██║"
echo "  ██║     ██║██████╔╝███████╗██║  ██║╚██████╔╝██║     ███████║"
echo "  ╚═╝     ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚══════╝"
echo "                         INSTALACIÓN AUTOMÁTICA 2025"
echo -e "\033[0m"

msg "🚀 Iniciando instalación de FiberOps 2025..."

# --- 0. Pre-requisitos ---
msg "Deshabilitando IPv6 para evitar problemas de descarga..."
echo -e "precedence ::ffff:0:0/96 100" | tee -a /etc/gai.conf

# --- 1. Actualizar sistema ---
msg "Actualizando sistema..."
apt update && apt upgrade -y

# --- 2. Instalar Apache ---
msg "Instalando Apache..."
apt install apache2 -y
systemctl enable apache2
systemctl start apache2

# --- 3. Instalar PHP 8.1 y módulos ---
msg "Instalando PHP 8.1 y módulos necesarios..."
add-apt-repository ppa:ondrej/php -y
apt update

# Instalar PHP 8.1 con TODAS las extensiones necesarias
apt install php8.1 php8.1-cli php8.1-fpm php8.1-common \
    php8.1-mysql php8.1-zip php8.1-gd php8.1-mbstring php8.1-curl \
    php8.1-xml php8.1-bcmath php8.1-snmp php8.1-pgsql php8.1-readline \
    php8.1-intl php8.1-dev -y

# Configurar PHP 8.1 como predeterminado
update-alternatives --set php /usr/bin/php8.1
apt install libapache2-mod-php8.1 -y
a2enmod php8.1
systemctl restart apache2

# Verificar instalación
php -v
msg "PHP 8.1 instalado correctamente"

# --- 4. Instalar y habilitar SSH2 ---
msg "Instalando extensión SSH2 para PHP..."
apt install php-pear libssh2-1-dev libssl-dev build-essential -y

# Instalar SSH2 con respuesta automática
echo -e "\n" | pecl install ssh2-1.3.1

# Habilitar SSH2
echo "extension=ssh2.so" | tee /etc/php/8.1/apache2/conf.d/20-ssh2.ini
echo "extension=ssh2.so" | tee /etc/php/8.1/cli/conf.d/20-ssh2.ini

# Verificar SSH2
systemctl restart apache2
if php -m | grep -q ssh2; then
    msg "SSH2 instalado correctamente"
else
    warning_msg "SSH2 no se detectó, pero puede funcionar"
fi

# --- 5. Dependencias SNMP y PostgreSQL ---
msg "Instalando dependencias de SNMP y PostgreSQL..."
apt install snmp snmpd libpq-dev python3-dev python3-pip -y
apt install snmp-mibs-downloader php-snmp -y
pip3 install psycopg2-binary

# --- 5.1 Habilitar y verificar extensiones PHP ---
msg "Habilitando extensiones PHP..."
phpenmod -v 8.1 intl snmp pgsql gd mbstring

# Verificar extensiones críticas
msg "Verificando extensiones instaladas..."
php -m | grep -E "(gd|intl|pdo|pgsql|snmp|mbstring|curl|xml)" | while read ext; do
    echo "  ✓ $ext"
done

# Reiniciar Apache
systemctl restart apache2

# --- 6. Base de datos PostgreSQL ---
msg "Instalando PostgreSQL..."
apt install postgresql postgresql-contrib -y
systemctl enable postgresql
systemctl start postgresql

if systemctl is-active --quiet postgresql; then
    msg "PostgreSQL instalado y ejecutándose"
else
    error_msg "PostgreSQL no se inició correctamente"
fi

# --- 7. Instalar Composer (versión actualizada) ---
msg "Instalando Composer..."
cd /tmp

# Descargar e instalar Composer
curl -sS https://getcomposer.org/installer | php
if [ $? -eq 0 ]; then
    mv composer.phar /usr/local/bin/composer
    chmod +x /usr/local/bin/composer
    msg "Composer descargado e instalado correctamente"
else
    error_msg "Error descargando Composer"
    exit 1
fi

# Verificar que Composer esté instalado
if [ -f "/usr/local/bin/composer" ]; then
    msg "Composer instalado correctamente en /usr/local/bin/composer"
else
    error_msg "Error: Composer no se encontró en /usr/local/bin/composer"
    exit 1
fi

# --- 8. Preparar directorio del proyecto ---
msg "Preparando directorio de FiberOps..."
mkdir -p /var/www/html/
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/

# Crear directorio de logs si no existe
mkdir -p /var/www/html/logs
chown -R www-data:www-data /var/www/html/logs
chmod -R 777 /var/www/html/logs

# --- 9. Preparar para dependencias PHP del proyecto ---
msg "Directorio preparado para FiberOps. Las dependencias se instalarán después del despliegue del código."

# --- 10. Configurar Apache ---
msg "Configurando Apache..."
phpenmod snmp
a2enmod rewrite
a2enmod headers


systemctl restart apache2

# --- 11. Configurar zona horaria ---
msg "Configurando zona horaria a Perú..."
timedatectl set-timezone America/Lima
timedatectl set-local-rtc 1

if timedatectl | grep -q "America/Lima"; then
    msg "Zona horaria configurada: $(timedatectl | grep 'Time zone' | cut -d: -f2)"
else
    warning_msg "Verificar configuración de zona horaria"
fi

# --- 12. Configurar PHP.ini optimizado ---
msg "Optimizando configuración PHP..."
PHP_INI="/etc/php/8.1/apache2/php.ini"
cp "$PHP_INI" "$PHP_INI.backup"

# Configuraciones recomendadas para FiberOps
sed -i 's/max_execution_time = 30/max_execution_time = 300/' "$PHP_INI"
sed -i 's/memory_limit = 128M/memory_limit = 512M/' "$PHP_INI"
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' "$PHP_INI"
sed -i 's/post_max_size = 8M/post_max_size = 100M/' "$PHP_INI"
sed -i 's/;date.timezone =/date.timezone = America\/Lima/' "$PHP_INI"

systemctl restart apache2

# --- 13. Verificación final del sistema ---
msg "Realizando verificación final del sistema..."

echo "=== ESTADO DE SERVICIOS ==="
systemctl status apache2 --no-pager -l
echo ""
systemctl status postgresql --no-pager -l

echo -e "\n=== VERSIONES INSTALADAS ==="
echo "PHP: $(php -v | head -n1)"
echo "Composer: $(composer --version)"
echo "Apache: $(apache2 -v | head -n1)"
echo "PostgreSQL: $(su - postgres -c "psql -c 'SELECT version();'" | head -n3 | tail -n1)"

echo -e "\n=== EXTENSIONES PHP CRÍTICAS ==="
php -m | grep -E "(ssh2|snmp|pgsql|gd|mbstring|curl|xml|intl)" | sort

echo -e "\n=== PERMISOS DEL DIRECTORIO ==="
ls -la /var/www/html/ | head -n10

# --- Fin ---
msg "✅ INSTALACIÓN COMPLETADA CON ÉXITO

📂 Sistema FiberOps 2025 preparado en: /var/www/html/
🌐 Acceso web: http://tu-servidor-ip/
🔧 PHP 8.1 con todas las extensiones necesarias
🗄️ PostgreSQL configurado y ejecutándose
📦 Composer actualizado instalado

🚀 PRÓXIMOS PASOS:
1. Subir código de FiberOps a /var/www/html/
2. Configurar base de datos PostgreSQL
3. Configurar archivos de configuración (.env, config.php)
4. Verificar permisos: chown -R www-data:www-data /var/www/html/

📧 Soporte: yeremitantaraico@gmail.com"

# --- Configurar permisos finales ---
msg "Configurando permisos finales del directorio..."
chmod -R 777 /var/www/html/
msg "Permisos 777 aplicados a /var/www/html/"

exit 0