#!/usr/bin/python3 -I
# Deja una herramienta de compatibilidad como predeterminada de Steam ("Steam
# Play para todos los demás títulos"), igual que en Configuración > Compatibilidad:
# CompatToolMapping > "0" en config/config.vdf. Steam reescribe ese archivo al
# cerrar, así que solo se debe llamar con Steam cerrado.
# Uso: krarupos-proton-default.py <config.vdf> <nombre interno de la herramienta>
import os, sys


def tokens(texto):
    i, n = 0, len(texto)
    while i < n:
        c = texto[i]
        if c.isspace():
            i += 1
        elif texto.startswith("//", i):
            i = texto.find("\n", i)
            i = n if i < 0 else i
        elif c in "{}":
            yield c
            i += 1
        elif c == '"':
            j, partes = i + 1, []
            while texto[j] != '"':
                if texto[j] == "\\":
                    partes.append(texto[j:j + 2])
                    j += 2
                else:
                    partes.append(texto[j])
                    j += 1
            yield "".join(partes)
            i = j + 1
        else:
            raise ValueError(f"vdf inesperado en {i}")


def leer(it):
    # Lista de [clave, valor]; el valor es texto o otra lista (un bloque).
    nodo = []
    for t in it:
        if t == "}":
            return nodo
        v = next(it)
        nodo.append([t, leer(it) if v == "{" else v])
    return nodo


def escribir(nodo, nivel=0):
    tab, salida = "\t" * nivel, []
    for k, v in nodo:
        if isinstance(v, list):
            salida.append(f'{tab}"{k}"\n{tab}{{\n{escribir(v, nivel + 1)}{tab}}}\n')
        else:
            salida.append(f'{tab}"{k}"\t\t"{v}"\n')
    return "".join(salida)


def bloque(nodo, clave):
    for par in nodo:
        if par[0].lower() == clave.lower() and isinstance(par[1], list):
            return par[1]
    nuevo = []
    nodo.append([clave, nuevo])
    return nuevo


ruta, herramienta = sys.argv[1], sys.argv[2]
with open(ruta, encoding="utf-8") as f:
    raiz = leer(iter(tokens(f.read())))

steam = raiz
for clave in ("InstallConfigStore", "Software", "Valve", "Steam", "CompatToolMapping"):
    steam = bloque(steam, clave)
steam[:] = [par for par in steam if par[0] != "0"]
steam.insert(0, ["0", [["name", herramienta], ["config", ""], ["priority", "75"]]])

with open(ruta + ".krarupos", "w", encoding="utf-8") as f:
    f.write(escribir(raiz))
os.replace(ruta + ".krarupos", ruta)
