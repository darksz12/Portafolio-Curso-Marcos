1. Preparación del Sistema Antes de comenzar, actualizamos los repositorios e instalamos el demonio de Snap (`snapd`) si no viene preinstalado. ```bash sudo apt update && sudo apt -y upgrade sudo apt -y install snapd

2. Instalación de Wekan
Instalamos el paquete snap de Wekan.
sudo snap install wekan

3. Configuración del Entorno
Wekan necesita saber en qué puerto escuchar y cuál es su URL raíz para generar los enlaces correctamente.
1.	Averigua tu IP con hostname -I o ip a  : 10.0.2.15
2.	Sustituye <IP-del-servidor> en el siguiente comando por tu IP real.
Bash
# Fijar el puerto de escucha (ej. 3001)
sudo snap set wekan port='3001'

# Fijar la URL Raíz (Vital para callbacks y navegación)
sudo snap set wekan root_url="http://<10.0.2.15>:3001"

4. Reinicio de Servicios
Al cambiar la configuración de un snap, es necesario reiniciar sus servicios internos para aplicar los cambios.
Bash
sudo systemctl restart snap.wekan.mongodb
sudo systemctl restart snap.wekan.wekan

5. Configuración del Firewall (UFW)
Si tienes el firewall activado en Ubuntu, debes permitir el tráfico entrante al puerto elegido.
Bash
sudo ufw allow 3001/tcp
sudo ufw reload
