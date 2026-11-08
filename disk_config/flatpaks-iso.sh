#!/usr/bin/bash
# Arma un repositorio de Flatpak (ostree, modo archive) con las apps de
# flatpaks-iso.txt y todo lo que necesitan (runtimes, extensiones, idiomas),
# para meterlo en la ISO. El sistema instalado lo usa en el primer arranque
# (usr/libexec/krarupos-flatpaks) y después actualiza desde Flathub.
# Uso: flatpaks-iso.sh <carpeta de salida>
set -euo pipefail

aqui=$(dirname "$(readlink -f "$0")")
salida=$1
mkdir -p "$salida"
apps=()
while read -r app; do
    app=${app%%#*}
    app=${app//[[:space:]]/}
    [[ -n $app ]] && apps+=("$app")
done <"$aqui/flatpaks-iso.txt"

# Instalación temporal de usuario: flatpak resuelve las dependencias.
FLATPAK_USER_DIR=$(mktemp -d --tmpdir="$salida")
export FLATPAK_USER_DIR
trap 'rm -rf "$FLATPAK_USER_DIR"' EXIT
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
for intento in 1 2 3; do
    flatpak install --user --noninteractive -y flathub "${apps[@]}" && break
    [[ $intento == 3 ]] && exit 1
    sleep 30
done

repo=$salida/repo
rm -rf "$repo"
ostree --repo="$repo" init --mode=archive
# "flatpak list" da la ref sin el tipo (app/ o runtime/), que el repo sí necesita.
{
    flatpak list --user --app --columns=ref | sed 's|^|app/|'
    flatpak list --user --runtime --columns=ref | sed 's|^|runtime/|'
} | while read -r ref; do
    commit=$(flatpak info --user --show-commit "$ref")
    ostree --repo="$repo" pull-local "$FLATPAK_USER_DIR/repo" "$commit"
    ostree --repo="$repo" refs --create="$ref" "$commit"
    echo "$ref"
done
flatpak build-update-repo "$repo"
printf '%s\n' "${apps[@]}" >"$salida/apps.txt"
du -sh "$repo"
