// krarupOS: el panel deja de ser flotante en los escritorios que ya existían (los nuevos lo
// traen así desde panel-layout.js). Plasma corre este archivo una sola vez por usuario.
// Flotante, al pasar a pegado cuando se acerca una ventana, la zona de clics del panel quedaba
// desactualizada y el triángulo de la bandeja no abría. Solo toca el panel de krarupOS
// (a la derecha, ajustado al contenido, esquiva ventanas).
panels().forEach(function (p) {
    if (p.location == "right" && p.lengthMode == "fit" && p.hiding == "dodgewindows") {
        p.floating = false
    }
})
