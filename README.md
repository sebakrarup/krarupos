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
- **Tema**: estilo Darkly, colores Breeze oscuro (bordes sin contraste), pantalla de inicio Vapor con el logo de krarupOS, letra 15, íconos Tela-circle-dracula-dark, cursor Bibata-Modern-Ice
  y el wallpaper Vía Láctea. Aparece como el aspecto global "krarupOS".
- **Logo krarupOS** (letra MuseoModerno, la del logo de Bazzite) en la pantalla de arranque y en la de inicio de KDE.
- **Sunshine** con los permisos de teclado, mouse y controles virtuales ya puestos (sin `additional-install.sh`).
- **YouTube en Steam**: VacuumTube se agrega solo a la biblioteca de Steam como "YouTube" (una vez por usuario; si se borra, no vuelve).
- **Proton-CachyOS** se instala solo con ProtonPlus ("Latest", así ProtonPlus lo actualiza), en versión x86-64-v3 si la CPU la soporta, y queda como Proton predeterminado de Steam (una vez; se puede cambiar).
- **Decky Loader** se instala solo una vez (con el instalador oficial, como `ujust setup-decky`) cuando Steam ya abrió, con los plugins CSS Loader, TabMaster, Animation Changer y SteamGridDB; si se desinstala, no vuelve.
- **Deck sin cambiarse a Bazzite**: Steam ya no puede mover el sistema a la imagen oficial de Bazzite al elegir canal de actualizaciones.
- **Deck parte en escritorio**: el primer arranque entra a KDE (sin pantalla negra mientras Steam se actualiza); "Gaming Mode" queda en los favoritos del menú (no en el escritorio).
- **SSH** activo desde el primer arranque, solo con llave (la de mi PC va en cada usuario nuevo).
- **Watts de la CPU** visibles en MangoHud y el overlay de Steam (lectura de RAPL sin root).
- **Caché de shaders de 10 GB** (Fedora usa 1 GB), para que los juegos grandes no vuelvan a compilar shaders.
- **liquidctl** para refrigeración líquida y fuentes Corsair/NZXT/etc., sin `sudo`.
- **Curva de ventiladores del H150i Platinum** automática solo si está ese cooler (y la RM850i si está): se aplica al arrancar y al despertar, y termina. Apagar: `sudo systemctl mask krarupos-corsair`.
- **Rueda del G502 X en resolución normal** al conectar (el kernel pone alta resolución y hace scroll con solo rozarla); solo si está ese mouse.
- **LACT listo sin configurar**: es la primera app que se instala y su servicio viene incluido; con la RX 9070 XT de Seba pone 250 W y Zero RPM apagado (una vez, como en CachyOS). OverDrive de amdgpu activado (`amdgpu.ppfeaturemask`), que LACT necesita para Zero RPM y overclock.
- **input-remapper** activado, con los presets de un Logitech G502 X LS.
- **Apps GTK** (como Transmission Remote) con el tema Breeze y los colores de KDE, también las Flatpak.
- **Konsole** con el perfil krarupOS (colores Vapor sin transparencia, Fira Code 16).
- **Dolphin** con íconos y vistas previas grandes, ruta completa y barra de herramientas propia.
- **Apps predeterminadas**: videos con mpv, Firefox como navegador y magnet links/torrents con Transmission Remote (sin que Firefox pregunte).
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
