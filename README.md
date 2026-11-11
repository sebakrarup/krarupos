# krarupOS

Bazzite con KDE, mis apps y mi configuración, lista para usar.

Hay tres variantes, que se construyen todos los días sobre la última Bazzite:

| Imagen | Base | Para |
|---|---|---|
| `ghcr.io/sebakrarup/krarupos` | `bazzite:stable` | Escritorio KDE |
| `ghcr.io/sebakrarup/krarupos-deck` | `bazzite-deck:stable` | KDE + modo juego de Steam |
| `ghcr.io/sebakrarup/krarupos-nvidia` | `bazzite-nvidia-open:stable` | Escritorio KDE con NVIDIA (RTX 16xx en adelante), sin lo que es solo para AMD (OverDrive, `amdgpu_top`, `rocm-smi`, `rip-1080p`, `rip-4k`) |
| `ghcr.io/sebakrarup/krarupos-deck-nvidia` | `bazzite-deck-nvidia:stable` | KDE + modo juego de Steam con NVIDIA (RTX 16xx en adelante), sin lo que es solo para AMD |

## Qué trae

- **Apps** (Flatpak, se instalan solas en el primer arranque; todas vienen dentro de la ISO con sus idiomas, español e inglés, y se instalan sin internet, salvo Chrome y Spotify, que bajan su programa al instalarse; las apps Flatpak quedan con esos dos idiomas): ver
  [`flatpaks.txt`](system_files/usr/share/krarupos/flatpaks.txt).
- **Programas**: `nmap`, `htop`, `amdgpu_top` y `rocm-smi` (para que `btop` muestre GPUs AMD). Los dos últimos no van en la variante NVIDIA.
  Videos: `mediainfo`, `mkvtoolnix` y `yt-dlp`. Red: `iperf3`, `wol` (Wake-on-LAN) y `nethogs`.
  Además `ncdu` (espacio por carpeta) y `exiftool` (datos de fotos).
- **Máquinas virtuales**: virt-manager con KVM/QEMU y libvirt (red NAT lista, TPM para Windows 11); los administradores lo usan sin contraseña.
- **Tema**: estilo Darkly, colores Breeze oscuro (bordes sin contraste), pantalla de inicio Vapor con el logo de krarupOS, letra 15, íconos Tela-circle-dracula-dark, cursor Bibata-Modern-Ice
- **Carpetas de usuario con color** en Dolphin: Home verde, Descargas roja, Música amarilla, Imágenes morada, Videos azul, Red (Network) naranja, Archivos recientes rojo y Ubicaciones recientes café; `homebrew` (Decky) café. El ícono de Dolphin con el círculo morado de Imágenes y el de System Settings con el azul de Videos. Sin las carpetas `Public`, `Templates` ni `Projects`. Dolphin se abre la primera vez en 1403×1187 en pantallas 4K.
  y el wallpaper Vía Láctea de KDE con el logo de krarupOS abajo a la izquierda (CC-BY-SA-4.0, ruvkr). Aparece como el aspecto global "krarupOS".
- **Panel**: a la derecha, centrado, flotante y transparente (Panel Colorizer), el ícono `org.alienarena.alienarena` en el menú (se abre en 816 × 684 la primera vez) y
- **Reloj en el escritorio**, abajo a la izquierda junto al logo krarupOS del fondo (no en el panel), solo con la hora.
  un punto bajo las apps abiertas (azul la activa, gris las demás, naranja si piden atención) en vez de cuadros.
