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

### Programas del sistema

# rocm-smi: btop lo necesita para mostrar las GPUs AMD.
dnf5 install -y nmap htop rocm-smi

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
# Pantalla de inicio Vapor (la de Steam Deck). Va en el aspecto global porque
# Plasma copia sus valores a ~/.config/kdedefaults, que manda sobre /etc/xdg.
sed -i '/^\[ksplashrc\]\[KSplash\]/,/^\[/ s/^Theme=.*/Theme=com.valve.vapor.desktop/' "$lnf/contents/defaults"
grep -A1 '^\[ksplashrc\]\[KSplash\]' "$lnf/contents/defaults" | grep -q '^Theme=com.valve.vapor.desktop$'
test -d /usr/share/plasma/look-and-feel/com.valve.vapor.desktop

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
kwriteconfig6 --file /etc/xdg/ksplashrc --group KSplash --key Theme com.valve.vapor.desktop

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
} >/etc/xdg/kde-mimeapps.list
grep -q '^video/mp4=io.mpv.Mpv.desktop;$' /etc/xdg/kde-mimeapps.list
kwriteconfig6 --file /etc/xdg/kdeglobals --group General --key BrowserApplication org.mozilla.firefox.desktop

### Favoritos

# Menú de inicio: los de Bazzite y después las apps de krarupOS.
# /etc/xdg manda sobre /usr/share/kde-settings, donde Bazzite pone los suyos.
favoritos=(
    preferred://browser steam net.lutris.Lutris systemsettings io.github.kolunmi.Bazaar
    io.github.ublue_os.yafti_gtk org.kde.konsole org.kde.dolphin org.telegram.desktop
    com.vysp3r.ProtonPlus io.missioncenter.MissionCenter com.dec05eba.gpu_screen_recorder
    org.jellyfin.JellyfinDesktop tv.kodi.Kodi com.moonlight_stream.Moonlight
    org.vinegarhq.Sober io.github.ryubing.Ryujinx rocks.shy.VacuumTube com.ktechpit.whatsie
    com.google.Chrome dev.lizardbyte.app.Sunshine
)
prepend=""
for app in "${favoritos[@]}"; do
    [[ $app == preferred://* ]] && prepend+="$app;" || prepend+="$app.desktop;"
done
cat >/etc/xdg/kicker-extra-favoritesrc <<EOF
[General]
Prepend=$prepend
IgnoreDefaults=true
EOF

# Panel: navegador, Konsole, Dolphin y Mission Center.
for f in /usr/share/plasma/layout-templates/org.kde.plasma.desktop.defaultPanel/contents/layout.js \
    /usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/bazzite-pins.js; do
    [[ -f $f ]] || continue
    python3 - "$f" <<'EOF'
import re, sys
p = sys.argv[1]
s = open(p).read()
pins = [
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

# input-remapper: los presets del G502 X LS vienen en /etc/skel.
systemctl enable input-remapper.service
systemctl enable krarupos-flatpaks.service
