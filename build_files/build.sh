#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /
chmod +x /usr/libexec/krarupos-flatpaks

### Nombre

# Se muestra "krarupOS" (menú de arranque, Acerca de, fastfetch). El ID
# se deja igual porque lo usan ujust y las actualizaciones de Bazzite.
sed -i \
    -e 's/^NAME=.*/NAME="krarupOS"/' \
    -e '/^PRETTY_NAME=/s/Bazzite/krarupOS/' \
    /usr/lib/os-release
grep -q '^PRETTY_NAME=.*krarupOS' /usr/lib/os-release ||
    sed -i 's/^PRETTY_NAME=.*/PRETTY_NAME="krarupOS"/' /usr/lib/os-release
# Nombre del PC en la red (Moonlight, Samba, Avahi) cuando no se eligió otro al
# instalar; Bazzite trae "bazzite".
if grep -q '^DEFAULT_HOSTNAME=' /usr/lib/os-release; then
    sed -i 's/^DEFAULT_HOSTNAME=.*/DEFAULT_HOSTNAME="krarupOS"/' /usr/lib/os-release
else
    echo 'DEFAULT_HOSTNAME="krarupOS"' >>/usr/lib/os-release
fi
grep -qx 'DEFAULT_HOSTNAME="krarupOS"' /usr/lib/os-release
# Bienvenida de la terminal: "Welcome to krarupOS" y la imagen de krarupOS en vez
# de la de Bazzite. image-info.json se deja igual porque lo leen muchos scripts
# de Bazzite (rollback, modo juego, ujust).
case $(jq -r '."image-name"' /usr/share/ublue-os/image-info.json) in
    *deck*) imagen=krarupos-deck ;;
    *) imagen=krarupos ;;
esac
# Variantes NVIDIA: la base trae el módulo del driver (bazzite-nvidia-open,
# bazzite-deck-nvidia) → krarupos-nvidia o krarupos-deck-nvidia.
nvidia=0
if [[ -n $(find /usr/lib/modules -name 'nvidia.ko*' -print -quit) ]]; then
    nvidia=1
    imagen=$imagen-nvidia
fi
# Containerfile pasa la base: si es NVIDIA y no se encontró el driver, mejor fallar.
if [[ ${BASE_IMAGE:-} == *nvidia* && $nvidia != 1 ]]; then
    echo "base $BASE_IMAGE sin el módulo nvidia" >&2
    exit 1
fi
# NVIDIA: mpv decodifica con NVDEC (CUDA) en vez de VAAPI, que en NVIDIA pasa por
# un traductor (nvidia-vaapi-driver) con menos formatos.
if [[ $nvidia == 1 ]]; then
    mpvconf=/etc/skel/.var/app/io.mpv.Mpv/config/mpv/mpv.conf
    sed -i -e 's/^# GPU decoding: .*/# GPU decoding (NVIDIA): NVDEC/' -e 's/^hwdec=vaapi$/hwdec=nvdec/' "$mpvconf"
    grep -qx 'hwdec=nvdec' "$mpvconf"

    # Sin lo que es solo para GPUs AMD: OverDrive de amdgpu (kargs) y
    # rip-1080p/rip-4k (codifican por VAAPI de AMD). amdgpu_top y rocm-smi no se
    # instalan (más abajo). LACT sí queda: también maneja GPUs NVIDIA
    # (ventiladores, potencia, overclock); krarupos-lact no hace nada sin la RX 9070 XT.
    rm /usr/lib/bootc/kargs.d/10-krarupos-amdgpu.toml /usr/bin/rip-1080p /usr/bin/rip-4k
    # Caché de shaders: la de NVIDIA (no Mesa), también de 10 GB.
    rm /usr/lib/environment.d/60-krarupos-mesa.conf
    cat >/usr/lib/environment.d/60-krarupos-nvidia.conf <<'EOF'
# Caché de shaders de NVIDIA: 10 GB (por defecto 1 GB) para que los juegos
# grandes no vuelvan a compilar shaders.
__GL_SHADER_DISK_CACHE_SIZE=10737418240
__GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
EOF
fi
motd=/usr/share/ublue-os/motd/template.md
sed -i \
    -e 's/^# Welcome to Bazzite/# Welcome to krarupOS/' \
    -e "s|\`\${MOTD_IMAGE_NAME}:\${MOTD_IMAGE_BRANCH}\`|\`ghcr.io/sebakrarup/$imagen:latest\`|" \
    "$motd"
grep -q '^# Welcome to krarupOS' "$motd"
grep -q "ghcr.io/sebakrarup/$imagen:latest" "$motd"
# Sin los links de Bazzite (Report an issue, Documentation, Discord, Bluesky) ni la
# tabla de comandos. Queda el título, la imagen, el estado y el consejo del día.
sed -i -e '/\.bazzite\.gg\//d' -e '/^|/d' "$motd"
cat -s "$motd" >"$motd.nuevo"
mv "$motd.nuevo" "$motd"
if grep -q -e 'bazzite\.gg/' -e '^|' "$motd"; then
    echo "quedaron links o comandos en la bienvenida" >&2
    exit 1
fi

# fastfetch: mostrar la imagen real. No sale de image-info.json (ver arriba), que
# se queda con el nombre de Bazzite.
fastfetch=/usr/share/ublue-os/bazzite/fastfetch.jsonc
sed -i "s|\"text\": \"/usr/libexec/bazzite-fetch-image\"|\"text\": \"echo $imagen:latest\"|" "$fastfetch"
grep -q "echo $imagen:latest" "$fastfetch"
# Logo de krarupOS (krarup azul, OS rosado, arriba de los datos porque es ancho). Colores
# básicos con negrita para que también se distingan en las TTY (16 colores).
sed -i \
    -e '/"logo"/,/}/{' \
    -e 's|"source": ".*"|"source": "/usr/share/krarupos/fastfetch-logo.txt"|' \
    -e 's|"type": "file",|&\n        "position": "top",|' \
    -e 's|"1": "94"|"1": "1;34"|' \
    -e 's|"2": "47"|"2": "1;35"|' \
    -e '}' "$fastfetch"
