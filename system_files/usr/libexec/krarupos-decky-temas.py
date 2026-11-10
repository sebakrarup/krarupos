#!/usr/bin/python3 -I
# Temas de CSS Loader (Decky) de Seba, con las mismas opciones que tiene él:
# se bajan de la tienda de CSS Loader (deckthemes.com, la última versión, igual
# que al instalarlos desde el plugin), se extraen en ~/homebrew/themes y quedan
# activados con config_USER.json. Los que ya estén no se tocan.
# Uso: krarupos-decky-temas.py <carpeta de temas> <usuario>
import io, json, os, pwd, shutil, sys, urllib.request, zipfile

API = "https://api.deckthemes.com"
# id en la tienda: opciones (las de Seba, 2026-11-10).
TEMAS = {
    "9ac2bf60-66c5-4f50-aa6b-f897465ba328": {   # Switch Like Home
        "active": True, "No Friends": "No", "Lift Hero": "0"},
    "c6844008-a809-41f6-b140-7aa76f2a62ad": {   # Round
        "active": True, "Intensity": "10px", "Outlines": "Round"},
    "a9776f60-2724-4ff0-824b-e1f82a04688e": {   # Clean Gameview
        "active": True, "Play Bar Style": "Transparent", "Alignment": "Contain",
        "Show Steam Cloud": "Yes", "Ignore Footer": "No", "Lock Logo": "Yes"},
}

carpeta, usuario = sys.argv[1], sys.argv[2]
uid, gid = pwd.getpwnam(usuario)[2:4]


def bajar(url):
    pedido = urllib.request.Request(url, headers={"User-Agent": "krarupOS"})
    with urllib.request.urlopen(pedido, timeout=120) as r:
        return r.read()


def del_usuario(ruta):
    os.chown(ruta, uid, gid)
    for base, dirs, archivos in os.walk(ruta):
        for n in dirs + archivos:
            os.chown(os.path.join(base, n), uid, gid, follow_symlinks=False)


os.makedirs(carpeta, exist_ok=True)
if os.stat(carpeta).st_uid == 0:
    del_usuario(carpeta)
for id_tema, opciones in TEMAS.items():
    tema = json.loads(bajar(f"{API}/themes/{id_tema}"))
    nombre = tema["name"]
    destino = os.path.join(carpeta, nombre)
    if os.path.exists(destino):
        continue
    with zipfile.ZipFile(io.BytesIO(bajar(f"{API}/blobs/{tema['download']['id']}"))) as z:
        nombres = z.namelist()
        # Una sola carpeta con el nombre del tema y nada fuera de ella.
        if any(n.startswith("/") or ".." in n.split("/") or n.split("/")[0] != nombre for n in nombres):
            sys.exit(f"{nombre}: el zip no trae solo la carpeta del tema")
        z.extractall(carpeta)
    with open(os.path.join(destino, "config_USER.json"), "w") as f:
        json.dump(opciones, f)
    del_usuario(destino)
    print(f"Instalado tema {nombre} {tema['version']}")
