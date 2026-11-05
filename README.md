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
  Videos: `mediainfo`, `mkvtoolnix` y `yt-dlp`. Red: `iperf3`, `wol` (Wake-on-LAN) y `nethogs`.
  Además `ncdu` (espacio por carpeta) y `exiftool` (datos de fotos).
- **Máquinas virtuales**: virt-manager con KVM/QEMU y libvirt (red NAT lista, TPM para Windows 11); los administradores lo usan sin contraseña.
- **Tema**: estilo Darkly, colores Breeze oscuro (bordes sin contraste), pantalla de inicio Vapor con el logo de krarupOS, letra 15, íconos Tela-circle-dracula-dark, cursor Bibata-Modern-Ice
  y el wallpaper Vía Láctea de KDE con el logo de krarupOS en la esquina (CC-BY-SA-4.0, ruvkr). Aparece como el aspecto global "krarupOS".
- **Panel**: a la izquierda, centrado, flotante y transparente (Panel Colorizer), con el ícono de Arch en el menú y
  un punto bajo las apps abiertas (azul la activa, gris las demás, naranja si piden atención) en vez de cuadros.
- **Logo krarupOS** (letra MuseoModerno, la del logo de Bazzite) en la pantalla de arranque y en la de inicio de KDE.
- **Sunshine** con los permisos de teclado, mouse y controles virtuales ya puestos (sin `additional-install.sh`), y preautorizado en el portal de KDE: captura la pantalla sin diálogo de permiso, así no queda bloqueado al entrar a distancia (una vez por usuario; si se quita, no vuelve).
- **Steam con el tema Dracula** (AdwSteamGtk): se pone solo y vuelve si una actualización de Steam lo borra; si se desinstala desde AdwSteamGtk, no vuelve.
- **YouTube en Steam**: VacuumTube se agrega solo a la biblioteca de Steam como "YouTube" (una vez por usuario; si se borra, no vuelve).
- **Proton-CachyOS** se instala solo con ProtonPlus ("Latest", así ProtonPlus lo actualiza), en versión x86-64-v3 (CPUs desde ~2015), y queda como Proton predeterminado de Steam (una vez; se puede cambiar).
- **Claude Code** se instala solo en cada usuario al primer inicio de sesión (instalador oficial, queda en `~/.local/bin/claude` y se actualiza solo); si se desinstala, no vuelve.
- **Decky Loader** se instala solo una vez (con el instalador oficial, como `ujust setup-decky`) cuando Steam ya abrió, con los plugins CSS Loader, TabMaster, Animation Changer y SteamGridDB; si se desinstala, no vuelve.
- **Deck sin cambiarse a Bazzite**: Steam ya no puede mover el sistema a la imagen oficial de Bazzite al elegir canal de actualizaciones.
- **Deck parte en escritorio**: el primer arranque entra a KDE (sin pantalla negra mientras Steam se actualiza); "Gaming Mode" queda en los favoritos del menú (no en el escritorio).
- **SSH** activo desde el primer arranque, solo con llave (la de mi PC va en cada usuario nuevo).
- **Wake-on-LAN** activo en el cable de red (paquete mágico), para prender el PC desde otro equipo. En la BIOS también tiene que estar permitido (en MSI: "Resume By PCI-E Device").
- **Perfil de energía en performance** desde el primer arranque (en PCs sin batería; portátiles y Deck se quedan en balanced). Solo una vez: si se cambia en KDE, se respeta.
- **Watts de la CPU** visibles en MangoHud y el overlay de Steam (lectura de RAPL sin root).
- **Caché de shaders de 10 GB** (Fedora usa 1 GB), para que los juegos grandes no vuelvan a compilar shaders.
- **liquidctl** para refrigeración líquida y fuentes Corsair/NZXT/etc., sin `sudo`.
- **Curva de ventiladores del H150i Platinum** automática solo si está ese cooler (y la RM850i si está): se aplica al arrancar y al despertar, y termina. Apagar: `sudo systemctl mask krarupos-corsair`.
- **Sin TDP Control** en la bandeja de KDE (es para handhelds).
- **Letra grande en las TTY** (Terminus 16x32, como en CachyOS); la de Fedora queda diminuta en 4K.
- **Consola clásica en las TTY** en vez de kmscon (el valor por defecto de Fedora 45), para que mpv muestre video.
- **TTY hasta Ctrl+Alt+F12** (por defecto solo hasta F6).
- **Mouse en las TTY** (gpm): seleccionar con el botón izquierdo y pegar con el del medio.
- **Perilla de volumen en las TTY**: cambia el volumen del sistema (tope de 100 %), sin mpv ni otro programa abierto. En Plasma sigue mandando el escritorio.
- **btop con la temperatura de la CPU** junto al promedio (sensor Tctl en Ryzen).
- **Bienvenida de la terminal** con "Welcome to krarupOS" y la imagen de krarupOS.
- **Konsole** sin barra de desplazamiento (el scroll sigue funcionando).
- **Prompt** con los colores de krarupOS (`seba@krarupOS:~$`).
- **fastfetch** con el logo de krarupOS y un color por línea, una vez por sesión, en la primera terminal.
- **Alias**: `krarup` muestra `fastfetch` con el logo de krarupOS; `ruedaON` y `ruedaOFF` cambian la rueda del G502 X a alta resolución o a normal (para todos los usuarios).
- **Rueda del G502 X en resolución normal** al conectar (el kernel pone alta resolución y hace scroll con solo rozarla); solo si está ese mouse.
- **Scroll natural en el G502 X** en KDE (solo ese mouse, también con input-remapper).
- **LACT listo sin configurar**: es la primera app que se instala y su servicio viene incluido; con la RX 9070 XT de Seba pone 250 W y Zero RPM apagado (una vez, como en CachyOS). OverDrive de amdgpu activado (`amdgpu.ppfeaturemask`), que LACT necesita para Zero RPM y overclock.
- **input-remapper** activado, con los presets de un Logitech G502 X LS.
- **Apps GTK** (como Transmission Remote) con el tema Breeze y los colores de KDE, también las Flatpak.
- **Konsole** con el perfil krarupOS (colores Vapor sin transparencia, Fira Code 16).
- **Dolphin** con íconos y vistas previas grandes, ruta completa y barra de herramientas propia.
- **Apps predeterminadas**: videos con mpv, Firefox como navegador y magnet links/torrents con Transmission Remote (sin que Firefox pregunte).
- **mpv con decodificación por GPU** (`hwdec=vaapi`): evita tirones en AV1 y videos a muchos fps.
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
con krarupOS instalan las apps nuevas en su siguiente actualización. Cada app se instala
una sola vez: si alguien la desinstala, no vuelve aunque cambie la lista. Quitar una app
de la lista no la desinstala de los computadores que ya la tienen.

Basado en [ublue-os/image-template](https://github.com/ublue-os/image-template).