grep -q '"source": "/usr/share/krarupos/fastfetch-logo.txt"' "$fastfetch"
grep -q '"position": "top"' "$fastfetch"
# Un color por línea, de los del prompt, sin negrita (9x y 38;5;n no dependen de la negrita;
# el "verde" y el "cian" del tema de Konsole son otros colores, por eso van fijos). La
# configuración es JSONC con comas finales: se quitan para leerla.
python3 - "$fastfetch" <<'PYEOF'
import json, re, sys
ruta = sys.argv[1]
d = json.loads(re.sub(r",(\s*[}\]])", r"\1", open(ruta).read()))
VERDE, NARANJA, AZUL, MORADO, AMARILLO, CIAN = "38;5;40", "38;5;3", "94", "95", "93", "38;5;51"
ROJO, BLANCO = "38;5;196", "38;5;231"
COLORES = {
    "command": VERDE, "os": AZUL, "kernel": NARANJA, "uptime": MORADO,
    "host": AMARILLO, "cpu": VERDE, "gpu": ROJO, "memory": AMARILLO, "disk": BLANCO,
    "display": AZUL, "battery": AMARILLO, "gamepad": CIAN,
    "de": VERDE, "wm": NARANJA, "shell": VERDE, "terminal": MORADO, "packages": AMARILLO,
}
hechos = 0
for m in d["modules"]:
    if isinstance(m, dict) and m["type"] in COLORES:
        m["keyColor"] = m["outputColor"] = COLORES[m["type"]]
        hechos += 1
assert hechos >= 10, "fastfetch: la configuración de Bazzite cambió"
d["display"]["brightColor"] = False
json.dump(d, open(ruta, "w"), ensure_ascii=False, indent=4)
PYEOF

# La ISO: bootc-image-builder (anaconda-iso) solo lee los repos de /etc/yum.repos.d, y
# Fedora 45 movió los suyos a /usr/share/dnf5/repos.d: sin esto no encuentra ningún paquete
# ("No match for argument") y falla (osbuild/image-builder#2704). Quitar cuando se arregle.
cp /usr/share/dnf5/repos.d/fedora.repo /usr/share/dnf5/repos.d/fedora-updates.repo /etc/yum.repos.d/

### Programas del sistema

# rocm-smi: btop lo necesita para mostrar las GPUs AMD (no en la variante NVIDIA).
# liquidctl: refrigeración líquida y fuentes (H150i, RM850i); permisos sin root en
# usr/lib/udev/rules.d/71-liquidctl.rules (Fedora no trae las reglas).
# terminus-fonts-console: letra grande en las TTY (ter-v32b, kargs.d/10-krarupos-consola.toml).
# gpm: mouse en las TTY (seleccionar y pegar).
# Videos (Jellyfin): mediainfo, mkvtoolnix (pistas de MKV sin recodificar), yt-dlp.
# Red: iperf3 (velocidad entre equipos), wol (Wake-on-LAN), nethogs (red por programa).
# headsetcontrol: luces/batería/sidetone del G733 (trae regla udev uaccess, sin sudo).
# ncdu: espacio por carpeta. perl-Image-ExifTool: exiftool para datos de fotos.
amd=(rocm-smi)
[[ $nvidia == 1 ]] && amd=()
dnf5 install -y nmap htop "${amd[@]}" liquidctl terminus-fonts-console gpm \
    mediainfo mkvtoolnix yt-dlp iperf3 wol nethogs ncdu perl-Image-ExifTool headsetcontrol
# Mission Center: red por programa con nethogs sin pedir contraseña. Son los
# permisos que pone su "preparación" (pkexec), que en krarupOS falla porque /usr
# es de solo lectura.
setcap "cap_net_admin,cap_net_raw,cap_dac_read_search,cap_sys_ptrace+pe" /usr/bin/nethogs
getcap /usr/bin/nethogs | grep -q cap_sys_ptrace

# liquidctl muestra SyntaxWarning de docopt en cada uso: la imagen deja la fecha
# de los archivos en 0, el .pyc no coincide y Python recompila docopt (y liquidctl)
# cada vez, sin poder guardarlo en /usr. Con unchecked-hash el .pyc no depende de la fecha.
# "some attributes cannot be read from corsair-psu kernel driver" (RM850i) pasa a
# info (solo con --verbose): lo que falta son uptime y modos de ventilador/OCP.
# find_spec da la ruta sin importar liquidctl (al importarlo pide XDG_RUNTIME_DIR).
liquidctl_dir=$(python3 -c 'import importlib.util, os; print(os.path.dirname(importlib.util.find_spec("liquidctl").origin))')
sed -i "s/_LOGGER.warning('some attributes cannot be read from/_LOGGER.info('some attributes cannot be read from/" \
    "$liquidctl_dir/driver/corsair_hid_psu.py"
grep -q "_LOGGER.info('some attributes cannot be read from" "$liquidctl_dir/driver/corsair_hid_psu.py"
docopt_py=$(python3 -c 'import docopt; print(docopt.__file__)')
python3 -m compileall -q -f -o 0 -o 1 --invalidation-mode unchecked-hash "$docopt_py" "$liquidctl_dir"

