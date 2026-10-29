#!/usr/bin/python3 -I
# Instala los plugins de Decky de la lista desde la tienda oficial, igual que
# Decky (backend/decky_loader/browser.py, _install): última versión, zip
# verificado con su sha256, extraído en ~/homebrew/plugins y con los mismos
# dueños. Los que ya estén no se tocan.
# Uso: krarupos-decky-plugins.py <carpeta de plugins> <usuario>
import hashlib, io, json, os, pwd, shutil, sys, urllib.request, zipfile

PLUGINS = ["CSS Loader", "TabMaster", "Animation Changer", "SteamGridDB"]
TIENDA = "https://plugins.deckbrew.xyz/plugins"
ZIPS = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/{}.zip"

carpeta, usuario = sys.argv[1], sys.argv[2]
uid, gid = pwd.getpwnam(usuario)[2:4]


def bajar(url):
    # La tienda responde 403 al User-Agent de urllib.
    pedido = urllib.request.Request(url, headers={"User-Agent": "krarupOS"})
    with urllib.request.urlopen(pedido, timeout=120) as r:
        return r.read()


def instalados():
    nombres = set()
    for d in os.listdir(carpeta):
        try:
            with open(os.path.join(carpeta, d, "plugin.json")) as f:
                nombres.add(json.load(f)["name"])
        except (OSError, ValueError, KeyError):
            pass
    return nombres


os.makedirs(carpeta, exist_ok=True)
tienda = {p["name"]: p for p in json.loads(bajar(TIENDA))}
ya = instalados()
for nombre in PLUGINS:
    if nombre in ya:
        continue
    version = tienda[nombre]["versions"][0]
    datos = bajar(version.get("artifact") or ZIPS.format(version["hash"]))
    if hashlib.sha256(datos).hexdigest() != version["hash"]:
        sys.exit(f"{nombre}: el zip no coincide con su sha256")
    with zipfile.ZipFile(io.BytesIO(datos)) as z:
        # Cada zip trae una sola carpeta con el plugin.
        raiz = {n.split("/")[0] for n in z.namelist()}
        if len(raiz) != 1:
            sys.exit(f"{nombre}: el zip no trae una sola carpeta")
        destino = os.path.join(carpeta, raiz.pop())
        shutil.rmtree(destino, ignore_errors=True)
        z.extractall(carpeta)

    # Como set_plugin_dir_permissions: el contenido es del usuario (o de root
    # si el plugin pide "root"), la carpeta y plugin.json de root, con 755.
    with open(os.path.join(destino, "plugin.json")) as f:
        de_root = "root" in json.load(f).get("flags", [])
    if not de_root:
        for base, dirs, archivos in os.walk(destino):
            for n in dirs + archivos:
                os.chown(os.path.join(base, n), uid, gid, follow_symlinks=False)
    for p in (destino, os.path.join(destino, "plugin.json")):
        os.chown(p, 0, 0)
        os.chmod(p, 0o755)
    print(f"Instalado {nombre} {version['name']}")
