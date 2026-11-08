# Nombre con zz-: corre después de user-motd.sh, así primero sale la bienvenida.
# fastfetch una vez por sesión: en la primera terminal interactiva después de iniciar
# sesión. La marca va en XDG_RUNTIME_DIR, que se vacía al cerrar la sesión del usuario.
# Se apaga junto con la bienvenida: ujust toggle-user-motd.
if [ -n "${PS1:-}" ] && [ -n "${BASH_VERSION:-}" ] && [ -n "${XDG_RUNTIME_DIR:-}" ] &&
    [ -t 1 ] && [ ! -e "$HOME/.config/no-show-user-motd" ]; then
    # noclobber: si se abren varias terminales a la vez, solo una crea la marca.
    if (set -C; : >"$XDG_RUNTIME_DIR/krarupos-fastfetch-visto") 2>/dev/null; then
        /usr/bin/fastfetch --color "$(/usr/libexec/bazzite-bling-fastfetch)" \
            -c /usr/share/ublue-os/bazzite/fastfetch.jsonc
    fi
fi