# Máquinas virtuales con virt-manager (KVM/QEMU de verdad, no el Flatpak, que corre
# como usuario). libvirt usa los servicios por separado de Fedora (virtqemud,
# virtnetworkd...), que arrancan solos por socket. swtpm: TPM para Windows 11.
# Sin contraseña para los administradores: usr/share/polkit-1/rules.d/50-krarupos-libvirt.rules.
dnf5 install -y qemu-kvm libvirt-daemon-kvm libvirt-daemon-config-network \
    virt-manager virt-install swtpm-tools
for s in virtqemud virtnetworkd virtstoraged virtnodedevd virtsecretd virtnwfilterd virtinterfaced virtlogd virtlockd; do
    systemctl enable $s.socket
done
# Red "default" (NAT) encendida desde el inicio, como en CachyOS.
mkdir -p /etc/libvirt/qemu/networks/autostart
ln -sf ../default.xml /etc/libvirt/qemu/networks/autostart/default.xml
test -f /etc/libvirt/qemu/networks/default.xml

# TDP Control (bandeja de KDE): límite de TDP vía steamos-manager, pensado para
# handhelds; en un PC de escritorio no sirve. Nada depende de él.
dnf5 remove -y plasma-applet-tdp-control

# amdgpu_top no está en los repos de Fedora: se instala el .rpm oficial
# de la última versión publicada por su autor. Solo con GPUs AMD.
if [[ $nvidia != 1 ]]; then
    amdgpu_top_rpm=$(curl -fsSL --retry 3 https://api.github.com/repos/Umio-Yasuno/amdgpu_top/releases/latest |
        grep -oE '"browser_download_url": *"[^"]*\.x86_64\.rpm"' | cut -d'"' -f4 | head -1)
    dnf5 install -y "$amdgpu_top_rpm"
fi

### Modo juego

# Scroll natural (invertido) en gamescope, como en KDE con el G502: gamescope no
# aplica NaturalScroll. La librería se agrega como dependencia de /usr/bin/gamescope;
# patchelf reescribe el archivo y le borra cap_sys_nice, así que se le vuelve a poner.
if [[ -x /usr/bin/gamescope ]]; then
    # gcc ya viene en la imagen; patchelf solo hace falta aquí.
    dnf5 install -y patchelf
    gcc -O2 -shared -fPIC -Wall -Wl,--version-script=/ctx/gamescope-scroll-invertido.map \
        -o /usr/lib64/gamescope-scroll-invertido.so /ctx/gamescope-scroll-invertido.c
    caps=$(getcap /usr/bin/gamescope | awk '{print $2}')
    patchelf --add-needed /usr/lib64/gamescope-scroll-invertido.so /usr/bin/gamescope
    dnf5 remove -y patchelf
    # Que gamescope tome de verdad las funciones de la librería. Antes del setcap:
    # el contenedor del build no tiene cap_sys_nice y no dejaría ejecutarlo.
    test "$(LD_DEBUG=bindings /usr/bin/gamescope --help 2>&1 |
        grep -c 'gamescope-scroll-invertido.so \[0\]: normal symbol `libinput_event_pointer_get_scroll_value')" -ge 1
    [[ -n $caps ]] && setcap "$caps" /usr/bin/gamescope
    getcap /usr/bin/gamescope | grep -q cap_sys_nice
fi

### Carpetas de usuario

# Sin "Public" (compartir en red), "Templates" (plantillas de Crear nuevo) ni
# "Projects" (nueva en xdg-user-dirs 0.20): no se crean en los usuarios nuevos.
sed -i -e 's/^TEMPLATES=/#TEMPLATES=/' -e 's/^PUBLICSHARE=/#PUBLICSHARE=/' \
    -e 's/^PROJECTS=/#PROJECTS=/' /etc/xdg/user-dirs.defaults
if grep -qE '^(TEMPLATES|PUBLICSHARE|PROJECTS)=' /etc/xdg/user-dirs.defaults; then exit 1; fi

### Tema

# Íconos Tela-circle-dracula (claro, normal y oscuro), última versión.
tela_tag=$(curl -fsSL --retry 3 https://api.github.com/repos/vinceliuice/Tela-circle-icon-theme/tags |
    grep -oE '"name": *"[^"]*"' | head -1 | cut -d'"' -f4)
git clone --depth 1 --branch "$tela_tag" https://github.com/vinceliuice/Tela-circle-icon-theme.git /tmp/tela
(cd /tmp/tela && ./install.sh -d /usr/share/icons dracula)
# Carpetas de usuario con color (en Dolphin y su barra lateral, cualquier idioma):
# Home verde, Descargas roja, Música amarilla, Imágenes morada, Videos azul, Red
# (Network) naranja, Archivos recientes rojo y Ubicaciones recientes café.
# Se reemplazan los íconos por los de color que trae el mismo tema, en todos los
# tamaños (los chicos son los de la barra lateral).
color=/usr/share/icons/Tela-circle-dracula/scalable/places
declare -A carpeta_color=(
    [user-home]=green-user-home
    [folder-download]=folder_color_red_downloads [folder-downloads]=folder_color_red_downloads
    [folder-music]=folder_color_yellow_music
    [folder-pictures]=folder_color_purple_pictures
    [folder-video]=folder_color_blue_videos [folder-videos]=folder_color_blue_videos
    [folder-network]=orange-network
    [document-open-recent]=red-folder-recent
    [folder-open-recent]=brown-folder-recent
)
for nombre in "${!carpeta_color[@]}"; do
    destino=$color/${carpeta_color[$nombre]}.svg
    test -f "$destino"
    find /usr/share/icons/Tela-circle-dracula* -path '*/places/*' -name "$nombre.svg" \
        -exec ln -sfn "$destino" {} \;
