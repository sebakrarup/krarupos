# Alias de krarupOS para todos los usuarios (bash).
alias krarup='fastfetch'
# Rueda del G502 X (solo con ese mouse): ruedaON = alta resolución (más sensible),
# ruedaOFF = resolución normal (la que se pone sola al conectarlo).
alias ruedaON='/usr/libexec/krarupos-g502-rueda on'
alias ruedaOFF='/usr/libexec/krarupos-g502-rueda off'
# Ver fotos en una TTY a resolución completa: foto ~/Pictures/*.jpg
# Teclas: > siguiente, < anterior, q salir.
alias foto='flatpak run io.mpv.Mpv --vo=drm --image-display-duration=inf'
# mpv es Flatpak (io.mpv.Mpv): sin esto "mpv video.mp4" no existe en la terminal ni en las TTY.
alias mpv='flatpak run io.mpv.Mpv'
# Moonlight es Flatpak: abrirlo desde la terminal o una TTY con "moonlight".
alias moonlight='flatpak run com.moonlight_stream.Moonlight'
# Control Bluetooth (Xbox u otro) despierta el PC desde suspensión: se activa a mano
# porque cualquier dispositivo Bluetooth enlazado también podría despertarlo. Pide sudo.
alias xboxcontrollerWake='/usr/libexec/krarupos-control-despertar on'
alias xboxcontrollerNoWake='/usr/libexec/krarupos-control-despertar off'
# fbi busca /dev/dri/card0, pero la tarjeta con pantalla puede ser card1: se le pasa
# la primera que tenga un monitor conectado. Teclas: espacio siguiente, RePág anterior, q salir.
fbi() {
    local s card=
    for s in /sys/class/drm/card*-*/status; do
        [ "$(cat "$s")" = connected ] && { card=${s#/sys/class/drm/}; card=${card%%-*}; break; }
    done
    command fbi ${card:+-d /dev/dri/$card} "$@"
}
