#!/usr/bin/bash
# Cambia los logos de Fedora del instalador (Anaconda) por los de krarupOS.
# bootc-image-builder arma el instalador con los paquetes de Fedora
# (fedora-logos), así que se cambian después, dentro de la ISO ya armada.
# Uso (como root): marca-instalador.sh <carpeta con la ISO>
set -euo pipefail

aqui=$(dirname "$(readlink -f "$0")")
iso=$(find "$1" -name '*.iso' | head -1)
[[ -n $iso ]]
tmp=$(mktemp -d --tmpdir="$(dirname "$iso")")
trap 'rm -rf "$tmp"' EXIT

volid=$(xorriso -indev "$iso" -pvd_info 2>/dev/null | sed -n 's/^Volume Id *: //p')
[[ -n $volid ]]

xorriso -osirrox on -indev "$iso" -extract /images/install.img "$tmp/install.img"
# MARCA_PRUEBA=1: prueba local sin root (sin etiquetas SELinux).
unsquashfs -q ${MARCA_PRUEBA:+-no-xattrs} -d "$tmp/raiz" "$tmp/install.img"
rm "$tmp/install.img"

pix=$tmp/raiz/usr/share/anaconda/pixmaps
for f in sidebar-logo.png anaconda_header.png; do
    [[ -f $pix/$f ]]
    install -m 644 "$aqui/instalador/$f" "$pix/$f"
done

mksquashfs "$tmp/raiz" "$tmp/install.img" -comp zstd -b 131072 -noappend -quiet
rm -rf "$tmp/raiz"

# replay repite el arranque de la ISO original (BIOS, UEFI y la partición EFI).
xorriso -indev "$iso" -outdev "$tmp/nueva.iso" -volid "$volid" \
    -boot_image any replay \
    -update "$tmp/install.img" /images/install.img
# Suma para "Test this media" (rd.live.check).
implantisomd5 --force "$tmp/nueva.iso"
mv "$tmp/nueva.iso" "$iso"

test "$(xorriso -indev "$iso" -pvd_info 2>/dev/null | sed -n 's/^Volume Id *: //p')" = "$volid"
checkisomd5 "$iso"
echo "Instalador con logos de krarupOS: $iso"