done
# Los de "recientes" también están en apps/ (el de tamaño grande, el que usa la barra
# lateral, sale de ahí) y "Ubicaciones recientes" no tiene versión grande.
ln -sfn "$color/red-folder-recent.svg" /usr/share/icons/Tela-circle-dracula/scalable/apps/document-open-recent.svg
ln -sfn "$color/brown-folder-recent.svg" "$color/folder-open-recent.svg"
test "$(readlink -f "$color/folder-download.svg")" = "$(readlink -f "$color/folder_color_red_downloads.svg")"
test "$(readlink -f /usr/share/icons/Tela-circle-dracula-dark/16/places/folder-music.svg)" = "$(readlink -f "$color/folder_color_yellow_music.svg")"
# Ícono de Dolphin con el círculo morado de la carpeta Imágenes (#7e57c2) en vez
# del gris. Solo org.kde.dolphin: system-file-manager lo usan otras apps.
apps=/usr/share/icons/Tela-circle-dracula/scalable/apps
dolphin_svg=$(readlink -f "$apps/org.kde.dolphin.svg")
rm -f "$apps/org.kde.dolphin.svg"
sed 's/style="color:#44475a"/style="color:#7e57c2"/' "$dolphin_svg" >"$apps/org.kde.dolphin.svg"
grep -q 'color:#7e57c2' "$apps/org.kde.dolphin.svg"
# System Settings (preferences-system) con el azul de la carpeta Videos (#5677fc).
sed -i 's/style="color:#44475a"/style="color:#5677fc"/' "$apps/preferences-system.svg"
grep -q 'color:#5677fc' "$apps/preferences-system.svg"
for t in /usr/share/icons/Tela-circle-dracula*; do gtk-update-icon-cache -f -q "$t"; done

# Cursor Bibata-Modern-Ice, última versión.
bibata_url=$(curl -fsSL --retry 3 https://api.github.com/repos/ful1e5/Bibata_Cursor/releases/latest |
    grep -oE '"browser_download_url": *"[^"]*/Bibata-Modern-Ice\.tar\.xz"' | cut -d'"' -f4)
curl -fsSL --retry 3 "$bibata_url" | tar -xJ -C /usr/share/icons

# Cursor por defecto también fuera de KDE (gamescope, apps X11).
cat >/usr/share/icons/default/index.theme <<'EOF'
[Icon Theme]
Inherits=Bibata-Modern-Ice
EOF

# Estilo de aplicaciones Darkly, del COPR de su autor. El COPR se apaga
# después para que no quede activado en los equipos.
dnf5 -y copr enable deltacopy/darkly
dnf5 install -y darkly
dnf5 -y copr disable deltacopy/darkly
test -n "$(find /usr/lib64/qt6/plugins/styles -iname '*darkly*')"

# Wallpaper: la Vía Láctea de KDE con el logo de krarupOS abajo a la izquierda. Paquete aparte
# para no pisar el original; conserva autor y licencia (CC-BY-SA-4.0).
fondo=/usr/share/wallpapers/krarupOS
cp -a /usr/share/wallpapers/MilkyWay "$fondo"
mv /usr/share/krarupos/MilkyWay-krarupOS.png "$fondo/contents/images/5120x2880.png"
python3 - "$fondo/metadata.json" <<'EOF'
import json, sys
p = sys.argv[1]
d = json.load(open(p))
k = d["KPlugin"]
k["Id"] = "krarupOS"
k["Name"] = "krarupOS"
for key in [x for x in k if x.startswith("Name[")]:
    del k[key]
json.dump(d, open(p, "w"), ensure_ascii=False, indent=4)
EOF

# Aspecto global "krarupOS": Breeze oscuro con los íconos, el cursor y el
# wallpaper (Vía Láctea) de krarupOS. Los usuarios lo pueden cambiar.
lnf=/usr/share/plasma/look-and-feel/com.krarupos.desktop
cp -a /usr/share/plasma/look-and-feel/org.kde.breezedark.desktop "$lnf"
# Se quitan los nombres traducidos para que se vea "krarupOS" en todos los idiomas.
python3 - "$lnf/metadata.json" <<'EOF'
import json, sys
p = sys.argv[1]
d = json.load(open(p))
k = d["KPlugin"]
k["Id"] = "com.krarupos.desktop"
k["Name"] = "krarupOS"
k["Description"] = "Breeze oscuro con el estilo Darkly, los colores, los íconos, el cursor, la pantalla de inicio y el wallpaper de krarupOS"
for key in [x for x in k if x.startswith(("Name[", "Description["))]:
    del k[key]
json.dump(d, open(p, "w"), ensure_ascii=False, indent=4)
EOF
sed -i \
    -e 's/^Theme=breeze-dark$/Theme=Tela-circle-dracula-dark/' \
    -e 's/^Image=Next$/Image=krarupOS/' \
    -e 's/^cursorTheme=breeze_cursors$/cursorTheme=Bibata-Modern-Ice\ncursorSize=28/' \
    -e 's/^ColorScheme=BreezeDark$/ColorScheme=BreezeDarkSeba/' \
    -e '/^\[kdeglobals\]\[KDE\]/,/^\[/ s/^widgetStyle=Breeze$/widgetStyle=Darkly/' \
    "$lnf/contents/defaults"
