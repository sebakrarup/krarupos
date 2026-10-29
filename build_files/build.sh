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

### Programas del sistema

# rocm-smi: btop lo necesita para mostrar las GPUs AMD.
# liquidctl: refrigeración líquida y fuentes (H150i, RM850i); permisos sin root en
# usr/lib/udev/rules.d/71-liquidctl.rules (Fedora no trae las reglas).
dnf5 install -y nmap htop rocm-smi liquidctl

# amdgpu_top no está en los repos de Fedora: se instala el .rpm oficial
# de la última versión publicada por su autor.
amdgpu_top_rpm=$(curl -fsSL --retry 3 https://api.github.com/repos/Umio-Yasuno/amdgpu_top/releases/latest |
    grep -oE '"browser_download_url": *"[^"]*\.x86_64\.rpm"' | cut -d'"' -f4 | head -1)
dnf5 install -y "$amdgpu_top_rpm"

### Tema

# Íconos Tela-circle-dracula (claro, normal y oscuro), última versión.
tela_tag=$(curl -fsSL --retry 3 https://api.github.com/repos/vinceliuice/Tela-circle-icon-theme/tags |
    grep -oE '"name": *"[^"]*"' | head -1 | cut -d'"' -f4)
git clone --depth 1 --branch "$tela_tag" https://github.com/vinceliuice/Tela-circle-icon-theme.git /tmp/tela
(cd /tmp/tela && ./install.sh -d /usr/share/icons dracula)

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
    -e 's/^Image=Next$/Image=MilkyWay/' \
    -e 's/^cursorTheme=breeze_cursors$/cursorTheme=Bibata-Modern-Ice\ncursorSize=28/' \
    -e 's/^ColorScheme=BreezeDark$/ColorScheme=BreezeDarkSeba/' \
    -e '/^\[kdeglobals\]\[KDE\]/,/^\[/ s/^widgetStyle=Breeze$/widgetStyle=Darkly/' \
    "$lnf/contents/defaults"
grep -q '^Theme=Tela-circle-dracula-dark$' "$lnf/contents/defaults"
grep -q '^Image=MilkyWay$' "$lnf/contents/defaults"
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
kwriteconfig6 --file /etc/xdg/ksplashrc --group KSplash --key Theme com.krarupos.desktop
# Konsole: perfil krarupOS (colores Vapor sin transparencia, Fira Code 16).
kwriteconfig6 --file /etc/xdg/konsolerc --group "Desktop Entry" --key DefaultProfile krarupOS.profile
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

# Menú de inicio, en el orden del usuario.
# /etc/xdg manda sobre /usr/share/kde-settings, donde Bazzite pone los suyos.
favoritos=(
    preferred://browser io.github.kolunmi.Bazaar org.jellyfin.JellyfinDesktop org.telegram.desktop
    com.moonlight_stream.Moonlight steam net.lutris.Lutris systemsettings
    io.github.ublue_os.yafti_gtk org.kde.konsole org.kde.dolphin com.vysp3r.ProtonPlus
    io.missioncenter.MissionCenter com.dec05eba.gpu_screen_recorder tv.kodi.Kodi
    rocks.shy.VacuumTube dev.lizardbyte.app.Sunshine
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

# Panel: Configuración, navegador, Konsole, Dolphin y Mission Center.
for f in /usr/share/plasma/layout-templates/org.kde.plasma.desktop.defaultPanel/contents/layout.js \
    /usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/bazzite-pins.js; do
    [[ -f $f ]] || continue
    python3 - "$f" <<'EOF'
import re, sys
p = sys.argv[1]
s = open(p).read()
pins = [
    "applications:systemsettings.desktop",
    "preferred://browser",
    "applications:org.kde.konsole.desktop",
    "preferred://filemanager",
    "applications:io.missioncenter.MissionCenter.desktop",
]
lista = ",\n".join(f'{" " * 20}"{x}"' for x in pins)
s, n = re.subn(r'(writeConfig\("launchers", \[)\s*.*?(\s*\]\);)', lambda m: m[1] + "\n" + lista + m[2], s, flags=re.S)
assert n == 1, n
# Ícono del menú de inicio (el logo de Plasma) y panel de 54 px de alto.
if "layout-templates" in p:
    s, n = re.subn(r'^panel\.height = .*$', 'panel.height = 54', s, flags=re.M)
    assert n == 1, n
    viejo = 'panel.addWidget("org.kde.plasma.kickoff")\n'
    assert s.count(viejo) == 1
    s = s.replace(viejo, 'var kickoff = panel.addWidget("org.kde.plasma.kickoff")\n'
                         'kickoff.currentConfigGroup = ["General"]\n'
                         'kickoff.writeConfig("icon", "plasma-symbolic")\n')
open(p, "w").write(s)
EOF
done

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

# input-remapper: los presets del G502 X LS vienen en /etc/skel.
systemctl enable input-remapper.service
# Bazzite deck esconde la app y apaga la carga de presets al entrar a KDE.
sed -i '/^Hidden=true$/d' /etc/xdg/autostart/input-remapper-autoload.desktop
sed -i '/^NoDisplay=true$/d' /usr/share/applications/input-remapper-gtk.desktop
if grep -qx 'Hidden=true' /etc/xdg/autostart/input-remapper-autoload.desktop; then exit 1; fi
systemctl enable krarupos-flatpaks.service
# LACT sin la ventana de instalar su servicio; arranca cuando LACT ya está instalada.
systemctl enable lactd.service
# Decky Loader: se instala solo una vez, cuando Steam ya abrió (usr/libexec/krarupos-decky).
systemctl enable krarupos-decky.service
# Bazzite deck apaga las actualizaciones automáticas porque las hace Steam en
# modo juego; krarupOS deck parte en el escritorio, así que se dejan como en desktop.
systemctl enable uupd.timer
# SSH desde el primer arranque, solo con llave (etc/ssh/sshd_config.d/40-krarupos.conf).
# La llave de CachyOS va en /etc/skel/.ssh/authorized_keys para cada usuario nuevo.
systemctl enable sshd.service
# YouTube (VacuumTube) en Steam, para cada usuario.
systemctl --global enable krarupos-steam-youtube.service
# Proton-CachyOS "Latest" con ProtonPlus (v3 si la CPU lo soporta), para cada usuario.
systemctl --global enable krarupos-proton-cachyos.service
systemctl --global enable krarupos-proton-default.service

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
