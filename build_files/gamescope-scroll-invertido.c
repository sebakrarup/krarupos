// Scroll natural (invertido) en el modo juego: gamescope lee el mouse con libinput y no
// aplica la opción NaturalScroll de KDE. build.sh la agrega como dependencia de
// /usr/bin/gamescope (patchelf), así que solo la carga gamescope.
#define _GNU_SOURCE
#include <dlfcn.h>

struct libinput_event_pointer;
enum libinput_pointer_axis { LIBINPUT_POINTER_AXIS_SCROLL_VERTICAL = 0 };

typedef double (*scroll_fn)(struct libinput_event_pointer *, enum libinput_pointer_axis);

// Las de libinput tienen versión: sin la misma versión (gamescope-scroll-invertido.map)
// gamescope no las toma de aquí.
#define INVERTIR(nombre, version)                                                        \
    double nombre(struct libinput_event_pointer *event, enum libinput_pointer_axis axis) \
    {                                                                                    \
        static scroll_fn original;                                                       \
        if (!original)                                                                   \
            original = (scroll_fn)dlvsym(RTLD_NEXT, #nombre, version);                   \
        return -original(event, axis);                                                   \
    }

INVERTIR(libinput_event_pointer_get_scroll_value, "LIBINPUT_1.19")
INVERTIR(libinput_event_pointer_get_scroll_value_v120, "LIBINPUT_1.19")
INVERTIR(libinput_event_pointer_get_axis_value, "LIBINPUT_0.12.0")
INVERTIR(libinput_event_pointer_get_axis_value_discrete, "LIBINPUT_0.12.0")