grep -q '^Theme=Tela-circle-dracula-dark$' "$lnf/contents/defaults"
grep -q '^Image=krarupOS$' "$lnf/contents/defaults"
grep -q '^cursorTheme=Bibata-Modern-Ice$' "$lnf/contents/defaults"
grep -q '^ColorScheme=BreezeDarkSeba$' "$lnf/contents/defaults"
grep -q '^widgetStyle=Darkly$' "$lnf/contents/defaults"
# Pantalla de inicio: la Vapor de Bazzite con el logo de krarupOS en vez del
# de Bazzite. Va en el aspecto global porque Plasma copia sus valores a
# ~/.config/kdedefaults, que manda sobre /etc/xdg.
splash="$lnf/contents/splash"
cp -a /usr/share/plasma/look-and-feel/com.valve.vapor.desktop/contents/splash "$splash"
rm "$splash/images/bazzite_logo.svgz"
cp /usr/share/krarupos/krarupos-logo.svg "$splash/images/krarupos_logo.svg"
# El logo de Bazzite es cuadrado; el de krarupOS es ancho, así que solo se fija
# el ancho y Qt mantiene la proporción.
sed -i \
    -e 's|source: "images/bazzite_logo.svgz"|source: "images/krarupos_logo.svg"|' \
    -e 's|sourceSize.width: size$|sourceSize.width: size * 2.4|' \
    -e '/sourceSize.height: size$/d' \
    "$splash/Splash.qml"
grep -q 'source: "images/krarupos_logo.svg"' "$splash/Splash.qml"
grep -q 'sourceSize.width: size \* 2.4$' "$splash/Splash.qml"
if grep -q 'sourceSize.height: size$' "$splash/Splash.qml"; then exit 1; fi
cp /usr/share/krarupos/splash-preview.png "$lnf/contents/previews/splash.png"
sed -i '/^\[ksplashrc\]\[KSplash\]/,/^\[/ s/^Theme=.*/Theme=com.krarupos.desktop/' "$lnf/contents/defaults"
grep -A1 '^\[ksplashrc\]\[KSplash\]' "$lnf/contents/defaults" | grep -q '^Theme=com.krarupos.desktop$'

# Panel de krarupOS: abajo, centrado, flotante, ajustado al contenido, 56 px,
# ícono archlinux en el menú, sin paginador ni "mostrar escritorio", y
# transparente con Panel Colorizer (layout en /usr/share/krarupos/panel-layout.js).
cp /usr/share/krarupos/panel-layout.js "$lnf/contents/layouts/org.kde.plasma.desktop-layout.js"
colorizer_url=$(curl -fsSL --retry 3 https://api.github.com/repos/luisbocanegra/plasma-panel-colorizer/releases/latest |
    jq -r '.assets[] | select(.name | endswith(".plasmoid")) | .browser_download_url' | head -1)
curl -fsSL --retry 3 -o /tmp/panel-colorizer.plasmoid "$colorizer_url"
python3 - <<'EOF'
import json, zipfile
z = zipfile.ZipFile("/tmp/panel-colorizer.plasmoid")
plugin_id = json.loads(z.read("metadata.json"))["KPlugin"]["Id"]
assert plugin_id == "luisbocanegra.panel.colorizer", plugin_id
z.extractall("/usr/share/plasma/plasmoids/" + plugin_id)
EOF
test -f /usr/share/plasma/plasmoids/luisbocanegra.panel.colorizer/contents/ui/main.qml
# Unreal Tournament (99) y 2004: instaladores oficiales de OldUnreal (el juego no
# va en la imagen: cada uno acepta las condiciones de Epic y lo baja de archive.org).
# Los usan los accesos "Instalar Unreal Tournament" (/usr/bin/krarupos-instalar-ut).
mkdir -p /usr/share/krarupos/oldunreal
for s in install-ut99.sh install-ut2004.sh; do
    curl -fsSL --retry 3 -o "/usr/share/krarupos/oldunreal/$s" \
        "https://raw.githubusercontent.com/OldUnreal/FullGameInstallers/master/Linux/$s"
    bash -n "/usr/share/krarupos/oldunreal/$s"
    grep -q 'OldUnreal <https://oldunreal.com>' "/usr/share/krarupos/oldunreal/$s"
    chmod 755 "/usr/share/krarupos/oldunreal/$s"
done
command -v 7z kdialog >/dev/null
# Apps del panel: sin cuadros azules de fondo; la activa lleva un punto azul
# abajo, las abiertas uno gris (más tenue si están minimizadas) y las que piden
# atención uno naranja. Reemplaza el tasks.svgz de Breeze.
cp /usr/share/krarupos/tasks.svgz /usr/share/plasma/desktoptheme/default/widgets/tasks.svgz
# La línea de los íconos abiertos de la bandeja (volumen, bluetooth...) va pegada
# al borde de la pantalla, como los puntos, y no del lado de adentro.
cp /usr/share/krarupos/tabbar.svgz /usr/share/plasma/desktoptheme/default/widgets/tabbar.svgz

# Predeterminados del sistema (cuentan para cualquier usuario nuevo).
kwriteconfig6 --file /etc/xdg/kdeglobals --group KDE --key LookAndFeelPackage com.krarupos.desktop
# Breeze oscuro con los bordes sin contraste (BreezeDarkSeba.colors).
kwriteconfig6 --file /etc/xdg/kdeglobals --group General --key ColorScheme BreezeDarkSeba
kwriteconfig6 --file /etc/xdg/kdeglobals --group KDE --key contrast 4
kwriteconfig6 --file /etc/xdg/kdeglobals --group KDE --key frameContrast 0
kwriteconfig6 --file /etc/xdg/kdeglobals --group KDE --key widgetStyle Darkly
kwriteconfig6 --file /etc/xdg/kdeglobals --group Icons --key Theme Tela-circle-dracula-dark
kwriteconfig6 --file /etc/xdg/kcminputrc --group Mouse --key cursorTheme Bibata-Modern-Ice
kwriteconfig6 --file /etc/xdg/kcminputrc --group Mouse --key cursorSize 28
# Scroll natural solo en el G502 X de Seba (046d:409f = 1133:16543), igual que en
# CachyOS. KWin lo guarda por mouse, así que otros mouses quedan normales. Con
# input-remapper activo, KDE ve el mouse "forwarded", por eso van los dos.
for g502 in "Logitech G502 X LS" "input-remapper Logitech G502 X LS forwarded"; do
    kwriteconfig6 --file /etc/xdg/kcminputrc --group Libinput --group 1133 --group 16543 \
        --group "$g502" --key NaturalScroll --type bool true
