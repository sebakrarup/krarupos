#!/usr/bin/bash
# Arma un repositorio de Flatpak (ostree, modo archive) con las apps de la lista
# de krarupOS (system_files/usr/share/krarupos/flatpaks.txt) y todo lo que
# necesitan (runtimes, extensiones, idiomas),
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
done <"$aqui/../system_files/usr/share/krarupos/flatpaks.txt"

# Instalación temporal de usuario: flatpak resuelve las dependencias.
FLATPAK_USER_DIR=$(mktemp -d --tmpdir="$salida")
export FLATPAK_USER_DIR
trap 'rm -rf "$FLATPAK_USER_DIR"' EXIT
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
# Solo español e inglés en los paquetes .Locale (igual que el sistema instalado,
# ver usr/libexec/krarupos-flatpaks); con todos los idiomas pesan cientos de MB.
flatpak config --user --set languages "es;en"
for intento in 1 2 3; do
    flatpak install --user --noninteractive -y flathub "${apps[@]}" && break
    [[ $intento == 3 ]] && exit 1
    sleep 30
done

repo=$salida/repo
rm -rf "$repo"
ostree --repo="$repo" init --mode=archive
ostree --repo="$repo" remote add --no-gpg-verify local "file://$FLATPAK_USER_DIR/repo"
# "flatpak list" da la ref sin el tipo (app/ o runtime/), que el repo sí necesita.
# --all: sin eso esconde los paquetes .Locale (idiomas) y la ISO quedaba sin ellos.
{
    flatpak list --user --all --app --columns=ref | sed 's|^|app/|'
    flatpak list --user --all --runtime --columns=ref | sed 's|^|runtime/|'
} | while read -r ref; do
    commit=$(flatpak info --user --show-commit "$ref")
    if [[ $ref == */*.Locale/* ]]; then
        # Instalado a medias (solo es y en): pull-local exige el commit completo.
        ostree --repo="$repo" pull --subpath=/metadata --subpath=/files/es --subpath=/files/en local "$commit"
    else
        ostree --repo="$repo" pull-local "$FLATPAK_USER_DIR/repo" "$commit"
    fi
    ostree --repo="$repo" refs --create="$ref" "$commit"
    echo "$ref"
done
ostree --repo="$repo" remote delete local
flatpak build-update-repo "$repo"
printf '%s\n' "${apps[@]}" >"$salida/apps.txt"
du -sh "$repo"