- **Logo krarupOS** (letra MuseoModerno, la del logo de Bazzite) en la pantalla de arranque, en la de inicio de KDE y en el instalador (la ISO).
- **Disco del sistema** con el nombre "krarupOS" (el instalador lo dejaba `krarupos_<nombre del PC>`). En los dispositivos de KDE, el disco del sistema y los SSD llevan su propio ícono en vez del de disco duro (se verá desde KDE Frameworks 6.32: la 6.31 tiene un error que lo ignora).
- **Sunshine** con los permisos de teclado, mouse y controles virtuales ya puestos (sin `additional-install.sh`), y preautorizado en el portal de KDE: captura la pantalla sin diálogo de permiso, así no queda bloqueado al entrar a distancia (una vez por usuario; si se quita, no vuelve). Si se cae (pasa a veces al desconectarse Moonlight), se reinicia solo a los 5 s.
- **Steam con el tema Dracula** (AdwSteamGtk): se pone solo y vuelve si una actualización de Steam lo borra; si se desinstala desde AdwSteamGtk, no vuelve.
- **YouTube en Steam**: VacuumTube se agrega solo a la biblioteca de Steam como "YouTube" (una vez por usuario; si se borra, no vuelve).
- **Proton-CachyOS** se instala solo con ProtonPlus ("Latest", así ProtonPlus lo actualiza), en versión x86-64-v3 (CPUs desde ~2015), y queda como Proton predeterminado de Steam y de Lutris (una vez; se puede cambiar).
- **Lutris** con los ajustes de Seba (una vez por usuario, sin pisar lo ya cambiado): Wine con Proton-CachyOS, sin DXVK-NVAPI, FSR, BattlEye ni Easy Anti-Cheat; sin GameMode ni MangoHud.
- **Unreal Tournament (99) y 2004**: accesos "Instalar Unreal Tournament" e "Instalar Unreal Tournament 2004" en el menú (Juegos). Usan el instalador oficial de OldUnreal (se baja al armar la imagen): muestra las condiciones de Epic, baja el juego de archive.org, le pone el parche para Linux y crea su acceso. El juego no va en la ISO (es de Epic y la ISO es pública).
- **Secret Maryo Chronicles**: acceso "Instalar Secret Maryo Chronicles" en el menú (Juegos). Lo instala con Lutris (juego libre, versión de Windows con Wine y la música en alta calidad) y le pone un pre-launch (`/usr/libexec/krarupos-smc-control`) que deja el control Xbox encendido y Start para el menú; si ya está instalado, solo le pone el pre-launch.
- **Claude Code** se instala solo en cada usuario al primer inicio de sesión (instalador oficial, queda en `~/.local/bin/claude` y se actualiza solo); si se desinstala, no vuelve.
- **Decky Loader** se instala solo una vez (con el instalador oficial, como `ujust setup-decky`) cuando Steam ya abrió, con los plugins CSS Loader, Animation Changer, SteamGridDB y Tabs krarupOS (pestañas de colecciones, propio; reemplaza a TabMaster; código en `decky/tabs-krarupos`), y los temas de CSS Loader Switch Like Home, Round y Clean Gameview activados con las opciones de Seba (bajados de la tienda de CSS Loader); si se desinstala, no vuelve.
- **Deck sin cambiarse a Bazzite**: Steam ya no puede mover el sistema a la imagen oficial de Bazzite al elegir canal de actualizaciones.
- **Deck parte en escritorio**: el primer arranque entra a KDE (sin pantalla negra mientras Steam se actualiza); "Gaming Mode" queda en los favoritos del menú (no en el escritorio). En Steam (Gaming Mode) la opción "Abrir escritorio por defecto" viene marcada, igual que el arranque; al desmarcarla, la PC arranca siempre en Gaming Mode (sin reiniciar entremedio). El ícono "Gaming Mode" entra solo por esa vez.
- **Scroll invertido** (como en Mac) en todos los mouse de KDE, también en los que se conecten después; si alguien lo deja normal en Configuración → Mouse, se respeta.
- **Captura de una región** con Spectacle: **Ctrl+Shift+P** (en vez de Meta+Shift+Print).
- **Game Mode en la resolución nativa** de cada monitor y su mayor frecuencia, sin "Ajustar la resolución automáticamente" (en un 4K de 27" Steam bajaba a la mitad); una vez por monitor, si se vuelve a activar se respeta.
- **Steam no se abre solo en KDE** (Bazzite lo abre en cada inicio de sesión): se abre a mano o entrando a Game Mode. Para que abra solo: Configuración del sistema → Inicio automático → Agregar → Steam.
- **SSH** activo desde el primer arranque, solo con llave (la de mi PC va en cada usuario nuevo).
- **Wake-on-LAN** activo en el cable de red (paquete mágico), para prender el PC desde otro equipo. En la BIOS también tiene que estar permitido (en MSI: "Resume By PCI-E Device").
- **Perfil de energía en performance** desde el primer arranque (en PCs sin batería; portátiles y Deck se quedan en balanced). Solo una vez: si se cambia en KDE, se respeta.
- **Watts de la CPU** visibles en MangoHud y el overlay de Steam (lectura de RAPL sin root).
- **Tamaños según la resolución** de la pantalla principal, que cambian solos al cambiar la resolución: letras 15 en 4K, 13 en 1440p y 12 en 1080p, también la de ancho fijo (la más pequeña legible, 2 menos; también en las vistas de Dolphin); en Dolphin, el panel lateral Huge en 4K y Large en menos, y el zoom 192 px en 4K, 160 en 1440p y 144 en 1080p (la ventana se abre en 1403 × 1187 en 4K y 1041 × 759 en 1080p); el panel de KDE con grosor 66, 60 y 54, y el menú de inicio en 816 × 684, 776 × 618 y 736 × 553; Konsole con letra 16, 14 y 13 (en 1080p se abre maximizado la primera vez); Mission Center en 1202 × 823, 1191 × 793 y 1180 × 763; Firefox con zoom por defecto 120 % en 4K y 100 % en menos (si está abierto, se cambia al cerrarlo); el puntero del mouse en 28, 24 y 20. Cada pantalla parte en escala 100 % la primera vez que aparece (KWin pone 170 % en un 4K de 27"); si se cambia, se respeta. Lo que alguien cambie a mano no se toca más.
- **Mission Center sin contraseña**: trae hecha su "preparación" (nethogs con permisos para la red por programa, RAPL legible y sensores detectados en el primer arranque) y no muestra la bienvenida que la pide; se abre en 1202 × 823 la primera vez.
- **Caché de shaders de 10 GB** (Fedora usa 1 GB), para que los juegos grandes no vuelvan a compilar shaders. En NVIDIA, la caché de NVIDIA (también 10 GB).
- **liquidctl** para refrigeración líquida y fuentes Corsair/NZXT/etc., sin `sudo`.
- **Curva de ventiladores del H150i Platinum** automática solo si está ese cooler (y la RM850i si está): se aplica al arrancar y al despertar, y termina. Apagar: `sudo systemctl mask krarupos-corsair`.
- **Sin TDP Control** en la bandeja de KDE (es para handhelds).
- **Letra grande en las TTY** (Terminus 16x32, como en CachyOS); la de Fedora queda diminuta en 4K.
- **Consola clásica en las TTY** en vez de kmscon (el valor por defecto de Fedora 45), para que mpv muestre video.
- **TTY hasta Ctrl+Alt+F12** (por defecto solo hasta F6).
- **Mouse en las TTY** (gpm): seleccionar con el botón izquierdo y pegar con el del medio.
- **Perilla de volumen en las TTY**: cambia el volumen del sistema (tope de 100 %), sin mpv ni otro programa abierto. En Plasma sigue mandando el escritorio.
- **btop con la temperatura de la CPU** junto al promedio (sensor Tctl en Ryzen) y **la GPU visible desde el inicio** (sin apretar 5), y la lista de procesos sin degradado de color.
- **Bienvenida de la terminal** con "Welcome to krarupOS" y la imagen de krarupOS.
- **Konsole** sin barra de desplazamiento (el scroll sigue funcionando).
- **Dolphin sin discos del sistema** en Dispositivos: ni la raíz (composefs, ~50 MB al 100 % en rojo) ni `/boot`.
- **Ventanas**: el foco sigue al puntero del mouse.
- **Sesión vacía** al entrar: no se vuelven a abrir las apps de la sesión anterior.
- **Prompt** con los colores de krarupOS (`seba@krarupOS:~$`).
- **fastfetch** con el logo de krarupOS y un color por línea, una vez por sesión, en la primera terminal.
- **Alias**: `krarup` muestra `fastfetch` con el logo de krarupOS; `mpv` abre el reproductor (Flatpak) desde la terminal o una TTY; `foto` muestra fotos en una TTY; `ruedaON` y `ruedaOFF` cambian la rueda del G502 X a alta resolución o a normal (para todos los usuarios).
- **Rueda del G502 X en resolución normal** al conectar (el kernel pone alta resolución y hace scroll con solo rozarla); solo si está ese mouse.
- **Scroll natural en el G502 X** en KDE (solo ese mouse, también con input-remapper).
- **LACT listo sin configurar** (también en las variantes NVIDIA): es la primera app que se instala y su servicio viene incluido; con la RX 9070 XT de Seba pone 250 W y Zero RPM apagado (como en CachyOS), y con la RTX 3080 Gigabyte de Erik su curva de ventiladores (40 % hasta 20 °C, 50 % a 50, 60 % a 60, 75 % a 70 y 100 % a 80 °C) y 300 W; una vez, lo que se cambie después en LACT se respeta. OverDrive de amdgpu activado (`amdgpu.ppfeaturemask`), que LACT necesita para Zero RPM y overclock.
- **WiFi Broadcom BCM4360, BCM4352 y BCM43142** (las de los Mac y las Fenvi): funcionan desde el primer inicio. Bazzite trae su driver `wl` bloqueado porque rompe otras tarjetas; krarupOS lo activa solo si el PC tiene una de estas.
- **input-remapper** activado, con los presets de un Logitech G502 X LS.
- **Apps GTK** (como Transmission Remote) con el tema Breeze y los colores de KDE, también las Flatpak.
- **Konsole** con el perfil krarupOS (colores Vapor sin transparencia, Fira Code 16); la primera ventana se abre de 124×42 para que quepan la bienvenida y fastfetch, en ese orden.
- **Dolphin** con íconos y vistas previas grandes, ruta completa y barra de herramientas propia. Descargas ordenada por fecha (la más nueva arriba) pero sin grupos (Group By: None; Dolphin la agrupa por fecha), una vez por usuario.
- **Apps predeterminadas**: videos con mpv, Firefox como navegador y magnet links/torrents con Transmission Remote (sin que Firefox pregunte).
- **mpv con decodificación por GPU** (`hwdec=vaapi`): evita tirones en AV1 y videos a muchos fps.
- **mpv se cierra al terminar el video**, como antes de la versión 0.42.
- **mpv sin pantalla negra al abrir en una TTY** (`target-colorspace-hint=no`): no le avisa SDR/HDR al monitor, que en monitores con HDR causaba unos segundos en negro. Los videos HDR se ven en SDR.
- **Panel fijado**: Firefox, Configuración, Konsole, Dolphin y Mission Center, en ese orden, y Gaming Mode al final en krarupos-deck. **Favoritos** del menú sin esas apps (ya están en el panel).

## Cambiarse a krarupOS desde Bazzite

```
rpm-ostree rebase ostree-unverified-registry:ghcr.io/sebakrarup/krarupos-deck:latest
```

Reiniciar, y después pasar a la versión con firma:

```
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/sebakrarup/krarupos-deck:latest
```

(Para escritorio, cambiar `krarupos-deck` por `krarupos`; con NVIDIA, por `krarupos-nvidia`.)

## Agregar o quitar apps

Editar [`flatpaks.txt`](system_files/usr/share/krarupos/flatpaks.txt). Los computadores
con krarupOS instalan las apps nuevas en su siguiente actualización. Cada app se instala
una sola vez: si alguien la desinstala, no vuelve aunque cambie la lista. Quitar una app
de la lista no la desinstala de los computadores que ya la tienen.

Basado en [ublue-os/image-template](https://github.com/ublue-os/image-template).