done
kwriteconfig6 --file /etc/xdg/ksplashrc --group KSplash --key Theme com.krarupos.desktop
# Konsole: perfil krarupOS (colores Vapor sin transparencia, Fira Code 16).
kwriteconfig6 --file /etc/xdg/konsolerc --group "Desktop Entry" --key DefaultProfile krarupOS.profile
# Ícono de Konsole: utilities-x-terminal del tema Tela-circle (el que eligió el usuario).
sed -i 's/^Icon=utilities-terminal$/Icon=utilities-x-terminal/' /usr/share/applications/org.kde.konsole.desktop
grep -qx 'Icon=utilities-x-terminal' /usr/share/applications/org.kde.konsole.desktop
# Ventanas: el foco sigue al puntero del mouse.
kwriteconfig6 --file /etc/xdg/kwinrc --group Windows --key FocusPolicy FocusFollowsMouse
# Sin efecto de zoom (lupa): se activaba sin querer con Meta+rueda / Meta+=.
kwriteconfig6 --file /etc/xdg/kwinrc --group Plugins --key zoomEnabled false
# Sesión: al entrar, empezar vacía (sin reabrir las apps de la sesión anterior).
kwriteconfig6 --file /etc/xdg/ksmserverrc --group General --key loginMode emptySession
# Apps GTK con el tema Breeze (toma los colores de KDE) en vez de Vapor/Adwaita.
# settings.ini lo leen las apps del sistema; el gschema lo pasa el portal a
# las Flatpak, que además necesitan org.gtk.Gtk3theme.Breeze (flatpaks.txt).
for v in 3.0 4.0; do
    mkdir -p /etc/xdg/gtk-$v
    kwriteconfig6 --file /etc/xdg/gtk-$v/settings.ini --group Settings --key gtk-theme-name Breeze
done
cat >/usr/share/glib-2.0/schemas/zz9-krarupos.gschema.override <<'EOF2'
[org.gnome.desktop.interface]
gtk-theme='Breeze'
EOF2
glib-compile-schemas /usr/share/glib-2.0/schemas

# Letra más grande (15 en vez de 10) y suavizado sin subpíxeles.
for clave in font menuFont toolBarFont; do
    kwriteconfig6 --file /etc/xdg/kdeglobals --group General --key $clave "Noto Sans,15,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0"
done
kwriteconfig6 --file /etc/xdg/kdeglobals --group General --key fixed "Fira Code,15,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0"
kwriteconfig6 --file /etc/xdg/kdeglobals --group General --key smallestReadableFont "Noto Sans,13,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0"
kwriteconfig6 --file /etc/xdg/kdeglobals --group WM --key activeFont "Noto Sans,15,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0"
kwriteconfig6 --file /etc/xdg/kdeglobals --group General --key XftAntialias true
kwriteconfig6 --file /etc/xdg/kdeglobals --group General --key XftHintStyle hintslight
kwriteconfig6 --file /etc/xdg/kdeglobals --group General --key XftSubPixel none

# Vistas previas también en carpetas remotas (Samba, etc.), sin límite de tamaño.
kwriteconfig6 --file /etc/xdg/kdeglobals --group PreviewSettings --key EnableRemoteFolderThumbnail true
kwriteconfig6 --file /etc/xdg/kdeglobals --group PreviewSettings --key MaximumRemoteSize 10485758951424

### Apps predeterminadas

# Bazzite abre los videos con Haruna, que no viene instalado: en krarupOS
# se abren con mpv. /etc/xdg manda sobre /usr/share/applications.
{
    echo '[Default Applications]'
    grep -E '^video/[^=]+=org\.kde\.haruna\.desktop' /usr/share/applications/kde-mimeapps.list |
        sed 's/=org\.kde\.haruna\.desktop.*/=io.mpv.Mpv.desktop;/'
    # Bazzite pone Falkon, que tampoco viene instalado.
    for tipo in x-scheme-handler/http x-scheme-handler/https text/html application/xhtml+xml; do
        echo "$tipo=org.mozilla.firefox.desktop;"
    done
    # Torrents y magnet links con Transmission Remote (Firefox los manda acá
    # gracias a /usr/share/krarupos/firefox-policies.json).
    for tipo in x-scheme-handler/magnet application/x-bittorrent; do
        echo "$tipo=io.github.TransmissionRemoteGtk.desktop;"
    done
} >/etc/xdg/kde-mimeapps.list
grep -q '^video/mp4=io.mpv.Mpv.desktop;$' /etc/xdg/kde-mimeapps.list
kwriteconfig6 --file /etc/xdg/kdeglobals --group General --key BrowserApplication org.mozilla.firefox.desktop

### Favoritos

# Menú de inicio, en el orden del usuario. Sin lo que ya está en el panel
# (Firefox, Configuración, Konsole, Dolphin, Mission Center).
# /etc/xdg manda sobre /usr/share/kde-settings, donde Bazzite pone los suyos.
favoritos=(
    io.github.kolunmi.Bazaar org.jellyfin.JellyfinDesktop org.telegram.desktop
    com.moonlight_stream.Moonlight steam net.lutris.Lutris
    io.github.ublue_os.yafti_gtk com.vysp3r.ProtonPlus
    com.dec05eba.gpu_screen_recorder tv.kodi.Kodi
    rocks.shy.VacuumTube dev.lizardbyte.app.Sunshine com.google.Chrome
)
# Deck: "Gaming Mode" en el menú y en favoritos (después de Steam) en vez del
# "Return to Gaming Mode" que Bazzite deja en el escritorio de cada usuario nuevo.
if [[ -x /usr/bin/return-to-gamemode ]]; then
    cat >/usr/share/applications/krarupos-gaming-mode.desktop <<'EOF2'
