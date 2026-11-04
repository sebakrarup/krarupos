# La perilla de volumen la maneja krarupos-tty-volumen, pero en la consola también
# llega a la terminal como F13/F14/F15 y bash dejaría un "~" por cada paso.
if [ -n "$BASH_VERSION" ] && [[ $- == *i* && $(tty 2>/dev/null) == /dev/tty[0-9]* ]]; then
    bind '"\e[25~": ""'
    bind '"\e[26~": ""'
    bind '"\e[28~": ""'
fi
