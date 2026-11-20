// krarupOS: quita Panel Colorizer de los paneles que ya existían (Plasma corre este
// archivo una sola vez por usuario). Con él partes del panel dejaban de recibir clics
// (el triángulo de la bandeja no abría); ahora la transparencia viene del tema
// (panel-background.svgz de Breeze con el fondo invisible, en build.sh).
panels().forEach(function (p) {
    p.widgets("luisbocanegra.panel.colorizer").forEach(function (w) {
        w.remove()
    })
})