[Desktop Entry]
Name=Gaming Mode
Comment=Volver al modo juego de Steam
Exec=/usr/bin/return-to-gamemode
Icon=steamdeck-gaming-return
Terminal=false
Type=Application
StartupNotify=false
Categories=Game;
EOF2
    for i in "${!favoritos[@]}"; do
        [[ ${favoritos[i]} == steam ]] && favoritos=("${favoritos[@]:0:i+1}" krarupos-gaming-mode "${favoritos[@]:i+1}") && break
    done
    printf '%s\n' "${favoritos[@]}" | grep -qx krarupos-gaming-mode
    rm -f /etc/skel/Desktop/Return.desktop
fi
prepend=""
for app in "${favoritos[@]}"; do
    [[ $app == preferred://* ]] && prepend+="$app;" || prepend+="$app.desktop;"
done
cat >/etc/xdg/kicker-extra-favoritesrc <<EOF
[General]
Prepend=$prepend
IgnoreDefaults=true
EOF

# Panel: navegador (Firefox), Configuración, Konsole, Dolphin y Mission Center (y Gaming Mode en deck).
for f in /usr/share/plasma/layout-templates/org.kde.plasma.desktop.defaultPanel/contents/layout.js \
    /usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/bazzite-pins.js; do
    [[ -f $f ]] || continue
    python3 - "$f" <<'EOF'
import re, sys
p = sys.argv[1]
s = open(p).read()
pins = [
    "preferred://browser",
    "applications:systemsettings.desktop",
    "applications:org.kde.konsole.desktop",
    "preferred://filemanager",
    "applications:io.missioncenter.MissionCenter.desktop",
]
lista = ",\n".join(f'{" " * 20}"{x}"' for x in pins)
s, n = re.subn(r'(writeConfig\("launchers", \[)\s*.*?(\s*\]\);)', lambda m: m[1] + "\n" + lista + m[2], s, flags=re.S)
assert n == 1, n
# Ícono del menú de inicio (org.alienarena.alienarena, del tema Tela-circle) y panel de 54 px de alto.
if "layout-templates" in p:
    s, n = re.subn(r'^panel\.height = .*$', 'panel.height = 54', s, flags=re.M)
    assert n == 1, n
    viejo = 'panel.addWidget("org.kde.plasma.kickoff")\n'
    assert s.count(viejo) == 1
    s = s.replace(viejo, 'var kickoff = panel.addWidget("org.kde.plasma.kickoff")\n'
                         'kickoff.currentConfigGroup = ["General"]\n'
                         'kickoff.writeConfig("icon", "org.alienarena.alienarena")\n')
open(p, "w").write(s)
EOF
done

# Deck: "Gaming Mode" también fijo en el panel, después de Mission Center.
if [[ -f /usr/share/applications/krarupos-gaming-mode.desktop ]]; then
    for f in /usr/share/plasma/layout-templates/org.kde.plasma.desktop.defaultPanel/contents/layout.js \
        /usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/bazzite-pins.js \
        "$lnf/contents/layouts/org.kde.plasma.desktop-layout.js"; do
        [[ -f $f ]] || continue
        python3 - "$f" <<'EOF'
import re, sys
p = sys.argv[1]
s = open(p).read()
s, n = re.subn(r'^(\s*)"applications:io\.missioncenter\.MissionCenter\.desktop"',
               lambda m: m[0] + ',\n' + m[1] + '"applications:krarupos-gaming-mode.desktop"', s, flags=re.M)
assert n == 1, (p, n)
open(p, "w").write(s)
EOF
    done
    grep -q 'krarupos-gaming-mode' "$lnf/contents/layouts/org.kde.plasma.desktop-layout.js"
fi

### Firma

# Para poder usar "ostree-image-signed": las imágenes de ghcr.io/sebakrarup
# se verifican con la llave pública de krarupOS (/etc/pki/containers/krarupos.pub).
python3 - <<'EOF'
import json
p = "/etc/containers/policy.json"
d = json.load(open(p))
d["transports"]["docker"]["ghcr.io/sebakrarup"] = [{
    "type": "sigstoreSigned",
    "keyPaths": ["/etc/pki/containers/krarupos.pub"],
    "signedIdentity": {"type": "matchRepository"},
}]
json.dump(d, open(p, "w"), indent=4)
EOF

### Servicios

# Que el Portal de Bazzite no se abra solo al entrar por primera vez.
# Sigue disponible en el menú.
rm -f /etc/skel/.config/autostart/bazzite-portal.desktop
# Ni los avisos de novedades de Bazzite al iniciar sesión.
rm -f /etc/xdg/autostart/bazzite-announcement.desktop
# Ni Steam en KDE: se abre a mano o entrando a Game Mode (ahí lo abre la sesión).
# Para que abra solo: Configuración del sistema > Inicio automático > Agregar > Steam.
# En los PCs ya instalados también se va (es igual al de Bazzite, /etc lo sigue).
rm -f /etc/xdg/autostart/steam.desktop
if [[ -e /etc/xdg/autostart/steam.desktop ]]; then exit 1; fi

# Spectacle: capturar una región con Ctrl+Shift+P (en vez de Meta+Shift+Print),
# como en el PC de Seba. Es el atajo por defecto, así que lo cambiado a mano se respeta.
sed -i '/^\[Desktop Action RectangularRegionScreenShot\]/,/^\[/ s/^X-KDE-Shortcuts=Meta+Shift+Print$/X-KDE-Shortcuts=Ctrl+Shift+P/' \
    /usr/share/applications/org.kde.spectacle.desktop
sed -n '/^\[Desktop Action RectangularRegionScreenShot\]/,/^\[Desktop Action WindowUnderCursor/p' \
    /usr/share/applications/org.kde.spectacle.desktop | grep -qx 'X-KDE-Shortcuts=Ctrl+Shift+P'

# input-remapper: los presets del G502 X LS vienen en /etc/skel.
systemctl enable input-remapper.service
# Bazzite deck esconde la app y apaga la carga de presets al entrar a KDE.
sed -i '/^Hidden=true$/d' /etc/xdg/autostart/input-remapper-autoload.desktop
sed -i '/^NoDisplay=true$/d' /usr/share/applications/input-remapper-gtk.desktop
if grep -qx 'Hidden=true' /etc/xdg/autostart/input-remapper-autoload.desktop; then exit 1; fi
systemctl enable krarupos-flatpaks.service
# Dolphin sin la raíz del sistema ni /boot en Dispositivos (usr/libexec/krarupos-ocultar-sistema).
systemctl enable krarupos-ocultar-sistema.service
# Letras de KDE y tamaños de Dolphin según la resolución de la pantalla principal
# (usr/libexec/krarupos-letras); no toca lo que alguien cambie a mano.
systemctl --global enable krarupos-letras.service krarupos-letras.path
# Sensores (RAM, placa) detectados solos en el primer arranque (usr/libexec/krarupos-sensores).
systemctl enable krarupos-sensores.service
# WiFi Broadcom que solo anda con wl (BCM4360 de Mac, etc.): wl activado solo en esos PCs (usr/libexec/krarupos-broadcom-wl).
systemctl enable krarupos-broadcom-wl.service
# LACT sin la ventana de instalar su servicio; arranca cuando LACT ya está instalada.
systemctl enable lactd.service
# Decky Loader: se instala solo una vez, cuando Steam ya abrió (usr/libexec/krarupos-decky).
systemctl enable krarupos-decky.service
# Perfil de energía en performance al primer arranque (no en equipos con batería).
systemctl enable krarupos-performance.service
# Bazzite deck apaga las actualizaciones automáticas porque las hace Steam en
# modo juego; krarupOS deck parte en el escritorio, así que se dejan como en desktop.
systemctl enable uupd.timer
# SSH desde el primer arranque, solo con llave (etc/ssh/sshd_config.d/40-krarupos.conf).
# La llave de CachyOS va en /etc/skel/.ssh/authorized_keys para cada usuario nuevo.
systemctl enable sshd.service
# Consola clásica en las TTY en vez de kmscon (el valor por defecto de Fedora 45):
# con kmscon mpv no muestra video, y no aplican la letra grande ni gpm.
systemctl disable kmsconvt@.service
systemctl enable getty@.service
[ "$(readlink /etc/systemd/system/autovt@.service)" = /usr/lib/systemd/system/getty@.service ]
# Mouse en las TTY.
systemctl enable gpm.service
# YouTube (VacuumTube) en Steam, para cada usuario.
systemctl --global enable krarupos-steam-youtube.service
# Tema Dracula para Steam con AdwSteamGtk, para cada usuario (y de nuevo si Steam
# lo borra al actualizarse).
systemctl --global enable krarupos-steam-tema.service
# Proton-CachyOS "Latest" (v3) con ProtonPlus, para cada usuario.
systemctl --global enable krarupos-proton-cachyos.service
systemctl --global enable krarupos-proton-default.service
# Claude Code (instalador oficial, en ~/.local/bin), para cada usuario.
systemctl --global enable krarupos-claude.service
# Sunshine preautorizado en el portal de KDE (sin diálogo de permiso), para cada usuario.
systemctl --global enable krarupos-sunshine-portal.service
# Descargas en Dolphin ordenada por fecha pero sin grupos ("Group By: None"), para cada usuario.
systemctl --global enable krarupos-dolphin-descargas.service
# Scroll invertido (como en Mac) en todos los mouse de KDE, también los que se conecten
# después; lo cambiado a mano se respeta (usr/libexec/krarupos-scroll-invertido).
systemctl --global enable krarupos-scroll-invertido.service
# Teclas de brillo del monitor con rampa suave por DDC/CI (powerdevil espera ~1 s
# y cambia de golpe); mantener la tecla sigue subiendo. Sin monitor DDC no hace nada.
systemctl --global enable krarupos-brillo-suave.service
# Perilla de volumen del teclado en las TTY: volumen del sistema con tope de 100 %.
# En Plasma no hace nada, porque ahí la maneja el escritorio.
systemctl --global enable krarupos-tty-volumen.service

### Pantalla de arranque

# Plymouth muestra system_files/usr/share/plymouth/themes/spinner/watermark.png
# (krarupOS en vez de bazzite). Vive dentro del initramfs, así que hay que
# rehacerlo igual que Bazzite (build_files/build-initramfs de ublue-os/bazzite).
kernels=(/usr/lib/modules/*)
test ${#kernels[@]} -eq 1
kver=$(basename "${kernels[0]}")
initramfs=/usr/lib/modules/$kver/initramfs.img
dracut --no-hostonly --kver "$kver" --reproducible --zstd -v --add ostree --add fido2 -f "$initramfs"
chmod 0600 "$initramfs"
lsinitrd "$initramfs" usr/share/plymouth/themes/spinner/watermark.png | cmp - /usr/share/plymouth/themes/spinner/watermark.png
