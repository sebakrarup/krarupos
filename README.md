# krarupOS

Bazzite con KDE, mis apps y mi configuración, lista para usar.

Hay dos variantes, que se construyen todos los días sobre la última Bazzite:

| Imagen | Base | Para |
|---|---|---|
| `ghcr.io/sebakrarup/krarupos` | `bazzite:stable` | Escritorio KDE |
| `ghcr.io/sebakrarup/krarupos-deck` | `bazzite-deck:stable` | KDE + modo juego de Steam |

## Qué trae

- **Apps** (Flatpak, se instalan solas en el primer arranque): ver
  [`flatpaks.txt`](system_files/usr/share/krarupos/flatpaks.txt).
- **Programas**: `nmap`, `htop`, `amdgpu_top` y `rocm-smi` (para que `btop` muestre GPUs AMD).
- **Tema**: Breeze oscuro, íconos Tela-circle-dracula-dark, cursor Bibata-Modern-Ice
  y el wallpaper Vía Láctea. Aparece como el aspecto global "krarupOS".
- **input-remapper** activado, con los presets de un Logitech G502 X LS.
- **Dolphin** con íconos y vistas previas grandes, ruta completa y barra de herramientas propia.
- **Apps predeterminadas**: videos con mpv y Firefox como navegador.
- **Favoritos** en el menú de inicio y Mission Center en el panel.

## Cambiarse a krarupOS desde Bazzite

```
rpm-ostree rebase ostree-unverified-registry:ghcr.io/sebakrarup/krarupos-deck:latest
```

Reiniciar, y después pasar a la versión con firma:

```
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/sebakrarup/krarupos-deck:latest
```

(Para la variante de escritorio, cambiar `krarupos-deck` por `krarupos`.)

## Agregar o quitar apps

Editar [`flatpaks.txt`](system_files/usr/share/krarupos/flatpaks.txt). Los computadores
con krarupOS instalan las apps nuevas en su siguiente actualización.

Basado en [ublue-os/image-template](https://github.com/ublue-os/image-template).
