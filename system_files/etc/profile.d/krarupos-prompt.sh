# Prompt con los colores de krarupOS (Fedora arma PS1 con PROMPT_USERHOST en
# bash-color-prompt.sh, que corre antes por orden alfabético). Colores fijos donde el tema
# de Konsole redefine la paleta: su "verde" es celeste y su "cian" es verde.
# Usuario verde, @ naranja, host azul, OS rosado, carpeta amarilla, $ cian.
if [ -n "${BASH_VERSION:-}" ] && [[ $- == *i* ]]; then
    h=${HOSTNAME%%.*}
    if [[ $h == *OS ]]; then
        PROMPT_USERHOST="\[\e[1;38;5;40m\]\u\[\e[38;5;3m\]@\[\e[1;34m\]${h%OS}\[\e[1;35m\]OS\[\e[0m\]"
    else
        PROMPT_USERHOST="\[\e[1;38;5;40m\]\u\[\e[38;5;3m\]@\[\e[1;34m\]\h\[\e[0m\]"
    fi
    PROMPT_END="\[\e[1;38;5;51m\]"
    PROMPT_DIR_COLOR="1;33"
    unset h
fi
